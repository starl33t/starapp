import SwiftUI

struct NewTrainingView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
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
                    .frame(maxWidth: 150) 
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
                    .frame(maxWidth: 150) 
                }
                .padding()
                
                Button("Save") {
                    let newSession = Session(
                        duration: duration ?? 0.0,
                        lactate: lactate ?? 0.0,
                        date: Date()
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
