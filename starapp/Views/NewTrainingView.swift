import SwiftUI

struct NewTrainingView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    @State private var distance: Double?
    @State private var duration: Double?
    @State private var lactate: Double?
    
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
                // Distance
                ZStack(alignment: .leading) {
                    if distance == nil {
                        Text("Distance (m)")
                            .foregroundColor(.gray)
                            .padding(.leading, 5)
                    }
                    TextField("", value: $distance, formatter: numberFormatter)
                        .foregroundColor(.white)
                        .keyboardType(.decimalPad)
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 1)
                )
                
                // Duration
                ZStack(alignment: .leading) {
                    if duration == nil {
                        Text("Duration")
                            .foregroundColor(.gray)
                            .padding(.leading, 5)
                    }
                    TextField("", value: $duration, formatter: numberFormatter)
                        .foregroundColor(.white)
                        .keyboardType(.decimalPad)
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 1)
                )
                
                // Lactate
                ZStack(alignment: .leading) {
                    if lactate == nil {
                        Text("Lactate")
                            .foregroundColor(.gray)
                            .padding(.leading, 5)
                    }
                    TextField("", value: $lactate, formatter: numberFormatter)
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
                        distance: distance ?? 0.0,
                        duration: duration ?? 0.0,
                        lactate: lactate ?? 0.0
                    )
                    context.insert(newSession)
                    dismiss()
                }
                .foregroundColor(.starMain)
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
