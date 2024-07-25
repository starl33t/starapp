import SwiftUI
import SwiftData

struct CalendarView: View {
    @State private var showDatePicker = false
    @State private var scrollViewProxy: ScrollViewProxy?
    @State private var visibleDates: Set<Date> = []
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    @Query private var sessions: [Session]
    @State private var selectedDate = Date()
    @State private var date = Date()
    @State private var days: [Date] = []
    @State private var isScrollingToDate = false
    
    init() {
        _date = State(initialValue: Date())
        _days = State(initialValue: Date().daysInYear)
    }
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                HStack {
                    Text("Filter")
                        .padding()
                        .foregroundStyle(.whiteOne)
                        .frame(maxWidth: .infinity)
                    Button(action: {
                        selectedDate = Date.now
                        DispatchQueue.main.async {
                            scrollToDate(Date.now, proxy: scrollViewProxy, anchor: .center)
                        }
                    }) {
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
                                let daySessions = sessions.filter { Calendar.current.isDate($0.date ?? Date(), inSameDayAs: day) }
                                
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
                                                                .foregroundColor(ColorLactate.color(for: session.lactate))
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
                                    updateCurrentMonth(visibleDates.sorted()[visibleDates.count / 2])
                                }
                                .onDisappear {
                                    visibleDates.remove(day)
                                }
                            }
                        }
                    }
                    .onAppear {
                        scrollViewProxy = proxy
                        scrollToDate(Date(), proxy: scrollViewProxy, anchor: .center)
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
        .onChange(of: selectedDate) { oldDate, newDate in
            date = newDate
            days = date.daysInYear
            scrollToDate(newDate, proxy: scrollViewProxy, anchor: .center)
        }
    }
    
    private func scrollToDate(_ date: Date, proxy: ScrollViewProxy?, anchor: UnitPoint = .top) {
        guard let proxy = proxy else { return }
        
        isScrollingToDate = true
        if let selectedIndex = days.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
            let selectedDate = days[selectedIndex]
            proxy.scrollTo(selectedDate, anchor: anchor)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isScrollingToDate = false
        }
    }
    
    private func updateCurrentMonth(_ day: Date) {
        guard !isScrollingToDate && !Calendar.current.isDate(date, equalTo: day, toGranularity: .month) else { return }
        date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: day)) ?? date
    }
}

#Preview {
    CalendarView()
}
