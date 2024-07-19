import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var showDatePicker = false
    @State private var middleY: CGFloat = UIScreen.main.bounds.height / 2
    @State private var initialScrollDone = false
    @State private var lastUpdate = Date()
    
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
                                
                            }
                        }
                    }
                    .onAppear {
                        viewModel.scrollToDate(proxy: proxy, date: viewModel.date)
                    }
                    .onChange(of: viewModel.date) {
                        viewModel.scrollToDate(proxy: proxy, date: viewModel.date)
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
                            .onChange(of: viewModel.date) {
                                viewModel.updateDates()
                            }
                            .environment(\.colorScheme, .dark)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.starBlack)
                    
                }
                .background(
                    Color.starBlack.opacity(0.1)
                    
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
