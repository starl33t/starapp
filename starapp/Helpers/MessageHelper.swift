import Combine
import Foundation

struct CreateThreadResponse: Codable {
    let id: String
}

struct Message: Identifiable, Codable, Comparable {
    var id: UUID
    var threadId: String
    var role: String
    var content: String
    var createdAt: Date

    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.createdAt > rhs.createdAt
    }
}

class MessageHelper: ObservableObject {
    @Published var messages: [Message] = []
    @Published var sortedMessages: [Message] = []
    @Published var threadId: String?

    let assistantId = "asst_LQa6lUG4q2TN2mdatyXXI490"
    let apiKey: String

    init() {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "OpenAIAPIKey") as? String else {
            fatalError("API Key not found in Info.plist")
        }
        self.apiKey = key
    }
    
    private func performRequest<T: Decodable>(url: String, method: String, body: [String: Any]? = nil) async throws -> T {
        guard let url = URL(string: url) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("assistants=v2", forHTTPHeaderField: "OpenAI-Beta")

        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        // If T is Data, return the raw data without decoding
        if T.self == Data.self {
            return data as! T
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

    func createThread() async {
        do {
            let threadResponse: CreateThreadResponse = try await performRequest(url: "https://api.openai.com/v1/threads", method: "POST")
            DispatchQueue.main.async {
                self.threadId = threadResponse.id
            }
        } catch {
            print("Error creating thread: \(error)")
        }
    }

    func createMessage(threadId: String, content: String) async {
        let jsonBody: [String: Any] = [
            "role": "user",
            "content": content
        ]

        do {
            _ = try await performRequest(url: "https://api.openai.com/v1/threads/\(threadId)/messages", method: "POST", body: jsonBody) as Data

            let newMessage = Message(
                id: UUID(),
                threadId: threadId,
                role: "user",
                content: content,
                createdAt: Date()
            )
            DispatchQueue.main.async {
                self.messages.append(newMessage)
                self.trimMessages()  // Ensure only 5 messages are stored
            }

            try await streamAssistantResponse(threadId: threadId)

        } catch {
            print("Error creating message: \(error)")
        }
    }

    func trimMessages() {
        if messages.count > 5 {
            messages.removeFirst(messages.count - 5)
        }
    }

   

    @MainActor
    func updateAssistantMessage(_ content: String, threadId: String) {
        if let lastMessage = self.messages.last, lastMessage.role == "assistant" {
            self.messages[self.messages.count - 1].content += content
        } else {
            let newAssistantMessage = Message(
                id: UUID(),
                threadId: threadId,
                role: "assistant",
                content: content,
                createdAt: Date()
            )
            self.messages.append(newAssistantMessage)
        }
    }

    func streamAssistantResponse(threadId: String) async throws {
        print("Starting streamAssistantResponse for threadId: \(threadId)")

        guard let url = URL(string: "https://api.openai.com/v1/threads/\(threadId)/runs") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("assistants=v2", forHTTPHeaderField: "OpenAI-Beta")

        let jsonBody: [String: Any] = [
            "assistant_id": assistantId,
            "stream": true
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: jsonBody, options: [])

        let (data, response) = try await URLSession.shared.bytes(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("Response Status Code: \(httpResponse.statusCode)")
        }

        for try await line in data.lines {
            if line.starts(with: "data: ") {
                let jsonData = line.dropFirst(6)
                if let jsonObject = try? JSONSerialization.jsonObject(with: Data(jsonData.utf8), options: []),
                   let dict = jsonObject as? [String: Any],
                   let delta = dict["delta"] as? [String: Any],
                   let contentArray = delta["content"] as? [[String: Any]] {
                    for contentItem in contentArray {
                        if let textContent = contentItem["text"] as? [String: Any],
                           let textValue = textContent["value"] as? String {
                            await updateAssistantMessage(textValue, threadId: threadId)
                        }
                    }
                }
            }
        }
    }
}
