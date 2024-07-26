import SwiftUI

struct LactateToolbar: View {
    @Binding var showingSheet: Bool
    @State var trainingSheet: Bool = false

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
            .sheet(isPresented: $trainingSheet) {
                NewTrainingView()
            }
        }
    }
}

#Preview {
    LactateToolbar(showingSheet: .constant(false))
}
