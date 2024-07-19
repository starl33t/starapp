import SwiftUI

class CalendarViewModel: ObservableObject {
    @Published var date = Date()
    @Published var days: [Date] = []
    let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    init() {
        updateDates()
    }
    
    func updateDates() {
        days = date.daysInYear
    }
    
    func scrollToDate(proxy: ScrollViewProxy, date: Date) {
        if let selectedIndex = days.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
            let selectedDate = days[selectedIndex]
            proxy.scrollTo(selectedDate, anchor: .center)
        }
    }

    func scrollToToday(proxy: ScrollViewProxy?) {
        date = Date()
        updateDates()
        if let proxy = proxy {
            scrollToDate(proxy: proxy, date: date)
        }
    }
    
    struct DateOffset: Identifiable, Equatable {
        var id: Date
        var offset: CGFloat
    }

    struct DateOffsetKey: PreferenceKey {
        typealias Value = [DateOffset]
        static var defaultValue: [DateOffset] = []
        static func reduce(value: inout [DateOffset], nextValue: () -> [DateOffset]) {
            value.append(contentsOf: nextValue())
        }
    }
}
