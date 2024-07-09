import Foundation
import SwiftData
import CloudKit

@Model
final class Item: Identifiable {
    @Attribute(.unique) var id: UUID
    @Attribute var name: String
    @Attribute var ckRecordID: String? // To store the CloudKit record ID
    
    init(id: UUID = UUID(), name: String, ckRecordID: String? = nil) {
        self.id = id
        self.name = name
        self.ckRecordID = ckRecordID
    }
}
