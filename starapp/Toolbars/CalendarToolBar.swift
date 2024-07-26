import SwiftUI

struct CalendarToolbar: View {
    @Binding var showingSheet: Bool

    var body: some View {
        HStack {
            Button(action: {
            }) {
                Label("Search", systemImage: "magnifyingglass")
            }
            Menu {
                Button(action: {
                    // Action 1
                }) {
                    Text("Today")
                }
                Button(action: {
                    // Action 2
                }) {
                    Text("Month")
                }
                Button(action: {
                    // Action 3
                }) {
                    Text("Date")
                }
            } label: {
                Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
            }
       
        }
    }
}

#Preview {
    CalendarToolbar(showingSheet: .constant(false))
}
