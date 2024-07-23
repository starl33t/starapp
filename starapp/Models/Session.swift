import SwiftUI
import SwiftData

@Model
class Session {
    var distance: Double?
    var duration: Double?
    var pace: Int?
    var power: Int?
    var heartRate: Int?
    var lactate: Double?
    var date: Date?
    var title: String?
    
    @Relationship(inverse: \User.sessions) var user: User?

    init(
        distance: Double? = nil,
        duration: Double? = nil,
        pace: Int? = nil,
        power: Int? = nil,
        heartRate: Int? = nil,
        lactate: Double? = nil,
        date: Date? = nil,
        title: String? = nil,
        user: User? = nil
    ) {
        self.distance = distance
        self.duration = duration
        self.pace = pace
        self.power = power
        self.heartRate = heartRate
        self.lactate = lactate
        self.date = date
        self.title = title
        self.user = user
    }
}
