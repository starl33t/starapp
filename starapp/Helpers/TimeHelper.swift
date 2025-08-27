import Foundation

enum TimeHelper {
    /// Format seconds into swimming/F1 style:
    /// - under 60 → "12.23"
    /// - 60 or more → "M:SS.ss" (e.g. "1:02.34")
    static func format(_ seconds: Double) -> String {
        if seconds < 60 {
            return String(format: "%.2f", seconds)
        } else {
            let minutes = Int(seconds) / 60
            let sec = seconds.truncatingRemainder(dividingBy: 60)
            return String(format: "%d:%05.2f", minutes, sec)
        }
    }
}
