import SwiftUI
import SwiftData
import Charts

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var viewModel: MessageHelper
    @Environment(\.modelContext) private var context
    @AppStorage("isprofileSelected") private var isprofileSelected = false
    @AppStorage("isChatSelected") private var isChatSelected = false
    @AppStorage("Adc") private var adc: Int = 0
    @AppStorage("Current") private var current: Double = 0.0
    @AppStorage("Lactate") private var lactate: Double = 0.0
    @AppStorage("uidString") private var uidString: String = ""
    @AppStorage("Research") var researchToggle: Bool = false
    @State private var selectedTime: Double?

    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                scanGuide()
                dataDisplay()
            }
            .onChange(of: uidString) {
                if !appState.research {
                    createNewTrainingSession()
                }
            }
            .onAppear{
                isChatSelected = false
            }
            if isprofileSelected {
                VStack {
                    ZStack(alignment: .top) {
                        Color.starBlack.opacity(0.98).ignoresSafeArea()
                            .frame(height: 305)
                    }
                    Spacer()
                }
                .transition(.move(edge: .top))
                .animation(.easeInOut(duration: 0.3), value: isprofileSelected)
                
            }
        }
        .onTapGesture {
            isprofileSelected = false
        }
    }
    
    //New training session whenever a new lactate values
    private func createNewTrainingSession() {
        let newSession = Session(
            lactate: lactate,
            date: Date(),
            uidString: uidString,
            adc: adc,
            current: current
        )
        context.insert(newSession)
    }
    
    @ViewBuilder
    private func dataDisplay() -> some View {
        let tooltipCurrent: Double? = {
            if let selected = selectedTime,
               let point = closestDataPoint(to: selected) {
                return point.current
            }
            return nil
        }()

        if researchToggle {
            Text("Current: \((tooltipCurrent ?? lactate), specifier: "%.1f") µA")
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(.whiteOne)
                .padding(.top, 52)
        } else {
            Text("Lactate: \(lactate, specifier: "%.1f") mM")
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(.whiteOne)
                .padding(.top, 52)
        }
        
        if !researchToggle {
            Text(LactateHelper.intensity(for: lactate).rawValue)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.darkTwo)
        }
        
        if appState.research && !appState.currentScanValues.isEmpty {
                Chart {
                    ForEach(appState.currentScanValues, id: \.time) { dataPoint in
                        LineMark(
                            x: .value("Time (s)", dataPoint.time),
                            y: .value("Current (µA)", dataPoint.current)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(.starMain)
                    }

                    // ✅ Tooltip marker + label
                    if let selected = selectedTime,
                       let point = closestDataPoint(to: selected) {

                        RuleMark(x: .value("Selected", selected))
                            .foregroundStyle(.white.opacity(0.4))

                        PointMark(
                            x: .value("Time", point.time),
                            y: .value("Current", point.current)
                        )
                        .symbolSize(30)
                        .foregroundStyle(.white)
                        .annotation(position: .top) {
                            Text("\(point.time.formatted(.number.precision(.fractionLength(1)))) s")
                                .font(.caption2)
                                .padding(4)
                                .background(Color.black.opacity(0.75))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(position: .bottom, values: .automatic(desiredCount: 6)) { value in
                        AxisTick()
                        AxisValueLabel() {
                            if let seconds = value.as(Double.self) {
                                Text("\(seconds, specifier: "%.1f") s")
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let current = value.as(Double.self) {
                                Text("\(Int(current)) µA")
                            }
                        }
                    }
                }
                .chartXSelection(value: $selectedTime) // ✅ track finger
                .chartXScale(
                    domain: 0.0...((appState.currentScanValues.last?.time ?? 1) + 2)
                )
                .chartYScale(domain: paddedYRange(for: appState.currentScanValues.map(\.current)))
                .frame(height: 180)
        }
        Spacer()
    }
    
    func closestDataPoint(to time: Double) -> (time: Double, current: Double)? {
        appState.currentScanValues.min(by: {
            abs($0.time - time) < abs($1.time - time)
        })
    }

    @ViewBuilder
    private func scanGuide() -> some View {
        HStack {
            Image(systemName: "wave.3.up")
                .font(.system(size: 84, weight: .light))
                .foregroundStyle(appState.isScanning ? .starMain : .whiteOne)
                .symbolEffect(.variableColor.cumulative.dimInactiveLayers, isActive: appState.isScanning)
                .opacity(appState.isScanning ? 1.0 : 0.05)
                .scaleEffect(appState.isScanning ? 1.30 : 1.0)
                .animation(.easeInOut(duration: 1.5), value: appState.isScanning)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}


