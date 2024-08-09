import SwiftUI
import SwiftData

struct CalendarView: View {
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    @Query private var sessions: [Session]
    @Binding var selectedDate: Date
    @Binding var days: [Date]
    @State private var sessionCache: [Date: [Session]] = [:]
    var onTodayButtonTapped: () -> Void
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                daysOfWeekHeader()
                scrollViewDate
                    .onChange(of: sessions) { 
                        CalendarHelper.updateEntireSessionCache(days: days, sessions: sessions, sessionCache: &sessionCache)
                    }
            }
            .padding()
            .foregroundStyle(.whiteTwo)
        }
        .onAppear {
            CalendarHelper.updateEntireSessionCache(days: days, sessions: sessions, sessionCache: &sessionCache)
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
    
    private var scrollViewDate: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(days, id: \.self) { day in
                        DayView(day: day, sessions: sessionCache[day, default: []])
                            .id(day)
                            .frame(height: 70)
                            .onAppear {
                                CalendarHelper.updateSessionCache(for: day, sessions: sessions, sessionCache: &sessionCache)
                            }
                    }
                }
            }
            .onAppear {
                proxy.scrollTo(days.first(where: { Calendar.current.isDate($0, inSameDayAs: Date()) }), anchor: .center)
            }
            .onChange(of: selectedDate) { oldDate, newDate in
                days = newDate.daysInYear
                proxy.scrollTo(days.first(where: { Calendar.current.isDate($0, inSameDayAs: newDate) }), anchor: .center)
                CalendarHelper.updateEntireSessionCache(days: days, sessions: sessions, sessionCache: &sessionCache)
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
                    Text(day.formatted(.dateTime.day()))
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                    if !sessions.isEmpty {
                        VStack {
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
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(height: 70)
        }
    }
}

#Preview {
    CalendarView(
        selectedDate: .constant(Date()),
        days: .constant(Date().daysInYear),
        onTodayButtonTapped: {}
    )
}
