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
    @Binding var showAnnotations: Bool
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            Chart(sessions) { session in
                
                if showAnnotations {
                    SectorMark(
                        angle: .value("Lactate", session.lactate ?? 0),
                        innerRadius: .ratio(0.6),
                        angularInset: 2
                    )
                    .foregroundStyle(LactateHelper.color(for: session.lactate))
                    .cornerRadius(5)
                    .annotation(position: .overlay, alignment: .center) {
                        Text(LactateHelper.formatLactate(session.lactate ?? 0))
                            .font(.system(size: 8))
                            .multilineTextAlignment(.center)
                            .fontWeight(.bold)
                    }
                   
                } else {
                    
                        SectorMark(
                            angle: .value("Lactate", session.lactate ?? 0),
                            innerRadius: .ratio(0.6),
                            angularInset: 2
                        )
                        .foregroundStyle(LactateHelper.color(for: session.lactate))
                        .cornerRadius(5)
                }
            }
            .scaledToFit()
            .chartLegend(.hidden)
        }
    }
}

#Preview {
    PieChartView(showAnnotations: .constant(true))
}
