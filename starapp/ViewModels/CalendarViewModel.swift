import SwiftUI
import Combine

class CalendarViewModel: ObservableObject {
    @Published var date = Date()
    @Published var days: [Date] = []
    @Published var isScrollingToDate = false
    let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    private var isUpdatingFromScroll = false
    
    init() {
        updateDates()
    }
    
    func updateDates() {
        days = date.daysInYear
    }
     
    func scrollToDate(date: Date, proxy: ScrollViewProxy?, anchor: UnitPoint = .top) {
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
        let today = Date()
        setDate(today) {
            DispatchQueue.main.async {
                self.scrollToDate(date: today, proxy: proxy, anchor: .center)
            }
        }
    }
    

    func handleDatePickerChange(_ newDate: Date, proxy: ScrollViewProxy?) {
        setDate(newDate)
        scrollToDate(date: newDate, proxy: proxy, anchor: .center)
    }
    
    func setDate(_ newDate: Date, completion: @escaping () -> Void = {}) {
            date = newDate
            updateDates()
            DispatchQueue.main.async {
                completion()
            }
        }
    
    func updateCurrentMonth(_ day: Date) {
        if !isScrollingToDate && !Calendar.current.isDate(date, equalTo: day, toGranularity: .month) {
            isUpdatingFromScroll = true
            date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: day))!
            isUpdatingFromScroll = false
        }
    }
    
    func shouldUpdateDate(_ newDate: Date) -> Bool {
        return !isUpdatingFromScroll
    }
}
