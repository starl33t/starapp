import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct CSVDocument: FileDocument, @unchecked Sendable {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }
    
    var sessions: [Session]
    
    // ✅ ISO8601 with fractional seconds, always UTC
    private static let iso8601UTC_ms: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.timeZone = .gmt
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
    
    // ✅ Strip subseconds to always show `.000Z`
    private func stripSubseconds(_ d: Date) -> Date {
        Date(timeIntervalSince1970: floor(d.timeIntervalSince1970))
    }
    
    init(sessions: [Session]) {
        self.sessions = sessions
    }
    
    init(configuration: ReadConfiguration) throws {
        sessions = []
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let headers = "Distance,Duration,Pace,Power,Heart Rate,Lactate,Date,Title,UID,adc,current\n"
        let csvString = headers + sessions.map { session in
            let distance = session.distance.map { String(format: "%.2f", $0) } ?? "N/A"
            let duration = session.duration.map { String(format: "%.2f", $0) } ?? "N/A"
            let pace = session.pace.map { String($0) } ?? "N/A"
            let power = session.power.map { String($0) } ?? "N/A"
            let heartRate = session.heartRate.map { String($0) } ?? "N/A"
            let lactate = session.lactate.map { String(format: "%.2f", $0) } ?? "N/A"
            let date = session.date.map { Self.iso8601UTC_ms.string(from: stripSubseconds($0)) } ?? "N/A"
            let title = session.title ?? "N/A"
            let uidString = session.uidString ?? "N/A"
            let adc = session.adc.map { String($0) } ?? "N/A"
            let current = session.current.map { String(format: "%.2f", $0) } ?? "N/A"
            
            return "\(distance),\(duration),\(pace),\(power),\(heartRate),\(lactate),\(date),\(title),\(uidString),\(adc),\(current)"
        }.joined(separator: "\n")
        
        let data = csvString.data(using: .utf8)!
        return FileWrapper(regularFileWithContents: data)
    }
}

extension CSVDocument {
    var csvString: String {
        let headers = "Distance,Duration,Pace,Power,Heart Rate,Lactate,Date,Title,UID,Adc,Current\n"
        let csvString = headers + sessions.map { session in
            let distance = session.distance.map { String(format: "%.2f", $0) } ?? "N/A"
            let duration = session.duration.map { String(format: "%.2f", $0) } ?? "N/A"
            let pace = session.pace.map { String($0) } ?? "N/A"
            let power = session.power.map { String($0) } ?? "N/A"
            let heartRate = session.heartRate.map { String($0) } ?? "N/A"
            let lactate = session.lactate.map { String(format: "%.2f", $0) } ?? "N/A"
            let date = session.date.map { Self.iso8601UTC_ms.string(from: stripSubseconds($0)) } ?? "N/A"
            let title = session.title ?? "N/A"
            let uidString = session.uidString ?? "N/A"
            let adc = session.adc.map { String($0) } ?? "N/A"
            let current = session.current.map { String(format: "%.2f", $0) } ?? "N/A"
            
            return "\(distance),\(duration),\(pace),\(power),\(heartRate),\(lactate),\(date),\(title),\(uidString),\(adc),\(current)"
        }.joined(separator: "\n")
        return csvString
    }
}

struct ScanCSVDocument {
    let dataPoints: [(time: TimeInterval, current: Double)]

    var csvString: String {
        let header = "Time (s),Current (µA)\n"
        let rows = dataPoints.map { point in
            let timeStr = String(format: "%.3f", point.time)
            let currentStr = String(format: "%.3f", point.current)
            return "\(timeStr),\(currentStr)"
        }
        .joined(separator: "\n")

        return header + rows
    }

    var csvData: Data {
        csvString.data(using: .utf8) ?? Data()
    }
}
