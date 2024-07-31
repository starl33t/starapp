import SwiftUI
import Charts
import SwiftData

struct PointChartView: View {
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    @Binding var showAnnotations: Bool
    
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            Chart(sessions) { session in
                    PointMark(
                        x: .value("Date", session.date ?? Date(), unit: .day),
                        y: .value("Lactate", session.lactate ?? 0)
                    )
                    .foregroundStyle(LactateHelper.color(for: session.lactate))
                
                if showAnnotations {
                    PointMark(
                        x: .value("Date", session.date ?? Date(), unit: .day),
                        y: .value("Lactate", session.lactate ?? 0)
                    )
                    .foregroundStyle(LactateHelper.color(for: session.lactate))
                    .annotation(position: .trailing, alignment: .center) {
                        Text(LactateHelper.formatLactate(session.lactate ?? 0))
                            .font(.system(size: 8))
                            .foregroundStyle(.whiteOne)
                            .fontWeight(.bold)
                    }
                }
                
            }
            
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .scaledToFit()
        }
    }
}

#Preview {
    PointChartView(showAnnotations: .constant(true))
}
