import SwiftUI
import SwiftData

@main
struct starappApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var starStore = StarStore()
    @StateObject private var navigationTitleTypes = NavigationTitleTypes()
    
    var body: some Scene {
        WindowGroup {
            if appState.currentUser != nil {
                ContentView()
                    .environmentObject(appState)
                    .environmentObject(starStore)
                    .environmentObject(navigationTitleTypes)
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
