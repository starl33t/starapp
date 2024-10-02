import SwiftUI
import MapKit
import SwiftData

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var viewModel: MessageHelper
    @EnvironmentObject var starStore: StarStore
    @Namespace private var tabAnimation
    @State private var selectedCapsuleIndex: Int? = nil
    @State private var selectedSession: Session? = nil
    @State private var showDatePicker: Bool = false
    @State private var selectedDateRange: DateRangeOption = .thisWeek
    @AppStorage("isGraphExpanded") private var isGraphExpanded = false
    @AppStorage("isFloatingChatExpanded") private var isFloatingChatExpanded = false
    @AppStorage("isCalendarSelected") private var isCalendarSelected = false
    @AppStorage("isChatSelected") private var isChatSelected = false
    @AppStorage("isprofileSelected") private var isprofileSelected = false
    @Query private var allSessions: [Session]
    @State private var newMessageContent: String = ""
    
    init() {
        let startOfLast7Days = Calendar.current.date(byAdding: .day, value: -365, to: Date())!
        let endOfValidPeriod = Date() // Today
        
        _allSessions = Query(
            filter: #Predicate<Session> { session in
                if let date = session.date {
                    return date >= startOfLast7Days && date <= endOfValidPeriod
                } else {
                    return false
                }
            },
            sort: \Session.date, order: .forward
        )
    }
    
    var sessions: [Session] {
        let startDate = Date().startDate(for: selectedDateRange)
        let endDate = Date().endDate(for: selectedDateRange)
        
        // Filter sessions based on the selected date range
        return allSessions.filter { session in
            if let date = session.date {
                return date >= startDate && date <= endDate
            } else {
                return false
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                ZStack(alignment: .top) {
                    mapView()
                }
                .onTapGesture {
                    isFloatingChatExpanded = false
                }
            }
            .tint(.starMain)
        }
        .onTapGesture {
            selectedSession = nil
            selectedCapsuleIndex = nil
        }
        .onAppear {
            updateActiveTabIfNeeded()
            isCalendarSelected = false
            isChatSelected = false
        }
        .onChange(of: selectedDateRange) {
            updateActiveTabIfNeeded()
        }
        .sheet(isPresented: $showDatePicker) {
            datePicker()
                .modifier(CloseButtonModifier(onClose: {showDatePicker = false}))
                .presentationDetents([.fraction(0.3)])
        }
    }
    
    
    @ViewBuilder
    private func mapView() -> some View {
        LiveView()
            .onTapGesture {
                isGraphExpanded = false
                isFloatingChatExpanded = false
                isprofileSelected = false
            }
        VStack {
            if isGraphExpanded {
                Text(appState.homeTitle)
                    .font(.headline)
                    .foregroundStyle(.whiteOne)
                    .padding()
                summaryView()
                HStack {
                    Button {
                        showDatePicker = true
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.whiteOne, lineWidth: 2)
                                .frame(width: 130, height: 32)
                            Text(selectedDateRange.displayText)
                        }
                    }
                    Spacer()
                    Text(sessionDisplayText)
                }
                .foregroundStyle(.whiteOne)
                .padding()
                sessionChartView(sessions: NumberHelper.filteredSessions(for: appState.homeActiveTab, in: sessions))
                    .frame(height: 100)
                    .padding()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isGraphExpanded)
        .background(Color.starBlack.opacity(0.9))
        .onTapGesture {
            selectedSession = nil
            selectedCapsuleIndex = nil
        }
        
        if isprofileSelected {
            VStack {
                ZStack(alignment: .top) {
                    Color.starBlack.opacity(0.9).ignoresSafeArea()
                        .frame(height: 300)
                }
                Spacer()
            }
            .transition(.move(edge: .top))
            .animation(.easeInOut(duration: 0.3), value: isprofileSelected)
            .onTapGesture {
                isprofileSelected = false
            }
        }
    }
    
    private func datePicker() -> some View {
        return ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                Picker("Date Range", selection: $selectedDateRange) {
                    ForEach(DateRangeOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .labelsHidden()
                .environment(\.colorScheme, .dark)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func updateActiveTabIfNeeded() {
        if NumberHelper.filteredSessions(for: appState.homeActiveTab, in: sessions).isEmpty {
            appState.homeActiveTab = availableTabs.first ?? .lactate
        }
    }
    
    private var availableTabs: [HomeTab] {
        return HomeTab.allCases.filter { tab in
            !NumberHelper.filteredSessions(for: tab, in: sessions).isEmpty
        }
    }
    
    private var sessionDisplayText: String {
        if let selectedSession = selectedSession, let date = selectedSession.date {
            return "\(date.formatAsDayMonthYear()): \(NumberHelper.valueForTab(appState.homeActiveTab, in: selectedSession))"
        } else {
            return "Total: \(NumberHelper.totalValue(for: appState.homeActiveTab, in: sessions))"
        }
    }
    
    @ViewBuilder
    private func summaryView() -> some View {
        let sessionsToUse = NumberHelper.filteredSessions(for: appState.homeActiveTab, in: sessions)
        let averageValue = NumberHelper.calculateAverageValue(for: appState.homeActiveTab, in: sessionsToUse)
        
        HStack(spacing: 0) {
            ForEach(availableTabs, id: \.rawValue) { tab in
                Button {
                    appState.homeActiveTab = tab
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: tab.rawValue)
                            .font(.title3)
                            .foregroundColor(.whiteOne)
                            .frame(height: 30)
                        
                        if appState.homeActiveTab == tab {
                            Text(tab.title(with: averageValue))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                        }
                    }
                    .foregroundColor(appState.homeActiveTab == tab ? .whiteOne : .gray)
                    .padding(.vertical, 2)
                    .padding(.leading, 10)
                    .padding(.trailing, 15)
                    .contentShape(Rectangle())
                    .background {
                        if appState.homeActiveTab == tab {
                            Capsule()
                                .fill(.starMain)
                                .matchedGeometryEffect(id: "ACTIVE_TAB", in: tabAnimation)
                        }
                    }
                }
                .disabled(NumberHelper.filteredSessions(for: tab, in: sessionsToUse).isEmpty)
            }
        }
        .animation(.smooth(duration: 0.3, extraBounce: 0), value: appState.homeActiveTab)
    }
    
    @ViewBuilder
    private func sessionChartView(sessions: [Session]) -> some View {
        let filteredSessions = NumberHelper.filteredSessions(for: appState.homeActiveTab, in: sessions)
        let dailyAverages = NumberHelper.calculateDailyAverages(for: appState.homeActiveTab, in: filteredSessions)
        
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
                        let isPaceTab = appState.homeActiveTab == .pace
                        
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
                                selectedCapsuleIndex = nil
                                selectedSession = nil
                            } else {
                                selectedCapsuleIndex = index
                                selectedSession = session
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .offset(x: 0, y: proxy.size.height * heightRatio)
                }
            }
        } else {
            ContentUnavailableView("No Sessions Found", systemImage: "exclamationmark.triangle")
                .foregroundStyle(.whiteOne)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}


