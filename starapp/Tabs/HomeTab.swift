//
//  Hometab.swift
//  starapp
//
//  Created by Peter Tran on 02/09/2024.
//

import Foundation

enum HomeTab: String, CaseIterable {
    case lactate = "gauge.with.dots.needle.67percent"
    case duration = "stopwatch"
    case distance = "road.lanes"
    case heartRate = "heart"
    case pace = "hare"
    case power = "bolt"
    
    func title(with averageValue: Double) -> String {
        guard averageValue.isFinite else { return "N/A" }
        
        switch self {
        case .lactate:
            return String(format: "%.1f mM", locale: Locale(identifier: "de_DE"), averageValue)
        case .duration:
            let roundedMinutes = Int(round(averageValue))
            let hours = roundedMinutes / 60
            let minutes = roundedMinutes % 60
            
            if hours > 0 {
                return String(format: "%d:%02d h:min", hours, minutes)
            } else {
                return "\(minutes) min"
            }
        case .distance:
            let roundedDistance = Int(ceil(averageValue))
            return "\(roundedDistance) km"
        case .heartRate:
            return String(format: "%.0f BPM", averageValue)
        case .pace:
            let minutes = Int(averageValue)
            let seconds = Int((averageValue - Double(minutes)) * 60)
            return String(format: "%d:%02d min/km", minutes, seconds)
        case .power:
            return String(format: "%.0f W", averageValue)
        }
    }
    
    var navigationTitle: String {
        switch self {
        case .lactate: return "Lactate"
        case .duration: return "Duration"
        case .distance: return "Distance"
        case .heartRate: return "Heart Rate"
        case .pace: return "Pace"
        case .power: return "Power"
        }
    }
}
