import SwiftUI

struct CalendarToolbar: View {
    @Binding var showingSheet: Bool

    var body: some View {
        HStack {
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
                Label("Notifications", systemImage: "calendar")
            }
            Button(action: {
                showingSheet.toggle()
            }) {
                Label("Calendar", systemImage: "plus")
            }
            .sheet(isPresented: $showingSheet) {
                CalendarEventView()
            }
        }
    }
}

#Preview {
    CalendarToolbar(showingSheet: .constant(false))
}
