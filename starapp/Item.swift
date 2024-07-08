//
//  Item.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import Foundation
import SwiftData

@Model
final class Item: Identifiable {
    @Attribute(.unique) var id: UUID
    @Attribute var timestamp: Date
    
    init(id: UUID = UUID(), timestamp: Date) {
        self.id = id
        self.timestamp = timestamp
    }
}
