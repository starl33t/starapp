import SwiftUI

class AppState: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var currentUser: User? {
        didSet {
            // Set tier and tagName when currentUser is set
            tier = currentUser?.tier ?? 0 
            tagName = currentUser?.tagName ?? ""
        }
    }
    @Published var tier: Int = 0
    @Published var tagName: String = ""
    @Published var selectedDate: Date = Date()
    @Published var days: [Date] = Date().daysInYear
    
    func loadOrCreateUser() {
            // 1) Try to fetch the user from CloudKit and save to local
            CloudHelper.syncWithCloudKit { [weak self] user in
                DispatchQueue.main.async {
                    if let user = user {
                        self?.currentUser = user
                        CloudHelper.saveToLocalCache(user: user)
                    } else {
                        // 2) If fetching from CloudKit fails, try to fetch the user from local and sync to CloudKit
                        if let localUser = CloudHelper.loadUserFromLocalCache() {
                            self?.currentUser = localUser
                            CloudHelper.syncLocalChangesToCloudKit(user: localUser) {
                                // Handle completion or errors if necessary
                            }
                        } else {
                            // 3) If neither CloudKit nor local cache works, then create the user
                            CloudHelper.createUserLocally { newUser in
                                self?.currentUser = newUser
                                // Optionally sync this new user back to CloudKit
                                CloudHelper.syncLocalChangesToCloudKit(user: newUser) {
                                    // Handle completion or errors if necessary
                                }
                            }
                        }
                    }
                }
            }
        }
    
    func updateTier(_ newTier: Int) {
        tier = newTier
        currentUser?.tier = newTier
        if let user = currentUser {
            CloudHelper.saveUserChanges(user: user)
        }
    }
    
    func updateTagName(_ newTagName: String) {
        tagName = newTagName
        currentUser?.tagName = newTagName
        if let user = currentUser {
            CloudHelper.saveUserChanges(user: user)
        }
    }
    
    func updateSubscriptionStatus(starStore: StarStore) {
            if let user = currentUser {
                starStore.checkSubscriptionStatus(for: user)
                tier = user.tier ?? 0
            }
        }
}
