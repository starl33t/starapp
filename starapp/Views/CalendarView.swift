import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                HStack {
                    Text("Filter")
                        .padding()
                        .foregroundColor(.whiteOne)
                        .frame(maxWidth: .infinity)
                    Button(action: {
                        viewModel.date = Date()
                        viewModel.updateDates()
                    }) {
                        Text("Today")
                            .foregroundColor(.whiteOne)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    DatePicker(
                        "",
                        selection: $viewModel.date,
                        displayedComponents: [.date]
                    )
                    .frame(maxWidth: .infinity)
                    .onChange(of: viewModel.date) {
                        viewModel.updateDates()
                    }
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
                                            .foregroundColor(
                                                Calendar.current.isDateInToday(day) ? .starMain : .starMain.opacity(0.3)
                                            )
                                    )
                                    .id(day)
                            }
                        }
                    }
                    .onAppear {
                        scrollToToday(proxy: proxy)
                    }
                    .onChange(of: viewModel.date) {
                        scrollToToday(proxy: proxy)
                    }
                }
            }
            .padding()
            .foregroundStyle(.whiteTwo)
            .onAppear {
                viewModel.updateDates()
            }
        }
    }
    
    private func scrollToToday(proxy: ScrollViewProxy) {
        DispatchQueue.main.async {
            if let todayIndex = viewModel.days.firstIndex(where: { Calendar.current.isDateInToday($0) }) {
                let today = viewModel.days[todayIndex]
                proxy.scrollTo(today, anchor: .center)
            }
        }
    }
}

#Preview {
    CalendarView()
}
