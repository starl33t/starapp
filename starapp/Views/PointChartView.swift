//
//  PointChartView.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI
import Charts

struct PointChartView: View {
<<<<<<< Updated upstream
    @StateObject private var viewModel = PointChartViewModel()

        var body: some View {
            ZStack {
                Color.starBlack.ignoresSafeArea()
                Chart(viewModel.data) { item in
=======
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            Chart(sessions) { session in
      
>>>>>>> Stashed changes
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
                .scaledToFit()
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
            }
        }
    }

#Preview {
    PointChartView()
}
