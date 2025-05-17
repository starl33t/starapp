import Foundation
import CoreNFC

/// Delegate gets raw calibration pages and raw ADC once the scan finishes.
public protocol NFCManagerDelegate: AnyObject {
    /// Called when the tag scan completes successfully.
    /// - pages: raw EEPROM page data for keys 0x28, 0x29, 0x2A
    /// - rawAdc: the signed 16-bit ADC reading
    func nfcManager(_ manager: NFCManager,
                    didReadCalibrationPages pages: [UInt8: Data],
                    rawAdc: Int)
    
    /// Called on any error during the scan.
    func nfcManager(_ manager: NFCManager,
                    didFailWith error: Error)
}

public class NFCManager: NSObject, NFCTagReaderSessionDelegate {
    // MARK: – Public API
    public weak var delegate: NFCManagerDelegate?
    private var session: NFCTagReaderSession?
    
    /// Starts the NFC scan.
    public func beginScanning() {
        guard NFCTagReaderSession.readingAvailable else {
            let err = NSError(domain: "NFCManager",
                              code: 0,
                              userInfo:[NSLocalizedDescriptionKey:"NFC not available"])
            delegate?.nfcManager(self, didFailWith: err)
            return
        }
        session = NFCTagReaderSession(pollingOption: [.iso14443],
                                      delegate: self)
        session?.alertMessage = "Tap on wearable"
        session?.begin()
        UserDefaults.standard.set(true, forKey: "isScanning")
    }
    
