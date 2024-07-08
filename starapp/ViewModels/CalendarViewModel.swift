//
//  CalendarViewModel.swift
//  starleet
//
//  Created by Peter Tran on 05/07/2024.
//

import SwiftUI

class CalendarViewModel: ObservableObject {
    @Published var date = Date()
    @Published var days: [Date] = []
    let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    init() {
        updateDates()
    }
    
    func updateDates() {
        days = date.daysInYear
    }
}
