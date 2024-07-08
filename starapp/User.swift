//
//  User.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//
import Foundation
import SwiftData

@Model
final class User: Identifiable {
    @Attribute(.unique) var id: UUID
    @Attribute var username: String
    @Attribute var password: String
    
    init(id: UUID = UUID(), username: String, password: String) {
        self.id = id
        self.username = username
        self.password = password
    }
}
