import Foundation

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var userInput: String = ""
    
    private let apiKey = Constants.openAIAPIKey
    var user: User
    
    init(user: User) {
        self.user = user
    }

    func sendMessage() {
        guard !userInput.isEmpty else { return }
        addMessage(content: userInput, isUser: true)
        sendMessageToChatbot(message: userInput)
        userInput = ""
    }

    private func addMessage(content: String, isUser: Bool) {
        let newMessage = Message(content: content, timestamp: Date(), isUser: isUser, user: isUser ? user : nil)
        DispatchQueue.main.async {
            self.messages.append(newMessage)
        }
    }

    private func sendMessageToChatbot(message: String) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "model": "gpt-4-turbo",
            "messages": [["role": "user", "content": message]]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String else { return }

            self.addMessage(content: content.trimmingCharacters(in: .whitespacesAndNewlines), isUser: false)
        }.resume()
    }
}
