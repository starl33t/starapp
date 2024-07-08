//
//  PieChartView.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI
import Charts

struct PieChartView: View {
    @StateObject private var viewModel = PieChartViewModel()

        var body: some View {
            ZStack {
                Color.starBlack.ignoresSafeArea()
                Chart(viewModel.data) { item in
                    SectorMark(
                        angle: .value("Count", item.count),
                        innerRadius: .ratio(0.6),
                        angularInset: 2
                    )
                    .cornerRadius(5)
                }
                .scaledToFit()
                .chartLegend(.hidden)
            }
        }
    }

#Preview {
    PieChartView()
}
