import SwiftUI
import SwiftData

struct CalendarView: View {
    @State private var showDatePicker = false
    @State private var visibleDates: Set<Date> = []
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    @Query private var sessions: [Session]
    @State private var selectedDate = Date()
    @State private var date = Date()
    @State private var days: [Date] = Date().daysInYear
    @State private var sessionCache: [Date: [Session]] = [:]
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                HStack {
                    Button(action: resetToToday) {
                        Text("Today")
                            .foregroundColor(.whiteOne)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    Text(date.formattedMonthYear())
                        .foregroundStyle(.whiteOne)
                        .onTapGesture { showDatePicker.toggle() }
                        .frame(maxWidth: .infinity)
                }
                .padding(.bottom, 16)
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
                                let daySessions = sessionCache[day, default: []]
                                
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
                                            if !daySessions.isEmpty {
                                                VStack {
                                                    HStack(spacing: 4) {
                                                        ForEach(daySessions, id: \.self) { session in
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
                                .id(day)
                                .frame(height: 70)
                                .onAppear {
                                    visibleDates.insert(day)
                                    updateVisibleDate()
                                    if sessionCache[day] == nil {
                                        sessionCache[day] = sessions.filter { Calendar.current.isDate($0.date ?? Date(), inSameDayAs: day) }
                                    }
                                }
                                .onDisappear {
                                    visibleDates.remove(day)
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
        
    }
    
    private func resetToToday() {
        let today = Date()
        selectedDate = today
        date = today
        days = today.daysInYear
    }
    
    private func updateVisibleDate() {
        guard let midDate = visibleDates.sorted().dropLast(visibleDates.count / 2).first else { return }
        date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: midDate)) ?? date
    }
}

#Preview {
    CalendarView()
}
