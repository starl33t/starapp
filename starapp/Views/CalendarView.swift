import SwiftUI
import SwiftData

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var showDatePicker = false
    @State private var scrollViewProxy: ScrollViewProxy?
    
    @Query private var sessions: [Session]
    
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
                        print("Today")
                        print("Today is \(viewModel.date)")
                        viewModel.handleDatePickerChange(Date(), proxy: scrollViewProxy)
                    }) {
                        Text("Today")
                            .foregroundColor(.whiteOne)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    Text(viewModel.date.formattedMonthYear())
                        .foregroundStyle(.whiteOne)
                        .onTapGesture { showDatePicker.toggle() }
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
                                .background(
                                    GeometryReader { geometry in
                                        let frame = geometry.frame(in: .global)
                                        Color.clear
                                            .onAppear {
                                                viewModel.handleDateAppear(day: day, frame: frame, screenHeight: UIScreen.main.bounds.height)
                                                print("today appeared is \(day)")
                                            }
                                            .onDisappear {
                                                viewModel.handleDateDisappear(day: day)
                                                print("today disappeared is \(day)")
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
                VStack {
                    Spacer()
                    VStack {
                        DatePicker("Select Date", selection: Binding(
                            get: { viewModel.date },
                            set: { newDate in
                                if viewModel.shouldUpdateDate(newDate) {
                                    viewModel.setDate(newDate)
                                    viewModel.handleDatePickerChange(newDate, proxy: scrollViewProxy)
                                    print("Datepicker is \(newDate)")
                                }
                            }
                        ), displayedComponents: [.date])
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
}

#Preview {
    CalendarView()
}
