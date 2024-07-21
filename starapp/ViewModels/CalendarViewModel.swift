import SwiftUI
import Combine

class CalendarViewModel: ObservableObject {
    @Published var date = Date()
    @Published var days: [Date] = []
    @Published var isScrollingToDate = false
    let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    init() {
        updateDates()
    }
    
    func updateDates() {
        days = date.daysInYear
    }
     
    func scrollToDate(date: Date, proxy: ScrollViewProxy?) {
        if let proxy = proxy {
            isScrollingToDate = true
            if let selectedIndex = days.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
                let selectedDate = days[selectedIndex]
                proxy.scrollTo(selectedDate, anchor: .center)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.isScrollingToDate = false
                self.updateVisibleDate(day: date, proxy: proxy)
            }
        }
    }
    
    func updateVisibleDate(day: Date, midY: CGFloat? = nil, middleY: CGFloat = UIScreen.main.bounds.height / 2, proxy: ScrollViewProxy? = nil) {
        if let midY = midY {
            if abs(midY - middleY) < 35 {
                if self.date != day {
                    self.updateDateIfNeeded(to: day)
                }
            }
        } else {
            for day in days {
                if Calendar.current.isDate(day, inSameDayAs: self.date) {
                    if let proxy = proxy {
                        proxy.scrollTo(day, anchor: .center)
                        break
                    }
                }
            }
        }
    }

    func handleDatePickerChange(_ newDate: Date, proxy: ScrollViewProxy?) {
        updateDates()
        scrollToDate(date: newDate, proxy: proxy)
    }
    
    func updateDateIfNeeded(to newDate: Date) {
        if Calendar.current.isDate(date, inSameDayAs: newDate) == false {
            date = newDate
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
