//
//  PieChartView.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI
import Charts

struct PieChartView: View {
<<<<<<< Updated upstream
    @StateObject private var viewModel = PieChartViewModel()

        var body: some View {
            ZStack {
                Color.starBlack.ignoresSafeArea()
                Chart(viewModel.data) { item in
=======
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    @Binding var showAnnotations: Bool
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            Chart(sessions) { session in
                
                if showAnnotations {
>>>>>>> Stashed changes
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
