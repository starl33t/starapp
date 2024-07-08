//
//  PieChartViewModel.swift
//  starleet
//
//  Created by Peter Tran on 06/07/2024.
//

import SwiftUI

class PieChartViewModel: ObservableObject {
    @Published var data: [PostCount] = []
    
    init() {
        loadData()
    }
    
    func loadData() {
        // Replace with actual data loading logic
        data = [
            .init(category: "Xcode", count: 79),
            .init(category: "Swift", count: 73),
            .init(category: "SwiftUI", count: 58),
            .init(category: "WWDC", count: 15),
            .init(category: "SwiftData", count: 9)
        ]
    }
}

struct PostCount: Identifiable {
    let id = UUID()
    var category: String
    var count: Int
}
