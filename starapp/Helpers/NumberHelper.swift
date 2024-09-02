import Foundation
import SwiftUI

struct NumberHelper {

    static func customFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.zeroSymbol = ""
        return formatter
    }

    static func calculatePace(distance: Double?, duration: Double?) -> Double? {
        if let distance = distance, let duration = duration, distance > 0, duration > 0 {
            return duration / distance
        } else {
            return nil
        }
    }

    static func calculateAverageValue(for tab: HomeTab, in sessions: [Session]) -> Double {
        let values = sessions.compactMap { session in
            switch tab {
            case .lactate:
                return (session.lactate ?? 0) > 0 ? session.lactate : nil
            case .duration:
                return (session.duration ?? 0) > 0 ? session.duration : nil
            case .distance:
                return (session.distance ?? 0) > 0 ? session.distance : nil
            case .heartRate:
                return (session.heartRate ?? 0) > 0 ? session.heartRate.map(Double.init) : nil
            case .pace:
                return (session.pace ?? 0) > 0 ? session.pace : nil
            case .power:
                return (session.power ?? 0) > 0 ? session.power.map(Double.init) : nil
            }
        }
        guard !values.isEmpty else { return 0.0 }
        return values.reduce(0, +) / Double(values.count)
    }

    static func filteredSessions(for tab: HomeTab, in sessions: [Session]) -> [Session] {
        return sessions.filter { session in
            switch tab {
            case .lactate:
                return (session.lactate ?? 0) > 0
            case .duration:
                return (session.duration ?? 0) > 0
            case .distance:
                return (session.distance ?? 0) > 0
            case .heartRate:
                return (session.heartRate ?? 0) > 0
            case .pace:
                return (session.pace ?? 0) > 0
            case .power:
                return (session.power ?? 0) > 0
            }
        }
    }

    static func calculateDailyAverages(for tab: HomeTab, in sessions: [Session]) -> [(Date, Double)] {
        let groupedSessions = Dictionary(grouping: sessions) { session in
            Calendar.current.startOfDay(for: session.date ?? Date())
        }

        let dailyAverages = groupedSessions.map { (date, sessions) -> (Date, Double) in
            let values = sessions.compactMap {
                switch tab {
                case .lactate:
                    return $0.lactate
                case .duration:
                    return $0.duration.map { $0 / 60 }
                case .distance:
                    return $0.distance
                case .heartRate:
                    return $0.heartRate.map(Double.init)
                case .pace:
                    return $0.pace
                case .power:
                    return $0.power.map(Double.init)
                }
            }
            let average = values.isEmpty ? 0.0 : values.reduce(0, +) / Double(values.count)
            return (date, average)
        }.sorted(by: { $0.0 < $1.0 })

        return dailyAverages
    }

    static func totalValue(for tab: HomeTab, in sessions: [Session], selectedSession: Session? = nil) -> String { // Updated to HomeTab
        let filteredSessions = filteredSessions(for: tab, in: sessions)

        if let selectedSession = selectedSession {
            return valueForTab(tab, in: selectedSession)
        } else {
            let total: Double
            switch tab {
            case .lactate:
                total = filteredSessions.compactMap { $0.lactate }.reduce(0, +)
                return String(format: "%.0f mM", total)
            case .duration:
                total = filteredSessions.compactMap { $0.duration }.reduce(0, +) // Duration is in minutes
                let roundedHours = Int(round(total / 60)) // Rounding to the nearest hour
                if roundedHours > 0 {
                    return String(format: "%d h", roundedHours)
                } else {
                    return "\(Int(total)) min"
                }
            case .distance:
                total = filteredSessions.compactMap { $0.distance }.reduce(0, +)
                return String(format: "%.0f km", total)
            case .heartRate:
                let average = filteredSessions.compactMap { $0.heartRate }.compactMap(Double.init).reduce(0, +) / Double(filteredSessions.count)
                let betterSessions = filteredSessions.compactMap { $0.heartRate }.filter { Double($0) > average }
                let percentage = (Double(betterSessions.count) / Double(filteredSessions.count)) * 100
                return String(format: "%.0f%% over avg.", percentage)
            case .pace:
                let average = filteredSessions.compactMap { $0.pace }.reduce(0, +) / Double(filteredSessions.count)
                let betterSessions = filteredSessions.compactMap { $0.pace }.filter { $0 < average }
                let percentage = (Double(betterSessions.count) / Double(filteredSessions.count)) * 100
                return String(format: "%.0f%% over avg.", percentage)
            case .power:
                let average = filteredSessions.compactMap { $0.power }.compactMap(Double.init).reduce(0, +) / Double(filteredSessions.count)
                let betterSessions = filteredSessions.compactMap { $0.power }.filter { Double($0) > average }
                let percentage = (Double(betterSessions.count) / Double(filteredSessions.count)) * 100
                return String(format: "%.0f%% over avg.", percentage)
            }
        }
    }

    static func valueForTab(_ tab: HomeTab, in session: Session) -> String { // Updated to HomeTab
        switch tab {
        case .lactate:
            return String(format: "%.1f mM", locale: Locale(identifier: "de_DE"), session.lactate ?? 0)
        case .duration:
            let duration = session.duration ?? 0
            if duration >= 60 {
                let hours = Int(duration / 60)
                let minutes = Int(duration) % 60
                return String(format: "%d:%02d h", hours, minutes)
            } else {
                return String(format: "%d min", Int(duration))
            }
        case .distance:
            return String(format: "%.1f km", locale: Locale(identifier: "de_DE"), session.distance ?? 0)
        case .heartRate:
            return String(format: "%d BPM", session.heartRate ?? 0)  // Format as integer
        case .pace:
            let pace = session.pace ?? 0
            let minutes = Int(pace)
            let seconds = Int((pace - Double(minutes)) * 60)
            return String(format: "%d:%02d min/km", minutes, seconds)
        case .power:
            return String(format: "%d W", session.power ?? 0)  // Format as integer
        }
    }
}
