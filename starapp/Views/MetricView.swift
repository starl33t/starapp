//
//  MetricView.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI

struct MetricView: View {
    @AppStorage("showAnnotations") var showAnnotations = true
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                TabView {
                    LineChartView(showAnnotations: $showAnnotations)
                    BarChartView(showAnnotations: $showAnnotations)
                    PieChartView(showAnnotations: $showAnnotations)
                    PointChartView(showAnnotations: $showAnnotations)
                }
                .tabViewStyle(PageTabViewStyle())
            }
        }
    }
}


#Preview {
    MetricView()
}
