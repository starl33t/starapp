//
//  ChatViewModel.swift
//  starleet
//
//  Created by Peter Tran on 06/07/2024.
//

import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    
    init() {
        loadMessages()
    }
    
    func loadMessages() {
        // Replace with actual data loading logic
        messages = (0..<10).map { num in
            ChatMessage(id: num, sender: "Satoshi Nakamoto", content: "You have to buy BITCOIN for access", time: "22d")
        }
    }
}

struct ChatMessage: Identifiable {
    let id: Int
    let sender: String
    let content: String
    let time: String
}
