//
//  LactateViewModel.swift
//  starleet
//
//  Created by Peter Tran on 06/07/2024.
//

import SwiftUI

class LactateViewModel: ObservableObject {
    @Published var lactateEntries: [LactateEntry] = []
    
    init() {
        loadLactateEntries()
    }
    
    func loadLactateEntries() {
        // Replace with actual data loading logic
        lactateEntries = (0..<10).map { _ in
            LactateEntry(minutes: 10, heartRate: 150, temperature: 38, lactateLevel: 2)
        }
    }
}

struct LactateEntry: Identifiable {
    let id = UUID()
    let minutes: Int
    let heartRate: Int
    let temperature: Double
    let lactateLevel: Double
}
