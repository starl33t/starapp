import SwiftUI
import SwiftData
import Charts

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var viewModel: MessageHelper
    @Environment(\.modelContext) private var context
    @AppStorage("isChatSelected") private var isChatSelected = false
    @AppStorage("isprofileSelected") private var isprofileSelected = false
    @AppStorage("Adc") private var adc: Int = 0
    @AppStorage("Current") private var current: Double = 0.0
    @AppStorage("Lactate") private var lactate: Double = 0.0
    @AppStorage("uidString") private var uidString: String = ""
    
    // Research (current/time) selection
    @State private var selectedTime: Double?
    
    // Lactate selection on numeric time axis
    @State private var selectedLactateIndex: Double?
    
    
    // Latest-first sessions from SwiftData
    @Query(sort: \Session.date, order: .reverse)
    private var sessions: [Session]
    
    
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
            .onAppear {
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
        .onChange(of: appState.research) {
            if !appState.research {
                selectedTime = nil
                selectedLactateIndex = nil
            }
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
        try? context.save()
    }
    
    // MARK: - Lactate series: latest 20 sessions → chronological → seconds since first
    private var lactateSeries20Indexed: [(i: Int, date: Date, lactate: Double)] {
        let latest20Chrono = sessions
            .prefix(20)
            .compactMap { s -> (Date, Double)? in
                guard let d = s.date, let l = s.lactate else { return nil }
                return (d, l)
            }
            .reversed() // chronological

        return latest20Chrono.enumerated().map { (idx, pair) in
            (i: idx, date: pair.0, lactate: pair.1)
        }
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

        let tooltipLactate: Double? = {
            if let sel = selectedLactateIndex,
               let p = closestLactatePoint(index: sel) {
                return p.lactate
            }
            return nil
        }()

        let latestLactateFromSessions = lactateSeries20Indexed.last?.lactate
        let displayLactate = tooltipLactate ?? latestLactateFromSessions ?? 0

        // NEW: last research current from the persisted trace
        let lastResearchCurrent = appState.currentScanValues.last?.current

        // Peak current (research trace) — use abs() if you want absolute peak instead
        let peakResearchCurrent: Double = appState.currentScanValues.map(\.current).max() ?? 0
        
        // Header
        if appState.research {
            let displayCurrent = tooltipCurrent ?? lastResearchCurrent ?? 0
            Text("Current: \(displayCurrent, specifier: "%.1f") µA")
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(.whiteOne)
                .padding(.top, 52)

            Text("Peak: \(peakResearchCurrent, specifier: "%.1f") µA")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.darkTwo)
        } else {
            Text("Lactate: \(displayLactate, specifier: "%.1f") mM")
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(.whiteOne)
                .padding(.top, 52)

            Text(LactateHelper.intensity(for: displayLactate).rawValue)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.darkTwo)
        }

        // Research mode: Current vs Time
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
                        .foregroundStyle(.whiteOne.opacity(0.4))
                    
                    PointMark(
                        x: .value("Time", point.time),
                        y: .value("Current", point.current)
                    )
                    .symbolSize(30)
                    .foregroundStyle(.whiteOne)
                    .annotation(position: .top) {
                        Text("\(point.time.formatted(.number.precision(.fractionLength(1)))) s")
                            .foregroundStyle(.whiteOne)
                            .font(.caption2)
                            .padding(4)
                            .background(Color.starBlack.opacity(0.75))
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
            .chartYScale(domain: paddedYRangeResearch(for: appState.currentScanValues.map(\.current)))
            .frame(height: 180)
        }
        else if !appState.research && !lactateSeries20Indexed.isEmpty {
            Chart {
                ForEach(lactateSeries20Indexed, id: \.i) { p in
                    LineMark(
                        x: .value("Index", Double(p.i)),
                        y: .value("Lactate (mM)", p.lactate)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.starMain)
                }

                if let sel = selectedLactateIndex,
                   let point = closestLactatePoint(index: sel) {
                    RuleMark(x: .value("Selected", sel))
                        .foregroundStyle(.whiteOne.opacity(0.4))

                    PointMark(
                        x: .value("Index", Double(point.i)),
                        y: .value("Lactate", point.lactate)
                    )
                    .symbolSize(30)
                    .foregroundStyle(.whiteOne)
                    .annotation(position: .top) {
                        VStack(spacing: 2) {
                            Text(point.date.formatAsHourMinute())
                        }
                        .foregroundStyle(.whiteOne)
                        .font(.caption2)
                        .padding(4)
                        .background(Color.starBlack.opacity(0.75))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom, values: .automatic(desiredCount: 5)) { v in
                    AxisTick()
                    AxisValueLabel {
                        if let x = v.as(Double.self) {
                            let i = Int(round(x))
                            if i >= 0, i < lactateSeries20Indexed.count {
                                Text(lactateSeries20Indexed[i].date
                                    .formatted(.dateTime.day().month(.abbreviated))
                                    .uppercased())
                            }
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { v in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let l = v.as(Double.self) {
                            Text("\(l, specifier: "%.1f") mM")
                        }
                    }
                }
            }
            .chartXSelection(value: $selectedLactateIndex)
            .chartXScale(domain: -0.5...(Double(lactateSeries20Indexed.count - 1) + 1))
            .chartYScale(domain: paddedYRangeLactate(for: lactateSeries20Indexed.map(\.lactate)))
            .frame(height: 180)
        }

        
        Spacer()
    }
    
    // MARK: - Helpers
    
    // Research closest (time/current)
    func closestDataPoint(to time: Double) -> (time: Double, current: Double)? {
        appState.currentScanValues.min {
            abs($0.time - time) < abs($1.time - time)
        }
    }
    
    // Lactate closest (seconds axis)
    private func closestLactatePoint(index: Double) -> (i: Int, date: Date, lactate: Double)? {
        lactateSeries20Indexed.min { abs(Double($0.i) - index) < abs(Double($1.i) - index) }
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
        .environmentObject(MessageHelper())
}


