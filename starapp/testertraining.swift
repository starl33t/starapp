//
//  testertraining.swift
//  starapp
//
//  Created by Peter Tran on 11/07/2024.
//

import SwiftUI

struct testertraining: View {
    @Environment(\.dismiss) var dismiss
    @State private var heartRate = 0
    @State private var temperature = 0
    @State private var lactateLevel = 0
    @State private var duration = 0
    var body: some View {
        Form{
            TextField("Duration", value: $duration, formatter: NumberFormatter())
                .keyboardType(.numberPad)
            TextField("Duration", value: $heartRate, formatter: NumberFormatter())
                .keyboardType(.numberPad)
            TextField("lactateLevel", value: $lactateLevel, formatter: NumberFormatter())
                .keyboardType(.numberPad)
            TextField("temperature", value: $temperature, formatter: NumberFormatter())
                .keyboardType(.numberPad)
            Button("create"){
                dismiss()
            }
        }
    }
}

#Preview {
    testertraining()
}
