import SwiftUI
import Charts
import SwiftData

struct BarChartView: View {
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    @State private var barSelection: Date?
    @Binding var showAnnotations: Bool
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            Chart(sessions) { session in
                
                BarMark(
                    x: .value("Date", session.date ?? Date(), unit: .day),
                    y: .value("Lactate", session.lactate ?? 0),
                    stacking: .standard
                )
                .foregroundStyle(LactateHelper.color(for: session.lactate))
                if showAnnotations {
                    BarMark(
                        x: .value("Date", session.date ?? Date(), unit: .day),
                        y: .value("Lactate", session.lactate ?? 0),
                        stacking: .standard
                    )
                    .foregroundStyle(LactateHelper.color(for: session.lactate))
                    .annotation(position: .overlay, alignment: .center) {
                        Text(LactateHelper.formatLactate(session.lactate ?? 0))
                            .multilineTextAlignment(.center)
                            .font(.system(size: 8))
                            .fontWeight(.bold)
                    }
                }
                    
                
                
                if let barSelection = barSelection {
                    RuleMark(x: .value("Date", barSelection, unit: .day))
                        .foregroundStyle(.gray)
                        .zIndex(-10)
                        .annotation(
                            position: .bottom,
                            spacing: 4,
                            overflowResolution: .init(x: .disabled, y: .disabled)
                        ) {
                            if let session = sessions.first(where: { Calendar.current.isDate($0.date ?? Date(), inSameDayAs: barSelection) }) {
                                VStack {
                                    Text(Date().formatDayMonth(date: session.date))
                                    Text(Date().formatYear(date: session.date))
                                }
                                .font(.system(size: 14))
                                .foregroundStyle(.gray)
                                
                            }
                        }
                }
            }
            .chartXSelection(value: $barSelection)
            .scaledToFit()
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .padding(.horizontal)
        }
    }
    
}

#Preview {
    BarChartView(showAnnotations: .constant(true))
}
