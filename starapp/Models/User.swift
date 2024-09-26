import SwiftUI
import SwiftData

@Model
class User {
    var userName: String?
    var tagName: String?
    var tagNamePreview: String?
    var tier: Int?
    var latitude: Double?
    var longitude: Double?
    var ban: Int?
    @Relationship(deleteRule: .cascade) var sessions: [Session]?
    
    init(
        userName: String? = nil,
        tagName: String? = nil,
        tagNamePreview: String? = nil,
        tier: Int? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        ban: Int? = nil,
        sessions: [Session]? = nil
    ) {
        self.userName = userName
        self.tagName = tagName
        self.tagNamePreview = tagNamePreview
        self.tier = tier
        self.latitude = latitude
        self.longitude = longitude
        self.ban = ban
        self.sessions = sessions
    }
}
