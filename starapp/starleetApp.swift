import SwiftUI
import SwiftData

@main
struct starappApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            if appState.currentUser != nil {
                ContentView()
                    .environmentObject(appState)
            } else {
                LoadingView()
                    .onAppear {
                        appState.loadOrCreateUser()
                    }
            }
        }
        .modelContainer(for: [User.self])
    }
}
