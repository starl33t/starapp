// CalendarHelper.swift
import Foundation
import SwiftUI

struct CalendarHelper {
    @AppStorage("selectedDate") static var selectedDate: Date = Date()
    
    static func resetToToday(days: Binding<[Date]>) {
        let today = Date()
        selectedDate = today
        days.wrappedValue = today.daysInYear
    }
    
    static func buildSessionCache(for days: [Date], with sessions: [Session]) -> [Date: [Session]] {
        var sessionCache: [Date: [Session]] = [:]
        for day in days {
            sessionCache[day] = filterSessions(for: day, from: sessions)
        }
        return sessionCache
    }
    
    static func filterSessions(for day: Date, from sessions: [Session]) -> [Session] {
        let startOfDay = Calendar.current.startOfDay(for: day)
        return sessions.filter {
            guard let sessionDate = $0.date else { return false }
            return Calendar.current.isDate(sessionDate, inSameDayAs: startOfDay)
        }
    }
    
    static func scrollToDay(_ date: Date, using proxy: ScrollViewProxy, in days: [Date], calendar: Calendar) {
        if let targetDay = days.first(where: { calendar.isDate($0, inSameDayAs: date) }) {
            proxy.scrollTo(targetDay, anchor: .center)
        }
    }
}
