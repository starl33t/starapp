import SwiftUI

struct HomeToolBarTrail: View {
    @AppStorage("Notifications") private var Notifications = false
    @AppStorage("isGraphExpanded") private var isGraphExpanded = false
    @AppStorage("isFloatingChatExpanded") private var isFloatingChatExpanded = false
    var body: some View {
        HStack {
            Button {
                isFloatingChatExpanded.toggle() // Toggles the boolean value
            } label: {
                Label("Chat", systemImage: isFloatingChatExpanded ? "text.bubble" : "bubble.left")
            }
            .foregroundStyle(isFloatingChatExpanded ? .starMain : .whiteTwo)
            Button {
                isGraphExpanded.toggle() // Toggles the boolean value
            } label: {
                Label("Notifications", systemImage: "chart.xyaxis.line")
            }
            .foregroundStyle(isGraphExpanded ? .starMain : .whiteTwo)
        }
    }
}
