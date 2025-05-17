import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct CSVDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }
    
    var sessions: [Session]
    
    init(sessions: [Session]) {
        self.sessions = sessions
    }
    
    init(configuration: ReadConfiguration) throws {
        sessions = []
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        // Updated header to include UID.
        let headers = "Distance,Duration,Pace,Power,Heart Rate,Lactate,Date,Title,UID,adc,current\n"
        let csvString = headers + sessions.map { session in
            let distance = session.distance.map { String(format: "%.2f", $0) } ?? "N/A"
            let duration = session.duration.map { String(format: "%.2f", $0) } ?? "N/A"
            let pace = session.pace.map { String($0) } ?? "N/A"
            let power = session.power.map { String($0) } ?? "N/A"
            let heartRate = session.heartRate.map { String($0) } ?? "N/A"
            let lactate = session.lactate.map { String(format: "%.2f", $0) } ?? "N/A"
            let date = session.date.map { $0.ISO8601Format() } ?? "N/A"
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
        // Updated header to include UID.
        let headers = "Distance,Duration,Pace,Power,Heart Rate,Lactate,Date,Title,UID,Adc,Current\n"
        let csvString = headers + sessions.map { session in
            let distance = session.distance.map { String(format: "%.2f", $0) } ?? "N/A"
            let duration = session.duration.map { String(format: "%.2f", $0) } ?? "N/A"
            let pace = session.pace.map { String($0) } ?? "N/A"
            let power = session.power.map { String($0) } ?? "N/A"
            let heartRate = session.heartRate.map { String($0) } ?? "N/A"
            let lactate = session.lactate.map { String(format: "%.2f", $0) } ?? "N/A"
            let date = session.date.map { $0.ISO8601Format() } ?? "N/A"
            let title = session.title ?? "N/A"
            let uidString = session.uidString ?? "N/A"
            let adc = session.adc.map { String($0) } ?? "N/A"
            let current = session.current.map { String(format: "%.2f", $0) } ?? "N/A"
            
            return "\(distance),\(duration),\(pace),\(power),\(heartRate),\(lactate),\(date),\(title),\(uidString),\(adc),\(current)"
        }.joined(separator: "\n")
        return csvString
    }
}
