//
//  IntegrationsView.swift
//  starapp
//
//  Created by Peter Tran on 09/07/2024.
//

import SwiftUI

struct IntegrationsView: View {
    @StateObject private var viewModel = IntegrationsViewModel()

        var body: some View {
            ZStack {
                Color.starBlack.ignoresSafeArea()
                VStack {
                    VStack {
                        HStack {
                            Toggle("Garmin", isOn: $viewModel.yGarminSelected)
                        }
                        .padding()
                        .foregroundColor(.whiteOne)
                        .tint(.green)
                        
                        HStack {
                            Toggle("Suunto", isOn: $viewModel.zSuuntoSelected)
                        }
                        .padding()
                        .foregroundColor(.whiteOne)
                        .tint(.green)
                        
                        HStack {
                            Toggle("Coros", isOn: $viewModel.bCorosSelected)
                        }
                        .padding()
                        .foregroundColor(.whiteOne)
                        .tint(.green)
                        
                        HStack {
                            Toggle("Polar", isOn: $viewModel.cPolarSelected)
                        }
                        .padding()
                        .foregroundColor(.whiteOne)
                        .tint(.green)
                    }
                    .padding()
                    .background(Color.starBlack)
                    .cornerRadius(16)
                    .presentationDetents([.medium])
                }
                .onAppear {
                    viewModel.showingSheet = true
                }
            }
        }
    }
#Preview {
    IntegrationsView()
}
