import SwiftUI
import SwiftData

@main
struct starappApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [User.self])
    }
    init() {
            print(URL.applicationSupportDirectory.path(percentEncoded: false))
        }
}
