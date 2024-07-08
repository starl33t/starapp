import SwiftUI
import SwiftData

class RegisterViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var showingAlert = false
    @Published var alertMessage = ""

    @Environment(\.modelContext) private var modelContext

    func register() {
        guard !username.isEmpty, !password.isEmpty else {
            alertMessage = "Please enter both username and password."
            showingAlert = true
            return
        }

        // Check if user already exists
        let existingUsers = (try? modelContext.fetch(FetchDescriptor<User>())) ?? []
        if existingUsers.contains(where: { $0.username == username }) {
            alertMessage = "Username already taken."
            showingAlert = true
            return
        }

        let newUser = User(username: username, password: password)
        modelContext.insert(newUser)

        do {
            try modelContext.save()
            alertMessage = "Registration successful!"
        } catch {
            alertMessage = "Error during registration: \(error.localizedDescription)"
        }

        showingAlert = true
    }
}
