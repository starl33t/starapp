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
    @State private var currentMidY: CGFloat = 0
    private let debounceInterval = 0.2
    @State private var debounceTimer: Timer?

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
                scrollToToday()
            }
            
            if showDatePicker {
                datePickerOverlay
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
                viewModel.date = Date()
                viewModel.updateDates()
                showDatePicker = false
                scrollToToday()
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
                                     // Adjust the offset as needed
                            }
                            VStack {
                                ZStack {
                                    GeometryReader { geo in
                                        Text(day.formatted(.dateTime.day()))
                                            .fontWeight(.bold)
                                            .frame(maxWidth: .infinity, minHeight: 70)
                                            .foregroundColor(
                                                Calendar.current.isDateInToday(day) ? .starMain : .whiteOne
                                            )
                                            .background(
                                                Color.clear.onAppear {
                                                    debounceMidYUpdate(newValue: geo.frame(in: .global).midY, day: day)
                                                }
                                            )
                                        
                                        // Display dots for sessions
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
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .frame(height: 70)
                        }
                    }
                }
                .onPreferenceChange(CalendarViewModel.DateOffsetKey.self) { offsets in
                    handlePreferenceChange(offsets: offsets)
                }
            }
            .onAppear {
                scrollViewProxy = proxy
                if !initialScrollDone {
                    DispatchQueue.main.async {
                        viewModel.scrollToDate(proxy: proxy, date: viewModel.date)
                        initialScrollDone = true
                    }
                }
            }
            .onChange(of: viewModel.date) { newDate in
                if initialScrollDone && !isDatePickerChanging {
                    DispatchQueue.main.async {
                        viewModel.scrollToDate(proxy: proxy, date: newDate)
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

    private func updateVisibleDate(midY: CGFloat, day: Date) {
        if abs(midY - middleY) < 35 {
            let now = Date()
            if now.timeIntervalSince(lastUpdate) > debounceInterval { // Debounce time interval
                DispatchQueue.main.async {
                    print("Updating visible date to: \(day)")
                    viewModel.updateDateIfNeeded(to: day)
                    lastUpdate = now
                }
            }
        }
    }

    private func debounceMidYUpdate(newValue: CGFloat, day: Date) {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: debounceInterval, repeats: false) { _ in
            updateVisibleDate(midY: newValue, day: day)
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

    private func scrollToToday() {
        DispatchQueue.main.async {
            isDatePickerChanging = true
            if let proxy = scrollViewProxy {
                viewModel.scrollToDate(proxy: proxy, date: Date())
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isDatePickerChanging = false
            }
        }
    }

    private func handleDatePickerChange(_ newDate: Date) {
        isDatePickerChanging = true
        viewModel.updateDates()
        DispatchQueue.main.async {
            if let proxy = scrollViewProxy {
                viewModel.scrollToDate(proxy: proxy, date: newDate)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isDatePickerChanging = false
            }
        }
    }

    private func handlePreferenceChange(offsets: [CalendarViewModel.DateOffset]) {
        guard !offsets.isEmpty else { return }
        if !isDatePickerChanging, let closestDate = offsets.min(by: { abs($0.offset - middleY) < abs($1.offset - middleY) })?.id {
            let now = Date()
            print("Offsets: \(offsets), ClosestDate: \(closestDate), LastUpdate: \(lastUpdate), Now: \(now)")
            if now.timeIntervalSince(lastUpdate) > debounceInterval { // Debounce time interval
                DispatchQueue.main.async {
                    viewModel.updateDateIfNeeded(to: closestDate)
                    lastUpdate = now
                }
            }
        }
    }
}

#Preview {
    CalendarView()
}
