import SwiftData
import Foundation

class UserService {
    static func fetchOrCreateUser(context: ModelContext) -> User {
        let fetchDescriptor = FetchDescriptor<User>()
        let users: [User] = (try? context.fetch(fetchDescriptor)) ?? []
        if let user = users.first {
            return user
        } else {
            let newUser = User(id: UUID(), userName: "NewUser", tagName: "NewTag")
            context.insert(newUser)
            saveContext(context)
            return newUser
        }
    }
    
    static func saveContext(_ context: ModelContext) {
        do {
            try context.save()
        } catch {
            print("Failed to save user: \(error)")
        }
    }
}

