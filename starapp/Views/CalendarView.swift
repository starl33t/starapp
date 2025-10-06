import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.calendar) private var calendar
    @Environment(\.modelContext) private var context
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    @EnvironmentObject var appState: AppState
    @State private var sessionCache: [Date: [Session]] = [:]
    @State private var currentDate = Date()
    @State private var headerOffset: CGFloat = 0
    @AppStorage("isFloatingTrainingExpanded") private var isFloatingTrainingExpanded = false
    @AppStorage("showTrainingList") var showTrainingList = false
    @AppStorage("showSpecificTrainingView") var showSpecificTrainingView = false
    @AppStorage("isprofileSelected") private var isprofileSelected = false
    @AppStorage("isGraphExpanded") private var isGraphExpanded = false
    @Namespace private var tabAnimation
    @State private var selectedCapsuleIndex: Int? = nil
    @State private var selectedSession: Session? = nil
    @State private var showDatePicker: Bool = false
    @State private var selectedDateRange: DateRangeOption = .thisWeek
    @Query private var allSessions: [Session]
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    init() {
        let start = Calendar.iso8601UTC.date(byAdding: .day, value: -365, to: Date())!
        let end = Date()

        _allSessions = Query(
            filter: #Predicate<Session> { session in
                if let d = session.date {
                    return d >= start && d <= end
                } else { return false }
            },
            sort: \Session.date, order: .forward
        )
    }
    
    var sessions2: [Session] {
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
                HStack {
                    Button(action: {
                        let today = Date()
                        appState.selectedDate = today
                        appState.days = today.daysInYear
                    }) {
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.whiteOne, lineWidth: 2)
                                .frame(width: 138, height: 34)
                            Text(appState.todayTitle)
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.whiteOne)
                        }
                    }
                }
                .font(.headline)
                .padding(.vertical, 6)
                if showTrainingList {
                    listTrainingView()
                } else {
                    daysOfWeekHeader()
                    dateScrollView
                        .onChange(of: sessions) {
                            sessionCache = CalendarHelper.buildSessionCache(for: appState.days, with: sessions)
                        }
                }
                
            }
            .animation(.easeInOut(duration: 0.3), value:  showTrainingList)
            .foregroundStyle(.whiteTwo)
            .overlay(alignment: .bottomTrailing) {
                FloatingButton {
                    FloatingAction(text: "4x6'") {
                        createNewSession(title: "4x6 min")
                    }
                    FloatingAction(text: "7x4'") {
                        createNewSession(title: "7x4 min")
                    }
                    FloatingAction(symbols: ["plus.square.dashed"]) {
                        createNewSession(title: "Title")
                    }
                } label: { isExpanded in
                    Image(systemName: "plus")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.whiteOne)
                        .rotationEffect(.init(degrees: isExpanded ? 135 : 0))
                        .scaleEffect(isExpanded ? 0.9 : 1)
                }
                .padding(.bottom, 50)
                .padding()
                
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
                    sessionChartView(sessions: NumberHelper.filteredSessions(for: appState.homeActiveTab, in: sessions2))
                        .frame(height: 100)
                        .padding()
                    Spacer()
                }
                
            }
            .animation(.easeInOut(duration: 0.3), value: isGraphExpanded)
            .background(Color.starBlack.opacity(0.98))
            .onTapGesture {
                selectedSession = nil
                selectedCapsuleIndex = nil
            }
            .tint(.starMain)
            .onChange(of: appState.homeActiveTab) { _,newValue in
                appState.updateHomeNavigationTitle()
            }
            .sheet(isPresented: $showDatePicker) {
                datePicker()
                    .modifier(CloseButtonModifier(onClose: {showDatePicker = false}))
                    .presentationDetents([.fraction(0.3)])
            }
            
        }
        .onAppear {
            isprofileSelected = false
            showSpecificTrainingView = false
            appState.updateTodayTitle()
            currentDate = Date()
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
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func updateActiveTabIfNeeded() {
        if NumberHelper.filteredSessions(for: appState.homeActiveTab, in: sessions2).isEmpty {
            appState.homeActiveTab = availableTabs.first ?? .lactate
        }
    }
    
    private var availableTabs: [HomeTab] {
        return HomeTab.allCases.filter { tab in
            !NumberHelper.filteredSessions(for: tab, in: sessions2).isEmpty
        }
    }
    
    private var sessionDisplayText: String {
        if let selectedSession = selectedSession, let date = selectedSession.date {
            return "\(date.formatAsDayMonthYear()): \(NumberHelper.valueForTab(appState.homeActiveTab, in: selectedSession))"
        } else {
            return "Total: \(NumberHelper.totalValue(for: appState.homeActiveTab, in: sessions2))"
        }
    }
    
    @ViewBuilder
    private func summaryView() -> some View {
        let sessionsToUse = NumberHelper.filteredSessions(for: appState.homeActiveTab, in: sessions2)
        let averageValue = NumberHelper.calculateAverageValue(for: appState.homeActiveTab, in: sessionsToUse)
        
        HStack(spacing: 0) {
            ForEach(availableTabs, id: \.rawValue) { tab in
                Button {
                    appState.homeActiveTab = tab
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: tab.rawValue)
                            .font(.title3)
                            .foregroundStyle(.whiteOne)
                            .frame(height: 30)
                        
                        if appState.homeActiveTab == tab {
                            Text(tab.title(with: averageValue))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                        }
                    }
                    .foregroundStyle(appState.homeActiveTab == tab ? .whiteOne : .whiteTwo.opacity(0.6))
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
                .disabled(NumberHelper.filteredSessions(for: tab, in: sessions2).isEmpty)
            }
        }
        .animation(.smooth(duration: 0.3, extraBounce: 0), value: appState.homeActiveTab)
    }
    
    @ViewBuilder
    private func sessionChartView(sessions: [Session]) -> some View {
        let filteredSessions = NumberHelper.filteredSessions(for: appState.homeActiveTab, in: sessions)

        // 1) Bucket sessions by UTC day
        let cal = Calendar.iso8601UTC
        let bucketsMap: [Date: [Session]] = Dictionary(grouping: filteredSessions) { s in
            cal.startOfDay(for: s.date ?? Date.distantPast)
        }

        // 2) Compute daily averages using your helper and align them with buckets
        //    Assumes calculateDailyAverages returns [(day: Date, avg: Double)]
        let dailyAverages: [(day: Date, avg: Double)] =
            NumberHelper.calculateDailyAverages(for: appState.homeActiveTab, in: filteredSessions)
                .map { ($0.0, $0.1) }

        // 3) Build a render-ready array that includes the sessions for each day
        let buckets: [(day: Date, avg: Double, sessions: [Session])] =
            dailyAverages.map { day, avg in
                let key = cal.startOfDay(for: day)
                return (day: key, avg: avg, sessions: bucketsMap[key] ?? [])
            }

        // 4) Prepare ranges for your HomeCapsuleGraph
        let ranges: [Range<Double>] = buckets.map { b in
            let lower = b.avg - (b.avg * 0.1)
            let upper = b.avg + (b.avg * 0.1)
            return lower..<upper
        }

        if
            let maxMagnitude = ranges.map({ magnitude(of: $0) }).max(),
            maxMagnitude > 0,
            let overallRange = Optional(rangeOfRanges(ranges))  // uses your existing helpers
        {
            let heightRatio = 1 - CGFloat(maxMagnitude / magnitude(of: overallRange))

            GeometryReader { proxy in
                let maxCapsuleWidth: CGFloat = 10
                HStack(alignment: .bottom, spacing: proxy.size.width / 120) {
                    ForEach(buckets.indices, id: \.self) { index in
                        let bucket = buckets[index]
                        let range  = ranges[index]
                        let avg    = bucket.avg
                        let isPaceTab = appState.homeActiveTab == .pace

                        HomeCapsuleGraph(
                            index: index,
                            color: selectedCapsuleIndex == index ? .starMain : .whiteTwo.opacity(0.6),
                            height: proxy.size.height,
                            range: range,
                            overallRange: overallRange,
                            isPace: isPaceTab
                        )
                        .frame(maxWidth: maxCapsuleWidth)
                        .animation(.ripple(index: index), value: avg)
                        .onTapGesture {
                            if selectedCapsuleIndex == index {
                                selectedCapsuleIndex = nil
                                selectedSession = nil
                            } else {
                                selectedCapsuleIndex = index
                                // pick a representative session for this day (e.g., latest in that day)
                                let rep = bucket.sessions.max { ($0.date ?? .distantPast) < ($1.date ?? .distantPast) }
                                selectedSession = rep ?? bucket.sessions.first
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
    
    private func listTrainingView() -> some View {
           List {
               ForEach(sessions.reversed()) { session in
                   NavigationLink(destination: TrainingView(session: session)) {
                       HStack {
                           ZStack {
                               RoundedRectangle(cornerRadius: 8)
                                   .stroke(Color.whiteOne, lineWidth: 2)
                                   .frame(width: 100, height: 48)
                               Text("\(session.duration ?? 0.0, specifier: "%.0f") min")
                                   .font(.system(size: 22, weight: .bold))
                                   .foregroundStyle(.whiteOne)
                                   .multilineTextAlignment(.center)
                           }
                           VStack(alignment: .leading, spacing: 4) {
                               Text("\(session.lactate ?? 0.0, specifier: "%.1f") mM")
                                   .font(.system(size: 22, weight: .bold))
                                   .foregroundStyle(.whiteOne)
                               Text("\(session.date?.formattedAsLocalTime() ?? "N/A")")
                                   .font(.system(size: 14))
                                   .foregroundStyle(.whiteTwo.opacity(0.6))
                           }
                           .foregroundStyle(.whiteOne)
                           .padding(.leading, 20)
                           .frame(minWidth: 110)
                           HStack {
                               let intensity = LactateHelper.intensity(for: session.lactate)
                               VStack {
                                   Image(systemName: intensity.icon)
                                       .font(.system(size: 24, weight: .bold))
                                       .foregroundStyle(intensity.color)
                                   Text(intensity.rawValue)
                                       .foregroundStyle(intensity.color)
                                       .font(.system(size: 14))
                               }
                               .padding(.leading, 20)
                               
                           }
                           .frame(maxWidth: .infinity, alignment: .center)
                       }
                   }
                   .padding()
                   .background(Color.starBlack)
                   .listRowInsets(EdgeInsets())
               }
               .onDelete { indexSet in
                   indexSet.forEach { index in
                       let session = sessions[index]
                       context.delete(session)
                   }
               }
           }
           .listStyle(PlainListStyle())
           .scrollIndicators(.hidden)
           .scrollContentBackground(.hidden)
           .padding(.top)
           
       }
    
    private func createNewSession(title: String) {
        let newSession = Session(lactate: 0.0, date: Date(), title: title)
        context.insert(newSession)
        try? context.save()

        let key = Calendar.iso8601UTC.startOfDay(for: Date())
        sessionCache[key, default: []].append(newSession)
    }
    
    private func daysOfWeekHeader() -> some View {
        VStack{
            HStack {
                ForEach(daysOfWeek, id: \.self) { dayOfWeek in
                    Text(dayOfWeek)
                        .frame(maxWidth: .infinity)
                }
            }
            .fontWeight(.black)
            .padding(.bottom, 8)
        }
    }
    
    private var dateScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(appState.days, id: \.self) { day in
                        DayView(day: day, sessions: sessionCache[day, default: []], currentDate: currentDate)
                            .id(day)
                            .frame(height: 70)
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.async {
                    CalendarHelper.scrollToDay(Date(), using: proxy, in: appState.days, calendar: calendar)
                }
                sessionCache = CalendarHelper.buildSessionCache(for: appState.days, with: sessions)
            }
            .onChange(of: appState.selectedDate) { oldDate, newDate in
                appState.days = newDate.daysInYear
                CalendarHelper.scrollToDay(newDate, using: proxy, in: appState.days, calendar: calendar)
                sessionCache = CalendarHelper.buildSessionCache(for: appState.days, with: sessions)
            }
        }
    }
}

struct DayView: View {
    let day: Date
    let sessions: [Session]
    let currentDate: Date
    @Environment(\.modelContext) private var context
    @Environment(\.calendar) private var calendar // stays for bucketing/ids if needed

    var body: some View {
        // Use local calendar for UI markers
        let uiCal = Calendar.current

        ZStack(alignment: .top) {
            if uiCal.component(.day, from: day) == 1 {
                Text(day.formatted(.dateTime.month(.abbreviated))) // already local
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
            }
            VStack {
                ZStack {
                    if uiCal.isDate(day, inSameDayAs: currentDate) {  // local "today"
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.whiteTwo, lineWidth: 2)
                            .frame(width: 26, height: 22)
                    }
                    Text(day.formatted(.dateTime.day())) // already local
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)

                    if !sessions.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(sessions, id: \.self) { session in
                                Circle()
                                    .frame(width: 6, height: 6)
                                    .foregroundStyle(LactateHelper.color(for: session.lactate))
                            }
                        }
                        .padding(.top, 38)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(height: 70)
        }
    }
}

