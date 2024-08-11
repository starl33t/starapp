import SwiftUI
import SwiftData

@main
struct starleetApp: App {
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
