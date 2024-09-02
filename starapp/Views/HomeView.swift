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
        }, sort: \Session.date, order: .reverse)
    }
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea() // Background color
            VStack {
                Divider()
                summaryView()
                Group{
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
                            Text("Total: \(totalValue(for: activeTab, in: MockSessionGenerator.createMockSessions(), selectedSession: selectedSession))")
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
                        sessionChartView(sessions: sessions)
                            .frame(height: 100)
                        HStack{
                            Spacer()
                            Text("Total: \(totalValue(for: activeTab, in: sessions, selectedSession: selectedSession))")
                        }
                        .foregroundStyle(.whiteOne)
                        .padding()
                    }
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
    
    @ViewBuilder
    private func summaryView() -> some View {
        let sessionsToUse = sessions.isEmpty ? MockSessionGenerator.createMockSessions() : sessions
        let averageValue = NumberHelper.calculateAverageValue(for: activeTab, in: sessionsToUse)
        
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.rawValue) { tab in
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
            }
        }
        .animation(.smooth(duration: 0.3, extraBounce: 0), value: activeTab)
    }
    
    private func totalValue(for tab: Tab, in sessions: [Session], selectedSession: Session? = nil) -> String {
        if let selectedSession = selectedSession {
            return valueForTab(tab, in: selectedSession)
        } else {
            let total: Double
            switch tab {
            case .lactate:
                total = sessions.compactMap { $0.lactate }.reduce(0, +)
                return String(format: "%.0f mM", total)
            case .duration:
                total = sessions.compactMap { $0.duration }.reduce(0, +) // Duration is in minutes
                let roundedHours = Int(round(total / 60)) // Rounding to the nearest hour
                if roundedHours > 0 {
                    return String(format: "%d h", roundedHours)
                } else {
                    return "\(Int(total)) min"
                }
            case .distance:
                total = sessions.compactMap { $0.distance }.reduce(0, +)
                return String(format: "%.0f km", total)
            case .heartRate:
                let average = sessions.compactMap { $0.heartRate }.compactMap(Double.init).reduce(0, +) / Double(sessions.count)
                let betterSessions = sessions.compactMap { $0.heartRate }.filter { Double($0) > average }
                let percentage = (Double(betterSessions.count) / Double(sessions.count)) * 100
                return String(format: "%.0f%% over avg.", percentage)
            case .pace:
                let average = sessions.compactMap { $0.pace }.reduce(0, +) / Double(sessions.count)
                let betterSessions = sessions.compactMap { $0.pace }.filter { $0 < average }
                let percentage = (Double(betterSessions.count) / Double(sessions.count)) * 100
                return String(format: "%.0f%% over avg.", percentage)
            case .power:
                let average = sessions.compactMap { $0.power }.compactMap(Double.init).reduce(0, +) / Double(sessions.count)
                let betterSessions = sessions.compactMap { $0.power }.filter { Double($0) > average }
                let percentage = (Double(betterSessions.count) / Double(sessions.count)) * 100
                return String(format: "%.0f%% over avg.", percentage)
            }
        }
    }
    
    private func valueForTab(_ tab: Tab, in session: Session) -> String {
        switch tab {
        case .lactate:
            return String(format: "%.1f mM", locale: Locale(identifier: "de_DE"), session.lactate ?? 0)
        case .duration:
            let duration = session.duration ?? 0
            if duration >= 60 {
                let hours = Int(duration / 60)
                let minutes = Int(duration) % 60
                return String(format: "%d:%02d h", hours, minutes)
            } else {
                return String(format: "%d min", Int(duration))
            }
        case .distance:
            return String(format: "%.1f km", locale: Locale(identifier: "de_DE"), session.distance ?? 0)
        case .heartRate:
            return String(format: "%d BPM", session.heartRate ?? 0)  // Format as integer
        case .pace:
            let pace = session.pace ?? 0
            let minutes = Int(pace)
            let seconds = Int((pace - Double(minutes)) * 60)
            return String(format: "%d:%02d min/km", minutes, seconds)
        case .power:
            return String(format: "%d W", session.power ?? 0)  // Format as integer
        }
    }
 
    @ViewBuilder
    private func sessionChartView(sessions: [Session]) -> some View {
        let groupedSessions = Dictionary(grouping: sessions) { session in
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
        }.sorted(by: { $0.0 > $1.0 })
        
        let keyPath = \ (Date, Double).1
        
        let ranges = dailyAverages.map { (element: (Date, Double)) -> Range<Double> in
            let averageValue = element[keyPath: keyPath]
            let lowerBound = averageValue - (averageValue * 0.1)
            let upperBound = averageValue + (averageValue * 0.1)
            return lowerBound..<upperBound
        }
        
        let overallRange = rangeOfRanges(ranges)
        let maxMagnitude = ranges.map { magnitude(of: $0) }.max()!
        let heightRatio = 1 - CGFloat(maxMagnitude / magnitude(of: overallRange))
        
        GeometryReader { proxy in
            let maxCapsuleWidth: CGFloat = 10
            HStack(alignment: .bottom, spacing: proxy.size.width / 120) {
                ForEach(0..<dailyAverages.count, id: \.self) { index in
                    let averageValue = dailyAverages[index][keyPath: keyPath]
                    let range = ranges[index]
                    let session = sessions[index]
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
