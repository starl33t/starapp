import SwiftUI
import Charts

struct PointChartView: View {
    @StateObject private var viewModel = PointChartViewModel()

    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            Chart {
                ForEach(viewModel.data) { item in
                    PointMark(
                        x: .value("Category", item.category),
                        y: .value("Value", item.value)
                    )
                }
                RuleMark(y: .value("Average", 1.5))
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
