import SwiftUI
import SwiftData

@main
struct starappApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            User.self,  // Include the User model in the schema
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            InitialView()
                .environment(\.modelContext, sharedModelContainer.mainContext)
        }
        .modelContainer(sharedModelContainer)
    }
}
