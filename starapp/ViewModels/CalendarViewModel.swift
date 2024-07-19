import SwiftUI

class CalendarViewModel: ObservableObject {
    @Published var date = Date()
    @Published var days: [Date] = []
    @Published var isDatePickerChanging = false
    @Published var scrollViewProxy: ScrollViewProxy? = nil
    @Published var sessionsByDate: [Date: [Session]] = [:]
    let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    init() {
        updateDates()
    }
    
    func updateDates() {
        days = date.daysInYear
    }
    
    func setSessions(_ sessions: [Session]) {
        let calendar = Calendar.current
        sessionsByDate = Dictionary(grouping: sessions, by: { calendar.startOfDay(for: $0.date ?? Date()) })
    }
    
    func sessions(for date: Date) -> [Session] {
        let startOfDay = Calendar.current.startOfDay(for: date)
        return sessionsByDate[startOfDay] ?? []
    }
    
    func scrollToDate(proxy: ScrollViewProxy, date: Date) {
        if let selectedIndex = days.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
            let selectedDate = days[selectedIndex]
            proxy.scrollTo(selectedDate, anchor: .center)
        }
    }

    func scrollToToday() {
        DispatchQueue.main.async {
            self.isDatePickerChanging = true
            if let proxy = self.scrollViewProxy {
                self.scrollToDate(proxy: proxy, date: self.date)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.isDatePickerChanging = false
            }
        }
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
