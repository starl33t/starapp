import SwiftUI
import SwiftData

struct InitialView: View {
    @State private var isAuthenticated: Bool = false

    var body: some View {
        Group {
            if isAuthenticated {
                ContentView()
            } else {
                LoginView(isAuthenticated: $isAuthenticated)
            }
        }
        .onAppear {
            isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
            #if DEBUG
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                isAuthenticated = true
            }
            #endif
        }
    }
}

#Preview {
    InitialView()
        .environment(\.modelContext, try! ModelContainer(for: User.self, Item.self).mainContext)
}
