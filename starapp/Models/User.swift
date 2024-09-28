import SwiftUI
import SwiftData

@Model
class User {
    var tier: Int?
    @Relationship(deleteRule: .cascade) var sessions: [Session]?
    
    init(
        tier: Int? = nil,
        sessions: [Session]? = nil
    ) {
        self.tier = tier
        self.sessions = sessions
    }
}
