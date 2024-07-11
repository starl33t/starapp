import SwiftUI
import SwiftData

@Model
class Session: Identifiable {
    @Attribute var distance: Double = 0.0 // Provide default value
    @Attribute var duration: Double = 0.0 // Provide default value
    @Attribute var heartRate: Int = 0 // Provide default value
    @Attribute var temperature: Double? = nil // Optional
    @Attribute var lactate: Double? = nil // Optional
    @Attribute var lapSplits: Double? = nil // Optional
    @Attribute var date: Date = Date.now // Provide default value
    @Attribute var title: String? = nil // Optional

    init(
        distance: Double = 0.0,
        duration: Double = 0.0,
        heartRate: Int = 0,
        temperature: Double? = nil,
        lactate: Double? = nil,
        lapSplits: Double? = nil, // Optional
        date: Date = Date(),
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
