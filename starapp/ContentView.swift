import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var messageManager: MessageHelper

    var body: some View {
        NavigationStack{
            ZStack {
                Color.starBlack.ignoresSafeArea()
                switch appState.selectedTab {
                case 0:
                    HomeView()
                case 1:
                    CalendarView()
                case 2:
                    ChatView()
                default:
                    HomeView()
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
                ChatToolBarLead()
            default:
                HomeToolBarLead()
            }
        }
        .overlay(alignment: .topTrailing) {
            switch appState.selectedTab {
            case 0:
                HomeToolBarTrail()
            case 1:
                CalendarToolBarTrail()
            case 2:
                ChatToolbarTrail(viewModel: messageManager)
            default:
                HomeToolBarTrail()
            }
        }
        .overlay(alignment: .bottom) {
            switch appState.selectedTab {
            case 0:
                HomeToolBarPrin()
            case 1:
                CalendarToolBarPrin()
            case 2:
                ChatToolBarPrin()
            default:
                CalendarToolBarPrin()
            }
        }
    }
}
