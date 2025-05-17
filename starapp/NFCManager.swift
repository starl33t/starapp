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
                Data([0xB4, 0xFF]), // Clear Error Flags
                Data([0x30, 0x28]), // EEPROM 0x28: Calibration for +16µA and +8µA
                Data([0x30, 0x29]), // EEPROM 0x29: Calibration for 0µA and -8µA
                Data([0x30, 0x2A]), // EEPROM 0x2A: Calibration for -16µA
                Data([0x30, 0x30]), // EEPROM 0x30: Buffer Offsets for RE and WE
                Data([0xB6, 0x04, 0x8F]), // Write ADC Divisor Register
                Data([0xB6, 0x05, 0x00]),  // Write ADC Prescaler Register
                Data([0xB6, 0x09, 0x00]),  // Write ADC Mode Config (Single Conversion Mode)
                Data([0xB6, 0x11, 0x01]),  // Write Potentiostat Config
                Data([0xB6, 0x18, 0x0F]), // Write Sensor Config (Potentiostat ON, ADC ON, DAC ON)
                Data([0xB6, 0x0A, 0x01]), // Set ADC LPF to 1250 kHz
                Data([0xB6, 0x08, 0x2D]),  // Write ADC Bit Config (signed mode)
                Data([0xB6, 0x10, 0x06]), // Map RE to IO[0], WE to IO[1], CE to IO[2]
                Data([0xB6, 0x07, 0x64]) // Warm_Clock = 104
            ]
        case .voltage:
            return [
                Data([0xB6, 0x0E, VRE_HEX]),
                Data([0xB6, 0x0F, VWE_HEX]),
                Data([0xB8, 0x00])
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
                    session.invalidate(errorMessage: "Cmd failed")
                    self.delegate?.nfcManager(self, didFailWith: error)
                    return
                }
                
                if cmd.first == 0xB8 {
                    guard response.count >= 2 else {
                        session.invalidate(errorMessage: "Read error")
                        self.delegate?.nfcManager(self, didFailWith: NSError(domain: "NFCManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "ADC response too short"]))
                        return
                    }
                    let raw = self.parseADC(response)
                    self.rawAdcValue = raw
                    session.alertMessage = "Done"
                    session.invalidate()
                    self.setScanning(false)
                    self.delegate?.nfcManager(self, didReadCalibrationPages: self.rawCalibPages, rawAdc: raw)
                } else {
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
            // Read RE and WE offsets (in 0.01 mV) → convert to mV (rounded)
            let reOffset = (CalibrationService.parseInt16(from: response, start: 0) + 50) / 100
            let weOffset = (CalibrationService.parseInt16(from: response, start: 2) + 50) / 100
            
            // Fixed safe targets (headroom below 1200 mV)
            let VWE_HEX = UInt8(clamping: (1150 - weOffset + 2) / 5)
            let VRE_HEX = UInt8(clamping: (350 - reOffset + 2) / 5)
            
            // Store
            self.VWE_HEX = VWE_HEX
            self.VRE_HEX = VRE_HEX
    
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
