//
//  LineChartViewModel.swift
//  starleet
//
//  Created by Peter Tran on 06/07/2024.
//

import SwiftUI

class LineChartViewModel: ObservableObject {
    @Published var data: [ValuePerCategory] = []
    
    init() {
        loadData()
    }
    
    func loadData() {
        // Replace with actual data loading logic
        data = [
            .init(category: "5:00", value: 1),
            .init(category: "4:45", value: 1.5),
            .init(category: "4:30", value: 1.7),
            .init(category: "4:15", value: 1.5),
            .init(category: "4:00", value: 2.0),
            .init(category: "3:45", value: 2.8),
            .init(category: "3:30", value: 7)
        ]
    }
}

struct ValuePerCategory: Identifiable {
    let id = UUID()
    let category: String
    let value: Double
}
