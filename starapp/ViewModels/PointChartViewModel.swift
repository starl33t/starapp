//
//  PointChartViewModel.swift
//  starleet
//
//  Created by Peter Tran on 06/07/2024.
//

import SwiftUI

class PointChartViewModel: ObservableObject {
    @Published var data: [ValuePerCategoryLineChart] = []
    
    init() {
        loadData()
    }
    
    func loadData() {
        // Replace with actual data loading logic
        data = [
            .init(category: "Week 1", value: 1),
            .init(category: "Week 2", value: 1.5),
            .init(category: "Week 3", value: 1.7),
            .init(category: "Week 4", value: 2.0)
        ]
    }
}

struct ValuePerCategoryLineChart: Identifiable {
    let id = UUID()
    let category: String
    let value: Double
}
