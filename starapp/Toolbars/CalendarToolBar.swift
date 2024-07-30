import SwiftUI

struct CalendarToolbar: View {
    @Binding var showingSheet: Bool
    var onTodayButtonTapped: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onTodayButtonTapped) {
                Label("Today", systemImage: "calendar.badge.checkmark")
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
    CalendarToolbar(showingSheet: .constant(false), onTodayButtonTapped: {})
}
