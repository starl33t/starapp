//
//  NewTrainingView.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI

struct NewTrainingView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    @State private var distance: Double = 0.0
    @State private var duration: Double = 0.0
    @State private var lactate: Double = 0.0
    @State private var heartRate: Int = 0
    //@StateObject private var viewModel = NewTrainingViewModel()
        
        var body: some View {
            ZStack {
                Color.starBlack.ignoresSafeArea()
                VStack {
                    ZStack(alignment: .leading) {
                        TextField("Distance", value: $distance, formatter: NumberFormatter())
                            .foregroundColor(.white)
                            .keyboardType(.numberPad)
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    
                    // Duration
                    ZStack(alignment: .leading) {
                        TextField("Duration", value: $duration, formatter: NumberFormatter())
                            .foregroundColor(.white)
                            .keyboardType(.numberPad)
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    
                    // Lactate
                    ZStack(alignment: .leading) {
                        TextField("Lactate", value: $lactate, formatter: NumberFormatter())
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
                    Button("Save") {
                        let newSession = Session(
                            distance: distance,
                            duration: duration,
                            heartRate: heartRate,
                            lactate: lactate
                        )
                        context.insert(newSession)
                        dismiss()
                    }
                    .padding()
                }
                .background(Color.starBlack)
                .padding()
                .presentationDetents([.medium])
            }
        }
    }

#Preview {
    NewTrainingView()
}
