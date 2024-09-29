import SwiftUI
import SwiftData

@main
struct starappApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var starStore = StarStore()
    @StateObject private var locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environmentObject(locationManager)
        .environmentObject(appState)
        .environmentObject(starStore)
        .modelContainer(for: [Session.self])
    }
}
