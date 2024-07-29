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
    @Query(sort: \Session.heartRate, order: .reverse) private var sessions: [Session]

       var body: some View {
           ZStack {
               Color.starBlack.ignoresSafeArea()
               Chart(sessions) { session in
                   LineMark(
                       x: .value("Heart Rate", session.heartRate ?? 0),
                       y: .value("Lactate", session.lactate ?? 0)
                   )
                   .foregroundStyle(.starMain)
                   .interpolationMethod(.cardinal)
                   PointMark(
                       x: .value("Heart Rate", session.heartRate ?? 0),
                       y: .value("Lactate", session.lactate ?? 0)
                   )
                   .foregroundStyle(.whiteOne)
               }
               
               .padding()
               .scaledToFit()
               .chartXAxis(.hidden)
               .chartYAxis(.hidden)
              
           }
       }
   }


#Preview {
    LineChartView()
}
