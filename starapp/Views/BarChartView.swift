import SwiftUI
import Charts
import SwiftData

struct BarChartView: View {
    @Query private var sessions: [Session]
    
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
            }
            .scaledToFit()
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .padding()
        }
    }
}

#Preview {
 BarChartView()
}
