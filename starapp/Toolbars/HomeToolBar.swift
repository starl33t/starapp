import SwiftUI

struct HomeToolBar: View {
    @Binding var showingSheet: Bool
    @State private var showSubscriptionSheet = false
    @AppStorage("Notifications") private var Notifications = false
    var body: some View {
        HStack {
            Button(action: {
                showSubscriptionSheet.toggle()
            }) {
                Label("Subsciptions", systemImage: "cpu")
            }
            .sheet(isPresented: $showSubscriptionSheet) {
                SubscriptionView()
                    .modifier(CloseButtonModifier(isPresented: $showSubscriptionSheet))
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
