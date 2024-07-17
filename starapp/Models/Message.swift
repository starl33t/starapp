import SwiftUI
import SwiftData

@Model
class Message {
    var content: String?
    var timestamp: Date?
    var isUser: Bool?
    @Relationship(inverse: \User.messages)
    var user: User?
    
    init(content: String? = nil, timestamp: Date? = nil, isUser: Bool? = nil,user: User? = nil) {
        self.content = content
        self.timestamp = timestamp
        self.isUser = isUser
        self.user = user
    }
}
