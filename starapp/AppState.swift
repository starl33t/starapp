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
    @Published var navigationTitle: String = "Home" //Homescreen
    @Published var trigger: Bool = false //Homescreen
    
    func loadOrCreateUser() {
        // 1) Load the user from cache
        if let cachedUser = CloudHelper.loadUserFromLocalCache() {
            self.currentUser = cachedUser
        } else {
            // 2) If no cache exists, create a new user on cache and save to cache
            CloudHelper.createUserLocally { [weak self] newUser in
                self?.currentUser = newUser
                CloudHelper.saveToLocalCache(user: newUser)
            }
        }
        
        // 3) Fetch user record from CloudKit
        CloudHelper.syncWithCloudKit { [weak self] cloudUser in
            DispatchQueue.main.async {
                if let cloudUser = cloudUser {
                    // 4) Save cloudkit user to local cache
                    self?.currentUser = cloudUser
                    CloudHelper.saveToLocalCache(user: cloudUser)
                } else {
                    // If no CloudKit records exist, create a new user on CloudKit
                    if let localUser = self?.currentUser {
                        CloudHelper.createUserRecord(user: localUser) { _, error in
                            if error == nil {
                                CloudHelper.saveToLocalCache(user: localUser)
                            } else {
                                print("Failed to create user on CloudKit: \(error!.localizedDescription)")
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
    
    func updateSubscriptionStatus(starStore: StarStore) async {
        if let user = currentUser {
            await starStore.checkSubscriptionStatus(for: user)
        }
    }
    
    func updateNavigationTitle(with newTitle: String, trigger: Bool) {
        self.navigationTitle = newTitle
        self.trigger = trigger
    }
}
