import SwiftUI
import MapKit
import SwiftData

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var viewModel: MessageHelper
    @Namespace private var tabAnimation
    @State private var selectedCapsuleIndex: Int? = nil
    @State private var selectedSession: Session? = nil
    @State private var showDatePicker: Bool = false
    @State private var selectedDateRange: DateRangeOption = .thisWeek
    @AppStorage("isGraphExpanded") private var isGraphExpanded = false
    @AppStorage("isFloatingChatExpanded") private var isFloatingChatExpanded = false
    @AppStorage("chatWithSapiens") private var chatWithSapiens: Bool = false
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
                mapView()
            }
            .tint(.starMain)
            .animation(.easeInOut(duration: 0.3), value:  isFloatingChatExpanded)
            .overlay(alignment: .bottomTrailing) {
                floatingActionButton()
            }
            .overlay(alignment: .bottom){
                if isFloatingChatExpanded {
                    chatViewBar()
                }
            }
        }
        .onTapGesture {
            selectedSession = nil
            selectedCapsuleIndex = nil
        }
        .onAppear {
            updateActiveTabIfNeeded()
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
    private func chatViewBar() -> some View {
        HStack {
            Button(action: {
                newMessageContent = "" // Clear the message input
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(newMessageContent.isEmpty ? .gray : .whiteOne)
                    .padding(.trailing, 5)
            }
            ZStack(alignment: .leading) {
                TextField("", text: $newMessageContent, axis: .vertical)
                    .foregroundStyle(.whiteOne)
                    .padding(.horizontal)
            }
            .padding(.vertical, 4)
            .background(.darkOne)
            .cornerRadius(24)
            Button(action: {
                Task {
                    await navigateToChatWithPrompt(newMessageContent)
                    newMessageContent = ""
                }
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .foregroundColor(newMessageContent.isEmpty ? .gray : .starMain)
                    .font(.system(size: 30))
                
            }
        }
    }
    
    @ViewBuilder
    private func mapView() -> some View {
        ZStack(alignment: .top) {
            LiveView()
                .onTapGesture {
                    isGraphExpanded = false
                }
                .overlay{
                    if isFloatingChatExpanded {
                        Color.starBlack.opacity(0.9).edgesIgnoringSafeArea(.all)
                    }
                }
            VStack {
                if isGraphExpanded {
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
            .animation(.easeInOut(duration: 0.3), value:  isGraphExpanded)
            .background(Color.starBlack.opacity(0.9))
            .onTapGesture {
                selectedSession = nil
                selectedCapsuleIndex = nil
            }
            
        }
        .onTapGesture {
            isFloatingChatExpanded = false
        }
    }
    
    @ViewBuilder
    private func floatingActionButton() -> some View {
        FloatingButtonText {
            FloatingActionText(text: " What is lactate threshold") {
                Task {
                    await navigateToChatWithPrompt("Explain what lactate threshold is")
                }
            }
            FloatingActionText(text: "          Help me get started") {
                Task {
                    await navigateToChatWithPrompt("How can I get started?")
                }
            }
            FloatingActionText(text: "     Make me a training plan") {
                Task {
                    await navigateToChatWithPrompt("Make me a training plan")
                }
            }
            FloatingActionText(text:"Estimate lactate threshold") {
                Task {
                    await navigateToChatWithPrompt("Estimate my lactate threshold")
                }
            }
            FloatingActionText(text: "    I need to taper for a race") {
                Task {
                    await navigateToChatWithPrompt("I need to taper for a race")
                }
            }
            FloatingActionText(text: "        I need help to recover") {
                Task {
                    await navigateToChatWithPrompt("I need help to recover")
                }
            }
            FloatingActionText(text: "Help me get over my injury") {
                Task {
                    await navigateToChatWithPrompt("Help me get over my injury")
                }
            }
        } label: { isFloatingChatExpanded in
            Image(systemName: isFloatingChatExpanded ? "text.bubble" : "bubble.left")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.whiteOne)
                .scaleEffect(isFloatingChatExpanded ? 1 : 0.9)
        }
        .padding(.bottom, 50)
        .padding()
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
    
    private func navigateToChatWithPrompt(_ prompt: String) async {
        if let threadId = viewModel.threadId {
            await viewModel.createMessage(threadId: threadId, content: prompt)
        } else {
            await viewModel.createThread()
            if let threadId = viewModel.threadId {
                await viewModel.createMessage(threadId: threadId, content: prompt)
            }
        }
        withAnimation(.easeInOut(duration: 0.3)) {
            appState.selectedTab = 3
        }
        isFloatingChatExpanded = false
        chatWithSapiens = false
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}


