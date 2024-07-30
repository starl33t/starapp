//
//  LineChartView.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI
import Charts
import SwiftData

struct LineChartView: View {
    @Query(sort: \Session.lactate, order: .reverse) private var sessions: [Session]
    @Binding var showAnnotations: Bool
    
    var body: some View {
        ZStack {
            Chart(sessions) { session in
                LineMark(
                    x: .value("Lactate", session.lactate ?? 0),
                    y: .value("Lactate", session.lactate ?? 0)
                )
                .foregroundStyle(.whiteOne)
                .interpolationMethod(.cardinal)
                
                PointMark(
                    x: .value("Lactate", session.lactate ?? 0),
                    y: .value("Lactate", session.lactate ?? 0)
                )
                .foregroundStyle(LactateHelper.color(for: session.lactate))
                
                if showAnnotations {
                    LineMark(
                        x: .value("Lactate", session.lactate ?? 0),
                        y: .value("Lactate", session.lactate ?? 0)
                    )
                    .foregroundStyle(.whiteOne)
                    .interpolationMethod(.cardinal)
                    PointMark(
                        x: .value("Lactate", session.lactate ?? 0),
                        y: .value("Lactate", session.lactate ?? 0)
                    )
                    .foregroundStyle(LactateHelper.color(for: session.lactate))
                    .annotation(position: .trailing, alignment: .top) {
                        Text(LactateHelper.formatLactate(session.lactate ?? 0))
                            .font(.system(size: 8))
                            .foregroundStyle(.whiteOne)
                            .fontWeight(.bold)
                    }
                }
            }
            .padding()
            .scaledToFit()
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            
        }
    }
}


#Preview {
    LineChartView(showAnnotations: .constant(true))
}
