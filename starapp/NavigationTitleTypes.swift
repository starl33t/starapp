import SwiftUI
import Combine

// Define an enum to represent different navigation title cases
enum NavigationTitleCase {
    case home
    case calendar
    case lactate
    case chat
    case metrics
    case special
}

// Define an ObservableObject to manage the navigation title
class NavigationTitleTypes: ObservableObject {
    // Published property to hold the current navigation title case
    @Published var currentTitle: NavigationTitleCase = .home
    
    // Computed property to return the title string based on the current case
    var title: String {
        switch currentTitle {
        case .home:
            return "Home"
        case .calendar:
            return "Calendar"
        case .lactate:
            return "Lactate"
        case .chat:
            return "Chat"
        case .metrics:
            return "Metrics"
        case .special:
            return "Special Home Title"
        }
    }
    
    // Function to update the title case
    func updateTitle(to newTitle: NavigationTitleCase) {
        currentTitle = newTitle
    }
}
