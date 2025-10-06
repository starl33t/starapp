import Foundation
import CoreNFC

public protocol NFCManagerDelegate: AnyObject {
    func nfcManager(_ manager: NFCManager,
                    didReadCalibrationPages pages: [UInt8: Data],
                    rawAdcResponse: Data,
                    applied_mV: Int)
    func nfcManager(_ manager: NFCManager, didFailWith error: Error)
}

public final class NFCManager: NSObject, NFCTagReaderSessionDelegate {
    public weak var delegate: NFCManagerDelegate?
    private var session: NFCTagReaderSession?
    private var rawCalibPages: [UInt8: Data] = [:]
    private var vre = Data([0xB6, 0x0E, 0x00]) // RE
    private var vwe = Data([0xB6, 0x0F, 0x00]) // WE
    private let  adc = Data([0xB8, 0x00])
    private var startUptime: TimeInterval = 0
    private var deadline: TimeInterval = 0
    private var cvStartDAC: Int = 0
    private var cvTargetDAC: Int = 0
    private var reOffset_mV: Double = 0.0
    private var weOffset_mV: Double = 0.0
    private var dropCount = 0
    private var activeScanTime: Double = 0
    
    private let appState: AppState
    init(appState: AppState) { self.appState = appState }
    
    // MARK: Public
    public func beginScanning() {
        guard NFCTagReaderSession.readingAvailable else {
            delegate?.nfcManager(self, didFailWith: NSError(
                domain: "NFCManager", code: 0,
                userInfo: [NSLocalizedDescriptionKey: "NFC not available"]))
            return
        }
        session = NFCTagReaderSession(pollingOption: [.iso14443], delegate: self)
        session?.begin()
    }
    
    // MARK: NFCTagReaderSessionDelegate
    public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {}
    
