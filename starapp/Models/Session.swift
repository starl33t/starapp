import SwiftUI
import SwiftData

@Model
class Session: Identifiable {
    @Attribute var distance: Double? = nil // Optional
    @Attribute var duration: Double? = nil // Optional
    @Attribute var heartRate: Int? = nil // Optional
    @Attribute var temperature: Double? = nil // Optional
    @Attribute var lactate: Double? = nil // Optional
    @Attribute var lapSplits: Int? = nil // Optional and changed to Int
    @Attribute var date: Date? = nil // Optional
    @Attribute var title: String? = nil // Optional

    init(
        distance: Double? = nil,
        duration: Double? = nil,
        heartRate: Int? = nil,
        temperature: Double? = nil,
        lactate: Double? = nil,
        lapSplits: Int? = nil, // Optional and changed to Int
        date: Date? = nil,
        title: String? = nil
    ) {
        self.distance = distance
        self.duration = duration
        self.heartRate = heartRate
        self.temperature = temperature
        self.lactate = lactate
        self.lapSplits = lapSplits
        self.date = date
        self.title = title
    }
}
