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
                if sessions.isEmpty {
                    ContentUnavailableView("No Sessions Found", systemImage: "figure.run")
                        .foregroundStyle(.whiteOne)
                } else {
                    sessionChartView()
                        .padding(.bottom)
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
    
    
    @ViewBuilder
    private func lactateSummaryView() -> some View {
        HStack (spacing: 0){
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                Button {
                    activeTab = tab
                    updateNavigationTitle()
                } label: {
                    HStack (spacing: 5) {
                        Image(systemName: tab.rawValue)
                            .font(.title3)
                            .foregroundColor(.whiteOne)
                            .frame(height: 30)
                        
                        if activeTab == tab {
                            Text(tab.title)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                        }
                    }
                    .foregroundColor(activeTab == tab ? .whiteOne : .gray)
                    .padding(.vertical, 2)
                    .padding(.leading, 10)
                    .padding(.trailing, 15)
                    .contentShape(.rect)
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
    private func sessionChartView() -> some View {
        Chart(sessions) { session in
            BarMark(
                x: .value("Date", session.date ?? Date(), unit: .day),
                y: .value("Lactate", session.lactate ?? 0),
                stacking: .standard
            )
            .foregroundStyle(LactateHelper.color(for: session.lactate))
            .annotation(position: .overlay, alignment: .center) {
                Text(LactateHelper.formatLactate(session.lactate ?? 0))
                    .multilineTextAlignment(.center)
                    .font(.system(size: 8))
                    .fontWeight(.bold)
            }
            if let barSelection = barSelection {
                RuleMark(x: .value("Date", barSelection, unit: .day))
                    .foregroundStyle(.gray)
                    .zIndex(-10)
                    .annotation(
                        position: .bottom,
                        spacing: 4,
                        overflowResolution: .init(x: .disabled, y: .disabled)
                    ) {
                        selectedDateAnnotation(for: barSelection)
                    }
            }
        }
        .chartXSelection(value: $barSelection)
        .scaledToFit()
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
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
    
    var title: AttributedString {
        switch self {
        case .lactate: return "10,0 mM"
        case .duration: return "200 min"
        case .distance: return "120 km"
        case .heartRate: return "150 BPM"
        case .pace: return "3:45 min/km"
        case .power: return "150 W"
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
