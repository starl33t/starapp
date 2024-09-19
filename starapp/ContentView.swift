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
                switch appState.selectedTab {
                case 0:
                    HomeView().environmentObject(viewModel)
                case 1:
                    CalendarView()
                case 2:
                    LiveView()
                case 3:
                    ChatView(viewModel: viewModel)
                case 4:
                    MetricView()
                default:
                    HomeView().environmentObject(viewModel)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.starBlack, for: .navigationBar)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    switch appState.selectedTab {
                    case 0:
                        HomeToolBarLead()
                    case 1:
                        CalendarToolBarLead()
                    case 2:
                        HomeToolBarLead()
                    case 3:
                        ChatToolBarLead()
                    case 4:
                        HomeToolBarLead()
                    default:
                        HomeToolBarLead()
                    }
                }
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
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    switch appState.selectedTab {
                    case 0:
                        HomeToolBarTrail()
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
