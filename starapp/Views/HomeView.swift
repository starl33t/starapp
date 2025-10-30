import SwiftUI
import SwiftData
import Charts

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var viewModel: MessageHelper
    @Environment(\.modelContext) private var context
    @AppStorage("isChatSelected") private var isChatSelected = false
    @AppStorage("isprofileSelected") private var isprofileSelected = false
    @State private var showTutorial = false
    @State private var showFeedback = false
    @AppStorage("hasSeenTutorialPrompt") private var hasSeenTutorialPrompt = false
    @State private var showTutorialAlert = false
    
    // Research (current/time) selection
    @State private var selectedTime: Double?
    
    // Lactate selection on numeric time axis
    @State private var selectedLactateIndex: Double?
    
    private let displayOffset: Double = 0.33
    private func tDisp(_ t: Double) -> Double { max(0.0, t - displayOffset) }
    
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
            .onAppear {
                isChatSelected = false
                appState.setModelContext(context)
                if !hasSeenTutorialPrompt {
                       DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                           showTutorialAlert = true
                       }
                       hasSeenTutorialPrompt = true
                   }
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
            VStack {
                Spacer()
                HStack {
                    Button {
                        showFeedback = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "star.bubble")
                            Text("Feedback")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                    }
                    .padding(.top, 8)
                    .padding(.trailing, 12)
                    
                    Spacer()
                    
                    Button {
                        showTutorial = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "play.rectangle.on.rectangle")
                            Text("Tutorial")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                    }
                    .padding(.top, 8)
                    .padding(.trailing, 12)
                }
            }
            .allowsHitTesting(true) // ensures taps on the button don't fall through
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
        .sheet(isPresented: $showTutorial) {
            VideoCarouselView(steps: [
                .init(title: "Step 1: Apply tape on top",    subtitle: "Peel off the paper from the tape's inner ring and aligned it on top of the wearable's edges. The central part of the wearable should be left uncovered to not interfere with its microfluidic system for optimal sweat wicking. ", videoName: "tutorial1"),
                .init(title: "Step 2: Attach wearable", subtitle: "Peel off the paper from the tape's outer ring to attach the wearable on your shoulder. There is no optimal place on the shoulder as long as it's a hairless spot and you can reach the wearable with your iPhone to scan.", videoName: "tutorial2"),
                .init(title: "Step 3: Scan with iPhone",       subtitle: "Scan with the back of your iPhone by following the scanlines. Remove your mobile case for a better connection. After the session, take off the wearable and rinse the electrodes under water. Do not peel off the tape on top. Apply a new tape on the bottom.", videoName: "tutorial3")
            ])
            .closeButton { showTutorial = false }
        }
        .sheet(isPresented: $showFeedback) {
           FeedbackView()
            .closeButton { showFeedback = false }
        }
        .alert("Welcome to Starapp", isPresented: $showTutorialAlert) {
            Button("Watch tutorial") {
                showTutorial = true
            }
            Button("Skip", role: .cancel) { }
        } message: {
            Text("Would you like to watch a quick tutorial on how to use the app?")
        }

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
        
        let peakPoint = appState.scanValues.max(by: { abs($0.current) < abs($1.current) })
        
        if appState.research {
            let liveCurrent = tooltipCurrent ?? (appState.scanValues.last?.current ?? 0)
            Text(verbatim: String(format: "Current: %.2f µA", liveCurrent))
                .font(.system(size: 42, weight: .bold))
                .foregroundStyle(.whiteOne)
                .padding(.top, 32)
            
            if appState.isScanning,
               let lastTime = appState.scanValues.last?.time {
                let elapsed = tDisp(lastTime)
                let total   = appState.scanTime
                
                Text(verbatim: "\(TimeHelper.format(elapsed)) / \(TimeHelper.format(total))")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.darkTwo)
            }
            
            if let selected = selectedTime,
               let p = closestDataPoint(to: selected) {
                switch appState.scanMode {
                case .cv:
                    Text(verbatim: String(format: "mV: %+d mV", p.mV))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.darkTwo)
                case .ca:
                    Text(verbatim: "Time: \(TimeHelper.format(tDisp(p.time)))")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.darkTwo)
                }
            } else if let p = peakPoint, !appState.isScanning {
                switch appState.scanMode {
                case .cv:
                    Text(verbatim: String(format: "Peak: %+.1f µA @ %+d mV", p.current, p.mV))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.darkTwo)
                case .ca:
                    let t = tDisp(p.time)
                    Text(verbatim: String(format: "Peak: %+.1f µA @ %@", p.current, TimeHelper.format(t)))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.darkTwo)
                }
            }
        }
        else {
            let latestLactateFromSessions = lactateSeries20Indexed.last?.lactate
            let displayLactate = tooltipLactate ?? latestLactateFromSessions ?? 0
            
            Text("Lactate: \(displayLactate, specifier: "%.1f") mM")
                .font(.system(size: 42, weight: .bold))
                .foregroundStyle(.whiteOne)
                .padding(.top, 52)
            
            Text(LactateHelper.intensity(for: displayLactate).rawValue)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.darkTwo)
        }
        
        let rawLast = appState.scanValues.last?.time ?? 1
        let displayedEnd = max(1, tDisp(rawLast) + 2)
        
        if appState.research && !appState.scanValues.isEmpty {
            Chart {
                ForEach(appState.scanValues, id: \.time) { dataPoint in
                    LineMark(
                        x: .value("Time (s)", tDisp(dataPoint.time)),
                        y: .value("Current (µA)", dataPoint.current)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.starMain)
                }
                
                if let selected = selectedTime,
                   let point = closestDataPoint(to: selected) {
                    
                    RuleMark(x: .value("Selected", tDisp(point.time)))
                        .foregroundStyle(.whiteOne.opacity(0.4))
                    
                    PointMark(
                        x: .value("Time", tDisp(point.time)),
                        y: .value("Current", point.current)
                    )
                    .symbolSize(30)
                    .foregroundStyle(.whiteOne)
                    .annotation(position: .top) {
                        Text(verbatim: TimeHelper.format(tDisp(point.time)))
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
                            Text("\(seconds, specifier: "%.2f") s")
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let y = value.as(Double.self) {
                            Text("\(y, specifier: "%.1f") µA")
                        }
                    }
                }
            }
            .chartXSelection(value: $selectedTime) // ✅ track finger
            .chartXScale(domain: 0.0...displayedEnd)
            .chartYScale(domain: paddedYRangeResearch(for: appState.scanValues.map(\.current)))
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
    func closestDataPoint(to displayedTime: Double) -> (time: Double, current: Double, mV: Int)? {
        guard let s = appState.scanValues.min(by: {
            abs(tDisp($0.time) - displayedTime) < abs(tDisp($1.time) - displayedTime)
        }) else {
            return nil
        }
        return (time: s.time, current: s.current, mV: s.mV)
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

