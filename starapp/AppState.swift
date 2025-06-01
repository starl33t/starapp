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

    // MARK: – Persistent Storage
    @AppStorage("userTier") private var userTier: Int = 0
    @AppStorage("Adc")      var adc: Int     = 0
    @AppStorage("Current")  var current: Double = 0.0
    @AppStorage("Lactate")  var lactate: Double = 0.0
    @AppStorage("uidString") var uidString: String = ""

    
    // MARK: – NFC
    private let nfcManager = NFCManager()
    
    init() {
        // wire up NFC delegate
        nfcManager.delegate = self
        
        updateHomeNavigationTitle()
    }
    
    // MARK: – NFCManagerDelegate
    
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
                }
            }
        }
    }
    
    public func nfcManager(_ manager: NFCManager, didFailWith error: Error) {
        // Handle scan errors here if you want to show an alert
        print("NFC scan failed: \(error.localizedDescription)")
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
        nfcManager.beginScanning()
    }

}
