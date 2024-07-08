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
                    .frame(height: 600)
                    .tabViewStyle(PageTabViewStyle())
                    
                    ForEach(viewModel.metrics) { metric in
                        VStack {
                            HStack(spacing: 16) {
                                Image(systemName: "1.circle")
                                    .font(.system(size: 38))
                                    .padding(8)
                                    .foregroundStyle(.starMain)
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("\(metric.minutes) min")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundStyle(.whiteTwo)
                                    }
                                    HStack {
                                        Text("\(metric.heartRate)")
                                        Image(systemName: "heart.fill")
                                        Text(" | ")
                                        Text("\(metric.temperature, specifier: "%.1f")°C")
                                    }
                                    .font(.system(size: 14))
                                    .foregroundStyle(.gray)
                                }
                                .foregroundStyle(.whiteOne)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                Text("\(metric.lactateLevel, specifier: "%.2f") mM")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundStyle(.starMain)
                            }
                            Divider()
                                .padding(.vertical, 8)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }


#Preview {
    MetricView()
}
