import SwiftUI
import CloudKit

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var starStore: StarStore
    @StateObject private var viewModel = MessageHelper()
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.starBlack.ignoresSafeArea()
                TabView(selection: $appState.selectedTab) {
                    HomeView()
                        .environmentObject(viewModel)
                        .tabItem {
                            Image(systemName: "sum")
                            Text("Home")
                        }
                        .tag(0)
                    CalendarView()
                        .tabItem {
                            Image(systemName: "calendar")
                            Text("Calendar")
                        }
                        .tag(1)
                    LiveView()
                        .tabItem {
                            Image(systemName: "dot.radiowaves.left.and.right")
                            Text("Live")
                        }
                        .tag(2)
                    ChatView(viewModel: viewModel)
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.starBlack, for: .navigationBar)
            .toolbar {
                ToolbarItemGroup(placement: .principal) {
                    switch appState.selectedTab {
                    case 0:
                        HomeToolBarPrin()
                    case 1:
                        CalendarToolBarPrin()
                    case 2:
                        LiveToolBarPrin()
                    case 3:
                        ChatToolBarPrin()
                    case 4:
                        MetricToolBarPrin()
                    default:
                        CalendarToolBarPrin()
                    }
                }
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    switch appState.selectedTab {
                    case 1:
                        ProfileToolBarLead()
                    case 2:
                        ProfileToolBarLead()
                    case 3:
                        ProfileToolBarLead()
                    case 4:
                        ProfileToolBarLead()
                    default:
                        ProfileToolBarLead()
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    switch appState.selectedTab {
                    case 1:
                        CalendarToolbarTrail()
                    case 2:
                        LiveToolbarTrail()
                    case 3:
                        ChatToolbarTrail(viewModel: viewModel)
                    case 4:
                        MetricToolBarTrail()
                    default:
                        HomeToolBarTrail()
                    }
                }
            }
            .tint(.whiteTwo)
        }
        .onAppear {
            // Check the subscription status when ContentView appears
            if appState.currentUser != nil {
                Task {
                    await appState.updateSubscriptionStatus(starStore: starStore)
                }
            }
        }
        .tint(.starMain)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(StarStore())
}
