//
//  CalendarHelper.swift
//  starapp
//
//  Created by Peter Tran on 30/07/2024.
//

import Foundation
import SwiftUI

struct CalendarHelper {
    static func resetToToday(selectedDate: Binding<Date>, date: Binding<Date>, days: Binding<[Date]>) {
        let today = Date()
        selectedDate.wrappedValue = today
        date.wrappedValue = today
        days.wrappedValue = today.daysInYear
    }
}



