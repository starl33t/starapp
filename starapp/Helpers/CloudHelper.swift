import CloudKit

class CloudHelper {
    
    static let customZoneID = CKRecordZone.ID(zoneName: "com.apple.coredata.cloudkit.zone", ownerName: CKCurrentUserDefaultName)
    
    // Updated fetch function to use the existing custom zone
    static func fetchUserRecord(completion: @escaping (CKRecord?, Error?) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "CD_User", predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.zoneID = customZoneID
        queryOperation.resultsLimit = 1
        
        var fetchedRecord: CKRecord?
        
        queryOperation.recordMatchedBlock = { (recordID, result) in
            switch result {
            case .success(let record):
                fetchedRecord = record
            case .failure(let error):
                print("Error fetching record: \(error.localizedDescription)")
            }
        }
        
        queryOperation.queryResultBlock = { result in
            switch result {
            case .success:
                completion(fetchedRecord, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
        
        CKContainer.default().privateCloudDatabase.add(queryOperation)
    }
    
    // Updated create function to use the existing custom zone
    static func createUserRecord(user: User, completion: @escaping (CKRecord?, Error?) -> Void) {
        let recordID = CKRecord.ID(zoneID: customZoneID)
        let record = CKRecord(recordType: "CD_User", recordID: recordID)
        record["CD_userName"] = user.userName
        record["CD_tagName"] = user.tagName
        record["CD_tier"] = user.tier
        
        CKContainer.default().privateCloudDatabase.save(record) { savedRecord, error in
            if let error = error {
                print("Failed to save new user: \(error.localizedDescription)")
                completion(nil, error)
            } else {
                completion(savedRecord, nil)
            }
        }
    }
    
    static func saveUserRecord(record: CKRecord, completion: @escaping (Error?) -> Void) {
            CKContainer.default().privateCloudDatabase.save(record) { savedRecord, error in
                completion(error)
            }
        }
    
    static func saveToLocalCache(user: User?) {
        guard let user = user else { return }

        let userDict: [String: Any] = [
            "userName": user.userName ?? "",
            "tagName": user.tagName ?? "",
            "tier": user.tier ?? 0
        ]
        UserDefaults.standard.set(userDict, forKey: "user")
    }

    // Save user changes (specific to ProfileView)
    static func saveUserChanges(user: User) {
        // Save to local cache first
        saveToLocalCache(user: user)

        // Attempt to save changes to CloudKit
        fetchUserRecord { record, error in
            if let record = record {
                record["CD_tagName"] = user.tagName
                record["CD_tier"] = user.tier

                saveUserRecord(record: record) { error in
                    // Handle any errors silently, or log if needed
                }
            }
        }
    }
}
