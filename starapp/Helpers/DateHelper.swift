import Foundation

extension Date {
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
        static func startOfLast14Days() -> Date {
            return Calendar.current.date(byAdding: .day, value: -13, to: Date())!
        }
    
    static func startOfLast28Days() -> Date {
        return Calendar.current.date(byAdding: .day, value: -27, to: Date())!
    }
    var daySquareIcon: String {
            let calendar = Calendar.current
            let day = calendar.component(.day, from: self)
            return "\(day).square"
        }
    
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

    
    func formatDayMonth(date: Date?) -> String {
            guard let date = date else { return "N/A" }
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
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
    
}
