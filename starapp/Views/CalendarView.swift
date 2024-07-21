import SwiftUI
import Combine
import SwiftData

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var showDatePicker = false
    @State private var middleY: CGFloat = UIScreen.main.bounds.height / 2
    @State private var scrollViewProxy: ScrollViewProxy? = nil
    
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
                        viewModel.date = Date()
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
                                            if !sessions.isEmpty {
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
                                        .background(
                                            GeometryReader { geo in
                                                Color.clear
                                                    .preference(key: CalendarViewModel.DateOffsetKey.self, value: [CalendarViewModel.DateOffset(id: day, offset: geo.frame(in: .global).midY)])
                                                    .onChange(of: geo.frame(in: .global).midY) { oldValue, newValue in
                                                        if !viewModel.isScrollingToDate && !showDatePicker {
                                                            viewModel.updateVisibleDate(day: day, midY: newValue, middleY: middleY, proxy: proxy)
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            viewModel.date = Date()
                            viewModel.handleDatePickerChange(Date(), proxy: scrollViewProxy)
                        }
                    }
                }
            }
            .padding()
            .foregroundStyle(.whiteTwo)
            if showDatePicker {
                VStack {
                    Spacer()
                    VStack {
                        DatePicker("Select Date", selection: $viewModel.date, displayedComponents: [.date])
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                            .onChange(of: viewModel.date) { oldDate, newDate in
                                viewModel.handleDatePickerChange(newDate, proxy: scrollViewProxy)
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
}

#Preview {
    CalendarView()
}
