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
        let today = Date()
        setDate(today) {
            DispatchQueue.main.async {
                self.scrollToDate(today, proxy: proxy, anchor: .center)
            }
        }
    }
    
    func handleDatePickerChange(_ newDate: Date, proxy: ScrollViewProxy?) {
        setDate(newDate)
        scrollToDate(newDate, proxy: proxy, anchor: .center)
    }

    func setDate(_ newDate: Date, completion: @escaping () -> Void = {}) {
        date = newDate
        updateDates()
        DispatchQueue.main.async {
            completion()
        }
    }
    
    func updateCurrentMonth(_ day: Date) {
        guard !isScrollingToDate && !Calendar.current.isDate(date, equalTo: day, toGranularity: .month) else { return }
        
        isUpdatingFromScroll = true
        date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: day)) ?? date
        isUpdatingFromScroll = false
    }
    
    func shouldUpdateDate(_ newDate: Date) -> Bool {
        !isUpdatingFromScroll
    }
    
    func handleDateAppear(day: Date, frame: CGRect, screenHeight: CGFloat) {
        if frame.minY >= 0 && frame.maxY <= screenHeight {
            visibleDates.insert(day)
            guard let middleDate = visibleDates.sorted()[safe: visibleDates.count / 2] else { return }
            updateCurrentMonth(middleDate)
        }
    }

    func handleDateDisappear(day: Date) {
        visibleDates.remove(day)
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
