//
//  PlotMetricView.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI

struct PlotMetricView: View {
    @StateObject private var viewModel = PlotMetricViewModel()

        var body: some View {
            ZStack {
                Color.starBlack.ignoresSafeArea()
                VStack {
                    VStack {
                        HStack {
                            Toggle("Power", isOn: $viewModel.yValuesSelected)
                        }
                        .padding()
                        .foregroundColor(.whiteOne)
                        
                        HStack {
                            Toggle("Pace", isOn: $viewModel.zValuesSelected)
                        }
                        .padding()
                        .foregroundColor(.whiteOne)
                        
                        HStack {
                            Toggle("Temperature", isOn: $viewModel.bValuesSelected)
                        }
                        .padding()
                        .foregroundColor(.whiteOne)
                        
                        HStack {
                            Toggle("Heart rate", isOn: $viewModel.cValuesSelected)
                        }
                        .padding()
                        .foregroundColor(.whiteOne)
                    }
                    .padding()
                    .background(Color.starBlack)
                    .cornerRadius(16)
                    .presentationDetents([.fraction(0.35)])
                }
                .onAppear {
                    viewModel.showingSheet = true
                }
            }
        }
    }

#Preview {
    PlotMetricView()
}
