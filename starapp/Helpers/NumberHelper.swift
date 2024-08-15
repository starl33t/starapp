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
}
