//
//  TrainingView.swift
//  starapp
//
//  Created by Peter Tran on 12/07/2024.
//

import SwiftUI

struct TrainingView: View {
    @Environment(\.dismiss) private var dismiss
    let session: Session
    @State private var distance: Double?
    @State private var duration: Double?
    @State private var lactate: Double?
    @State private var heartRate: Int?
    @State private var temperature: Double?
    @State private var lapSplits: Int?
    @State private var date: Date = Date.distantPast
    @State private var title: String = ""
    
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.zeroSymbol = ""
        return formatter
    }
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                HStack {
                    ZStack(alignment: .leading) {
                        if title.isEmpty {
                            Text("Title")
                                .foregroundStyle(.gray)
                        }
                        TextField("", text: $title)
                            .foregroundStyle(.whiteTwo)
                    }
                    .padding()
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.whiteTwo, Color.starBlack]),
                            startPoint: .leading,
                            endPoint: .center
                        )
                        .frame(height: 2),
                        alignment: .bottom
                    )
                    ZStack(alignment: .trailing) {
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .foregroundStyle(.whiteTwo)
                            .labelsHidden()
                    }
                }
                HStack {
                    Text("Distance")
                        .foregroundStyle(.whiteTwo)
                    Spacer()
                    ZStack(alignment: .leading) {
                        TextField("Kilometer", value: $distance, formatter: numberFormatter)
                            .keyboardType(.decimalPad)
                            .foregroundStyle(.whiteTwo)
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .frame(maxWidth: 150)
                }
                .padding()
                
                HStack {
                    Text("Duration")
                        .foregroundStyle(.whiteTwo)
                    Spacer()
                    ZStack(alignment: .leading) {
                        TextField("Minutes", value: $duration, formatter: numberFormatter)
                            .keyboardType(.decimalPad)
                            .foregroundStyle(.whiteTwo)
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .frame(maxWidth: 150)
                }
                .padding()
                
                // Lactate
                HStack {
                    Text("Lactate")
                        .foregroundStyle(.whiteTwo)
                    Spacer()
                    ZStack(alignment: .leading) {
                        TextField("mM", value: $lactate, formatter: numberFormatter)
                            .keyboardType(.decimalPad)
                            .foregroundStyle(.whiteTwo)
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .frame(maxWidth: 150)
                }
                .padding()
                
                HStack {
                    Text("Heart Rate")
                        .foregroundStyle(.whiteTwo)
                    Spacer()
                    ZStack(alignment: .leading) {
                        TextField("BPM", value: $heartRate, formatter: numberFormatter)
                            .keyboardType(.numberPad)
                            .foregroundStyle(.whiteTwo)
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .frame(maxWidth: 150)
                }
                .padding()
                
                HStack {
                    Text("Temperature")
                        .foregroundStyle(.whiteTwo)
                    Spacer()
                    ZStack(alignment: .leading) {
                        TextField("°C", value: $temperature, formatter: numberFormatter)
                            .keyboardType(.decimalPad)
                            .foregroundStyle(.whiteTwo)
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .frame(maxWidth: 150) // Adjust the width as needed
                }
                .padding()
                
                if changed {
                    Button("Save") {
                        // Assuming session is a class and these properties are mutable
                        session.date = date
                        session.title = title
                        session.distance = distance
                        session.duration = duration
                        session.lactate = lactate
                        session.heartRate = heartRate
                        session.temperature = temperature
                        dismiss()
                    }
                    .foregroundColor(.starMain)
                    .padding()
                }
            }
            .background(Color.starBlack)
            .padding()
            .presentationDetents([.large])
            .onAppear {
                date = session.date ?? Date()
                title = session.title ?? ""
                distance = session.distance
                duration = session.duration
                lactate = session.lactate
                heartRate = session.heartRate
                temperature = session.temperature
            }
        }
    }
    
    var changed: Bool {
        (date != session.date ?? Date())
        || title != session.title ?? ""
        || distance != session.distance
        || duration != session.duration
        || lactate != session.lactate
        || heartRate != session.heartRate
        || temperature != session.temperature
    }
}

#Preview {
    TrainingView(session: Session(distance: nil, duration: nil, heartRate: nil, temperature: nil,lactate: nil, date: Date(), title: ""))
}
