import SwiftUI
import SwiftData

@Model
class Split {
    var splitNumber: Int?
    var distance: Double?
    var duration: Double?
    var pace: Double?
    var power: Int?
    var heartRate: Int?
    var lactate: Double?
    var date: Date?
    var title: String?
    @Relationship(inverse: \Session.splits)
    var session: Session?

    init(splitNumber: Int? = nil, distance: Double? = nil, duration: Double? = nil, pace: Double? = nil, power: Int? = nil, heartRate: Int? = nil, lactate: Double? = nil, date: Date? = nil, title: String? = nil, session: Session? = nil) {
        self.splitNumber = splitNumber
        self.distance = distance
        self.duration = duration
        self.pace = pace
        self.power = power
        self.heartRate = heartRate
        self.lactate = lactate
        self.date = date
        self.title = title
        self.session = session
    }
}
