import SwiftUI

struct NewTrainingView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    @State private var distance: Double?
    @State private var duration: Double?
    @State private var lactate: Double?
    @State private var date: Date = Date()
    
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
                HStack{
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
                
                // Duration
                HStack{
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
                    .frame(maxWidth: 150) // Adjust the width as needed
                }
                .padding()
                
                // Lactate
                HStack{
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
                    .frame(maxWidth: 150) // Adjust the width as needed
                }
                .padding()
                
                Button("Save") {
                    let newSession = Session(
                        distance: distance ?? 0.0,
                        duration: duration ?? 0.0,
                        lactate: lactate ?? 0.0,
                        date: date
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
