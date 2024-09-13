import Foundation

extension Date {
    //Calendarview
    static var calendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Start week on Monday
        return calendar
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
        return Calendar.current.date(byAdding: .day, value: -27, to: Date())!
    }
    
    //Calendarview's todays date button
    var daySquareIcon: String {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: self)
        return "\(day).square"
    }
    
    //LactateView
    func formattedAsRelative() -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else if let daysAgo = calendar.dateComponents([.day], from: self, to: Date()).day {
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
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
    
    func formatDayMonthLong(date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateFormat = "E dd MMMM"
        return formatter.string(from: date)
    }
    
    func formatYear(date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
    func formatSessionDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy (HH:mm)"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: self)
    }
    
    //Homeview
    func formatAsDayMonthYear() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E dd MMM" // Format: "Mon 02 Feb"
        return dateFormatter.string(from: self)
    }
    
    // Start of current week
    var startOfWeek: Date {
        let components = Date.calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return Date.calendar.date(from: components)!
    }
    
    // End of current week
    var endOfWeek: Date {
        return Date.calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
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
        return Calendar.current.date(byAdding: .day, value: -29, to: Date())!
    }
    
    func startDate(for dateRange: DateRangeOption) -> Date {
            switch dateRange {
            case .thisWeek:
                return self.startOfWeek
            case .thisMonth:
                return self.startOfMonth
            case .thisYear:
                return self.startOfYear
            case .last7Days:
                return self.addingTimeInterval(-7 * 24 * 60 * 60)
            case .last30Days:
                return self.addingTimeInterval(-30 * 24 * 60 * 60)
            case .last365Days:
                return self.addingTimeInterval(-365 * 24 * 60 * 60)
            }
        }
        
        func endDate(for dateRange: DateRangeOption) -> Date {
            switch dateRange {
            case .thisWeek:
                return self.endOfWeek
            case .thisMonth:
                return self.endOfMonth
            case .thisYear:
                return self.endOfYear
            case .last7Days, .last30Days, .last365Days:
                return Date()
            }
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
