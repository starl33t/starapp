import CloudKit

class CloudHelper {
    
    // Fetch user record from CloudKit using recordName
    static func fetchUserRecord(completion: @escaping (CKRecord?, Error?) -> Void) {
        let container = CKContainer.default()
        container.fetchUserRecordID { userRecordID, error in
            if let userRecordID = userRecordID {
                let recordName = userRecordID.recordName
                let recordID = CKRecord.ID(recordName: recordName)
                
                print("Debug: Fetching record with recordName: \(recordName)")
                
                container.publicCloudDatabase.fetch(withRecordID: recordID) { fetchedRecord, error in
                    if let error = error as? CKError, error.code == .unknownItem {
                        print("Debug: No record found with recordName: \(recordName)")
                        // No record found, return nil without error
                        completion(nil, nil)
                    } else if let error = error {
                        print("Debug: Error fetching record: \(error.localizedDescription)")
                        completion(nil, error)
                    } else {
                        print("Debug: Successfully fetched record with recordName: \(recordName)")
                        completion(fetchedRecord, nil)
                    }
                }
            } else if let error = error {
                print("Debug: Error fetching userRecordID: \(error.localizedDescription)")
                completion(nil, error)
            }
        }
    }
    
    // Create a new user record in CloudKit using recordName
    static func createUserRecord(user: User, completion: @escaping (CKRecord?, Error?) -> Void) {
        let container = CKContainer.default()
        container.fetchUserRecordID { userRecordID, error in
            if let userRecordID = userRecordID {
                let recordName = userRecordID.recordName
                let recordID = CKRecord.ID(recordName: recordName)
                
                print("Debug: Attempting to create record with recordName: \(recordName)")
                
                // Check if record already exists
                fetchUserRecord { existingRecord, error in
                    if let _ = existingRecord {
                        // Record already exists, no need to create a new one
                        print("Debug: User record already exists, skipping creation.")
                        completion(nil, nil)
                        return
                    }
                    
                    print("Debug: No existing record found, creating new record.")
                    
                    let record = CKRecord(recordType: "User", recordID: recordID)
                    record["CD_userName"] = user.userName
                    record["CD_tagName"] = user.tagName
                    record["CD_tier"] = user.tier
                    record["CD_latitude"] = user.latitude
                    record["CD_longitude"] = user.longitude
                    
                    container.publicCloudDatabase.save(record) { savedRecord, error in
                        if let error = error {
                            print("Debug: Error saving new record: \(error.localizedDescription)")
                            completion(nil, error)
                        } else {
                            print("Debug: Successfully created and saved new record with recordName: \(recordName)")
                            completion(savedRecord, nil)
                        }
                    }
                }
            } else if let error = error {
                print("Debug: Error fetching userRecordID: \(error.localizedDescription)")
                completion(nil, error)
            }
        }
    }
    
    // Save an existing user record to CloudKit
    static func saveUserRecord(record: CKRecord, completion: @escaping (Error?) -> Void) {
        print("Debug: Saving record with recordName: \(record.recordID.recordName)")
        CKContainer.default().publicCloudDatabase.save(record) { _, error in
            if let error = error {
                print("Debug: Error saving record: \(error.localizedDescription)")
            } else {
                print("Debug: Successfully saved record with recordName: \(record.recordID.recordName)")
            }
            completion(error)
        }
    }
    
    // Save user data to local cache
    static func saveToLocalCache(user: User?) {
        guard let user = user else { return }
        
        let userDict: [String: Any] = [
            "userName": user.userName ?? "",
            "tagName": user.tagName ?? "",
            "tier": user.tier ?? 0,
            "latitude": user.latitude ?? 0.0,
            "longitude": user.longitude ?? 0.0
        ]
        UserDefaults.standard.set(userDict, forKey: "user")
    }
    
    // Load user data from local cache
    static func loadUserFromLocalCache() -> User? {
        if let userDict = UserDefaults.standard.dictionary(forKey: "user") {
            return User(
                userName: userDict["userName"] as? String,
                tagName: userDict["tagName"] as? String,
                tier: userDict["tier"] as? Int,
                latitude: userDict["latitude"] as? Double,
                longitude: userDict["longitude"] as? Double
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
                record["CD_tagNamePreview"] = user.tagNamePreview
                record["CD_tier"] = user.tier
                record["CD_latitude"] = user.latitude
                record["CD_longitude"] = user.longitude
                
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
                    userName: record["CD_userName"] as? String ?? "",
                    tagName: record["CD_tagName"] as? String ?? "",
                    tier: record["CD_tier"] as? Int ?? 0,
                    latitude: record["CD_latitude"] as? Double,
                    longitude: record["CD_longitude"] as? Double
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
            userName: "",
            tagName: "",
            tier: 0,
            latitude: 0.0,
            longitude: 0.0
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
