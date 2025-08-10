// CalendarHelper.swift
import Foundation
import SwiftUI

struct CalendarHelper {

    // Keep a single place to decide the calendar (UTC by default)
    private static var cal: Calendar { Calendar.iso8601UTC }

    static func updateSessionCache(for days: [Date], with sessions: [Session]) -> [Date: [Session]] {
        buildSessionCache(for: days, with: sessions)
    }

    static func buildSessionCache(for days: [Date], with sessions: [Session]) -> [Date: [Session]] {
        let grouped: [Date: [Session]] = Dictionary(grouping: sessions.compactMap { s -> (Date, Session)? in
            guard let d = s.date else { return nil }
            return (cal.startOfDay(for: d), s)
        }, by: { cal.startOfDay(for: $0.0) })
        .mapValues { $0.map(\.1) }

        var cache: [Date: [Session]] = [:]
        for day in days {
            let key = cal.startOfDay(for: day)
            cache[day] = grouped[key] ?? []
        }
        return cache
    }

    static func filterSessions(for day: Date, from sessions: [Session]) -> [Session] {
        let startOfDayUTC = cal.startOfDay(for: day)
        return sessions.filter {
            guard let sessionDate = $0.date else { return false }
            return cal.isDate(sessionDate, inSameDayAs: startOfDayUTC)
        }
    }

    static func scrollToDay(_ date: Date, using proxy: ScrollViewProxy, in days: [Date], calendar: Calendar) {
        // Caller already passes the calendar (you pass the injected UTC one).
        if let targetDay = days.first(where: { calendar.isDate($0, inSameDayAs: date) }) {
            proxy.scrollTo(targetDay, anchor: .center)
        }
    }
}
