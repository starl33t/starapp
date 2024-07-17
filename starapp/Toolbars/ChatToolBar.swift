import SwiftUI

struct ChatToolbar: View {
    @Binding var showingSheet: Bool

    var body: some View {
        HStack {
            Button(action: {
                showingSheet.toggle()
            }) {
                Label("AI", systemImage: "brain.head.profile")
            }
            .sheet(isPresented: $showingSheet) {

            }
            
            Button(action: {
                showingSheet.toggle()
            }) {
                Label("Group", systemImage: "bubble.left.and.text.bubble.right")
            }
            .sheet(isPresented: $showingSheet) {

            }
        }
    }
}

#Preview {
    ChatToolbar(showingSheet: .constant(false))
}
