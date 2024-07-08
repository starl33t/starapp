//
//  NewTrainingView.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI

struct NewTrainingView: View {
    @StateObject private var viewModel = NewTrainingViewModel()
        
        var body: some View {
            ZStack {
                Color.starBlack.ignoresSafeArea()
                VStack {
                    ZStack(alignment: .leading) {
                        if viewModel.distanceInMeters.isEmpty {
                            Text("Distance (m)")
                                .foregroundColor(.gray)
                        }
                        TextField("", text: $viewModel.distanceInMeters)
                            .foregroundColor(.white)
                            .keyboardType(.numberPad)
                    }
                    .padding()
                    .background(Color.starBlack)
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    
                    // Duration
                    ZStack(alignment: .leading) {
                        if viewModel.duration.isEmpty {
                            Text("Duration")
                                .foregroundColor(.gray)
                        }
                        TextField("", text: $viewModel.duration)
                            .foregroundColor(.white)
                            .keyboardType(.numberPad)
                    }
                    .padding()
                    .background(Color.starBlack)
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    
                    // Lactate
                    ZStack(alignment: .leading) {
                        if viewModel.lactateLevel.isEmpty {
                            Text("Lactate")
                                .foregroundColor(.gray)
                        }
                        TextField("", text: $viewModel.lactateLevel)
                            .foregroundColor(.white)
                            .keyboardType(.decimalPad)
                    }
                    .padding()
                    .background(Color.starBlack)
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    Button(action: {
                        viewModel.saveForm()
                    }) {
                        Text("Save")
                            .foregroundColor(.starMain)
                    }
                    .padding()
                }
                .background(Color.starBlack)
                .padding()
                .presentationDetents([.fraction(0.40)])
            }
        }
    }

#Preview {
    NewTrainingView()
}
