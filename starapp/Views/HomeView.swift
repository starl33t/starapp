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
    @State private var selectedButton: String = "Sweet spot"
    @State private var barSelection: Date?
    @Query private var sessions: [Session]
    @State private var selectedSession: String = "Session"
    @State private var activeTab: Tab = .lactate
    
    init() {
        let startOfLast7Days = Calendar.current.date(byAdding: .day, value: -6, to: Date())!
        let endOfValidPeriod = Calendar.current.date(byAdding: .day, value: 6, to: Date())!
        
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
                Text("This Week")
                    .foregroundStyle(.whiteOne)
                Group{
                    if sessions.isEmpty {
                        sessionChartView(sessions: HomeView.createMockSessions())
                    } else {
                        sessionChartView(sessions: sessions)
                    }
                }
                .frame(height: 200)
                Spacer()
                sessionScrollView()
                    .scrollIndicators(.hidden)
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
        let sessionsToUse = sessions.isEmpty ? HomeView.createMockSessions() : sessions
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
                                .fill(colorForTab(activeTab))
                                .matchedGeometryEffect(id: "ACTIVE_TAB", in: tabAnimation)
                        }
                    }
                }
            }
        }
        .animation(.smooth(duration: 0.3, extraBounce: 0), value: activeTab)
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
                    return $0.duration.map { $0 / 60 } // converting to minutes for display
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
        
        let overallRange = rangeOfRanges(ranges)
        let maxMagnitude = ranges.map { magnitude(of: $0) }.max()!
        let heightRatio = 1 - CGFloat(maxMagnitude / magnitude(of: overallRange))
        
        GeometryReader { proxy in
            let sessionCount = dailyAverages.count
            let additionalCapsules = max(0, 30 - sessionCount)

            HStack(alignment: .bottom, spacing: proxy.size.width / 120) {
                ForEach(0..<(sessionCount + additionalCapsules), id: \.self) { index in
                    if index < sessionCount {
                        let averageValue = dailyAverages[index][keyPath: keyPath]
                        let range = ranges[index]
                        HomeCapsuleGraph(
                            index: index,
                            color: colorForTab(activeTab),
                            height: proxy.size.height,
                            range: range,
                            overallRange: overallRange
                        )
                        .animation(.ripple(index: index), value: averageValue)
                    } else {
                        Capsule()
                            .fill(Color.starBlack)
                    }
                }
                .offset(x: 0, y: proxy.size.height * heightRatio)
            }
        }
    }

    
    func rangeOfRanges<C: Collection>(_ ranges: C) -> Range<Double>
    where C.Element == Range<Double> {
        guard !ranges.isEmpty else { return 0..<1 } // Default to a small range if empty
        let low = ranges.lazy.map { $0.lowerBound }.min()!
        let high = ranges.lazy.map { $0.upperBound }.max()!
        return low..<high
    }
    
    private func colorForTab(_ tab: Tab) -> Color {
        switch tab {
        case .lactate:
            return .yellow
        case .duration:
            return .blue
        case .distance:
            return .green
        case .heartRate:
            return .red
        case .pace:
            return .purple
        case .power:
            return .orange
        }
    }
    
    @ViewBuilder
    private func selectedDateAnnotation(for date: Date) -> some View {
        if let session = sessions.first(where: { Calendar.current.isDate($0.date ?? Date(), inSameDayAs: date) }) {
            VStack {
                Text(Date().formatDayMonth(date: session.date))
            }
            .font(.system(size: 14))
            .foregroundStyle(.gray)
        }
    }
    
    @ViewBuilder
    private func sessionScrollView() -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 35) {
                ForEach(sessions) { session in
                    sessionView(for: session)
                }
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func sessionView(for session: Session) -> some View {
        let intensity = LactateHelper.intensity(for: session.lactate)
        VStack {
            Text("\(session.lactate ?? 0.0, specifier: "%.1f") mM")
                .font(.system(size: 14))
                .foregroundStyle(intensity.color)
            Image(systemName: intensity.icon)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(intensity.color)
                .aspectRatio(contentMode: .fill)
            Text("\(session.date?.formattedAsRelative() ?? "N/A")")
                .font(.system(size: 14))
                .foregroundStyle(.gray)
        }
    }
    
    static func createMockSessions() -> [Session] {
        // Use the new MockSessionGenerator
        return MockSessionGenerator.createMockSessions()
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
        guard averageValue.isFinite else { return "Invalid value" }
        
        switch self {
        case .lactate:
            return String(format: "%.1f mM", locale: Locale(identifier: "de_DE"), averageValue)
        case .duration:
            let totalMinutes = Int(round(averageValue))
            let hours = totalMinutes / 60
            let minutes = totalMinutes % 60
            
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
            return String(format: minutes > 9 ? "%d:%02d min/km" : "%d:%02d min/km", minutes, seconds)
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


extension Animation {
    static func ripple(index: Int) -> Animation {
        Animation.spring(dampingFraction: 0.5)
            .speed(2)
            .delay(0.03 * Double(index))
    }
}
