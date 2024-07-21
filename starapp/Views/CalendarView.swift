import SwiftUI
import Combine
import SwiftData

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var showDatePicker = false
    @State private var middleY: CGFloat = UIScreen.main.bounds.height / 2
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
                handleDatePickerChange(Date())
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
                                                        .foregroundColor(ColorLactate.color(for: session.lactate))
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
                                            .onChange(of: geo.frame(in: .global).midY) { oldValue, newValue in
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
                viewModel.updateDates()
                viewModel.setSessions(sessions)
                updateVisibleDate(for: Date())
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
                    .onChange(of: viewModel.date) { oldDate, newDate in
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

    private func updateVisibleDate(geo: GeometryProxy, day: Date) {
        let midY = geo.frame(in: .global).midY
        if abs(midY - middleY) < 35 {
            if viewModel.date != day {
                viewModel.updateDateIfNeeded(to: day)
            }
        }
    }
    
    private func scrollToDate(_ date: Date) {
        if let proxy = self.scrollViewProxy {
            self.isScrollingToDate = true
            self.viewModel.scrollToDate(proxy: proxy, date: date)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.isScrollingToDate = false
                updateVisibleDate(for: date)
            }
        }
    }

    private func handleDatePickerChange(_ newDate: Date) {
        viewModel.updateDates()
        scrollToDate(newDate)
    }

    private func updateVisibleDate(for date: Date) {
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
