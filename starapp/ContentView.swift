import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) var context
    @State private var selectedTab: Int = 0
    @State private var currentUser: User?
    @State private var days: [Date] = Date().daysInYear
    @State private var selectedDate: Date = Date()
    @StateObject private var assistantViewModel = MessageHelper()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.starBlack.ignoresSafeArea()
                if let user = currentUser {
                    TabView(selection: $selectedTab) {
                        HomeView()
                            .tabItem {
                                Image(systemName: "sum")
                                Text("Home")
                            }
                            .tag(0)
                        CalendarView(selectedDate: $selectedDate, days: $days)
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
                        ChatView(viewModel: assistantViewModel, user: user)
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if let user = currentUser {
                        NavigationLink(destination: ProfileView(user: user)) {
                            Label("Profile", systemImage: "person.fill")
                        }
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                        switch selectedTab {
                        case 3:
                            ChatToolbar(viewModel: assistantViewModel)
                        case 1:
                            CalendarToolbar(selectedDate: $selectedDate, onTodayButtonTapped: {
                                CalendarHelper.resetToToday(selectedDate: $selectedDate, days: $days)
                            })
                        case 2:
                            LactateToolbar()
                        case 4:
                            MetricToolBar()
                        default:
                            HomeToolBar()
                        }
                }
            }
            .tint(.whiteTwo)
        }
        .tint(.starMain)
    }
    
}

