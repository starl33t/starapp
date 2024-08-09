import SwiftUI
import SwiftData

struct ChatToolbar: View {
    @Binding var messages: [ChatMessage]
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    var user: User
    
    var body: some View {
        HStack {
            Menu {
                Button(action: {
                    sendMessage("Maximize my recovery")
                }) {
                    Text("Maximize my recovery")
                }
                Button(action: {
                    sendMessage("Make me a recovery plan")
                }) {
                    Text("Make me a recovery plan")
                }
                Button(action: {
                    sendMessage("Help me with my injuries")
                }) {
                    Text("Help me with my injuries")
                }
            } label: {
                Label("Recovery", systemImage: "figure.pilates")
            }
            Menu {
                Button(action: {
                    sendMessage("Optimize my training")
                }) {
                    Text("Optimize my training")
                }
                Button(action: {
                    sendMessage("Give me a training plan")
                }) {
                    Text("Give me a training plan")
                }
                Button(action: {
                    sendMessage("I want to peak")
                }) {
                    Text("I want to peak")
                }
            } label: {
                Label("Performance", systemImage: "trophy")
            }
        }
    }
    
    private func sendMessage(_ text: String) {
        let sessionInfo = formatSessionInfo()
        let fullMessage = "\(text)\n\n\(sessionInfo)"
        
        MessageHelper.sendMessage(userInput: fullMessage) { responseMessage in
            if let responseMessage = responseMessage {
                messages.append(responseMessage)
            }
        }
    }
    
    private func formatSessionInfo() -> String {
        if sessions.isEmpty {
            return "No sessions."
        }
        
        return sessions.enumerated().map { index, session in
            let sessionDescription = describeSession(session)
            let dateDescription = session.date?.formatSessionDate() ?? ""
            return """
                Session \(index + 1)@\(dateDescription):
                \(sessionDescription)
                """
        }.joined(separator: "\n\n")
    }
    
    private func describeSession(_ session: Session) -> String {
        var description = ""
        
        if let title = session.title {
            description += "Title: \(title)\n"
        }
        if let distance = session.distance {
            description += "Distance: \(distance) km\n"
        }
        if let duration = session.duration {
            description += "Duration: \(duration) min\n"
        }
        if let pace = session.pace {
            description += "Pace: \(pace) min/km\n"
        }
        if let power = session.power {
            description += "Power: \(power) W\n"
        }
        if let heartRate = session.heartRate {
            description += "Heart Rate: \(heartRate) BPM\n"
        }
        if let lactate = session.lactate {
            description += "Lactate: \(lactate) mM\n"
        }
        
        return description.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

#Preview {
    ChatToolbar(messages: .constant([]), user: User(tagName: "PreviewUser"))
}
