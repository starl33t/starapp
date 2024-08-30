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
            Color.starBlack.ignoresSafeArea()
            VStack {
                Divider()
                lactateSummaryView()
                Text("This Week")
                    .foregroundStyle(.whiteOne)
                Spacer()
                // Check if sessions are empty and show mock sessions if needed
                if sessions.isEmpty {
                    Text("No sessions available. Displaying mock data.")
                        .foregroundColor(.gray)
                    sessionChartView(sessions: HomeView.createMockSessions())
                } else {
                    sessionChartView(sessions: sessions)
                }
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
    
    private func calculateAverageValue(for tab: Tab, in sessions: [Session]) -> Double {
        let values = sessions.compactMap { session in
            switch tab {
            case .lactate:
                return session.lactate
            case .duration:
                return session.duration.map { $0 / 60 } // converting to minutes for display
            case .distance:
                return session.distance
            case .heartRate:
                return session.heartRate.map(Double.init)
            case .pace:
                return session.pace
            case .power:
                return session.power.map(Double.init)
            }
        }
        return values.reduce(0, +) / Double(values.count)
    }

    
    
    @ViewBuilder
    private func lactateSummaryView() -> some View {
        let sessionsToUse = sessions.isEmpty ? HomeView.createMockSessions() : sessions
        let averageValue = calculateAverageValue(for: activeTab, in: sessionsToUse)

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
                                .fill(Color.starMain)
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
              let average = values.reduce(0, +) / Double(values.count)
              return (date, average)
          }.sorted(by: { $0.0 < $1.0 })

          GeometryReader { proxy in
              HStack(alignment: .bottom, spacing: proxy.size.width / 120) {
                  ForEach(dailyAverages, id: \.0) { (date, averageValue) in
                      GraphCapsule(
                          index: 0,
                          color: colorForTab(activeTab),
                          height: proxy.size.height,
                          value: averageValue,
                          overallMax: dailyAverages.map(\.1).max() ?? 1.0
                      )
                      .animation(.default)
                  }
              }
          }
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
            let calendar = Calendar.current
            return [
                Session(distance: 5.2, duration: 3600, pace: 4.5, power: 200, heartRate: 150, lactate: 4.5, date: calendar.date(byAdding: .day, value: -6, to: Date()), title: "Morning Run"),
                Session(distance: 10.0, duration: 5400, pace: 5.0, power: 220, heartRate: 160, lactate: 3.8, date: calendar.date(byAdding: .day, value: -5, to: Date()), title: "Evening Jog"),
                Session(distance: 7.0, duration: 4200, pace: 6.0, power: 210, heartRate: 155, lactate: 5.0, date: calendar.date(byAdding: .day, value: -4, to: Date()), title: "Afternoon Training"),
                Session(distance: 8.0, duration: 4800, pace: 4.8, power: 230, heartRate: 162, lactate: 4.2, date: calendar.date(byAdding: .day, value: -3, to: Date()), title: "Morning Run"),
                Session(distance: 12.0, duration: 7200, pace: 5.2, power: 240, heartRate: 165, lactate: 6.1, date: calendar.date(byAdding: .day, value: -2, to: Date()), title: "Long Run"),
                Session(distance: 4.5, duration: 3000, pace: 4.2, power: 190, heartRate: 145, lactate: 3.9, date: calendar.date(byAdding: .day, value: -1, to: Date()), title: "Speed Workout"),
                Session(distance: 6.0, duration: 3600, pace: 4.0, power: 195, heartRate: 148, lactate: 4.7, date: calendar.date(byAdding: .day, value: 0, to: Date()), title: "Recovery Run"),
                Session(distance: 9.0, duration: 5400, pace: 4.9, power: 215, heartRate: 158, lactate: 5.2, date: calendar.date(byAdding: .day, value: 1, to: Date()), title: "Tempo Run"),
                Session(distance: 11.0, duration: 6000, pace: 5.4, power: 225, heartRate: 160, lactate: 4.1, date: calendar.date(byAdding: .day, value: 2, to: Date()), title: "Steady Run"),
                Session(distance: 13.0, duration: 7800, pace: 5.5, power: 235, heartRate: 163, lactate: 3.7, date: calendar.date(byAdding: .day, value: 3, to: Date()), title: "Long Run")
            ]
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


struct GraphCapsule: View, Equatable {
    var index: Int
    var color: Color
    var height: CGFloat
    var value: Double
    var overallMax: Double

    var heightRatio: CGFloat {
        guard overallMax > 0 else { return 0 }  // No height if overallMax is 0
        let ratio = CGFloat(value / overallMax)
        return ratio.isFinite && ratio > 0 ? ratio : 0
    }

    @ViewBuilder
    var body: some View {
        if heightRatio > 0 {
            Capsule()
                .fill(color)
                .frame(height: height * heightRatio)
                .offset(x: 0, y: height * (1 - heightRatio))
        }
    }
}
