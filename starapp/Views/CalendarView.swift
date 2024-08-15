import SwiftUI
import SwiftData

struct CalendarView: View {
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    @Environment(\.calendar) private var calendar
    @Query private var sessions: [Session]
    @AppStorage("selectedDate") private var selectedDate: Date = Date()
    @Binding var days: [Date]
    @State private var sessionCache: [Date: [Session]] = [:]
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                daysOfWeekHeader()
                dateScrollView
                    .onChange(of: sessions) {
                        updateSessionCache()
                    }
            }
            .foregroundStyle(.whiteTwo)
        }
        .onAppear {
            updateSessionCache()
        }
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
                    ForEach(days, id: \.self) { day in
                        DayView(day: day, sessions: sessionCache[day, default: []])
                            .id(day)
                            .frame(height: 70)
                            .onAppear {
                                if sessionCache[day] == nil {
                                    sessionCache[day] = CalendarHelper.filterSessions(for: day, from: sessions)
                                }
                            }
                    }
                }
            }
            .onAppear {
                CalendarHelper.scrollToDay(Date(), using: proxy, in: days, calendar: calendar)
            }
            .onChange(of: selectedDate) { oldDate, newDate in
                days = newDate.daysInYear
                CalendarHelper.scrollToDay(newDate, using: proxy, in: days, calendar: calendar)
                updateSessionCache()
            }
        }
    }
    private func updateSessionCache() {
        sessionCache = CalendarHelper.buildSessionCache(for: days, with: sessions)
    }
}

struct DayView: View {
    let day: Date
    let sessions: [Session]
    
    var body: some View {
        ZStack(alignment: .top) {
            if Calendar.current.component(.day, from: day) == 1 {
                Text(day.formatted(.dateTime.month(.abbreviated)))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
            }
            VStack {
                ZStack {
                    if Calendar.current.isDateInToday(day) {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.whiteTwo, lineWidth: 1)
                            .frame(width: 20, height: 20)
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
                        .padding(.top, 28)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(height: 70)
        }
    }
}
