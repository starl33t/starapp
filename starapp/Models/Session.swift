import SwiftUI
import SwiftData

@Model
class Session {
    var distance: Double?
    var duration: Double?
    var pace: Double?
    var power: Int?
    var heartRate: Int?
    var lactate: Double?
    var date: Date?
    var title: String?
    var uidString: String?
    var adc: Int?
    var current: Double?

    init(
        distance: Double? = nil,
        duration: Double? = nil,
        pace: Double? = nil,
        power: Int? = nil,
        heartRate: Int? = nil,
        lactate: Double? = nil,
        date: Date? = nil,
        title: String? = nil,
        uidString: String? = nil,
        adc: Int? = nil,
        current: Double? = nil
    ) {
        self.distance = distance
        self.duration = duration
        self.pace = pace
        self.power = power
        self.heartRate = heartRate
        self.lactate = lactate
        self.date = date
        self.title = title
        self.uidString = uidString
        self.adc = adc
        self.current = current
    }
}
