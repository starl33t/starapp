//
//  PieChartView.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI
import Charts
import SwiftData

struct PieChartView: View {
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]

        var body: some View {
            ZStack {
                Color.starBlack.ignoresSafeArea()
                Chart(sessions) { session in
                    SectorMark(
                        angle: .value("Lactate", session.lactate ?? 0),
                        innerRadius: .ratio(0.6),
                        angularInset: 2
                    )
                    .foregroundStyle(LactateHelper.color(for: session.lactate))
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
