//
//  CalendarScroll.swift
//  starapp
//
//  Created by Peter Tran on 21/07/2024.
//

import SwiftUI

struct CalendarScroll {
    static func scrollToDate(date: Date, proxy: ScrollViewProxy?, days: [Date], isScrollingToDate: Binding<Bool>, updateVisibleDate: @escaping (Date) -> Void) {
        if let proxy = proxy {
            isScrollingToDate.wrappedValue = true
            if let selectedIndex = days.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
                let selectedDate = days[selectedIndex]
                proxy.scrollTo(selectedDate, anchor: .center)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isScrollingToDate.wrappedValue = false
                updateVisibleDate(date)
            }
        }
    }

    static func updateVisibleDate(day: Date, midY: CGFloat? = nil, middleY: CGFloat = UIScreen.main.bounds.height / 2, days: [Date], date: Date, proxy: ScrollViewProxy? = nil, updateDateIfNeeded: @escaping (Date) -> Void) {
        if let midY = midY {
            if abs(midY - middleY) < 35 {
                if date != day {
                    updateDateIfNeeded(day)
                }
            }
        } else {
            for day in days {
                if Calendar.current.isDate(day, inSameDayAs: date) {
                    if let proxy = proxy {
                        proxy.scrollTo(day, anchor: .center)
                        break
                    }
                }
            }
        }
    }

    static func handleDatePickerChange(_ newDate: Date, proxy: ScrollViewProxy?, updateDates: @escaping () -> Void, days: [Date], isScrollingToDate: Binding<Bool>, updateVisibleDate: @escaping (Date) -> Void) {
        updateDates()
        scrollToDate(date: newDate, proxy: proxy, days: days, isScrollingToDate: isScrollingToDate, updateVisibleDate: updateVisibleDate)
    }

    static func updateDateIfNeeded(to newDate: Date, date: Binding<Date>) {
        if !Calendar.current.isDate(date.wrappedValue, inSameDayAs: newDate) {
            date.wrappedValue = newDate
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
