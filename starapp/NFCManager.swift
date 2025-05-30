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
            return [
                // Calibration & Offset
                Data([0xB4, 0xFF]), // Clear error flags
                Data([0x30, 0x28]), // 5 ADC calibration points (-16 µA, -8 µA, 0 µA, +8 µA, +16 µA)
                Data([0x30, 0x30]), // Page 0x30 → RE_BUFF_OFFSET, WE_BUFF_OFFSET
                
                // ADC Frequency setup (50 kHz)
                Data([0xB6, 0x04, 0x8F]), // Divisor = 143
                Data([0xB6, 0x05, 0x00]), // Prescaler = 0
                
                //Config potentiostat
                Data([0xB6, 0x11, 0x01]), // Enable potentiostat
                Data([0xB6, 0x18, 0x0F]),  // AFE + DAC + ADC on
                Data([0xB6, 0x10, 0x06]), // Map RE to IO[0], WE to IO[1], CE to IO[2]
                Data([0xB6, 0x0A, 0x01]), // LPF = 1250 kHz
                
                //ADC sampling mode
                Data([0xB6, 0x09, 0x00]), // Single-conversion mode
                Data([0xB6, 0x08, 0x2D]), // OSR = 1024, avg = 4, signed
                Data([0xB6, 0x07, 0x81]) // Warm-up clock = 24 cycles
            ]
            
        case .voltage:
            return [
                Data([0xB6, 0x0E, VRE_HEX]), // Set RE voltage
                Data([0xB6, 0x0F, VWE_HEX]), // Set WE voltage
                Data([0xB8, 0x00])          // GetADC: reads latest continuous value
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

                if cmd.first == 0x30 {
                    if response.count < 16 {
                        failAndRetry()
                        return
                    }
                    
                    self.rawCalibPages[cmd[1]] = response
                    
                    if cmd[1] == 0x30, response.count >= 4 {
                        let reOffset = Double(CalibrationService.parseInt16(from: response, start: 0)) / 100.0
                        let weOffset = Double(CalibrationService.parseInt16(from: response, start: 2)) / 100.0
                        self.VRE_HEX = UInt8(round((400.0 - reOffset) / 5.0))
                        self.VWE_HEX = UInt8(round((1200.0 - weOffset) / 5.0))
                    }
                    run(index + 1)
                    return
                }
                
                if cmd.first == 0xB6 {
                    if response.count < 1 || response[0] != 0x1A {
                        failAndRetry()
                        return
                    }
                    run(index + 1)
                    return
                }
                
                if cmd.first == 0xB8 {
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
                    return
                }
                
                run(index + 1)
            }
        }
        
        run(0)
    }
    
}
