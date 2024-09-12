import Foundation
import SwiftUI

struct MockSessionGenerator {
    static func createMockSessions() -> [Session] {
        let calendar = Calendar.current
        let titles = ["Morning Run", "Evening Jog", "Afternoon Training", "Recovery Run", "Speed Workout", "Hill Repeats", "Long Run"]

        // Define fixed values for each session
        let fixedSessionsData: [(distance: Double, duration: Double, pace: Double, power: Int, heartRate: Int, lactate: Double)] = [
            (distance: 5.0, duration: 45.0, pace: 5.0, power: 180, heartRate: 130, lactate: 3.0),
            (distance: 10.0, duration: 90.0, pace: 5.5, power: 220, heartRate: 145, lactate: 4.2),
            (distance: 6.0, duration: 50.0, pace: 4.7, power: 190, heartRate: 140, lactate: 3.5),
            (distance: 4.0, duration: 35.0, pace: 5.8, power: 170, heartRate: 135, lactate: 2.8),
            (distance: 8.0, duration: 75.0, pace: 4.2, power: 210, heartRate: 150, lactate: 4.5),
            (distance: 7.0, duration: 60.0, pace: 4.8, power: 230, heartRate: 155, lactate: 3.8),
            (distance: 12.0, duration: 110.0, pace: 5.4, power: 240, heartRate: 160, lactate: 5.0)
        ]

        var sessions: [Session] = []

        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            let data = fixedSessionsData[i]

            let session = Session(
                distance: data.distance,
                duration: data.duration,
                pace: data.pace,
                power: data.power,
                heartRate: data.heartRate,
                lactate: data.lactate,
                date: date,
                title: titles[i],
                user: nil // Assuming no user relationship needed for mock data
            )

            sessions.append(session)
        }

        return sessions.sorted(by: { $0.date ?? Date() < $1.date ?? Date() })
    }
}

// Usage: Call this function to generate mock sessions
let mockSessions = MockSessionGenerator.createMockSessions()
