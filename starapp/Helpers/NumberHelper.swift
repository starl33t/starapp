// NumberFormatterHelper.swift
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
        if let distance = distance, let duration = duration, distance > 0 {
            return duration / distance
        } else {
            return nil
        }
    }
    
    static func calculateAverageValue(for tab: Tab, in sessions: [Session]) -> Double {
        let values = sessions.compactMap { session in
            switch tab {
            case .lactate:
                return session.lactate
            case .duration:
                return session.duration.map { $0 / 60 } // converting to minutes for display
            case .distance:
                return session.distance
            case .heartRate:
                return session.heartRate.map(Double.init)
            case .pace:
                return session.pace
            case .power:
                return session.power.map(Double.init)
            }
        }
        return values.reduce(0, +) / Double(values.count)
    }
    
}
