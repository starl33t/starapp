import Foundation
import CoreNFC

public protocol NFCManagerDelegate: AnyObject {
    func nfcManager(_ manager: NFCManager, didReadCalibrationPages pages: [UInt8: Data], rawAdc: Int)
    func nfcManager(_ manager: NFCManager, didFailWith error: Error)
}

public class NFCManager: NSObject, NFCTagReaderSessionDelegate {
    public weak var delegate: NFCManagerDelegate?
    private var session: NFCTagReaderSession?
    private var rawCalibPages: [UInt8: Data] = [:]
    private var rawAdcValue: Int?
    private var VRE_HEX: UInt8 = 0
    private var VWE_HEX: UInt8 = 0
    
    public func beginScanning() {
        guard NFCTagReaderSession.readingAvailable else {
            delegate?.nfcManager(self, didFailWith: NSError(domain: "NFCManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "NFC not available"]))
            return
        }
        session = NFCTagReaderSession(pollingOption: [.iso14443], delegate: self)
        session?.alertMessage = "Tap on wearable"
        session?.begin()
        setScanning(true)
    }
    
    public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {}
    
    public func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        setScanning(false)
        delegate?.nfcManager(self, didFailWith: error)
    }
    
    public func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard case let .miFare(tag) = tags.first else {
            session.invalidate(errorMessage: "Invalid tag")
            return
        }
        
        session.connect(to: tags[0]) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                session.invalidate(errorMessage: "Connection failed")
                self.delegate?.nfcManager(self, didFailWith: error)
                return
            }
            
            self.rawCalibPages.removeAll()
            self.rawAdcValue = nil
            
            self.executeCommands(self.buildCommands(phase: .setup), tag: tag, session: session) {
                self.executeCommands(self.buildCommands(phase: .voltage), tag: tag, session: session) {}
            }
        }
    }
    
    private enum CommandPhase { case setup, voltage }
    
    private func buildCommands(phase: CommandPhase) -> [Data] {
        switch phase {
        case .setup:
            return [
                Data([0xB4, 0xFF]), // Clear error flags
                
                // EEPROM reads for calibration
                Data([0x30, 0x28]),
                Data([0x30, 0x29]),
                Data([0x30, 0x2A]),
                Data([0x30, 0x30]),
                
                // Final config for fast, stable ADC conversion
                Data([0xB6, 0x04, 0x19]), // ADC_Divisor = 25 → f_sensor ≈ 88 kHz
                Data([0xB6, 0x05, 0x00]), // ADC_Prescaler = 0
                Data([0xB6, 0x06, 0x4C]), // ADC_Samp_Pt = 76 (mid-point of one ADC cycle)
                Data([0xB6, 0x07, 0x52]), // Warm_Clock: M=5, N=2 → 8 + 20 = 28
                Data([0xB6, 0x08, 0x19]), // ADC: 10-bit, signed, 1 sample
                Data([0xB6, 0x10, 0x06]), // IO Map: RE, WE, CE
                Data([0xB6, 0x11, 0x01]), // Potentiostat config
                Data([0xB6, 0x18, 0x0F]), // Sensor config: AFE+ADC+DAC on
            ]
            
        case .voltage:
            return [
                Data([0xB6, 0x0E, VRE_HEX]),
                Data([0xB6, 0x0F, VWE_HEX]),
                Data([0xB8, 0x00]) // GetADC
            ]
        }
    }
    
    
    private func executeCommands(_ commands: [Data], tag: NFCMiFareTag, session: NFCTagReaderSession, completion: @escaping () -> Void) {
        func next(_ index: Int) {
            guard index < commands.count else { completion(); return }
            let cmd = commands[index]
            
            tag.sendMiFareCommand(commandPacket: cmd) { [weak self] response, error in
                guard let self = self else { return }
                
                if let error = error {
                    session.invalidate(errorMessage: "It failed, try again")
                    self.delegate?.nfcManager(self, didFailWith: error)
                    return
                }
                
                if cmd.first == 0xB8 {
                    guard response.count >= 2 else {
                        session.invalidate(errorMessage: "Read error")
                        self.setScanning(false)
                        self.delegate?.nfcManager(self, didReadCalibrationPages: self.rawCalibPages, rawAdc: 0)
                        return
                    }
                    
                    let raw = self.parseADC(response)
                    self.rawAdcValue = raw
                    
                    if raw == 0 {
                        self.executeCommands(self.buildCommands(phase: .setup), tag: tag, session: session) {
                            self.executeCommands(self.buildCommands(phase: .voltage), tag: tag, session: session) {}
                        }
                        return
                    }
                    
                    // ✅ Valid ADC received
                    session.alertMessage = "Done"
                    session.invalidate()
                    self.setScanning(false)
                    self.delegate?.nfcManager(self, didReadCalibrationPages: self.rawCalibPages, rawAdc: raw)
                }
                else {
                    self.process(cmd, response)
                    next(index + 1)
                }
            }
        }
        next(0)
    }
    
    private func process(_ cmd: Data, _ response: Data) {
        guard cmd.count == 2, cmd[0] == 0x30 else { return }
        switch cmd[1] {
        case 0x28, 0x29, 0x2A:
            rawCalibPages[cmd[1]] = response
        case 0x30 where response.count >= 4:
            // 1. Parse EEPROM offsets (in 0.01 mV units)
            let reOffset = Double(CalibrationService.parseInt16(from: response, start: 0)) / 100.0
            let weOffset = Double(CalibrationService.parseInt16(from: response, start: 2)) / 100.0
            // 2. Compute DAC values for 800 mV Vbias
            self.VRE_HEX = UInt8(round((400.0 - reOffset) / 5.0))
            self.VWE_HEX = UInt8(round((1200.0 - weOffset) / 5.0))
        default:
            break
        }
    }
    
    private func parseADC(_ response: Data) -> Int {
        let hex = response.map { String(format: "%02x", $0) }.joined()
        var raw = Int(hex, radix: 16) ?? 0
        raw &= 0xFFFF
        return (raw & 0x8000) != 0 ? raw - 65536 : raw
    }
    
    private func setScanning(_ isScanning: Bool) {
        UserDefaults.standard.set(isScanning, forKey: "isScanning")
    }
}
