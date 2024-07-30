import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) var context
    @State private var selectedTab: Int = 0
    @State private var searchText: String = ""
    @State private var showingSheet: Bool = false
    @State private var currentUser: User?
    @State private var selectedDate = Date()
    @State private var date = Date()
    @State private var days: [Date] = Date().daysInYear
    
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
                                selectedDate: $selectedDate,
                                date: $date,
                                days: $days,
                                onTodayButtonTapped: {
                                    CalendarHelper.resetToToday(selectedDate: $selectedDate, date: $date, days: $days)
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
                            ChatView(user: user)
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
                            CalendarToolbar(showingSheet: $showingSheet, onTodayButtonTapped: {
                                CalendarHelper.resetToToday(selectedDate: $selectedDate, date: $date, days: $days)
                            })
                        case 2:
                            LactateToolbar(showingSheet: $showingSheet)
                        case 3:
                            ChatToolbar(showingSheet: $showingSheet)
                        case 4:
                            MetricToolBar(showingSheet: .constant(false))
                        default:
                            HomeToolBar(showingSheet: $showingSheet)
                        }
                    }
                }
            }
            .tint(.whiteTwo)
        }
    }
}



#Preview {
    NavigationView {
        ContentView()
    }
}
