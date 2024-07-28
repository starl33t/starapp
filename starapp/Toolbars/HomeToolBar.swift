import SwiftUI

struct HomeToolBar: View {
    @Binding var showingSheet: Bool
    @AppStorage("Notifications") private var Notifications = false
    var body: some View {
        HStack {
            Menu {
                Button(action: {
                    // Action 1
                }) {
                    Text("AI Model Nola 1.0")
                }
            } label: {
                Label("AI", systemImage: "cpu")
            }

            Menu {
                Button(action: {
                    // Action 1
                }) {
                    Text("No Notifications!")
                }
            } label: {
                Label("Notifications", systemImage: Notifications ? "bell" : "bell.slash")
            }
        }
    }
}

#Preview {
    HomeToolBar(showingSheet: .constant(false))
}
