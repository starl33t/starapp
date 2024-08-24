import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.calendar) private var calendar
    @Query private var sessions: [Session]
    @EnvironmentObject var appState: AppState
    @State private var sessionCache: [Date: [Session]] = [:]
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                daysOfWeekHeader()
                dateScrollView
                    .onChange(of: sessions) {
                        sessionCache = CalendarHelper.buildSessionCache(for: appState.days, with: sessions)
                    }
            }
            .foregroundStyle(.whiteTwo)
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
                    ForEach(appState.days, id: \.self) { day in
                        DayView(day: day, sessions: sessionCache[day, default: []])
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