    public func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        delegate?.nfcManager(self, didFailWith: error)
    }
    
    public func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard tags.count == 1, case let .miFare(tag) = tags[0] else {
            session.restartPolling()
            return
        }
        session.connect(to: tags[0]) {error in
            guard error == nil else { session.restartPolling(); return }
            
            self.rawCalibPages.removeAll(keepingCapacity: true)
            self.executeCommands( // Read calibration/offset pages + config writes
                Self.setupCommands,
                tag: tag,
                session: session,
                drivesWE: self.appState.drivesWE,
                restartOnFailure: true // safe during setup
            ) {
                self.startScan(tag: tag, session: session)
            }
        }
    }
    // MARK: Scan entry
    private func startScan(tag: NFCMiFareTag, session: NFCTagReaderSession) {
        let drivesWE = appState.drivesWE  // Freeze policy for the whole session
        let bias = appState.biasVoltage
        let re400 = CalibrationService.mVToDACInt(400.0, offset_mV: self.reOffset_mV) // 400 mV codes (with offsets)
        let we400 = CalibrationService.mVToDACInt(400.0, offset_mV: self.weOffset_mV)
        let reTarget = CalibrationService.mVToDACInt(400.0 + abs(bias), offset_mV: self.reOffset_mV) // Target codes
        let weTarget = CalibrationService.mVToDACInt(400.0 + max(0.0, bias), offset_mV: self.weOffset_mV)
        let stationary: Data = drivesWE ? Data([0xB6, 0x0E, UInt8(re400)]) : Data([0xB6, 0x0F, UInt8(we400)])  // drive/hold re/we
        let mode: ScanMode = appState.research ? appState.scanMode : .ca  // Effective mode: non-research always CA
        
        if mode == .ca { // DAC for CA
            cvStartDAC  = drivesWE ? weTarget : reTarget
            cvTargetDAC = cvStartDAC            // span == 0 -> CA streaming branch in cvTick
        } else { // DACs for CV
            cvStartDAC  = drivesWE ? we400    : re400
            cvTargetDAC = drivesWE ? weTarget : reTarget
        }
        
        activeScanTime = appState.research ? appState.researchScanTime : appState.nonResearchScanTime
        
        let tickBuffer: Double
        if appState.research {
            switch appState.scanMode {
            case .ca:
                tickBuffer = 0.118
            case .cv:
                tickBuffer = 0.121
            }
        } else {
            tickBuffer = 0.0       // CA non-research → no buffer
        }
        // === Unified CA/CV streaming (non-research forces scanTime=1.0 upstream) ===
        startUptime = ProcessInfo.processInfo.systemUptime
        deadline    = startUptime + activeScanTime + tickBuffer
        dropCount = 5
        
        executeCommands(
            [stationary],
            tag: tag,
            session: session,
            drivesWE: drivesWE,
            restartOnFailure: true
        ) {
            if drivesWE {
                self.vre[2] = stationary[2]
                self.vwe[2] = UInt8(self.cvStartDAC)
            } else {
                self.vwe[2] = stationary[2]
                self.vre[2] = UInt8(self.cvStartDAC)
            }
            self.cvTick(tag: tag, session: session, drivesWE: drivesWE)
        }
    }
    
    private func cvTick(tag: NFCMiFareTag, session: NFCTagReaderSession, drivesWE: Bool) {
   
        let span = abs(cvTargetDAC - cvStartDAC)
        if span == 0 {
            let code = UInt8(cvTargetDAC)
            if drivesWE { vwe[2] = code } else { vre[2] = code }
            let write = drivesWE ? vwe : vre
            
            //CA
            executeCommands([write, adc], tag: tag, session: session, drivesWE: drivesWE, restartOnFailure: true) {
                if ProcessInfo.processInfo.systemUptime <= self.deadline {
                    self.cvTick(tag: tag, session: session, drivesWE: drivesWE)
                } else {
                    session.invalidate()
                }
            }
            return
        }
        // CV triangle 0→1→0 over two halves
        let half  = max(0.001, activeScanTime / 2.0)
        let phase = min(ProcessInfo.processInfo.systemUptime - startUptime, activeScanTime)
        let dir   = (cvTargetDAC >= cvStartDAC) ? 1 : -1
        let x     = phase / half
        let frac  = (x <= 1.0) ? x : max(0.0, 2.0 - x)
        let dac   = cvStartDAC + dir * Int((Double(span) * frac).rounded())
        
        let code = UInt8(dac)
        if drivesWE { vwe[2] = code } else { vre[2] = code }
        let write = drivesWE ? vwe : vre
        
        // CV branch
        executeCommands([write, adc], tag: tag, session: session, drivesWE: drivesWE, restartOnFailure: true) {
            if ProcessInfo.processInfo.systemUptime <= self.deadline {
                self.cvTick(tag: tag, session: session, drivesWE: drivesWE)
            } else {
                session.invalidate()
            }
        }
    }
    
    // MARK: Command executor (per-command retry; early error; frozen drivesWE)
    private func executeCommands(
        _ commands: [Data],
        tag: NFCMiFareTag,
        session: NFCTagReaderSession,
        drivesWE: Bool,
        restartOnFailure: Bool,
        completion: @escaping () -> Void
    ) {
        let maxAttempts = 5
        var attempt = 0
        
        func run(_ index: Int) {
            guard index < commands.count else { completion(); return }
            let cmd = commands[index]
            let opcode = cmd[0]
            
            tag.sendMiFareCommand(commandPacket: cmd) {response, error in
                
                func failAndRetry() {
                    attempt += 1
                    if attempt < maxAttempts {
                        run(index)
                    } else {
                        if restartOnFailure { session.restartPolling() }
                        else { session.invalidate() }
                    }
                }
                
                switch opcode {
                case 0x30: // READ page
                    guard response.count >= 16 else { failAndRetry(); return }
                    self.rawCalibPages[cmd[1]] = response
                    if cmd[1] == 0x30 {
                        let (reOff, weOff) = CalibrationService.offsets(fromPage30: response)
                        self.reOffset_mV = reOff
                        self.weOffset_mV = weOff
                    }
                    attempt = 0
                    run(index + 1)
                    
                case 0xB6: // WRITE register (ACK 0x1A)
                    guard response.first == 0x1A else { failAndRetry(); return }
                    attempt = 0
                    run(index + 1)
                    
                case 0xB8: // ADC read (0x1A + 2 bytes)
                    guard response.count == 3, response.first == 0x1A else { failAndRetry(); return }
                    
                    if self.dropCount > 0 {
                        self.dropCount -= 1
                        completion()
                        return
                    }
                    
                    let electrode: CalibrationService.Electrode = drivesWE ? .we : .re
                    let applied_mV = CalibrationService.appliedMillivolts(
                        activeElectrode: electrode,
                        vreHex: self.vre[2],
                        vweHex: self.vwe[2],
                        reOffset_mV: self.reOffset_mV,
                        weOffset_mV: self.weOffset_mV
                    )
                    
                    if self.appState.research {
                        // 🔬 Research mode → send every ADC as normal
                        self.delegate?.nfcManager(
                            self, didReadCalibrationPages: self.rawCalibPages,
                            rawAdcResponse: response,
                            applied_mV: applied_mV)
                        completion()
                    } else {
                        // ⚙️ Non-research mode → only send the very last ADC
                        if ProcessInfo.processInfo.systemUptime >= self.deadline {
                            self.delegate?.nfcManager(
                                self, didReadCalibrationPages: self.rawCalibPages,
                                rawAdcResponse: response,
                                applied_mV: applied_mV)
                        }
                        completion()
                    }

                default:
                    attempt = 0
                    run(index + 1)
                }
            }
        }
        run(0)
    }
    private static let setupCommands: [Data] = [
        Data([0xB4, 0xFF]),   // reset/enter mode
        Data([0x30, 0x28]),   // read calibration page
        Data([0x30, 0x30]),   // read offsets page
        Data([0xB6, 0x04, 0x8F]),   // Divisor = 143
        Data([0xB6, 0x05, 0x00]),   // Prescaler = 0, essential
        Data([0xB6, 0x11, 0x01]),   // 3-electrode, RE ≠ GND, 20 µA,essential
        Data([0xB6, 0x18, 0x0F]),   // AFE + DAC + ADC on
        Data([0xB6, 0x10, 0x18]),   // Map WE to IO[2], CE to IO[0] and RE to IO[1]
        Data([0xB6, 0x0A, 0x01]),   // LPF = 1250 kHz
        Data([0xB6, 0x09, 0x02]),   // Continuous ADC sampling
        Data([0xB6, 0x08, 0x2D]),   // OSR = 1024, avg = 4, signed
        Data([0xB6, 0x07, 0x00])    // Warm-up clock = 8 cycles
    ]
}
