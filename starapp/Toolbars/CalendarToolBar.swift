import SwiftUI

struct CalendarToolbar: View {
    @State private var showDatePicker: Bool = false
    @Binding var selectedDate: Date
    
    var body: some View {
        HStack {
            Button(action: {
                selectedDate = Date()
            }) {
                Image(systemName: Date().daySquareIcon)
            }
            Button(action: {
                showDatePicker = true
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
        let dateRange: ClosedRange<Date> = {
            let calendar = Calendar.current
            let startComponents = DateComponents(year: 2024, month: 1, day: 1)
            let endComponents = DateComponents(year: 2024, month: 12, day: 31, hour: 23, minute: 59, second: 59)
            return calendar.date(from:startComponents)!
            ...
            calendar.date(from:endComponents)!
        }()
        return ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                DatePicker("Select Date", selection: $selectedDate, in: dateRange, displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .environment(\.colorScheme, .dark)
            }
            .frame(maxWidth: .infinity)
            
        }
    }
}
