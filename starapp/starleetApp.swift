import SwiftUI
import SwiftData

@main
struct starappApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var starStore = StarStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environmentObject(appState)
        .environmentObject(starStore)
        .modelContainer(for: [Session.self])
    }
}
