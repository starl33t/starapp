import SwiftUI
import Combine
import SwiftData

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var showDatePicker = false
    @State private var scrollViewProxy: ScrollViewProxy? = nil
    @State private var visibleDates: Set<Date> = []

    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]

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
                        viewModel.scrollToToday(proxy: scrollViewProxy)
                        viewModel.handleDatePickerChange(Date(), proxy: scrollViewProxy)
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

                HStack {
                    ForEach(viewModel.daysOfWeek, id: \.self) { dayOfWeek in
                        Text(dayOfWeek)
                            .frame(maxWidth: .infinity)
                    }
                }
                .fontWeight(.black)
                .padding(.bottom, 8)

                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVGrid(columns: viewModel.columns) {
                            ForEach(viewModel.days, id: \.self) { day in
                                DayView(day: day, viewModel: viewModel, sessions: sessions)
                                    .id(day)
                                    .frame(height: 70)
                                    .background(
                                        GeometryReader { geometry in
                                            Color.clear.onAppear {
                                                handleDateAppear(day: day, geometry: geometry)
                                            }
                                            .onDisappear {
                                                handleDateDisappear(day: day, geometry: geometry)
                                            }
                                        }
                                    )
                            }
                        }
                    }
                    .onAppear {
                        scrollViewProxy = proxy
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            viewModel.scrollToToday(proxy: scrollViewProxy)
                        }
                    }
                }
            }
            .padding()
            .foregroundStyle(.whiteTwo)

            if showDatePicker {
                DatePickerOverlay(
                    date: Binding(
                        get: { viewModel.date },
                        set: { newDate in
                            if viewModel.shouldUpdateDate(newDate) {
                                viewModel.setDate(newDate)
                                viewModel.handleDatePickerChange(newDate, proxy: scrollViewProxy)
                            }
                        }
                    ),
                    isPresented: $showDatePicker
                )
            }
        }
    }

    private func handleDateAppear(day: Date, geometry: GeometryProxy) {
        let globalFrame = geometry.frame(in: .global)
        let screenHeight = UIScreen.main.bounds.height
        if globalFrame.minY >= 0 && globalFrame.maxY <= screenHeight {
            visibleDates.insert(day)
            updateDatePickerIfNeeded()
        }
    }

    private func handleDateDisappear(day: Date, geometry: GeometryProxy) {
        visibleDates.remove(day)
        updateDatePickerIfNeeded()
    }

    private func updateDatePickerIfNeeded() {
        guard !visibleDates.isEmpty else { return }
        let sortedDates = visibleDates.sorted()
        if let middleDate = sortedDates[safe: sortedDates.count / 2] {
            viewModel.updateCurrentMonth(middleDate)
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct DayView: View {
    let day: Date
    @ObservedObject var viewModel: CalendarViewModel
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
                    let daySessions = sessions.filter { Calendar.current.isDate($0.date ?? Date(), inSameDayAs: day) }
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
    }
}

struct DatePickerOverlay: View {
    @Binding var date: Date
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Spacer()
            VStack {
                DatePicker("Select Date", selection: $date, displayedComponents: [.date])
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
                    isPresented = false
                }
        )
    }
}

#Preview {
    CalendarView()
}
