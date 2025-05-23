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
                Data([0x30, 0x28]), // 5 ADC calibration points (-16 µA, -8 µA, 0 µA, +8 µA, +16 µA)
                Data([0x30, 0x30]), // Page 0x30 → RE_BUFF_OFFSET, WE_BUFF_OFFSET
                
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
                Data([0xB6, 0x08, 0x54]), // OSR = 512, avg = 4, signed
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
        case 0x28:
            rawCalibPages[cmd[1]] = response
        case 0x30 where response.count >= 4:
            // 1. Parse EEPROM offsets (in 0.01 mV units)
            let reOffset = Double(CalibrationService.parseInt16(from: response, start: 0)) / 100.0
            let weOffset = Double(CalibrationService.parseInt16(from: response, start: 2)) / 100.0
            // 2. Compute DAC values for 800 mV Vbias
            self.VRE_HEX = UInt8(round((400.0 - reOffset) / 5.0))
            self.VWE_HEX = UInt8(round((1150.0 - weOffset) / 5.0))
        default:
            break
        }
    }
    
    /// Parses the GetADC reply (16-bit MSB of the 24-bit ADC_RESULT register)
    /// for the current OSR = 512 setting (→ 11 effective bits).
    private func parseADC(_ response: Data) -> Int {
        guard response.count >= 2 else { return 0 }
        let raw16 = Int16(bitPattern: UInt16(response[0]) << 8 | UInt16(response[1]))    // Convert response bytes to 16-bit MSB word
        let signed11 = raw16 >> 5  // Mask to 11-bit signed value
        return Int(signed11)
    }
        
    private func setScanning(_ isScanning: Bool) {
        UserDefaults.standard.set(isScanning, forKey: "isScanning")
    }
}
