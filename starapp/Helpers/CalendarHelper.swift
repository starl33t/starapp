import Foundation
import SwiftUI

struct CalendarHelper {
    static func resetToToday(selectedDate: Binding<Date>, date: Binding<Date>, days: Binding<[Date]>) {
        let today = Date()
        selectedDate.wrappedValue = today
        date.wrappedValue = today
        days.wrappedValue = today.daysInYear
    }
    
    static func updateSessionCache(for day: Date, sessions: [Session]) -> [Session] {
        let startOfDay = Calendar.current.startOfDay(for: day)
        return sessions.filter {
            guard let sessionDate = $0.date else { return false }
            return Calendar.current.isDate(sessionDate, inSameDayAs: startOfDay)
        }
    }
    
    static func updateEntireSessionCache(days: [Date], sessions: [Session]) -> [Date: [Session]] {
        var sessionCache: [Date: [Session]] = [:]
        for day in days {
            sessionCache[day] = updateSessionCache(for: day, sessions: sessions)
        }
        return sessionCache
    }
}
