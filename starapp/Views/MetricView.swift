//
//  MetricView.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI

struct MetricView: View {
    @StateObject private var viewModel = MetricViewModel()

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
