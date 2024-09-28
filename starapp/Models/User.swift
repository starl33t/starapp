import SwiftUI
import SwiftData

@Model
class User {
    var userName: String?
    var tagName: String?
    var tier: Int?
    var latitude: Double?
    var longitude: Double?
    @Relationship(deleteRule: .cascade) var sessions: [Session]?
    
    init(
        userName: String? = nil,
        tagName: String? = nil,
        tier: Int? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        sessions: [Session]? = nil
    ) {
        self.userName = userName
        self.tagName = tagName
        self.tier = tier
        self.latitude = latitude
        self.longitude = longitude
        self.sessions = sessions
    }
}
