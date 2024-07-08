//
//  PointChartView.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI
import Charts

struct PointChartView: View {
    @StateObject private var viewModel = PointChartViewModel()

        var body: some View {
            ZStack {
                Color.starBlack.ignoresSafeArea()
                Chart(viewModel.data) { item in
                    PointMark(
                        x: .value("Category", item.category),
                        y: .value("Value", item.value)
                    )
                    RuleMark(y: .value("Average", 1.5))
                        .foregroundStyle(.gray)
                        .annotation(position: .bottom, alignment: .bottomLeading) {
                            Text("avg. 1.5 mM")
                                .fontWeight(.black)
                                .foregroundStyle(.whiteTwo)
                                .padding(.leading)
                        }
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .frame(height: 500)
            }
        }
    }

#Preview {
    PointChartView()
}
