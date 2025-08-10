import Foundation


extension TimeZone {
    static let utc = TimeZone(secondsFromGMT: 0)!
}

extension Calendar {
    static var iso8601UTC: Calendar {
        var cal = Calendar(identifier: .iso8601)
        cal.timeZone = .utc
        cal.firstWeekday = 2 // Monday
        return cal
    }
}


extension Date {
    //Calendarview
    static var calendar: Calendar {
        Calendar.iso8601UTC  // <<< was Calendar.current + Monday
    }

    var startOfYear: Date {
        let components = Date.calendar.dateComponents([.year], from: self)
        return Date.calendar.date(from: components)!
    }
    
    var endOfYear: Date {
        let components = DateComponents(year: 1, day: -1)
        return Date.calendar.date(byAdding: components, to: startOfYear)!
    }
    
    var daysInYear: [Date] {
        var days: [Date] = []
        var current = startOfYear
        
        // Add leading days to align the first day of the year
        let firstDayOfWeek = Date.calendar.component(.weekday, from: startOfYear)
        let leadingDays = (firstDayOfWeek - Date.calendar.firstWeekday + 7) % 7
        for _ in 0..<leadingDays {
            current = Date.calendar.date(byAdding: .day, value: -1, to: current)!
            days.insert(current, at: 0)
        }
        
        // Reset current to the start of the year
        current = startOfYear
        while current <= endOfYear {
            days.append(current)
            current = Date.calendar.date(byAdding: .day, value: 1, to: current)!
        }
        
        // Add trailing days to complete the last week
        let trailingDays = (7 - days.count % 7) % 7
        if trailingDays < 7 {
            for _ in 0..<trailingDays {
                days.append(current)
                current = Date.calendar.date(byAdding: .day, value: 1, to: current)!
            }
        }
        return days
    }
    
    //last month in MetricView
    static func startOfLast28Days() -> Date {
        Calendar.iso8601UTC.date(byAdding: .day, value: -27, to: Date())!
    }
    
    //Calendarview's todays date button
    var daySquareIcon: String {
        let day = Calendar.iso8601UTC.component(.day, from: self)
        return "\(day).square"
    }
    
    //LactateView
    // LactateView
    func formattedAsRelative() -> String {
        let calendar = Calendar.iso8601UTC
        let now = Date()
        if calendar.isDate(self, inSameDayAs: now) {
            return "Today"
        } else if calendar.isDate(self, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: now)!) {
            return "Yesterday"
        } else if let daysAgo = calendar.dateComponents([.day], from: self, to: now).day {
            if daysAgo < 31 {
                return "\(daysAgo) days ago"
            } else if daysAgo >= 365 {
                return ">1 year ago"
            } else {
                return "\(daysAgo) days ago"
            }
        } else {
            return "N/A"
        }
    }
    
    //CalendarView
    func formatDayMonth(date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let f = DateFormatter()
        f.timeZone = .utc            // <<< KEY
        f.dateFormat = "d MMM"
        return f.string(from: date)
    }
    
    func formatDayMonthLong(date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let f = DateFormatter()
        f.timeZone = .utc            // <<< KEY
        f.dateFormat = "E dd MMM"
        return f.string(from: date)
    }
    
    func formatYear(date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let f = DateFormatter()
        f.timeZone = .utc            // <<< KEY
        f.dateFormat = "yyyy"
        return f.string(from: date)
    }
    
    func formatSessionDate() -> String {
        let f = DateFormatter()
        f.timeZone = .utc            // <<< was .current
        f.dateFormat = "d MMM yyyy (HH:mm)"
        return f.string(from: self)
    }
    
    //Homeview
    func formatAsDayMonthYear() -> String {
        let f = DateFormatter()
        f.timeZone = .utc
        f.dateFormat = "E dd MMM"
        return f.string(from: self)
    }

    
    // Start of current week
    var startOfWeek: Date {
        let components = Date.calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return Date.calendar.date(from: components)!
    }
    
    // End of current week
    var endOfWeek: Date {
        return Date.calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
    }
    
    // Start of current month
    var startOfMonth: Date {
        let components = Date.calendar.dateComponents([.year, .month], from: self)
        return Date.calendar.date(from: components)!
    }
    
    // End of current month
    var endOfMonth: Date {
        let startOfNextMonth = Date.calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        return Date.calendar.date(byAdding: .day, value: -1, to: startOfNextMonth)!
    }
    
    // Last 30 days
    static func startOfLast30Days() -> Date {
        Calendar.iso8601UTC.date(byAdding: .day, value: -29, to: Date())!
    }
    
    // DateRangeOption boundaries
    func startDate(for dateRange: DateRangeOption) -> Date {
        let cal = Calendar.iso8601UTC
        switch dateRange {
        case .thisWeek:   return self.startOfWeek
        case .thisMonth:  return self.startOfMonth
        case .thisYear:   return self.startOfYear
        case .last7Days:  return cal.date(byAdding: .day, value: -7, to: self)!
        case .last30Days: return cal.date(byAdding: .day, value: -30, to: self)!
        case .last365Days:return cal.date(byAdding: .day, value: -365, to: self)!
        }
    }

    func endDate(for dateRange: DateRangeOption) -> Date {
        switch dateRange {
        case .thisWeek:   return self.endOfWeek
        case .thisMonth:  return self.endOfMonth
        case .thisYear:   return self.endOfYear
        case .last7Days, .last30Days, .last365Days:
            return Date() // `Date()` is an instant; comparisons use UTC via Calendar.iso8601UTC
        }
    }
    
    // HomeView tooltip: HH:mm format
    func formatAsHourMinute() -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .utc            // <<< was .current
        f.dateFormat = "HH:mm"
        return f.string(from: self)
    }
}

enum DateRangeOption: String, CaseIterable {
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    case thisYear = "This Year"
    case last7Days = "Last 7 Days"
    case last30Days = "Last 30 Days"
    case last365Days = "Last 365 Days"
    
    var displayText: String {
        switch self {
        case .thisWeek:
            return "This Week"
        case .thisMonth:
            return "This Month"
        case .thisYear:
            return "This Year"
        case .last7Days:
            return "Last 7 Days"
        case .last30Days:
            return "Last 30 Days"
        case .last365Days:
            return "Last 365 Days"
        }
    }
}
