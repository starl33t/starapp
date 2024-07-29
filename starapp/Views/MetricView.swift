//
//  MetricView.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI

struct MetricView: View {

        var body: some View {
            ZStack {
                Color.starBlack.ignoresSafeArea()
                VStack {
                    TabView {
                        LineChartView()
                        BarChartView()
                        PieChartView()
                        PointChartView()
                    }
                    .tabViewStyle(PageTabViewStyle())
                }
            }
        }
    }


#Preview {
    MetricView()
}
