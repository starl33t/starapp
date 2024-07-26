import SwiftUI

struct HomeToolBar: View {
    @Binding var showingSheet: Bool
    @AppStorage("Notifications") private var Notifications = false
        
    var body: some View {
        HStack {
            Button(action: {
                showingSheet.toggle()
            }) {
                Label("Subscription", systemImage: "cpu")
            }
            .sheet(isPresented: $showingSheet) {
                SubscriptionView()
            }
            Menu {
                Button(action: {
                    // Action 1
                }) {
                    Text("No Notifications!")
                }
            } label: {
                Label("Notifictations", systemImage: Notifications ? "bell" : "bell.slash")
            }
        }
    }
}

#Preview {
    HomeToolBar(showingSheet: .constant(false))
}
