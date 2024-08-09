import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) var context
    @State private var selectedTab: Int = 0
    @State private var searchText: String = ""
    @State private var currentUser: User?
    @State private var selectedDate = Date()
    @State private var days: [Date] = Date().daysInYear
    @State private var showDatePicker: Bool = false
    @State private var messages: [ChatMessage] = []
    @State private var sessions: [Session] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.starBlack.ignoresSafeArea()
                Group {
                    if let user = currentUser {
                        TabView(selection: $selectedTab) {
                            HomeView()
                                .tabItem {
                                    Image(systemName: "sum")
                                    Text("Home")
                                }
                                .tag(0)
                            CalendarView(
                                showDatePicker: $showDatePicker,
                                selectedDate: $selectedDate,
                                days: $days,
                                onTodayButtonTapped: {
                                    CalendarHelper.resetToToday(selectedDate: $selectedDate, days: $days)
                                }
                            )
                            .tabItem {
                                Image(systemName: "calendar")
                                Text("Calendar")
                            }
                            .tag(1)
                            LactateView()
                                .tabItem {
                                    Image(systemName: "dot.radiowaves.left.and.right")
                                    Text("Lactate")
                                }
                                .tag(2)
                            ChatView(messages: $messages, user: user)
                                .tabItem {
                                    Image(systemName: "person.2")
                                    Text("Chat")
                                }
                                .tag(3)
                            MetricView()
                                .tabItem {
                                    Image(systemName: "chart.xyaxis.line")
                                    Text("Metrics")
                                }
                                .tag(4)
                        }
                        .tint(.starMain)
                    } else {
                        Text("Loading...")
                            .onAppear {
                                currentUser = UserService.fetchOrCreateUser(context: context)
                            }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if let user = currentUser {
                        NavigationLink(destination: ProfileView(user: user)) {
                            Label("Profile", systemImage: "person.fill")
                        }
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if currentUser != nil {
                        switch selectedTab {
                        case 1:
                            CalendarToolbar(showDatePicker: $showDatePicker, onTodayButtonTapped: {
                                CalendarHelper.resetToToday(selectedDate: $selectedDate, days: $days)
                            })
                        case 2:
                            LactateToolbar()
                        case 3:
                            ChatToolbar(messages: $messages, user: currentUser!)
                        case 4:
                            MetricToolBar()
                        default:
                            HomeToolBar()
                        }
                    }
                }
            }
            .tint(.whiteTwo)
        }
        .tint(.starMain)
    }
}



#Preview {
    NavigationView {
        ContentView()
    }
}
