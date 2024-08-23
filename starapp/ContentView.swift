import SwiftUI
import CloudKit

struct ContentView: View {
    @State private var selectedTab: Int = 0
    @State private var currentUser: User?
    @State private var selectedDate: Date = Date()
    @State private var days: [Date] = Date().daysInYear
    @StateObject private var viewModel = MessageHelper()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.starBlack.ignoresSafeArea()
                if let user = currentUser {
                    TabView(selection: $selectedTab) {
                        HomeView()
                            .tabItem {
                                Image(systemName: "sum")
                                Text("Home")
                            }
                            .tag(0)
                        CalendarView(selectedDate: $selectedDate, days: $days)
                            .tabItem {
                                Image(systemName: "calendar")
                                Text("Calendar")
                            }
                            .tag(1)
                        LactateView()
                            .tabItem {
                                Image(systemName: "dot.radiowaves.left.and.right")
                                Text("Lactate")
                            }
                            .tag(2)
                        ChatView(viewModel: viewModel, user: user)
                            .tabItem {
                                Image(systemName: "person.2")
                                Text("Chat")
                            }
                            .tag(3)
                        MetricView()
                            .tabItem {
                                Image(systemName: "chart.xyaxis.line")
                                Text("Metrics")
                            }
                            .tag(4)
                    }
                    .tint(.starMain)
                } else {
                    Text("Loading...")
                        .onAppear {
                            loadOrCreateUser()
                        }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if let user = currentUser {
                        NavigationLink(destination: ProfileView(user: user)) {
                            Label("Profile", systemImage: "person.fill")
                        }
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if let user = currentUser {
                        switch selectedTab {
                        case 3:
                            ChatToolbar(viewModel: viewModel, user: user)
                        case 1:
                            CalendarToolbar(selectedDate: $selectedDate, days: $days)
                        case 2:
                            LactateToolbar()
                        case 4:
                            MetricToolBar()
                        default:
                            HomeToolBar()
                        }
                    }
                }
            }
            .tint(.whiteTwo)
        }
        .tint(.starMain)
    }
    
    private func loadOrCreateUser() {
        if let userDict = UserDefaults.standard.dictionary(forKey: "user") {
            self.currentUser = User(
                userName: userDict["userName"] as? String,
                tagName: userDict["tagName"] as? String,
                tier: userDict["tier"] as? Int
            )
            print("Loaded user from local cache.")
            syncLocalChangesToCloudKit() // Sync local changes to CloudKit
        } else {
            print("No user found in local cache. Attempting to fetch from CloudKit...")
            syncWithCloudKit() // If no cache, attempt to fetch from CloudKit
        }
    }
    
    private func syncLocalChangesToCloudKit() {
        guard let user = currentUser else { return }
        
        CloudHelper.fetchUserRecord { record, error in
            if let record = record {
                // Update CloudKit record with local changes
                record["CD_userName"] = user.userName
                record["CD_tagName"] = user.tagName
                record["CD_tier"] = user.tier
                
                CloudHelper.saveUserRecord(record: record) { error in
                    if let error = error {
                        print("Failed to sync local changes to CloudKit: \(error.localizedDescription)")
                    } else {
                        print("Local changes successfully synced to CloudKit.")
                    }
                }
            } else if let error = error as? CKError, error.code == .networkUnavailable || error.code == .networkFailure {
                // Handle offline situation
                print("No internet connection. Local changes will remain unsynced.")
            } else {
                print("No user record found in CloudKit. Creating a new user.")
                createUser()
            }
        }
    }
    
    private func syncWithCloudKit() {
        CloudHelper.fetchUserRecord { record, error in
            if let record = record {
                print("User record found: \(record.recordID.recordName)")
                DispatchQueue.main.async {
                    if self.currentUser != nil {
                        // Local user exists, so prefer local data and sync it back to CloudKit
                        self.syncLocalChangesToCloudKit()
                    } else {
                        // No local data, so use CloudKit data
                        self.currentUser = User(
                            userName: record["CD_userName"] as? String ?? "defaultUserName",
                            tagName: record["CD_tagName"] as? String ?? "defaultTagName",
                            tier: record["CD_tier"] as? Int ?? 0
                        )
                        saveToLocalCache() // Update local cache with CloudKit data
                    }
                }
            } else if let error = error as? CKError, error.code == .networkUnavailable || error.code == .networkFailure {
                // Handle no internet by using or creating a local user
                print("No internet connection. Using or creating a local user.")
                createUserLocally()
            } else {
                print("No user record found in CloudKit. Creating a new user.")
                createUser()
            }
        }
    }
    
    private func createUserLocally() {
        let newUser = User(
            userName: "defaultUserName",
            tagName: "defaultTagName",
            tier: 0
        )
        self.currentUser = newUser
        saveToLocalCache() // Save new user to local cache
        print("New user created and saved locally.")
    }
    
    private func createUser() {
        let newUser = User(
            userName: "defaultUserName",
            tagName: "defaultTagName",
            tier: 0
        )
        print("Attempting to create a new user record in CloudKit...")
        CloudHelper.createUserRecord(user: newUser) { savedRecord, error in
            if let savedRecord = savedRecord {
                print("New user created with recordID: \(savedRecord.recordID.recordName)")
                DispatchQueue.main.async {
                    self.currentUser = newUser
                    saveToLocalCache() // Save new user to local cache after CloudKit creation
                }
            } else if let error = error {
                print("Failed to create new user in CloudKit: \(error.localizedDescription)")
                saveToLocalCache() // Save locally even if CloudKit fails
            }
        }
    }
    
    private func saveToLocalCache() {
        if let user = currentUser {
            let userDict: [String: Any] = [
                "userName": user.userName ?? "",
                "tagName": user.tagName ?? "",
                "tier": user.tier ?? 0
            ]
            UserDefaults.standard.set(userDict, forKey: "user")
            print("User saved to local cache.")
        }
    }
}
