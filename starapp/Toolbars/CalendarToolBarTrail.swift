import SwiftUI
import SwiftData

struct CalendarToolbarTrail: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    @Query private var sessions: [Session]
    @State var trainingSheet: Bool = false
    @State private var lactate: Double?
    @State private var date: Date = Date()
    @State private var showDatePicker: Bool = false
    @AppStorage("showTrainingList") var showTrainingList = false
    @State private var isExporting = false
    
    var body: some View {
        HStack {
            Button(action: {
                showTrainingList.toggle()
            }) {
                Label("List", systemImage: showTrainingList ? "square.grid.3x3" : "line.3.horizontal")
            }
            if showTrainingList {
                Button(action: {
                    isExporting = true
                }) {
                    Label("CSV Export", systemImage: "arrow.down.to.line.compact")
                }
            } else {
                Button(action: {
                    showDatePicker = true
                }) {
                    Label("Calendar", systemImage: "calendar")
                }
            }
        }
        .sheet(isPresented: $showDatePicker) {
            datePicker()
                .modifier(CloseButtonModifier(onClose: {showDatePicker = false}))
                .presentationDetents([.fraction(0.3)])
        }
        .fileExporter(
            isPresented: $isExporting,
            document: CSVDocument(sessions: sessions),
            contentType: .commaSeparatedText,
            defaultFilename: "sessions.csv"
        ) { result in
            switch result {
            case .success(let url):
                print("Saved to \(url)")
            case .failure(let error):
                print(error.localizedDescription)
            }
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
        }
    }
}
