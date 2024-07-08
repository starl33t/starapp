//
//  MetricViewModel.swift
//  starleet
//
//  Created by Peter Tran on 06/07/2024.
//

import SwiftUI

class MetricViewModel: ObservableObject {
    @Published var metrics: [Metric] = []
    
    init() {
        loadMetrics()
    }
    
    func loadMetrics() {
        // Replace with actual data loading logic
        metrics = [Metric(minutes: 10, heartRate: 150, temperature: 38.0, lactateLevel: 10.1234)]
    }
}

struct Metric: Identifiable {
    let id = UUID()
    let minutes: Int
    let heartRate: Int
    let temperature: Double
    let lactateLevel: Double
}
