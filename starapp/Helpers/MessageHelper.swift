import Combine
import Foundation

struct Message: Codable {
    var threadId: String
    var role: String
    var content: String
}

class MessageHelper: ObservableObject {
    @Published var currentMessage: Message?
    @Published var threadId: String?

    let assistantId = "asst_LQa6lUG4q2TN2mdatyXXI490"
    let apiKey: String

    init() {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "OpenAIAPIKey") as? String else {
            fatalError("API Key not found in Info.plist")
        }
        self.apiKey = key
    }
    
    private func performRequest(url: String, method: String, body: [String: Any]? = nil) async throws -> [String: Any] {
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("assistants=v2", forHTTPHeaderField: "OpenAI-Beta")

        if let body = body {
            request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: [])
        }

        let (data, _) = try! await URLSession.shared.data(for: request)
        let jsonObject = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        return jsonObject
    }


    func createThread() async {
        let response = try! await performRequest(url: "https://api.openai.com/v1/threads", method: "POST")
        let threadId = response["id"] as! String
        DispatchQueue.main.async {
            self.threadId = threadId
        }
    }


    func createMessage(threadId: String, content: String) async {
        let jsonBody: [String: Any] = [
            "role": "user",
            "content": content
        ]

        // Make the request to create a message
        _ = try! await performRequest(url: "https://api.openai.com/v1/threads/\(threadId)/messages", method: "POST", body: jsonBody)

        // Create and append the new message locally
        let newMessage = Message(
            threadId: threadId,
            role: "user",
            content: content
        )
        DispatchQueue.main.async {
            self.currentMessage = newMessage
        }

        // Stream assistant response
        try! await streamAssistantResponse(threadId: threadId)
    }


    @MainActor
    func updateAssistantMessage(_ content: String, threadId: String) {
            if let lastMessage = self.currentMessage, lastMessage.role == "assistant" {
                self.currentMessage?.content += content
            } else {
                let newAssistantMessage = Message(
                    threadId: threadId,
                    role: "assistant",
                    content: content
                )
                self.currentMessage = newAssistantMessage
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
