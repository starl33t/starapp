import SwiftUI
import SwiftData

struct ChatToolbarTrail: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var viewModel: MessageHelper
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    @AppStorage("userTier") private var userTier: Int = 0
    @AppStorage("isWaitingForResponse") private var isWaitingForResponse: Bool = false
    @AppStorage("dailyMessageCount") private var dailyMessageCount: Int = 0
    @AppStorage("lastMessageDate") private var lastMessageDate: String = Date().formatted()
    @AppStorage("showAlert") private var showAlert: Bool = false
    @AppStorage("canSendMessage") private var canSendMessage: Bool = true
    @AppStorage("isChatSelected") private var isChatSelected = false
    
    var body: some View {
        HStack {
            Menu {
                Button(action: {
                    sendMessage("My latest 10 sessions")
                }) {
                    Text("Send last 10 sessions")
                }
            } label: {
                Image(systemName: "trophy")
                    .font(.system(size: 24)) // Increase symbol size
                    .fontWeight(.semibold)
                    .foregroundStyle(.whiteOne)
                    .frame(width: 50, height: 50) 
                    .background(Circle().fill(Color.darkOne))
                    .contentShape(Circle())
            }
            Button {
                appState.selectedTab = 0
            } label: {
                Image(systemName: isChatSelected ? "text.bubble" : "bubble.left")
                    .font(.system(size: 24)) 
                    .fontWeight(.semibold)
                    .foregroundStyle(isChatSelected ? .starMain : .whiteOne)
                    .symbolEffect(.bounce, value: isChatSelected)
                    .frame(width: 50, height: 50)
                    .background(Circle().fill(Color.darkOne))
                    .contentShape(Circle())
            }
        }
        .padding(.horizontal, 4)
    }
    
    private func sendMessage(_ text: String) {
        if canSendMessage {
            Task {
                let sessionInfo = formatSessionInfo()
                let fullMessage = "\(text)\n\n\(sessionInfo)"
                
                if let threadId = viewModel.threadId {
                    isWaitingForResponse = true
                    await viewModel.createMessage(threadId: threadId, content: fullMessage)
                    updateCanSendMessage()
                    dailyMessageCount += 1
                    isWaitingForResponse = false
                } else {
                    print("Thread ID not available.")
                }
            }
        } else {
            showAlert = true
        }
    }
    
    private func updateCanSendMessage() {
        if lastMessageDate != Date().formatDayMonth(date: Date()) {
            dailyMessageCount = 0
            lastMessageDate = Date().formatDayMonth(date: Date())
        }

        let maxMessages = 10
        canSendMessage = dailyMessageCount < maxMessages
    }
    
    private func formatSessionInfo() -> String {
        if sessions.isEmpty {
            return "No sessions."
        }
        
        return sessions.prefix(10).enumerated().map { index, session in
            let sessionDescription = describeSession(session)
            return """
                Session \(index + 1):
                \(sessionDescription)
                """
        }.joined(separator: "\n\n")
    }
    
    private func describeSession(_ session: Session) -> String {
        var description = ""
        
        if let title = session.title, !title.isEmpty {
            description += "Title: \(title)\n"
        }
        if let distance = session.distance {
            description += "Distance: \(distance) km\n"
        }
        if let duration = session.duration {
            let minutes = Int(duration)
            let seconds = Int((duration - Double(minutes)) * 60)
            description += String(format: "Duration: %d min %02d sec\n", minutes, seconds)
        }
        if let pace = session.pace {
            let paceMinutes = Int(pace)
            let paceSeconds = Int((pace - Double(paceMinutes)) * 60)
            description += String(format: "Pace: %02d:%02d min/km\n", paceMinutes, paceSeconds) 
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
