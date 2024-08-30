import Foundation
import SwiftUI

// Generate 50 mock sessions using your existing Session model
struct MockSessionGenerator {
    static func createMockSessions() -> [Session] {
        var sessions: [Session] = []
        let calendar = Calendar.current

        for i in 0..<80 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!

            // Create lower and upper bounds for each metric
            let distanceLower = Double.random(in: 3.0...6.0)
            let distanceUpper = Double.random(in: 6.0...12.0)
            let durationLower = Double.random(in: 1800...3600) // 30 min to 60 min
            let durationUpper = Double.random(in: 3600...7200) // 60 min to 120 min
            let paceLower = Double.random(in: 4.0...5.0)
            let paceUpper = Double.random(in: 5.0...7.0)
            let powerLower = Int.random(in: 150...200)
            let powerUpper = Int.random(in: 200...300)
            let heartRateLower = Int.random(in: 120...150)
            let heartRateUpper = Int.random(in: 150...180)
            let lactateLower = Double.random(in: 2.0...4.0)
            let lactateUpper = Double.random(in: 4.0...7.0)

            // Generate a random title
            let titles = ["Morning Run", "Evening Jog", "Afternoon Training", "Recovery Run", "Speed Workout"]
            let title = titles.randomElement()!

            // Create the session using your existing model
            let session = Session(
                distance: Double.random(in: distanceLower...distanceUpper),
                duration: Double.random(in: durationLower...durationUpper),
                pace: Double.random(in: paceLower...paceUpper),
                power: Int.random(in: powerLower...powerUpper),
                heartRate: Int.random(in: heartRateLower...heartRateUpper),
                lactate: Double.random(in: lactateLower...lactateUpper),
                date: date,
                title: title,
                user: nil // Assuming no user relationship needed for mock data
            )

            sessions.append(session)
        }

        return sessions
    }
}

// Usage: Call this function to generate mock sessions
let mockSessions = MockSessionGenerator.createMockSessions()
