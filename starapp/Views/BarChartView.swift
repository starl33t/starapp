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
<<<<<<< Updated upstream
=======
                .foregroundStyle(LactateHelper.color(for: session.lactate))
                if showAnnotations {
                    BarMark(
                        x: .value("Date", session.date ?? Date(), unit: .day),
                        y: .value("Lactate", session.lactate ?? 0),
                        stacking: .standard
                    )
                    .foregroundStyle(LactateHelper.color(for: session.lactate))
                    .annotation(position: .overlay, alignment: .center) {
                        Text(LactateHelper.formatLactate(session.lactate ?? 0))
                            .multilineTextAlignment(.center)
                            .font(.system(size: 8))
                            .fontWeight(.bold)
                    }
                }
                
                if let barSelection = barSelection {
                    RuleMark(x: .value("Date", barSelection, unit: .day))
                        .foregroundStyle(.gray)
                        .zIndex(-10)
                        .annotation(
                            position: .bottom,
                            spacing: 4,
                            overflowResolution: .init(x: .disabled, y: .disabled)
                        ) {
                            if let session = sessions.first(where: { Calendar.current.isDate($0.date ?? Date(), inSameDayAs: barSelection) }) {
                                VStack {
                                    Text(Date().formatDayMonth(date: session.date))
                                    Text(Date().formatYear(date: session.date))
                                }
                                .font(.system(size: 14))
                                .foregroundStyle(.gray)
                                
                            }
                        }
                }
>>>>>>> Stashed changes
            }
            .scaledToFit()
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
        }
    }
}

#Preview {
    BarChartView()
}
