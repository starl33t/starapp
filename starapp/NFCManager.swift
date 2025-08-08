import Foundation
import CoreNFC

public protocol NFCManagerDelegate: AnyObject {
    func nfcManager(_ manager: NFCManager, didReadCalibrationPages pages: [UInt8: Data], rawAdcResponse: Data)
    func nfcManager(_ manager: NFCManager, didFailWith error: Error)
}


public class NFCManager: NSObject, NFCTagReaderSessionDelegate {
    public weak var delegate: NFCManagerDelegate?
    private var session: NFCTagReaderSession?
    private var rawCalibPages: [UInt8: Data] = [:]
    private var VRE_HEX: UInt8 = 0
    private var VWE_HEX: UInt8 = 0
    private unowned let appState: AppState  // ✅ injected instead of cast
    private var lastADCResponse: Data?
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    public func beginScanning() {
        guard NFCTagReaderSession.readingAvailable else {
            delegate?.nfcManager(self, didFailWith: NSError(domain: "NFCManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "NFC not available"]))
            return
        }
        session = NFCTagReaderSession(pollingOption: [.iso14443], delegate: self)
        session?.alertMessage = "Tap on wearable"
        session?.begin()
    }
    
    public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {}
    
    public func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        delegate?.nfcManager(self, didFailWith: error)
    }
    
    public func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard case let .miFare(tag) = tags.first else { return }
        
        session.connect(to: tags[0]) { [weak self] error in
            guard let self = self else { return }
            
            self.rawCalibPages.removeAll()
            let startTime = Date()
            
            // Run setup ONCE at the start of each scan
            self.executeCommands(self.buildSetupCommands(), tag: tag, session: session) {
                
                func performVoltageLoop() {
                    let voltageCommands: [Data] = [
                        Data([0xB6, 0x0F, self.VWE_HEX]),
                        Data([0xB8, 0x00])
                    ]

                    self.executeCommands(voltageCommands, tag: tag, session: session) {
                        if let response = self.lastADCResponse {
                            self.delegate?.nfcManager(self, didReadCalibrationPages: self.rawCalibPages, rawAdcResponse: response)
                        }

                        let time = self.appState.scanTime
                        let isResearch = self.appState.research
                        let elapsed = Date().timeIntervalSince(startTime)
                        
                        if isResearch, elapsed < time {
                            let timeLeft = Int(time - elapsed)
                            session.alertMessage = "Scanning: \(timeLeft) seconds left"
                            performVoltageLoop()
                        } else {
                            session.invalidate()
                        }
                    }
                }
                performVoltageLoop()
            }
        }
    }
    
    private func buildSetupCommands() -> [Data] {
        return [
            // Calibration & Offset
            Data([0xB4, 0xFF]),
            Data([0x30, 0x28]),
            Data([0x30, 0x30]),
            
            // ADC Frequency setup
            Data([0xB6, 0x04, 0x8F]),
            Data([0xB6, 0x05, 0x00]),
            
            // Potentiostat config
            Data([0xB6, 0x11, 0x07]),
            Data([0xB6, 0x18, 0x0F]),
            Data([0xB6, 0x10, 0x26]),
            Data([0xB6, 0x0A, 0x01]),
            
            // ADC sampling mode
            Data([0xB6, 0x09, 0x00]),
            Data([0xB6, 0x08, 0x2D]),
            Data([0xB6, 0x07, 0x00])
        ]
    }
    
    private func executeCommands(
        _ commands: [Data],
        tag: NFCMiFareTag,
        session: NFCTagReaderSession,
        completion: @escaping () -> Void
    ) {
        let maxAttempts = 5
        var attempt = 0
        
        func run(_ index: Int) {
            guard index < commands.count else {
                completion()
                return
            }
            
            let cmd = commands[index]
            tag.sendMiFareCommand(commandPacket: cmd) { [weak self] response, error in
                guard let self = self else { return }
                
                func failAndRetry() {
                    attempt += 1
                    if attempt < maxAttempts {
                        run(index)
                    } else {
                        session.restartPolling()
                    }
                }
                
                switch cmd.first {
                case 0x30:
                    if response.count < 16 {
                        failAndRetry()
                        return
                    }
                    self.rawCalibPages[cmd[1]] = response
                    if cmd[1] == 0x30, response.count >= 4 {
                        let weOffset = Double(CalibrationService.parseInt16(from: response, start: 2)) / 100.0
                        let voltage = appState.workingElectrodeVoltage
                        self.VWE_HEX = UInt8(round((voltage - weOffset) / 5.0)) //1200 mV
                    }
                    run(index + 1)
                    
                case 0xB6:
                    if response.count < 1 || response[0] != 0x1A {
                        failAndRetry()
                        return
                    }
                    run(index + 1)
                    
                case 0xB8:
                    if response.count != 3 || response[0] != 0x1A {
                        failAndRetry()
                        return
                    }
                    self.lastADCResponse = response
                    completion()
                default:
                    run(index + 1)
                }
            }
        }
        
        run(0)
    }
    
}
