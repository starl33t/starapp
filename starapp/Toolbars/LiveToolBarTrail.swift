import SwiftUI
import MapKit

struct LiveToolbarTrail: View {
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
        }
    }
}
