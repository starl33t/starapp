import SwiftUI
import SwiftData

@Model
class Message {
    var content: String?
    var timestamp: Date?
    @Relationship(inverse: \User.messages)
    var user: User?
    
    init(content: String? = nil, timestamp: Date? = nil, user: User? = nil) {
        self.content = content
        self.timestamp = timestamp
        self.user = user
    }
}
