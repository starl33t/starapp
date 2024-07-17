import SwiftUI
import SwiftData

@Model
class User {
    var id: UUID? // Optional unique identifier for the user
    var username: String?
    var tagName: String?
    var photoURL: URL?
    @Relationship(deleteRule: .cascade) var messages: [Message]?
    @Relationship(deleteRule: .cascade) var sessions: [Session]?
    
    init(id: UUID? = nil, username: String? = nil, tagName: String? = nil, photoURL: URL? = nil) {
        self.id = id
        self.username = username
        self.tagName = tagName
        self.photoURL = photoURL
    }
}
