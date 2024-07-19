import SwiftUI
import Combine

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var showDatePicker = false
    @State private var middleY: CGFloat = UIScreen.main.bounds.height / 2
    @State private var initialScrollDone = false
    @State private var lastUpdate = Date()
    @State private var isDatePickerChanging = false
    @State private var scrollViewProxy: ScrollViewProxy? = nil

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
                        viewModel.date = Date()
                        viewModel.updateDates()
                        scrollToToday()
                        showDatePicker = false
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
                        LazyVGrid(columns: viewModel.columns, spacing: 16) {
                            ForEach(viewModel.days, id: \.self) { day in
                                GeometryReader { geo in
                                    Text(day.formatted(.dateTime.day()))
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity, minHeight: 70)
                                        .background(
                                            Circle()
                                                .foregroundStyle(
                                                    Calendar.current.isDateInToday(day) ? .starMain : .starMain.opacity(0.3)
                                                )
                                        )
                                        .id(day)
                                        .background(
                                            GeometryReader { innerGeo in
                                                Color.clear.preference(key: CalendarViewModel.DateOffsetKey.self, value: [CalendarViewModel.DateOffset(id: day, offset: innerGeo.frame(in: .global).midY)])
                                            }
                                        )
                                }
                                .frame(height: 70)
                            }
                        }
                        .onPreferenceChange(CalendarViewModel.DateOffsetKey.self) { offsets in
                            guard !offsets.isEmpty else { return }
                            if !isDatePickerChanging, let closestDate = offsets.min(by: { abs($0.offset - middleY) < abs($1.offset - middleY) })?.id {
                                let now = Date()
                                if now.timeIntervalSince(lastUpdate) > 0.2 { // Debounce time interval
                                    DispatchQueue.main.async {
                                        viewModel.date = closestDate
                                        lastUpdate = now
                                    }
                                }
                            }
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
                    .onChange(of: viewModel.date) { oldDate, newDate in
                        if initialScrollDone && !isDatePickerChanging {
                            viewModel.scrollToDate(proxy: proxy, date: newDate)
                        }
                    }
                }
            }
            .padding()
            .foregroundStyle(.whiteTwo)
            .onAppear {
                viewModel.updateDates()
            }
            
            if showDatePicker {
                VStack {
                    Spacer()
                    VStack {
                        DatePicker("Select Date", selection: $viewModel.date, displayedComponents: [.date])
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                            .onChange(of: viewModel.date) { oldDate, newDate in
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
        }
    }
    
    private func scrollToToday() {
        DispatchQueue.main.async {
            if let proxy = scrollViewProxy {
                viewModel.scrollToDate(proxy: proxy, date: viewModel.date)
            }
        }
    }
}

#Preview {
    CalendarView()
}
