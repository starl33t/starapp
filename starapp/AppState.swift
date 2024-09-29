import SwiftUI

class AppState: ObservableObject {
    @Published var selectedTab: Int = 0
    @AppStorage("userTier") private var userTier: Int = 0
    @Published var selectedDate: Date = Date()
    @Published var days: [Date] = Date().daysInYear
    @Published var homeTitle: String = "Lactate"
    @Published var homeActiveTab: HomeTab = .lactate
    @Published var todayTitle: String = ""
    
    func checkSubscriptionStatus(starStore: StarStore) async {
        await starStore.updateCustomerProductStatus()
        
        DispatchQueue.main.async {
            if starStore.purchasedSubscriptions.contains(where: { $0.id == "tier1" }) {
                self.userTier = 1
            } else {
                self.userTier = 0
            }
        }
    }
    
    func updateHomeNavigationTitle() {
        self.homeTitle = self.homeActiveTab.navigationTitle
    }
    
    func updateTodayTitle() {
        let today = Date()
        self.todayTitle = today.formatDayMonthLong(date: today)
    }
}
