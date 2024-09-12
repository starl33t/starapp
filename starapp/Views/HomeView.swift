import SwiftUI
import Charts
import SwiftData

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var viewModel: MessageHelper
    @Namespace private var tabAnimation
    @State private var selectedCapsuleIndex: Int? = nil
    @State private var selectedSession: Session? = nil
    @State private var showDatePicker: Bool = false
    @State private var selectedDateRange: DateRangeOption = .thisWeek
    
    @Query private var allSessions: [Session]
    
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
        let startDate = startDate(for: selectedDateRange)
        let endDate = endDate(for: selectedDateRange)
        
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
            ScrollView {
                LazyVStack {
                    summaryView()
                    if sessions.isEmpty {
                        HStack {
                            Text("This week")
                        }
                        .foregroundStyle(.whiteOne)
                        .padding()
                        sessionChartView(sessions: MockSessionGenerator.createMockSessions())
                            .frame(height: 100)
                        HStack {
                            Spacer()
                            Text(sessionDisplayText)
                        }
                        .padding()
                        .foregroundStyle(.whiteOne)
                        
                        VStack(alignment: .leading) {
                            Text("Renato")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Hello, I'm Renato CanovAI. Your AI-Coach. You didn't have any sessions so I gave you some examples to play around with. We can talk over chat or you can use one of the ready-made prompts below.")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(.darkTwo)
                                .cornerRadius(10)
                        }
                        .padding()
                        promptButtons1
                    } else {
                        HStack {
                            Button {
                                showDatePicker = true
                            } label: {
                                Text(selectedDateRange.displayText)
                            }
                        }
                        .foregroundStyle(.whiteOne)
                        .padding()
                        sessionChartView(sessions: NumberHelper.filteredSessions(for: appState.homeActiveTab, in: sessions))
                            .frame(height: 100)
                        HStack {
                            Spacer()
                            Text(sessionDisplayText)
                        }
                        .padding()
                        .foregroundStyle(.whiteOne)
                        VStack(alignment: .leading) {
                            Text("Renato")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Great! Let's go on with the next steps. We can talk over chat or you can use one of the ready-made prompts below.")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(.darkTwo)
                                .cornerRadius(10)
                        }
                        .padding()
                        promptButtons2
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedCapsuleIndex = nil
                    selectedSession = nil
                }
            }
            .padding(.top)
        }
        .onAppear {
            updateActiveTabIfNeeded()
        }
        .onChange(of: selectedDateRange) {
            updateActiveTabIfNeeded()
        }
        .sheet(isPresented: $showDatePicker) {
            datePicker()
                .modifier(CloseButtonModifier(isPresented: $showDatePicker))
                .presentationDetents([.fraction(0.3)])
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
    
    private func startDate(for dateRange: DateRangeOption) -> Date {
        switch dateRange {
        case .thisWeek:
            return Date().startOfWeek
        case .thisMonth:
            return Date().startOfMonth
        case .thisYear:
            return Date().startOfYear
        case .last7Days:
            return Date().addingTimeInterval(-7 * 24 * 60 * 60) // 7 days ago2
        case .last30Days:
            return Date().addingTimeInterval(-30 * 24 * 60 * 60) // 30 days ago
        case .last365Days:
            return Date().addingTimeInterval(-365 * 24 * 60 * 60) // 365 days ago
        }
    }
    
    private func endDate(for dateRange: DateRangeOption) -> Date {
        switch dateRange {
        case .thisWeek:
            return Date().endOfWeek
        case .thisMonth:
            return Date().endOfMonth
        case .thisYear:
            return Date().endOfYear
        case .last7Days:
            return Date()
        case .last30Days:
            return Date()
        case .last365Days:
            return Date()
        }
    }
    
    private func updateActiveTabIfNeeded() {
        let sessionsToCheck = sessions.isEmpty ? MockSessionGenerator.createMockSessions() : sessions
        if NumberHelper.filteredSessions(for: appState.homeActiveTab, in: sessionsToCheck).isEmpty {
            appState.homeActiveTab = availableTabs.first ?? .lactate
        }
    }
    
    private var availableTabs: [HomeTab] {
        let sessionsToCheck = sessions.isEmpty ? MockSessionGenerator.createMockSessions() : sessions
        return HomeTab.allCases.filter { tab in
            !NumberHelper.filteredSessions(for: tab, in: sessionsToCheck).isEmpty
        }
    }
    
    private var sessionDisplayText: String {
        let sessionsToUse = sessions.isEmpty ? MockSessionGenerator.createMockSessions() : sessions
        
        if let selectedSession = selectedSession, let date = selectedSession.date {
            return "\(date.formatAsDayMonthYear()): \(NumberHelper.valueForTab(appState.homeActiveTab, in: selectedSession))"
        } else {
            return "Total: \(NumberHelper.totalValue(for: appState.homeActiveTab, in: sessionsToUse))"
        }
    }
    
    @ViewBuilder
    private func summaryView() -> some View {
        let sessionsToUse = sessions.isEmpty ? MockSessionGenerator.createMockSessions() : NumberHelper.filteredSessions(for: appState.homeActiveTab, in: sessions)
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
    
    private var promptButtons1: some View {
        VStack{
            HStack {
                Button(action: {
                    Task {
                        await navigateToChatWithPrompt("Explain what lactate threshold is")
                    }
                }) {
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.whiteOne, lineWidth: 2)
                            .frame(width: 170, height: 24)
                        Text("What's lactate threshold?")
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.whiteOne)
                    }
                }
                
                Button(action: {
                    Task {
                        await navigateToChatWithPrompt("How can I get started?")
                    }
                }) {
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.whiteOne, lineWidth: 2)
                            .frame(width: 150, height: 24)
                        Text("How can I get started?")
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.whiteOne)
                    }
                    
                }
            }
            Button(action: {
                Task {
                    await navigateToChatWithPrompt("Make me a training plan")
                }
            }) {
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.whiteOne, lineWidth: 2)
                        .frame(width: 150, height: 24)
                    Text("Make a training plan")
                        .font(.system(size: 14))
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.whiteOne)
                }
                
            }
        }
    }
    
    private var promptButtons2: some View {
        VStack{
            HStack {
                Button(action: {
                    Task {
                        await navigateToChatWithPrompt("Make me a training plan")
                    }
                }) {
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.whiteOne, lineWidth: 2)
                            .frame(width: 150, height: 24)
                        Text("Make a training plan")
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.whiteOne)
                    }
                }
                
                Button(action: {
                    Task {
                        await navigateToChatWithPrompt("What's my lactate threshold?")
                    }
                }) {
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.whiteOne, lineWidth: 2)
                            .frame(width: 150, height: 24)
                        Text("What's my threshold?")
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.whiteOne)
                    }
                    
                }
            }
            Button(action: {
                Task {
                    await navigateToChatWithPrompt("I have an upcoming race")
                }
            }) {
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.whiteOne, lineWidth: 2)
                        .frame(width: 150, height: 24)
                    Text("I'm going to race soon")
                        .font(.system(size: 14))
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.whiteOne)
                }
                
            }
        }
    }
    
    private func navigateToChatWithPrompt(_ prompt: String) async {
        if let threadId = viewModel.threadId {
            await viewModel.createMessage(threadId: threadId, content: prompt)
        } else {
            await viewModel.createThread()
            if let threadId = viewModel.threadId {
                await viewModel.createMessage(threadId: threadId, content: prompt)
            }
        }
        appState.selectedTab = 3
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}

enum DateRangeOption: String, CaseIterable {
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    case thisYear = "This Year"
    case last7Days = "Last 7 Days"
    case last30Days = "Last 30 Days"
    case last365Days = "Last 365 Days"
    
    var displayText: String {
        switch self {
        case .thisWeek:
            return "This Week"
        case .thisMonth:
            return "This Month"
        case .thisYear:
            return "This Year"
        case .last7Days:
            return "Last 7 Days"
        case .last30Days:
            return "Last 30 Days"
        case .last365Days:
            return "Last 365 Days"
        }
    }
}
