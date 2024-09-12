import SwiftUI

struct LiveToolBarPrin: View {
    @EnvironmentObject var appState: AppState
    @Namespace private var tabAnimation
    
    // Enum for managing live tabs
    enum FindLive: String {
        case athletes = "Athletes"
        case events = "Events"
    }
    
    var body: some View {
        HStack(spacing: 0) {
            liveTabButton(for: .athletes)
            liveTabButton(for: .events)
        }
        .onAppear {
            appState.todayLive()
        }
    }
    
    // Refactored function to create the tab button
    private func liveTabButton(for tab: FindLive) -> some View {
        Button {
            appState.selectedLive = tab
            appState.todayLive()
        } label: {
            HStack(spacing: 5) {
                Text(tab.rawValue)
            }
            .font(.headline)
            .foregroundColor(appState.selectedLive == tab ? .whiteOne : .gray)
            .padding(.vertical, 2)
            .padding(.leading, 10)
            .padding(.trailing, 15)
            .contentShape(Rectangle())
            .background {
                if appState.selectedLive == tab {
                    Capsule()
                        .fill(Color.starMain)
                        .matchedGeometryEffect(id: "ACTIVE_TAB", in: tabAnimation)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.selectedLive)
    }
}
