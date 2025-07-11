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
    private var VWE_HEX: UInt8 = 0
    
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
        guard case let .miFare(tag) = tags.first else {
            return
        }
        
        session.connect(to: tags[0]) { [weak self] error in
            guard let self = self else { return }
            
            self.rawCalibPages.removeAll()
            
            self.executeCommands(self.buildCommands(phase: .setup), tag: tag, session: session) {
                self.executeCommands(self.buildCommands(phase: .voltage), tag: tag, session: session) {}
            }
        }
    }
    
    private enum CommandPhase { case setup, voltage }
    
    private func buildCommands(phase: CommandPhase) -> [Data] {
        switch phase {
        case .setup:
            let rawValue = UserDefaults.standard.integer(forKey: "AdcLpfSetting") & 0b11
            let lpfSetting = UInt8(rawValue)
            return [
                // Calibration & Offset
                Data([0xB4, 0xFF]), // Clear error flags
                Data([0x30, 0x28]), // 5 ADC calibration points (-16 µA, -8 µA, 0 µA, +8 µA, +16 µA)
                Data([0x30, 0x30]), // Page 0x30 → RE_BUFF_OFFSET, WE_BUFF_OFFSET
                
                // ADC Frequency setup (50 kHz)
                Data([0xB6, 0x04, 0x8F]), // Divisor = 143
                Data([0xB6, 0x05, 0x00]), // Prescaler = 0, essential
                
                //Config potentiostat
                Data([0xB6, 0x11, 0x07]), // 2-electrode, RE to GND, 20 µA,essential
                Data([0xB6, 0x18, 0x0F]),  // AFE + DAC + ADC on
                Data([0xB6, 0x10, 0x26]), // Map WE to IO[1], CE/RE to IO[2], essential
                Data([0xB6, 0x0A, lpfSetting]), // LPF = 1250 kHz
                
                //ADC sampling mode
                Data([0xB6, 0x09, 0x00]), // Single-conversion mode
                Data([0xB6, 0x08, 0x2D]), // OSR = 1024, avg = 4, signed
                Data([0xB6, 0x07, 0x00]) // Warm-up clock = 8 cycles
            ]
            
        case .voltage:
            return [
                Data([0xB6, 0x0F, VWE_HEX]), // Set WE voltage
                Data([0xB8, 0x00])          // GetADC: reads latest value
            ]
        }
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
                        run(0)
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
                        let voltage = UserDefaults.standard.double(forKey: "WorkingElectrodeVoltage")
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
                    session.invalidate()
                    self.delegate?.nfcManager(
                        self,
                        didReadCalibrationPages: self.rawCalibPages,
                        rawAdcResponse: response
                    )
                default:
                    run(index + 1)
                }
            }
        }
        
        run(0)
    }
    
}
