import SwiftUI
import SwiftData

struct CalendarToolBarTrail: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    @Query private var sessions: [Session]
    @State var trainingSheet: Bool = false
    @State private var lactate: Double?
    @State private var date: Date = Date()
    @State private var showDatePicker: Bool = false
    @AppStorage("showTrainingList") var showTrainingList = false
    @AppStorage("showSpecificTrainingView") var showSpecificTrainingView = false
    @State private var isExporting = false
    
    var body: some View {
        HStack {
            if showSpecificTrainingView {
                HStack{}
            } else {
                Button {
                    showTrainingList.toggle()
                } label: {
                    Image(systemName: showTrainingList ? "square.grid.3x3" : "line.3.horizontal")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.whiteOne)
                        .frame(width: 50, height: 50)
                        .background(Circle().fill(Color.darkOne))
                        .contentShape(Circle())
                }
                if showTrainingList {
                    Button {
                        isExporting = true
                    }  label: {
                        Image(systemName: "arrow.down.to.line.compact")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(isExporting ? .starMain : .whiteOne)
                            .symbolEffect(.bounce, value: isExporting)
                            .frame(width: 50, height: 50) // Matching button size
                            .background(Circle().fill(Color.darkOne))
                            .contentShape(Circle())
                    }
                } else {
                    Button {
                        showDatePicker = true
                    }  label: {
                        Image(systemName: "calendar")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(showDatePicker ? .starMain : .whiteOne)
                            .symbolEffect(.bounce, value: showDatePicker)
                            .frame(width: 50, height: 50) // Matching button size
                            .background(Circle().fill(Color.darkOne))
                            .contentShape(Circle())
                    }
                }
            }
          
            
        }
        .padding(.horizontal, 4)
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
