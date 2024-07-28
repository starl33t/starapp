import SwiftUI

struct ChatToolbar: View {
    @Binding var showingSheet: Bool
    
    var body: some View {
        HStack {
            Menu {
                Button(action: {
                    // Action 1
                }) {
                    Text("Maximize my recovery")
                }
                Button(action: {
                    // Action 2
                }) {
                    Text("Make me a recovery plan")
                }
                Button(action: {
                    // Action 3
                }) {
                    Text("Help me with my injuries")
                }
            } label: {
                Label("Recovery", systemImage: "figure.pilates")
            }
            Menu {
                Button(action: {
                    // Action 1
                }) {
                    Text("Optimize my training")
                }
                Button(action: {
                    // Action 2
                }) {
                    Text("Give me a training plan")
                }
                Button(action: {
                    // Action 3
                }) {
                    Text("I want to peak")
                }
            } label: {
                Label("Performance", systemImage: "trophy")
            }
        }
    }
}

#Preview {
    ChatToolbar(showingSheet: .constant(false))
}
