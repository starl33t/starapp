import SwiftUI
import SwiftData

@main
struct starappApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environmentObject(appState)
        .modelContainer(for: [Session.self])
    }
}
