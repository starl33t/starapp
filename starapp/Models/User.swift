import SwiftUI
import SwiftData

@Model
class User {
    var userName: String?
    var tagName: String?
    var avatar: String?
    var tier: Int?
    @Relationship(deleteRule: .cascade) var sessions: [Session]?
    
    init(
        userName: String? = nil,
        tagName: String? = nil,
        avatar: String? = nil,
        tier: Int? = nil,
        sessions: [Session]? = nil
    ) {
        self.userName = userName
        self.tagName = tagName
        self.avatar = avatar
        self.tier = tier
        self.sessions = sessions
    }
}
