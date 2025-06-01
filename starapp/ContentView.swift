import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var messageManager = MessageHelper()
    private let nfcManager = NFCManager()

    
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
                    ChatView().environmentObject(messageManager)
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
