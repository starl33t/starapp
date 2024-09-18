
import SwiftUI

struct CalendarToolBarLead: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        HStack {
            NavigationLink(destination: ProfileView()) {
                Label("Profile", systemImage: "person.fill")
            }
            Button {
                appState.selectedTab = 0
            } label: {
                Label("Globe", systemImage: "globe")
            }
        }
    }
}
