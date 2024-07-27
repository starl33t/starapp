//
//  MessageHelper.swift
//  starapp
//
//  Created by Peter Tran on 27/07/2024.
//

import Foundation

struct MessageHelper {
    static let apiKey = Constants.openAIAPIKey
    
    static func sendMessageToChatbot(message: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            completion(nil)
            return
        }
        
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
                  let content = message["content"] as? String else {
                completion(nil)
                return
            }

            completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
        }.resume()
    }

    static func sendMessage(userInput: String, completion: @escaping (ChatMessage?) -> Void) {
        guard !userInput.isEmpty else { return }
        let userMessage = ChatMessage(id: UUID(), content: userInput, timestamp: Date(), isUser: true)
        addMessage(message: userMessage, completion: completion)
        sendMessageToChatbot(message: userInput) { response in
            if let response = response {
                let botMessage = ChatMessage(id: UUID(), content: response, timestamp: Date(), isUser: false)
                addMessage(message: botMessage, completion: completion)
            }
        }
    }

    static func addMessage(message: ChatMessage, completion: @escaping (ChatMessage?) -> Void) {
        DispatchQueue.main.async {
            completion(message)
        }
    }
}

struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    let content: String
    let timestamp: Date
    let isUser: Bool
}
