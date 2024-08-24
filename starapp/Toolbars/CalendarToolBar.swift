import SwiftUI

struct CalendarToolbar: View {
    @EnvironmentObject var appState: AppState
    @State private var showDatePicker: Bool = false
    
    var body: some View {
        HStack {
            Button(action: {
                let today = Date()
                appState.selectedDate = today
                appState.days = today.daysInYear
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
                DatePicker("Select Date", selection: $appState.selectedDate, in: dateRange, displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .environment(\.colorScheme, .dark)
            }
            .frame(maxWidth: .infinity)
            
        }
    }
}
