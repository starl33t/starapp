import SwiftUI

class AppState: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var currentUser: User? {
        didSet {
            // Set tier and tagName when currentUser is set
            tier = currentUser?.tier ?? 0
            tagName = currentUser?.tagName ?? ""
            currentUser?.latitude = currentUser?.latitude ?? 0.0
            currentUser?.longitude = currentUser?.longitude ?? 0.0
        }
    }
    @Published var tier: Int = 0
    @Published var tagName: String = ""
    @Published var selectedDate: Date = Date()
    @Published var days: [Date] = Date().daysInYear
    @Published var homeTitle: String = "Lactate" //Homescreen
    @Published var metricTitle: String = "Line Chart" //Metric
    @Published var trigger: Bool = true //Homescreen
    @Published var homeActiveTab: HomeTab = .lactate // Homescreen
    @Published var animatedText: String = ""
    @Published var todayTitle: String = "" // New property for CalendarView
    @Published var todayChat: String = "AI Coach"
    @Published var liveTitle: String = "Athletes" //Homescreen
    @Published var isTextExpanded: Bool = false //FloatingButtonText
    @Published var isExpanded: Bool = false // floatingbutton
    @Published var selectedChart: MetricView.ChartType = .lineChart //metricview
    @Published var selectedLive: LiveToolBarPrin.FindLive = .athletes // liveview
    @AppStorage("Athletes") var athletesToggle: Bool = false
    @AppStorage("Events") var eventsToggle: Bool = false
   
    
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
    
    func updateHomeNavigationTitle() {
        self.homeTitle = self.homeActiveTab.navigationTitle
    }
    
    func updateTodayTitle() {
        let today = Date()
        self.todayTitle = today.formatDayMonthLong(date: today)
    }
    
    func updateMetricTitle() {
        switch selectedChart {
        case .lineChart:
            metricTitle = "Line Chart"
        case .barChart:
            metricTitle = "Bar Chart"
        case .pieChart:
            metricTitle = "Pie Chart"
        case .scatterPlot:
            metricTitle = "Scatter Plot"
        }
    }
    
    func todayLive() {
        switch selectedLive {
        case .athletes:
            liveTitle = "Athletes"
            athletesToggle = true
            eventsToggle = false  // Make sure eventsToggle is false when athletes are selected
        case .events:
            liveTitle = "Events"
            athletesToggle = false  // Make sure athletesToggle is false when events are selected
            eventsToggle = true
        }
    }
}
