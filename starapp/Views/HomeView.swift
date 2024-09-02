//
//  HomeView.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI
import Charts
import SwiftData


struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @Namespace private var tabAnimation
    @State private var trigger = false
    @Query private var sessions: [Session]
    @State private var activeTab: Tab = .lactate
    @State private var selectedCapsuleIndex: Int? = nil
    @State private var selectedSession: Session? = nil
    
    init() {
        let startOfLast7Days = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let endOfValidPeriod = Calendar.current.date(byAdding: .day, value: 0, to: Date())!
        
        _sessions = Query(filter: #Predicate<Session> { session in
            if let date = session.date {
                return date >= startOfLast7Days && date <= endOfValidPeriod
            } else {
                return false
            }
        }, sort: \Session.date, order: .forward)
    }
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea() // Background color
            VStack {
                Divider()
                summaryView()
                
                if sessions.isEmpty {
                    HStack{
                        Text("This Week")
                    }
                    .foregroundStyle(.whiteOne)
                    .padding()
                    sessionChartView(sessions: MockSessionGenerator.createMockSessions())
                        .frame(height: 100)
                    HStack{
                        Spacer()
                        Text(sessionDisplayText)
                    }
                    .foregroundStyle(.whiteOne)
                    .padding()
                    VStack(alignment: .leading) {
                        Text("Renato")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Hello, I'm Renato CanovAI. Your AI-Coach. You didn't have any sessions so I gave you some examples to play around with. Whenever you're ready then let's get started! You can add new sessions with lactate and/or talk with me in the chat.")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(.darkTwo)
                            .cornerRadius(10)
                    }
                    .padding()
                } else {
                    HStack{
                        Text("This Week")
                        Spacer()
                    }
                    .foregroundStyle(.whiteOne)
                    .padding()
                    sessionChartView(sessions: filteredSessions(for: activeTab, in: sessions))
                        .frame(height: 100)
                    HStack{
                        Spacer()
                        Text(sessionDisplayText)
                    }
                    .foregroundStyle(.whiteOne)
                    .padding()
                }
                
                Spacer()
                
            }
            .contentShape(Rectangle())
            .onTapGesture {
                selectedCapsuleIndex = nil
                selectedSession = nil
            }
        }
        .onAppear {
            updateNavigationTitle()
            
        }
    }
    
    private func updateNavigationTitle() {
        appState.updateNavigationTitle(with: activeTab.navigationTitle, trigger: trigger)
    }
    
    private var availableTabs: [Tab] {
        return Tab.allCases.filter { tab in
            !filteredSessions(for: tab, in: sessions).isEmpty
        }
    }
    
    private var sessionDisplayText: String {
        let sessionsToUse = sessions.isEmpty ? MockSessionGenerator.createMockSessions() : sessions
        
        if let selectedSession = selectedSession, let date = selectedSession.date {
            // Format the date and display it along with the value for the selected session
            return "\(date.formatAsDayMonthYear()): \(NumberHelper.valueForTab(activeTab, in: selectedSession))"
        } else {
            // Display "Total" and the total value when no capsule is selected
            return "Total: \(NumberHelper.totalValue(for: activeTab, in: sessionsToUse))"
        }
    }
    
    private func filteredSessions(for tab: Tab, in sessions: [Session]) -> [Session] {
        return sessions.filter { session in
            switch tab {
            case .lactate:
                return (session.lactate ?? 0) > 0
            case .duration:
                return (session.duration ?? 0) > 0
            case .distance:
                return (session.distance ?? 0) > 0
            case .heartRate:
                return (session.heartRate ?? 0) > 0
            case .pace:
                return (session.pace ?? 0) > 0
            case .power:
                return (session.power ?? 0) > 0
            }
        }
    }
    
    @ViewBuilder
    private func summaryView() -> some View {
        let sessionsToUse = sessions.isEmpty ? MockSessionGenerator.createMockSessions() : filteredSessions(for: activeTab, in: sessions)
        let averageValue = NumberHelper.calculateAverageValue(for: activeTab, in: sessionsToUse)
        
        
        HStack(spacing: 0) {
            ForEach(availableTabs, id: \.rawValue) { tab in
                Button {
                    activeTab = tab
                    updateNavigationTitle()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: tab.rawValue)
                            .font(.title3)
                            .foregroundColor(.whiteOne)
                            .frame(height: 30)
                        
                        if activeTab == tab {
                            Text(tab.title(with: averageValue))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                        }
                    }
                    .foregroundColor(activeTab == tab ? .whiteOne : .gray)
                    .padding(.vertical, 2)
                    .padding(.leading, 10)
                    .padding(.trailing, 15)
                    .contentShape(Rectangle())
                    .background {
                        if activeTab == tab {
                            Capsule()
                                .fill(.starMain)
                                .matchedGeometryEffect(id: "ACTIVE_TAB", in: tabAnimation)
                        }
                    }
                }
                .disabled(filteredSessions(for: tab, in: sessions).isEmpty)
            }
        }
        .animation(.smooth(duration: 0.3, extraBounce: 0), value: activeTab)
    }
    
    @ViewBuilder
    private func sessionChartView(sessions: [Session]) -> some View {
        let filteredSessions = filteredSessions(for: activeTab, in: sessions)
        
        let groupedSessions = Dictionary(grouping: filteredSessions) { session in
            Calendar.current.startOfDay(for: session.date ?? Date())
        }
        
        let dailyAverages = groupedSessions.map { (date, sessions) -> (Date, Double) in
            let values = sessions.compactMap {
                switch activeTab {
                case .lactate:
                    return $0.lactate
                case .duration:
                    return $0.duration.map { $0 / 60 }
                case .distance:
                    return $0.distance
                case .heartRate:
                    return $0.heartRate.map(Double.init)
                case .pace:
                    return $0.pace
                case .power:
                    return $0.power.map(Double.init)
                }
            }
            let average = values.isEmpty ? 0.0 : values.reduce(0, +) / Double(values.count)
            return (date, average)
        }.sorted(by: { $0.0 < $1.0 })
        
        let keyPath = \ (Date, Double).1
        
        let ranges = dailyAverages.map { (element: (Date, Double)) -> Range<Double> in
            let averageValue = element[keyPath: keyPath]
            let lowerBound = averageValue - (averageValue * 0.1)
            let upperBound = averageValue + (averageValue * 0.1)
            return lowerBound..<upperBound
        }
        
        if let maxMagnitude = ranges.map({ magnitude(of: $0) }).max(), maxMagnitude > 0 {
            let overallRange = rangeOfRanges(ranges)
            let heightRatio = 1 - CGFloat(maxMagnitude / magnitude(of: overallRange))
            
            GeometryReader { proxy in
                let maxCapsuleWidth: CGFloat = 10
                HStack(alignment: .bottom, spacing: proxy.size.width / 120) {
                    ForEach(0..<dailyAverages.count, id: \.self) { index in
                        let averageValue = dailyAverages[index][keyPath: keyPath]
                        let range = ranges[index]
                        let session = filteredSessions[index]
                        let isPaceTab = activeTab == .pace
                        
                        HomeCapsuleGraph(
                            index: index,
                            color: selectedCapsuleIndex == index ? .starMain : .gray,
                            height: proxy.size.height,
                            range: range,
                            overallRange: overallRange,
                            isPace: isPaceTab
                        )
                        .frame(maxWidth: maxCapsuleWidth)
                        .animation(.ripple(index: index), value: averageValue)
                        .onTapGesture {
                            if selectedCapsuleIndex == index {
                                // Deselect if the capsule is already selected
                                selectedCapsuleIndex = nil
                                selectedSession = nil
                            } else {
                                // Select the capsule and update the selected session
                                selectedCapsuleIndex = index
                                selectedSession = session  // Assign the selected session
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .offset(x: 0, y: proxy.size.height * heightRatio)
                }
            }
        } else {
            Text("No valid data available")
                .foregroundColor(.white)
        }
    }
}


#Preview {
    HomeView()
        .environmentObject(AppState())
}

enum Tab: String, CaseIterable {
    case lactate = "gauge.with.dots.needle.67percent"
    case duration = "stopwatch"
    case distance = "road.lanes"
    case heartRate = "heart"
    case pace = "hare"
    case power = "bolt"
    
    func title(with averageValue: Double) -> String {
        guard averageValue.isFinite else { return "N/A" }
        
        switch self {
        case .lactate:
            return String(format: "%.1f mM", locale: Locale(identifier: "de_DE"), averageValue)
        case .duration:
            let roundedMinutes = Int(round(averageValue))
            let hours = roundedMinutes / 60
            let minutes = roundedMinutes % 60
            
            if hours > 0 {
                return String(format: "%d:%02d h:min", hours, minutes)
            } else {
                return "\(minutes) min"
            }
        case .distance:
            let roundedDistance = Int(ceil(averageValue))
            return "\(roundedDistance) km"
        case .heartRate:
            return String(format: "%.0f BPM", averageValue)
        case .pace:
            let minutes = Int(averageValue)
            let seconds = Int((averageValue - Double(minutes)) * 60)
            return String(format: "%d:%02d min/km", minutes, seconds)
        case .power:
            return String(format: "%.0f W", averageValue)
        }
    }
    
    var navigationTitle: String {
        switch self {
        case .lactate: return "Lactate"
        case .duration: return "Duration"
        case .distance: return "Distance"
        case .heartRate: return "Heart Rate"
        case .pace: return "Pace"
        case .power: return "Power"
        }
    }
}
