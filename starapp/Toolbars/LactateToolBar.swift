import SwiftUI

struct LactateToolbar: View {
    @State var trainingSheet: Bool = false
    @State private var lactate: Double?
    @State private var date: Date = Date()
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    
    var body: some View {
        HStack {
            Menu {
                Button(action: {
                    
                }) {
                    Text("No wearables detected!")
                }
            } label: {
                Label("Notifications", systemImage: "gear")
            }
            Button(action: {
                trainingSheet.toggle()
            }) {
                Label("New Training", systemImage: "plus")
            }
            .sheet(isPresented: $trainingSheet, onDismiss: {
                resetFields()
            }) {
                NewTrainingView(dismiss: {
                    resetFields() 
                    trainingSheet = false
                })
            }
        }
    }
    
    private func NewTrainingView(dismiss: @escaping () -> Void) -> some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                HStack{
                    Text("Lactate")
                        .foregroundStyle(.whiteTwo)
                    Spacer()
                    ZStack(alignment: .leading) {
                        TextField("mM", value: $lactate, formatter: NumberFormatter.customFormatter)
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
        .overlay(
                Button(action: dismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 22))
                        .foregroundStyle(.whiteOne)
                        .padding()
                }
                , alignment: .topLeading
            )
    }
    
    private func resetFields() {
        lactate = nil
        date = Date()
    }
}

#Preview {
    LactateToolbar()
}
