import SwiftUI
import SwiftData

@Model
class Session: Identifiable {
    @Attribute var distance: Double?
    @Attribute var duration: Double?
    @Attribute var pace: Int?
    @Attribute var power: Int?
    @Attribute var heartRate: Int?
    @Attribute var lactate: Double?
    @Attribute var lap: Int?
    @Attribute var date: Date?
    @Attribute var title: String?

    init(
        distance: Double? = nil,
        duration: Double? = nil,
        pace: Int? = nil,
        power: Int? = nil,
        heartRate: Int? = nil,
        lactate: Double? = nil,
        lap: Int? = nil,
        date: Date? = nil,
        title: String? = nil
    ) {
        self.distance = distance
        self.duration = duration
        self.pace = pace
        self.power = power
        self.heartRate = heartRate
        self.lactate = lactate
        self.lap = lap
        self.date = date
        self.title = title
    }
}
