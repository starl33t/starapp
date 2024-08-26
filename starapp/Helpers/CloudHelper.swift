import CloudKit

class CloudHelper {
    
    // Fetch user record from CloudKit
    static func fetchUserRecord(completion: @escaping (CKRecord?, Error?) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "CD_User", predicate: predicate)
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.resultsLimit = 1  // Ensure only one record is fetched
        
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
        
        CKContainer.default().publicCloudDatabase.add(queryOperation)
    }
    
    // Create a new user record in CloudKit (only if no record exists)
    static func createUserRecord(user: User, completion: @escaping (CKRecord?, Error?) -> Void) {
        fetchUserRecord { existingRecord, error in
            if let _ = existingRecord {
                // Record already exists, no need to create a new one
                print("User record already exists, skipping creation.")
                completion(nil, nil)
                return
            }
            
            let record = CKRecord(recordType: "CD_User")
            record["CD_userName"] = user.userName
            record["CD_tagName"] = user.tagName
            record["CD_tier"] = user.tier
            
            CKContainer.default().publicCloudDatabase.save(record) { savedRecord, error in
                if let error = error {
                    completion(nil, error)
                } else {
                    completion(savedRecord, nil)
                }
            }
        }
    }
    
    // Save an existing user record to CloudKit
    static func saveUserRecord(record: CKRecord, completion: @escaping (Error?) -> Void) {
        CKContainer.default().publicCloudDatabase.save(record) { _, error in
            completion(error)
        }
    }
    
    // Save user data to local cache
    static func saveToLocalCache(user: User?) {
        guard let user = user else { return }
        
        let userDict: [String: Any] = [
            "userName": user.userName ?? "",
            "tagName": user.tagName ?? "",
            "tier": user.tier ?? 0
        ]
        UserDefaults.standard.set(userDict, forKey: "user")
    }
    
    // Load user data from local cache
    static func loadUserFromLocalCache() -> User? {
        if let userDict = UserDefaults.standard.dictionary(forKey: "user") {
            return User(
                userName: userDict["userName"] as? String,
                tagName: userDict["tagName"] as? String,
                tier: userDict["tier"] as? Int
            )
        }
        return nil
    }
    
    // Sync local changes to CloudKit
    static func syncLocalChangesToCloudKit(user: User?, completion: @escaping () -> Void) {
           guard let user = user else { return }
           
           fetchUserRecord { record, error in
               if let record = record {
                   // Update existing CloudKit record with local changes
                   record["CD_userName"] = user.userName
                   record["CD_tagName"] = user.tagName
                   record["CD_tier"] = user.tier
                   
                   saveUserRecord(record: record) { error in
                       completion()
                   }
               } else {
                   // No record found, create a new one only if none exists
                   createUserRecord(user: user) { _, error in
                       completion()
                   }
               }
           }
       }
    
    // Sync with CloudKit and update local cache
    static func syncWithCloudKit(completion: @escaping (User?) -> Void) {
        fetchUserRecord { record, error in
            if let record = record {
                let user = User(
                    userName: record["CD_userName"] as? String ?? "defaultUserName",
                    tagName: record["CD_tagName"] as? String ?? "Enter Tag",
                    tier: record["CD_tier"] as? Int ?? 0
                )
                saveToLocalCache(user: user)
                completion(user)
            } else {
                completion(nil)
            }
        }
    }
    
    // Create a new user locally and save it
    static func createUserLocally(completion: @escaping (User) -> Void) {
        let newUser = User(
            userName: "defaultUserName",
            tagName: "defaultTagName",
            tier: 0
        )
        saveToLocalCache(user: newUser)
        completion(newUser)
    }
    
    static func saveUserChanges(user: User) {
        // 1. Save changes to CloudKit
        syncLocalChangesToCloudKit(user: user) {
            // 2. After saving to CloudKit, sync with CloudKit to update the local cache
            syncWithCloudKit { updatedUser in
                // The local cache is automatically updated by syncWithCloudKit
                if updatedUser == nil {
                    // Handle the error if needed
                }
            }
        }
    }

}
