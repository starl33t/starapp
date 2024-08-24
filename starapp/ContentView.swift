import SwiftUI
import CloudKit

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = MessageHelper()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.starBlack.ignoresSafeArea()
                TabView(selection: $appState.selectedTab) {
                    HomeView()
                        .tabItem {
                            Image(systemName: "sum")
                            Text("Home")
                        }
                        .tag(0)
                    CalendarView(selectedDate: $appState.selectedDate, days: $appState.days)
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
                    ChatView(viewModel: viewModel, user: appState.currentUser!)
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
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    
                    NavigationLink(destination: ProfileView(user: appState.currentUser!)) {
                        Label("Profile", systemImage: "person.fill")
                    }
                    
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    switch appState.selectedTab {
                    case 3:
                        ChatToolbar(viewModel: viewModel, user: appState.currentUser!)
                    case 1:
                        CalendarToolbar(selectedDate: $appState.selectedDate, days: $appState.days)
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
