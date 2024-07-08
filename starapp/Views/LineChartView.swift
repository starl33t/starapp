//
//  LineChartView.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI
import Charts

struct LineChartView: View {
    @StateObject private var viewModel = LineChartViewModel()

       var body: some View {
           ZStack {
               Color.starBlack.ignoresSafeArea()
               Chart(viewModel.data, id: \.category) { item in
                   LineMark(
                       x: .value("Category", item.category),
                       y: .value("Value", item.value)
                   )
                   .interpolationMethod(.cardinal)
                   PointMark(
                       x: .value("Category", item.category),
                       y: .value("Value", item.value)
                   )
               }
               .chartXAxis(.hidden)
               .chartYAxis(.hidden)
               .frame(height: 500)
               Text("2.8 mM")
                   .fontWeight(.black)
                   .foregroundStyle(.whiteTwo)
           }
       }
   }


#Preview {
    LineChartView()
}
