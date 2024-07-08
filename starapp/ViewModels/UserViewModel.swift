import SwiftUI
import SwiftData

class UserViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var showingAlert = false
    @Published var alertMessage = ""

    func login(modelContext: ModelContext) {
        guard !username.isEmpty, !password.isEmpty else {
            alertMessage = "Please enter both username and password."
            showingAlert = true
            return
        }

        do {
            let users = try fetchUsers(modelContext: modelContext)
            if users.contains(where: { $0.username == username && $0.password == password }) {
                alertMessage = "Login successful!"
                // Handle successful login, e.g., navigate to the main app view
            } else {
                alertMessage = "Invalid username or password."
            }
        } catch {
            alertMessage = "Error during login: \(error.localizedDescription)"
        }

        showingAlert = true
    }

    private func fetchUsers(modelContext: ModelContext) throws -> [User] {
        // Fetch all users from the model context
        let fetchRequest = FetchDescriptor<User>()
        return try modelContext.fetch(fetchRequest)
    }
}
