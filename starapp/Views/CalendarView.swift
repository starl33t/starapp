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
    @AppStorage("showTrainingList") var showTrainingList = false
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
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
                        .scaleEffect(1.02)
                        .scaleEffect(isExpanded ? 0.9 : 1)
                }
                .padding()
                
            }
            
        }
        .onAppear {
            currentDate = Date()
        }
    }
    
    private func createNewSession(title: String) {
            let newSession = Session(
                lactate: 0.0,  // Set default values or user input
                date: Date(),  // Use today's date
                title: title   // Set the session title from the FloatingAction text
            )
            context.insert(newSession)
            try? context.save()  // Save the new session to the context
            sessionCache[Date(), default: []].append(newSession)  // Optionally update session cache
        }
    
    private func listTrainingView() -> some View {
        List {
            ForEach(sessions) { session in
                NavigationLink(destination: TrainingView(session: session)) {
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.whiteOne, lineWidth: 2)
                                .frame(width: 100, height: 48)
                            Text("\(session.duration ?? 0.0, specifier: "%.0f") min")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.whiteOne)
                                .multilineTextAlignment(.center)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(session.lactate ?? 0.0, specifier: "%.1f") mM")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.whiteOne)
                            Text("\(session.date?.formattedAsRelative() ?? "N/A")")
                                .font(.system(size: 14))
                                .foregroundStyle(.gray)
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
    
    private func daysOfWeekHeader() -> some View {
        HStack {
            ForEach(daysOfWeek, id: \.self) { dayOfWeek in
                Text(dayOfWeek)
                    .frame(maxWidth: .infinity)
            }
        }
        .fontWeight(.black)
        .padding(.bottom, 8)
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
                CalendarHelper.scrollToDay(Date(), using: proxy, in: appState.days, calendar: calendar)
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
    
    var body: some View {
        ZStack(alignment: .top) {
            if Calendar.current.component(.day, from: day) == 1 {
                Text(day.formatted(.dateTime.month(.abbreviated)))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
            }
            VStack {
                ZStack {
                    if Calendar.current.isDate(day, inSameDayAs: currentDate) {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.whiteTwo, lineWidth: 2)
                            .frame(width: 26, height: 22)
                    }
                    Text(day.formatted(.dateTime.day()))
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
