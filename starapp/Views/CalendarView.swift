import SwiftUI
import SwiftData
import Combine
struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showDatePicker = false
    @State private var visibleDates: Set<Date> = []
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
//    @Query private var sessions: [Session]
    @StateObject private var viewModel = CalendarViewModel()
    @State private var selectedDate = Date()
    @State private var date = Date()
    @State private var days: [Date] = Date().daysInYear
    
    
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
                        let today = Date.now
                        selectedDate = today
                        date = today
                        days = today.daysInYear
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
//                                let daySessions = sessions.filter { Calendar.current.isDate($0.date ?? Date(), inSameDayAs: day) }
                                let daySessions = viewModel.sessionsByDay[day] ?? []
                                
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
                                                                .foregroundStyle(ColorLactate.color(for: session.lactate))
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
                                    date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: visibleDates.sorted()[visibleDates.count / 2])) ?? date
                                }
                                .onDisappear {
                                    visibleDates.remove(day)
                                }
                                
                            }
                            
                        }
                    }
                    .onAppear {
                        proxy.scrollTo(days.first(where: { Calendar.current.isDate($0, inSameDayAs: Date.now) }), anchor: .center)
                        
                    }
                    .onChange(of: selectedDate) { oldDate, newDate in
                        date = newDate
                        days = date.daysInYear
                        visibleDates.removeAll()
                        proxy.scrollTo(days.first(where: { Calendar.current.isDate($0, inSameDayAs: newDate) }), anchor: .center)
                        
                    }
                    .onReceive(NotificationCenter.default.publisher(for: .reloadSessions)) { _ in
                        viewModel.loadSessions(from: modelContext)
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
        .onAppear {
            viewModel.loadSessions(from: modelContext)
        }
        
    }
    
}

#Preview {
    CalendarView()
}
class CalendarViewModel: ObservableObject {
    @Published var sessions = [Session]()
    @Published var sessionsByDay = [Date: [Session]]()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        NotificationCenter.default.publisher(for: .newSessionSaved)
            .sink { [weak self] _ in
                self?.reloadSessions()
            }
            .store(in: &cancellables)
    }
    
    func reloadSessions() {
        NotificationCenter.default.post(name: .reloadSessions, object: nil)
    }
    
    func loadSessions(from context: ModelContext) {
        let fetchDescriptor = FetchDescriptor<Session>()
        
        do {
            sessions = try context.fetch(fetchDescriptor)
            organizeSessionsByDay()
        } catch {
            print("Failed to fetch sessions")
        }
    }
    
    private func organizeSessionsByDay() {
        let calendar = Calendar.current
        sessionsByDay = Dictionary(grouping: sessions, by: { session in
            calendar.startOfDay(for: session.date ?? Date())
        })
    }
}

extension Notification.Name {
    static let newSessionSaved = Notification.Name("newSessionSaved")
    static let reloadSessions = Notification.Name("reloadSessions")
}
