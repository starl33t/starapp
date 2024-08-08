import SwiftUI

struct CalendarToolbar: View {
    @Binding var showDatePicker: Bool
    var onTodayButtonTapped: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onTodayButtonTapped) {
                Image(systemName: Date().daySquareIcon)
            }
            Button(action: {
                showDatePicker.toggle()  // Toggle the binding here
            }) {
                Label("Filter", systemImage: "calendar")
            }
        }
    }
}

#Preview {
    CalendarToolbar(showDatePicker: .constant(false), onTodayButtonTapped: {})
}
