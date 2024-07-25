import SwiftUI
import Combine

class CalendarViewModel: ObservableObject {
    @Published private(set) var date = Date()
    @Published private(set) var days: [Date] = []
    @Published private(set) var isScrollingToDate = false
    @Published private(set) var visibleDates: Set<Date> = []
    
    let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    private var isUpdatingFromScroll = false
    
    init() {
        updateDates()
    }
    
    func updateDates() {
        days = date.daysInYear
    }
    
    func scrollToDate(_ date: Date, proxy: ScrollViewProxy?, anchor: UnitPoint = .top) {
        guard let proxy = proxy else { return }
        
        isScrollingToDate = true
        if let selectedIndex = days.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
            let selectedDate = days[selectedIndex]
            proxy.scrollTo(selectedDate, anchor: anchor)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isScrollingToDate = false
        }
    }
    
    func scrollToToday(proxy: ScrollViewProxy?) {
        setDate(Date())
        DispatchQueue.main.async {
            self.scrollToDate(Date(), proxy: proxy, anchor: .center)
        }
    }
    
    func handleDatePickerChange(_ newDate: Date, proxy: ScrollViewProxy?) {
        setDate(newDate)
        scrollToDate(newDate, proxy: proxy, anchor: .center)
    }
    
    func setDate(_ newDate: Date) {
        date = newDate
        updateDates()
    }
    
    func updateCurrentMonth(_ day: Date) {
        guard !isScrollingToDate && !Calendar.current.isDate(date, equalTo: day, toGranularity: .month) else { return }
        date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: day)) ?? date
    }
    
    func shouldUpdateDate(_ newDate: Date) -> Bool {
        !isUpdatingFromScroll
    }
    
}
