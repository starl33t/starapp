import SwiftUI
import Charts
import SwiftData

struct PointChartView: View {
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            Chart(sessions) { session in
      
                    PointMark(
                        x: .value("Date", session.date ?? Date(), unit: .day),
                        y: .value("Lactate", session.lactate ?? 0)
                    )
                    .foregroundStyle(LactateHelper.color(for: session.lactate))
                
                RuleMark(y: .value("xxx", 1.5))
                    .foregroundStyle(.gray)
            }
            
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .overlay(alignment: .bottomLeading) {
                Text("avg. 1.5 mM")
                    .fontWeight(.black)
                    .foregroundStyle(.whiteTwo)
                    .padding()
            }
            .scaledToFit()
        }
    }
}

#Preview {
    PointChartView()
}
