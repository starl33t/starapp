// MinPerKm.swift

import Foundation

func calculatePace(distance: Double?, duration: Double?) -> String {
    guard let distance = distance, let duration = duration, distance > 0 else {
        return "N/A"
    }
    let pace = duration / distance
    let minutes = Int(pace)
    let seconds = Int((pace - Double(minutes)) * 60)
    return String(format: "%d:%02d", minutes, seconds)
}
