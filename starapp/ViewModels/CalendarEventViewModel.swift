//
//  CalendarEventViewModel.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI

class CalendarEventViewModel: ObservableObject {
    @Published var showingForm: Bool = false
    @Published var selectedDate: Date = Date()
    @Published var distanceInMeters: String = ""
    @Published var duration: String = ""
    @Published var lactateLevel: String = ""
    
    func saveForm() {
        // Add logic to save the form
        showingForm = false
    }
}
