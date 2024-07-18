import SwiftUI

struct LactateToolbar: View {
    @Binding var showingSheet: Bool

    var body: some View {
        HStack {
            Menu {
                Button(action: {
                    // Action 1
                }) {
                    Text("Device coming soon!")
                }
            } label: {
                Label("Notifications", systemImage: "gear")
            }
            Button(action: {
                showingSheet.toggle()
            }) {
                Label("New Training", systemImage: "plus")
            }
            .sheet(isPresented: $showingSheet) {
                NewTrainingView()
            }
        }
    }
}

#Preview {
    LactateToolbar(showingSheet: .constant(false))
}
