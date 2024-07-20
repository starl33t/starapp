import SwiftUI
import Combine
import SwiftData

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var showDatePicker = false
    @State private var middleY: CGFloat = UIScreen.main.bounds.height / 2
    @State private var initialScrollDone = false
    @State private var lastUpdate = Date()
    @State private var isDatePickerChanging = false
    @State private var scrollViewProxy: ScrollViewProxy? = nil
    @State private var isScrollingToDate = false

    @Environment(\.modelContext) private var context
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]

    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                headerView
                daysOfWeekHeader
                calendarScrollView
            }
            .padding()
            .foregroundStyle(.whiteTwo)
            .onAppear {
                viewModel.updateDates()
                viewModel.setSessions(sessions)
                viewModel.date = Date() // Set the date to today on appear
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    
                    scrollToToday {
                        viewModel.date = Date()
                        updateVisibleDate(for: Date())
                    }
                }
            }
            
            if showDatePicker {
                datePickerOverlay
            }
        }
        .onPreferenceChange(CalendarViewModel.DateOffsetKey.self) { offsets in
            if !isScrollingToDate {
                handlePreferenceChange(offsets: offsets)
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Filter")
                .padding()
                .foregroundStyle(.whiteOne)
                .frame(maxWidth: .infinity)
            Button(action: {
                showDatePicker = false
                updateToTodayAndScroll()
            }) {
                Text("Today")
                    .foregroundColor(.whiteOne)
            }
            .frame(maxWidth: .infinity)
            .padding()
            Text(viewModel.date.formattedMonthYear())
                .foregroundStyle(.whiteOne)
                .onTapGesture {
                    showDatePicker.toggle()
                }
                .frame(maxWidth: .infinity)
        }
        .padding(.bottom, 16)
    }
    
    private var daysOfWeekHeader: some View {
        HStack {
            ForEach(viewModel.daysOfWeek, id: \.self) { dayOfWeek in
                Text(dayOfWeek)
                    .frame(maxWidth: .infinity)
            }
        }
        .fontWeight(.black)
        .padding(.bottom, 8)
    }
    
    private var calendarScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVGrid(columns: viewModel.columns, spacing: 16) {
                    ForEach(viewModel.days, id: \.self) { day in
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
                                        .frame(maxWidth: .infinity, minHeight: 70)
                                        .foregroundColor(
                                            Calendar.current.isDateInToday(day) ? .starMain : .whiteOne
                                        )
                                    
                                    if !viewModel.sessions(for: day).isEmpty {
                                        VStack(spacing: 2) {
                                            Spacer()
                                            HStack(spacing: 4) {
                                                ForEach(viewModel.sessions(for: day), id: \.self) { session in
                                                    Circle()
                                                        .frame(width: 6, height: 6)
                                                        .foregroundColor(colorForLactate(session.lactate))
                                                }
                                            }
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .background(
                                    GeometryReader { geo in
                                        Color.clear
                                            .preference(key: CalendarViewModel.DateOffsetKey.self, value: [CalendarViewModel.DateOffset(id: day, offset: geo.frame(in: .global).midY)])
                                            .onChange(of: geo.frame(in: .global).midY) { newValue in
                                                if !isScrollingToDate {
                                                    updateVisibleDate(geo: geo, day: day)
                                                }
                                            }
                                    }
                                )
                            }
                            .frame(height: 70)
                        }
                    }
                }
            }
            .onAppear {
                scrollViewProxy = proxy
                if !initialScrollDone {
                    scrollToToday {
                        initialScrollDone = true
                        updateVisibleDate(for: Date())
                    }
                }
            }
        }
    }
    
    private var datePickerOverlay: some View {
        VStack {
            Spacer()
            VStack {
                DatePicker("Select Date", selection: $viewModel.date, displayedComponents: [.date])
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .onChange(of: viewModel.date) { newDate in
                        handleDatePickerChange(newDate)
                    }
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
                    withAnimation {
                        showDatePicker.toggle()
                    }
                }
        )
    }

    private func handlePreferenceChange(offsets: [CalendarViewModel.DateOffset]) {
        guard !offsets.isEmpty else { return }
        if let closestDate = offsets.min(by: { abs($0.offset - middleY) < abs($1.offset - middleY) })?.id {
            let now = Date()
            if now.timeIntervalSince(lastUpdate) > 0.2 { // Debounce time interval
                lastUpdate = now
                DispatchQueue.main.async {
                    viewModel.updateDateIfNeeded(to: closestDate)
                }
            }
        }
    }

    private func colorForLactate(_ lactate: Double?) -> Color {
        guard let lactate = lactate else { return .whiteOne }
        
        if lactate < 1.0 {
            return .blue
        } else if lactate <= 1.5 {
            return .green
        } else if lactate <= 3.0 {
            return .yellow
        } else if lactate <= 4.9 {
            return .orange
        } else {
            return .red
        }
    }

    private func updateVisibleDate(geo: GeometryProxy, day: Date) {
        let midY = geo.frame(in: .global).midY
        if abs(midY - middleY) < 35 {
            if viewModel.date != day {
                viewModel.updateDateIfNeeded(to: day)
                print("updateVisibleDate: Updated date to \(day) based on position \(midY)")
            } else {
                print("updateVisibleDate: Date \(day) already set as current date")
            }
        } else {
            print("updateVisibleDate: Date \(day) at position \(midY) is not within the middle Y range")
        }
    }

    private func updateToTodayAndScroll() {
        isDatePickerChanging = true
        isScrollingToDate = true
        viewModel.date = Date()
        viewModel.updateDates()
        scrollToToday {
            isDatePickerChanging = false
            isScrollingToDate = false
        }
    }

    private func scrollToToday(completion: (() -> Void)? = nil) {
        if let proxy = scrollViewProxy {
            isScrollingToDate = true
            viewModel.scrollToDate(proxy: proxy, date: Date())
            initialScrollDone = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isScrollingToDate = false
                isDatePickerChanging = false
                completion?()
                DispatchQueue.main.async {
                    updateVisibleDate(for: Date())
                }
            }
        }
    }

    private func scrollToDate(_ date: Date, completion: (() -> Void)? = nil) {
        if let proxy = self.scrollViewProxy {
            self.isScrollingToDate = true
            self.viewModel.scrollToDate(proxy: proxy, date: date)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.isScrollingToDate = false
                completion?()
                DispatchQueue.main.async {
                    updateVisibleDate(for: date)
                }
            }
        } else {
            completion?()
        }
    }

    private func handleDatePickerChange(_ newDate: Date) {
        print("DatePicker changed to: \(newDate)")
        isDatePickerChanging = true
        viewModel.updateDates()
        scrollToDate(newDate) {
            isDatePickerChanging = false
        }
    }

    private func updateVisibleDate(for date: Date) {
        // Ensure that the date is correctly centered in the visible range
        for day in viewModel.days {
            if Calendar.current.isDate(day, inSameDayAs: date) {
                if let proxy = scrollViewProxy {
                    proxy.scrollTo(day, anchor: .center)
                    break
                }
            }
        }
    }
}

#Preview {
    CalendarView()
}
