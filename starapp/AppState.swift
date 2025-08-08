import SwiftUI
import CoreNFC  // for NFCManagerDelegate

class AppState: ObservableObject, NFCManagerDelegate {
    // MARK: – UI State
    @Published var selectedTab: Int = 0
    @Published var selectedDate: Date = Date()
    @Published var days: [Date] = Date().daysInYear
    @Published var homeTitle: String = "Lactate"
    @Published var homeActiveTab: HomeTab = .lactate
    @Published var todayTitle: String = ""
    @Published var currentScanValues: [(time: TimeInterval, current: Double)] = []
    // MARK: – Persistent Storage
    @AppStorage("Adc")      var adc: Int     = 0
    @AppStorage("Current")  var current: Double = 0.0
    @AppStorage("Lactate")  var lactate: Double = 0.0
    @AppStorage("uidString") var uidString: String = ""
    @AppStorage("CalibrationFactor") var calibrationFactor: Double = 1.0
    @AppStorage("WorkingElectrodeVoltage") var workingElectrodeVoltage: Double = 1200.0
    @AppStorage("Research") var research: Bool = false
    @AppStorage("ScanTime") var scanTime: Double = 1.0
    @Published var isScanning = false

    // MARK: – NFC
    private lazy var nfcManager = NFCManager(appState: self)
    private var scanStartTime: Date?
    
    init() {
        ensureAppStorageDefaults()
        nfcManager.delegate = self
        
        updateHomeNavigationTitle()
    }
    // MARK: – NFCManagerDelegate
    
    func ensureAppStorageDefaults() {
        let defaults = UserDefaults.standard
        
        if defaults.object(forKey: "WorkingElectrodeVoltage") == nil {
            let defaultValue = 1200.0
            defaults.set(defaultValue, forKey: "WorkingElectrodeVoltage")
            workingElectrodeVoltage = defaultValue
        }
        
        if defaults.object(forKey: "CalibrationFactor") == nil {
            let defaultValue = 1.0
            defaults.set(defaultValue, forKey: "CalibrationFactor")
            calibrationFactor = defaultValue
        }
        
        if defaults.object(forKey: "ScanTime") == nil {
            let defaultValue = 20.0
            defaults.set(defaultValue, forKey: "ScanTime")
            scanTime = defaultValue
        }
    }
    
    func nfcManager(_ manager: NFCManager,
                    didReadCalibrationPages pages: [UInt8: Data],
                    rawAdcResponse: Data) {
        guard let p28 = pages[0x28] else { return }
        let rawAdc = CalibrationService.parseADC(from: rawAdcResponse)
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let result = CalibrationService.computeCalibration(page28: p28, rawAdcValue: rawAdc) {
                DispatchQueue.main.async {
                    self.adc     = rawAdc
                    self.current = result.current
                    self.lactate = result.lactate
                    self.uidString = UUID().uuidString
                    if self.research, let start = self.scanStartTime {
                        let elapsedSec = Date().timeIntervalSince(start)  // seconds
                        self.currentScanValues.append((time: elapsedSec, current: result.current))
                    }
                }
            }
        }
    }
    
    public func nfcManager(_ manager: NFCManager, didFailWith error: Error) {
        // Handle scan errors here if you want to show an alert
        DispatchQueue.main.async {
            self.isScanning = false
        }
    }
    
    // MARK: – Helpers
    
    func updateHomeNavigationTitle() {
        homeTitle = homeActiveTab.navigationTitle
    }
    
    func updateTodayTitle() {
        todayTitle = Date().formatDayMonthLong(date: Date())
    }
    
    // Call this when you want to start a scan, e.g. from your toolbar:
    func startNFCScan() {
        isScanning = true
        currentScanValues.removeAll()
        scanStartTime = Date()
        nfcManager.beginScanning()
    } 
}
