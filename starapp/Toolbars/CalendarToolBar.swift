import SwiftUI

struct CalendarToolbar: View {
    @Binding var showDatePicker: Bool
    @Binding var selectedDate: Date
    var onTodayButtonTapped: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onTodayButtonTapped) {
                Image(systemName: Date().daySquareIcon)
            }
            Button(action: {
                showDatePicker = true  // Set showDatePicker to true to show the sheet
            }) {
                Label("Calendar", systemImage: "calendar")
            }
        }
        .sheet(isPresented: $showDatePicker) {
            datePicker()
                .presentationDetents([.fraction(0.3)])
        }
    }

    private func datePicker() -> some View {
            ZStack {
                Color.starBlack.ignoresSafeArea()
                VStack {
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .environment(\.colorScheme, .dark)
                }
                .frame(maxWidth: .infinity)
              
            }
    }
}

#Preview {
    CalendarToolbar(showDatePicker: .constant(false), selectedDate: .constant(Date()), onTodayButtonTapped: {})
}
