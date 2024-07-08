//
//  NewMessageViewModel.swift
//  starleet
//
//  Created by Peter Tran on 06/07/2024.
//

import SwiftUI

class NewMessageViewModel: ObservableObject {
    @Published var showingForm: Bool = false
    @Published var receiver: String = ""
    @Published var message: String = ""
    @Published var showingSheet: Bool = true
    @Published var messages: [Message] = [
        Message(sender: "Satoshi Nakamoto", content: "You have to buy BITCOIN for access", time: "22d"),
        // Add more sample messages here if needed
    ]
    
    func sendMessage() {
        // Add logic to send the message
        let newMessage = Message(sender: "You", content: message, time: "Just now")
        messages.append(newMessage)
        showingForm = false
    }
}
