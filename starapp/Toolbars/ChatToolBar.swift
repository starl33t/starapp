import SwiftUI

struct ChatToolbar: View {
    @Binding var showingSheet: Bool

    var body: some View {
        HStack {
            Menu {
                Button(action: {
                    // Action 1
                }) {
                    Text("Group 1")
                }
                Button(action: {
                    // Action 2
                }) {
                    Text("Group 2")
                }
                Button(action: {
                    // Action 3
                }) {
                    Text("Group 3")
                }
            } label: {
                Label("Notifications", systemImage: "rectangle.3.group.bubble.fill")
            }
            
            Button(action: {
                showingSheet.toggle()
            }) {
                Label("Message", systemImage: "square.and.pencil")
            }
            .sheet(isPresented: $showingSheet) {
                NewMessageView()
            }
        }
    }
}

#Preview {
    ChatToolbar(showingSheet: .constant(false))
}
