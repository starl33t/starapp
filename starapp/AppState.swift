import SwiftUI

class AppState: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var currentUser: User? {
        didSet {
            tier = currentUser?.tier ?? 0
        }
    }
    @Published var tier: Int = 0
    @Published var selectedDate: Date = Date()
    @Published var days: [Date] = Date().daysInYear
    @Published var homeTitle: String = "Lactate"
    @Published var homeActiveTab: HomeTab = .lactate
    @Published var todayTitle: String = ""

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
}
