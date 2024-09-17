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
    
    @Query private var allSessions: [Session]
    
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 360) // Maximum zoom out to show the globe
        )
    )
    @State private var selectedEvent: EventMarker?
    @State private var showEventDetails = false
    
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
            ScrollView {
                VStack {
                    if sessions.isEmpty {
                        emptySessionsView()
                    } else {
                        realSessionsView()
                    }
                }
            }
            .animation(.easeInOut(duration: 1.4), value:  appState.isTextExpanded)
            .padding(.top)
            .overlay(alignment: .bottomTrailing) {
                floatingActionButton() 
            }
        }
        .onTapGesture {
            selectedCapsuleIndex = nil
            selectedSession = nil
            appState.isTextExpanded = false
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
    private func realSessionsView() -> some View {
        if appState.isTextExpanded {
            VStack(alignment: .leading) {
                Text("Great! Let's go on with the next steps. We can talk over chat or you can use one of the ready-made prompts below.")
                    .foregroundStyle(.whiteOne)
            }
            .padding()
        } else {
            summaryView()
            HStack {
                Button {
                    showDatePicker = true
                } label: {
                    Text(selectedDateRange.displayText)
                }
                Spacer()
                Text(sessionDisplayText)
            }
            .foregroundStyle(.whiteOne)
            .padding()
            sessionChartView(sessions: NumberHelper.filteredSessions(for: appState.homeActiveTab, in: sessions))
                .frame(height: 100)
            mapView()
        }
        
    }
    
    @ViewBuilder
    private func emptySessionsView() -> some View {
        if appState.isTextExpanded {
            VStack(alignment: .leading) {
                Text("Hello, I'm Renato CanovAI. Your AI-Coach. You didn't have any sessions so I gave you some examples to play around with. We can talk over chat or you can use one of the ready-made prompts below. Also, you can play around with the globe to see the latest races and active athletes. If you want to join them then head over to Live.")
                    .foregroundStyle(.whiteOne)
            }
            .padding()
        } else {
            summaryView()
            HStack {
                Text("Example by AI")
                Spacer()
                Text(sessionDisplayText)
            }
            .foregroundStyle(.whiteOne)
            .padding()
            
            sessionChartView(sessions: MockSessionGenerator.createMockSessions())
                .frame(height: 100)
            ContentUnavailableView {
                Label("Get started", systemImage: "brain.head.profile")
            } description: {
                Text("Chat with our AI-Coach by tapping the bubble icon on the bottom right corner or locate your favorite events on the globe below.")
            }
            .foregroundStyle(.whiteOne)
            .padding()
            mapView()
        }
    }
    
    @ViewBuilder
    private func mapView() -> some View {
        Map(position: $position, selection: $selectedEvent) {
            // Display event markers
            ForEach(LocationEvents.allEventMarkers(), id: \.self) { event in
                Group {
                    if event.systemImage != "" {
                        Marker(coordinate: event.coordinate) {
                            Label(event.label, systemImage: event.systemImage)
                        }
                        .tint(.starMain)
                    }
                }
                .tag(event)
            }
        }
        .mapStyle(.imagery(elevation: .realistic))
        .frame(height: 400)  // Set height of the map
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
        } label: { isExpanded in
            Image(systemName: isExpanded ? "text.bubble" : "bubble.left")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.whiteOne)
                .scaleEffect(isExpanded ? 1 : 0.9)
        }
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


