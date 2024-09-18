import SwiftUI

struct HomeToolBarTrail: View {
    @AppStorage("Notifications") private var Notifications = false
    @AppStorage("isGraphExpanded") private var isGraphExpanded = false
    var body: some View {
        HStack {
            Menu {
                Button(action: {
                    // Action 1
                }) {
                    Text("Park Runs")
                }
            } label: {
                Label("Settings", systemImage: "gear")
            }
            Button {
                isGraphExpanded.toggle() // Toggles the boolean value
            } label: {
                Label("Notifications", systemImage: "chart.xyaxis.line")
            }
            .foregroundStyle(isGraphExpanded ? .starMain : .whiteTwo)
        }
    }
}
