import SwiftUI
import CoreNFC
import SwiftData

class AppState: ObservableObject, NFCManagerDelegate {
    
    public struct ScanValue {
        let time: TimeInterval
        let dac: Int           // applied mV at electrode
        let adc: Int           // raw signed 16-bit ADC
        let current: Double
        let lactate: Double
        let uidString: String
        let mV: Int            // signed bias relative to 400 mV
    }
    // MARK: – UI State
    @Published var selectedTab: Int = 0
    @Published var selectedDate: Date = Date()
    @Published var days: [Date] = Date().daysInYear
    @Published var homeTitle: String = "Lactate"
    @Published var homeActiveTab: HomeTab = .lactate
    @Published var todayTitle: String = ""
    @Published var isScanning = false
    @Published var scanValues: [ScanValue] = []
    
    // MARK: – Persistent Storage
    @AppStorage("CalibrationFactor") var calibrationFactor: Double = 1.0
    @AppStorage("WorkingElectrodeVoltage") var workingElectrodeVoltage: Double = 1200.0
    @AppStorage("ReferenceElectrodeVoltage") var referenceElectrodeVoltage: Double = 400.0
    @AppStorage("BiasVoltage") var biasVoltage: Double = 0.0
    @AppStorage("Research") var research: Bool = false
    @AppStorage("ScanTime") var scanTime: Double = 1.0
    @AppStorage("ScanMode") var scanMode: ScanMode = .ca
    @AppStorage("ResearchScanTime") var researchScanTime: Double = 20.0
    @AppStorage("NonResearchScanTime") var nonResearchScanTime: Double = 0.1
    
    
    // MARK: – NFC
    private lazy var nfcManager = NFCManager(appState: self)
    private var scanStartTime: Date?
    public var drivesWE: Bool { biasVoltage >= 0 } // true → WE active, RE held ~400 mV
    private var modelContext: ModelContext?
    func setModelContext(_ ctx: ModelContext) { self.modelContext = ctx }
    
    init() {
        ensureAppStorageDefaults()
        nfcManager.delegate = self
        updateHomeNavigationTitle()
        updateBiasFromElectrodes()
    }
    
    // MARK: – NFCManagerDelegate
    func ensureAppStorageDefaults() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "ReferenceElectrodeVoltage") == nil {
            let v = 400.0
            defaults.set(v, forKey: "ReferenceElectrodeVoltage")
            referenceElectrodeVoltage = v
        }
        if defaults.object(forKey: "WorkingElectrodeVoltage") == nil {
            let v = 1200.0
            defaults.set(v, forKey: "WorkingElectrodeVoltage")
            workingElectrodeVoltage = v
        }
        if defaults.object(forKey: "CalibrationFactor") == nil {
            let v = 1.0
            defaults.set(v, forKey: "CalibrationFactor")
            calibrationFactor = v
        }
        if defaults.object(forKey: "ScanTime") == nil {
            let v = 20.0
            defaults.set(v, forKey: "ScanTime")
            scanTime = v
        }
        if defaults.object(forKey: "ResearchScanTime") == nil {
            defaults.set(20.0, forKey: "ResearchScanTime")
            researchScanTime = 20.0
        }
        if defaults.object(forKey: "NonResearchScanTime") == nil {
            defaults.set(0.1, forKey: "NonResearchScanTime")
            nonResearchScanTime = 0.1
        }
    }
    
    func nfcManager(_ manager: NFCManager,
                    didReadCalibrationPages pages: [UInt8: Data],
                    rawAdcResponse: Data,
                    applied_mV: Int) {
        guard let p28 = pages[0x28] else { return }
        let rawAdc = CalibrationService.parseADC(from: rawAdcResponse)
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let result = CalibrationService.computeCalibration(page28: p28, rawAdcValue: rawAdc) {
                let elapsedSec = self.scanStartTime.map { Date().timeIntervalSince($0) } ?? 0
                let signedMV   = (self.biasVoltage >= 0) ? (applied_mV - 400) : -(applied_mV - 400)
                let scan = ScanValue(
                    time: elapsedSec,
                    dac: applied_mV,
                    adc: rawAdc,
                    current: result.current,
                    lactate: result.lactate,
                    uidString: UUID().uuidString,
                    mV: signedMV
                )
                
                DispatchQueue.main.async {
                    if self.research {                // ✅ Research CA/CV → live series
                        self.scanValues.append(scan)
                    } else {                          // ✅ Non-research CA → persist session only
                        self.saveSession(from: scan)
                    }
                }
            }
        }
    }
    
    public func nfcManager(_ manager: NFCManager, didFailWith error: Error) {
        DispatchQueue.main.async { self.isScanning = false }
    }
    
    // MARK: – Helpers
    func updateHomeNavigationTitle() {
        homeTitle = homeActiveTab.navigationTitle
    }
    func updateTodayTitle() {
        todayTitle = Date().formatDayMonthLong(date: Date())
    }
    
    // Trigger a scan
    func startNFCScan() {
        isScanning = true
        if research {
            scanValues.removeAll()
            scanTime = researchScanTime
        } else {
            scanTime = nonResearchScanTime
        }
        scanStartTime = Date()
        nfcManager.beginScanning()
    }
    
    
    // Keep bias/electrodes in sync
    func updateBiasFromElectrodes() {
        if workingElectrodeVoltage != 400 {
            biasVoltage = workingElectrodeVoltage - 400
        } else {
            biasVoltage = -(referenceElectrodeVoltage - 400)
        }
    }
    func updateElectrodesFromBias() {
        if biasVoltage >= 0 {
            workingElectrodeVoltage = 400 + biasVoltage
            referenceElectrodeVoltage = 400
        } else {
            workingElectrodeVoltage = 400
            referenceElectrodeVoltage = 400 + abs(biasVoltage)
        }
    }
    
    private func saveSession(from scan: ScanValue) {
        guard let ctx = modelContext else { return }
        
        let descriptor = FetchDescriptor<Session>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let sessions = (try? ctx.fetch(descriptor)) ?? []
        let lastSession = sessions.first
        
        let now = Date()
        var duration: Double = 0
        
        if let previous = lastSession,
           let prevDate = previous.date,
           now.timeIntervalSince(prevDate) < 5 * 3600 {
            duration = now.timeIntervalSince(prevDate) / 60.0
        }
        
        let newSession = Session(
            duration: duration,
            lactate: scan.lactate,
            date: now,
            uidString: scan.uidString,
            adc: scan.adc,
            current: scan.current
        )
        ctx.insert(newSession)
        try? ctx.save()
    }

}

enum ScanMode: String, CaseIterable {
    case ca
    case cv
}
