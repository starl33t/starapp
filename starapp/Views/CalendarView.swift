import SwiftUI
import SwiftData

struct CalendarView: View {
    @Binding var showDatePicker: Bool
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    @Query private var sessions: [Session]
    @Binding var selectedDate: Date
    @Binding var date: Date
    @Binding var days: [Date]
    @State private var sessionCache: [Date: [Session]] = [:]
    var onTodayButtonTapped: () -> Void
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                HStack {
                    ForEach(daysOfWeek, id: \.self) { dayOfWeek in
                        Text(dayOfWeek)
                            .frame(maxWidth: .infinity)
                    }
                }
                .fontWeight(.black)
                .padding(.bottom, 8)
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVGrid(columns: columns) {
                            ForEach(days, id: \.self) { day in
                                DayView(day: day, sessions: sessionCache[day, default: []])
                                    .id(day)
                                    .frame(height: 70)
                                    .onAppear {
                                        updateSessionCache(for: day)
                                    }
                            }
                        }
                    }
                    .onAppear {
                        proxy.scrollTo(days.first(where: { Calendar.current.isDate($0, inSameDayAs: Date()) }), anchor: .center)
                    }
                    .onChange(of: selectedDate) { oldDate, newDate in
                        date = newDate
                        days = date.daysInYear
                        proxy.scrollTo(days.first(where: { Calendar.current.isDate($0, inSameDayAs: newDate) }), anchor: .center)
                    }
                }
            }
            .padding()
            .foregroundStyle(.whiteTwo)
            if showDatePicker {
                VStack {
                    Spacer()
                    VStack {
                        DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                            .environment(\.colorScheme, .dark)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.starBlack)
                    .cornerRadius(10)
                    .shadow(radius: 20)
                }
                .background(
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showDatePicker = false
                        }
                )
            }
        }
        .onChange(of: sessions) { _, _ in
            updateEntireSessionCache()
        }
    }
    
    private func updateSessionCache(for day: Date) {
        let startOfDay = Calendar.current.startOfDay(for: day)
        sessionCache[startOfDay] = CalendarHelper.updateSessionCache(for: startOfDay, sessions: sessions)
    }
    
    private func updateEntireSessionCache() {
        sessionCache = CalendarHelper.updateEntireSessionCache(days: days, sessions: sessions)
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
                        .foregroundColor(
                            Calendar.current.isDateInToday(day) ? .starMain : .whiteOne
                        )
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
        showDatePicker: .constant(false),
        selectedDate: .constant(Date()),
        date: .constant(Date()),
        days: .constant(Date().daysInYear),
        onTodayButtonTapped: {}
    )
}
