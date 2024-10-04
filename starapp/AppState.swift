import SwiftUI
import MapKit

class AppState: ObservableObject {
    @Published var selectedTab: Int = 0
    @AppStorage("userTier") private var userTier: Int = 0
    @Published var selectedDate: Date = Date()
    @Published var days: [Date] = Date().daysInYear
    @Published var homeTitle: String = "Lactate"
    @Published var homeActiveTab: HomeTab = .lactate
    @Published var todayTitle: String = ""
    @Published var position: MapCameraPosition = .userLocation(fallback: .automatic) //LiveView
    @Published var selectedEvent: EventMarker? //LiveView
    @Published var lastSelectedEvent: EventMarker? //LiveView
    @Published var route: MKRoute? //LiveView
    @Published var currentEvent: EventMarker? //LiveView
    @Published var travelInterval: TimeInterval?
    
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
