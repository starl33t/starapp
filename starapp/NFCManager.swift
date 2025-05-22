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
    private var scanStartTime: CFAbsoluteTime? //timer
    
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
            self.scanStartTime = CFAbsoluteTimeGetCurrent() //Start timer
            
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
                
                // Calibration EEPROM reads
                Data([0x30, 0x28]),
                Data([0x30, 0x29]),
                Data([0x30, 0x2A]),
                Data([0x30, 0x30]),
                
                // ADC Frequency setup (50 kHz)
                Data([0xB6, 0x04, 0x8F]), // Divisor = 143
                Data([0xB6, 0x05, 0x00]), // Prescaler = 0
               
                
                //Config potentiostat
                Data([0xB6, 0x11, 0x01]), // Enable potentiostat
                Data([0xB6, 0x18, 0x0F]),  // AFE + DAC + ADC on
                Data([0xB6, 0x10, 0x06]), // Map RE to IO[0], WE to IO[1], CE to IO[2]
                Data([0xB6, 0x0A, 0x03]),   // Set ADC LPF to 325 kHz (most quiet)
                
                //ADC sampling mode
                Data([0xB6, 0x09, 0x02]), // ADC Continuous Mode
                Data([0xB6, 0x08, 0x19]), // OSR = 64, avg = 2, signed
                Data([0xB6, 0x07, 0x00])  // Warm-up = 8 clocks (fastest)
            ]
            
        case .voltage:
            return [
                Data([0xB6, 0x0E, VRE_HEX]), // Set RE voltage
                Data([0xB6, 0x0F, VWE_HEX]), // Set WE voltage
                Data([0xB8, 0x00])          // GetADC: reads latest continuous value
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
                    let raw = self.parseADC(response)
                    self.rawAdcValue = raw
                    
                    if raw == 0 {
                        self.executeCommands(self.buildCommands(phase: .setup), tag: tag, session: session) {
                            self.executeCommands(self.buildCommands(phase: .voltage), tag: tag, session: session) {}
                        }
                        return
                    }
                    
                    // ✅ Valid ADC received
                    session.invalidate()
                    self.setScanning(false)
                    self.delegate?.nfcManager(self, didReadCalibrationPages: self.rawCalibPages, rawAdc: raw)
                    if let start = self.scanStartTime {
                        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000 //end timer
                        print("DEBUG: ⏱️ Total NFC scan time: \(String(format: "%.3f", elapsed)) ms")
                    }
                    
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
            self.VWE_HEX = UInt8(round((400.0 - weOffset) / 5.0))
            print("DEBUG: Computed VRE=0x\(String(format:"%02X", VRE_HEX)), VWE=0x\(String(format:"%02X", VWE_HEX))")
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
