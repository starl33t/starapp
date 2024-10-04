import SwiftUI
import CloudKit

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var starStore: StarStore
    @EnvironmentObject var locationManager: LocationManager
    @StateObject private var messageManager = MessageHelper()
    
    var body: some View {
        NavigationStack{
            ZStack {
                Color.starBlack.ignoresSafeArea()
                switch appState.selectedTab {
                case 0:
                    HomeView().environmentObject(messageManager)
                case 1:
                    CalendarView()
                case 2:
                    LiveView().environmentObject(locationManager)
                case 3:
                    ChatView().environmentObject(messageManager)
                case 4:
                    MetricView()
                default:
                    HomeView().environmentObject(messageManager)
                }
            }
            .navigationBarHidden(true)
        }
        .tint(.starMain)
        .overlay(alignment: .topLeading) {
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
        .overlay(alignment: .top) {
            switch appState.selectedTab {
            case 0:
                HomeToolBarPrin().environmentObject(appState)
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
        .overlay(alignment: .topTrailing) {
            switch appState.selectedTab {
            case 0:
                HomeToolBarTrail()
            case 1:
                CalendarToolBarTrail()
            case 2:
                LiveToolbarTrail()
            case 3:
                ChatToolbarTrail(viewModel: messageManager)
            case 4:
                MetricToolBarTrail()
            default:
                HomeToolBarTrail()
            }
        }
        .onAppear {
            Task {
                await appState.checkSubscriptionStatus(starStore: starStore)
            }
        }
    }
}
