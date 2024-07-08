//
//  BarChartView.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI
import Charts

struct BarChartView: View {
    @StateObject private var viewModel = BarChartViewModel()
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            Chart(viewModel.data) { item in
                BarMark(
                    x: .value("Category", item.category),
                    y: .value("Value", item.value)
                )
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 500)
        }
    }
}

#Preview {
    BarChartView()
}