    // MARK: – NFCTagReaderSessionDelegate
    public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) { }
    
    public func tagReaderSession(_ session: NFCTagReaderSession,
                                 didInvalidateWithError error: Error) {
        UserDefaults.standard.set(false, forKey: "isScanning")
        // If scan was cancelled by user, you might not want to treat as error.
        delegate?.nfcManager(self, didFailWith: error)
    }
    
    public func tagReaderSession(_ session: NFCTagReaderSession,
                                 didDetect tags: [NFCTag]) {
        guard let first = tags.first,
              case let .miFare(miFareTag) = first else {
            session.invalidate(errorMessage: "Invalid tag")
            return
        }
        session.connect(to: first) { [weak self] error in
            if let err = error {
                session.invalidate(errorMessage: "Connection failed")
                self?.delegate?.nfcManager(self!, didFailWith: err)
                return
            }
            self?.executeCommandSequence(tag: miFareTag, session: session)
        }
    }
    
    // MARK: – Internal State
    private var rawCalibPages: [UInt8: Data] = [:]
    private var rawAdcValue: Int?
    private var VRE_HEX: UInt8 = 0
    private var VWE_HEX: UInt8 = 0
    
    // MARK: – Full Command Sequence
    private func executeCommandSequence(tag: NFCMiFareTag,
                                        session: NFCTagReaderSession) {
        // Clear previous state
        rawCalibPages.removeAll()
        rawAdcValue = nil
        
        // 1) Read pages 0x28,0x29,0x2A and offsets 0x30
        executeCommands(buildSetupCommands(),
                        tag: tag,
                        session: session) { [weak self] in
            guard let self = self else { return }
            // 2) Apply voltages & then read ADC
            self.executeCommands(self.buildVoltageCommands(),
                                 tag: tag,
                                 session: session) {
                // nothing more here—delegate will be called in the ADC branch
            }
        }
    }
    
    private func executeCommands(_ commands: [Data],
                                 tag: NFCMiFareTag,
                                 session: NFCTagReaderSession,
                                 completion: @escaping () -> Void) {
        func execNext(_ index: Int) {
            guard index < commands.count else {
                completion()
                return
            }
            let cmd = commands[index]
            tag.sendMiFareCommand(commandPacket: cmd) { [weak self] response, error in
                guard let self = self else { return }
                if let err = error {
                    session.invalidate(errorMessage: "Cmd failed")
                    self.delegate?.nfcManager(self, didFailWith: err)
                    return
                }
                
                // If this is the ADC‐read (0xB8), stash raw value & finish
                if cmd.first == 0xB8 {
                    guard response.count >= 2 else {
                        let err = NSError(domain: "NFCManager",
                                          code: 2,
                                          userInfo: [NSLocalizedDescriptionKey:"ADC response too short"])
                        session.invalidate(errorMessage: "Read error")
                        self.delegate?.nfcManager(self, didFailWith: err)
                        return
                    }
                    let raw = parseADCResponse(response)
                    self.rawAdcValue = raw
                    print("DEBUG: parsed raw ADC = \(raw)")
                    
                    
                    // tear down NFC UI
                    session.alertMessage = "Done"
                    session.invalidate()
                    UserDefaults.standard.set(false, forKey: "isScanning")
                    
                    // inform delegate with just the raw data
                    self.delegate?.nfcManager(self,
                                              didReadCalibrationPages: self.rawCalibPages,
                                              rawAdc: raw
                    )
                    return
                }
                
                // Otherwise collect calibration or offset pages
                self.processResponse(for: cmd, response: response)
                execNext(index + 1)
            }
        }
        execNext(0)
    }
    
    // MARK: – Command Builders
    private func buildSetupCommands() -> [Data] {
        return [
            Data([0xB4, 0xFF]),        // Clear errors
            Data([0x30, 0x28]),        // EEPROM page 0x28
            Data([0x30, 0x29]),        // EEPROM page 0x29
            Data([0x30, 0x2A]),        // EEPROM page 0x2A
            Data([0x30, 0x30]),        // buffer offsets
            Data([0xB6, 0x04, 0x8F]),   // Write ADC Divisor Register
            Data([0xB6, 0x05, 0x00]),   // Write ADC Prescaler Register
            Data([0xB6, 0x09, 0x00]),   // Write ADC Mode Config (Single Conversion Mode)
            Data([0xB6, 0x11, 0x01]),   // Write Potentiostat Config
            Data([0xB6, 0x18, 0x0F]),   // Write Sensor Config (Potentiostat ON, ADC ON, DAC ON)
            Data([0xB6, 0x0A, 0x01]),   // Set ADC LPF to 1250 kHz
            Data([0xB6, 0x08, 0x2D]),   // Write ADC Bit Config (signed mode)
            Data([0xB6, 0x10, 0x06]),   // Map RE to IO[0], WE to IO[1], CE to IO[2]
            Data([0xB6, 0x07, 0x64])    // Warm_Clock = 104
        ]
    }
    
    private func buildVoltageCommands() -> [Data] {
        return [
            Data([0xB6, 0x0E, VRE_HEX]),  // set VRE
            Data([0xB6, 0x0F, VWE_HEX]),  // set VWE
            Data([0xB8, 0x00])            // read ADC
        ]
    }
    
    // MARK: – Collecting Responses
    private func processResponse(for command: Data, response: Data) {
        guard command.count == 2, command[0] == 0x30 else { return }
        let page = command[1]
        switch page {
        case 0x28, 0x29, 0x2A:
            // stash calibration-page bytes
            rawCalibPages[page] = response
            
        case 0x30:
            // compute VRE_HEX/VWE_HEX from raw offsets
            guard response.count >= 4 else { return }
            let reWord = UInt16(response[0])<<8 | UInt16(response[1])
            let weWord = UInt16(response[2])<<8 | UInt16(response[3])
            let reOff  = Double(Int16(bitPattern: reWord)) / 100.0
            let weOff  = Double(Int16(bitPattern: weWord)) / 100.0
            let expectedRE = 400.0, expectedWE = 1200.0
            VRE_HEX = UInt8(round((expectedRE - reOff) / 5.0))
            VWE_HEX = UInt8(round((expectedWE - weOff) / 5.0))
            
        default:
            break  // no other pages
        }
    }
    
    // MARK: – Data Parsing Helper
    private func parseADCResponse(_ response: Data) -> Int {
        // 1) hex-string of all bytes
        let hexString = response.map { String(format: "%02x", $0) }.joined()
        // 2) parse as integer
        var raw = Int(hexString, radix: 16) ?? 0
        // 3) keep only 16 bits
        raw &= 0xFFFF
        // 4) two’s-complement if high bit set
        if (raw & 0x8000) != 0 { raw -= 65536 }
        return raw
    }
    
}
