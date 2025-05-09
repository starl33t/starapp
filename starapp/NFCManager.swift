import CoreNFC
import SwiftUI

class NFCManager: NSObject, NFCTagReaderSessionDelegate {
    private var session: NFCTagReaderSession?
    private var adcReferenceValues: [Int: Int] = [:]
    private var bufferOffsets: [Int: Double] = [:]
    
    private var VRE_HEX: UInt8 = 0x00
    private var VWE_HEX: UInt8 = 0x00
    // Calibration polynomial coefficients: [b0, b1, b2, b3] for I(ADC) = b0 + b1*ADC + b2*ADC² + b3*ADC³
    private var polyCoeffs: [Double] = [0, 0, 0, 0]
    
    // Accumulate ADC responses from a successful iteration.
    private var adcResponses: [Int] = []
    
    //UID
    private var fullUID: [UInt8] = []
    
    
    // MARK: - Public Entry Point
    
    func beginScanning() {
        guard NFCTagReaderSession.readingAvailable else {
            print("DEBUG: NFC not available")
            return
        }
        session = NFCTagReaderSession(pollingOption: [.iso14443], delegate: self)
        session?.alertMessage = "Tap on wearable"
        session?.begin()
        UserDefaults.standard.set(true, forKey: "isScanning")
    }
    
    // MARK: - NFCTagReaderSessionDelegate Methods
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {}
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let firstTag = tags.first, case let .miFare(miFareTag) = firstTag else {
            session.invalidate(errorMessage: "Invalid tag")
            return
        }
        session.connect(to: firstTag) { [weak self] error in
            if let error = error {
                print("DEBUG: Connection failed – \(error.localizedDescription)")
                session.invalidate(errorMessage: "Connection failed.")
                return
            }
            print("DEBUG: Connected to NFC potentiostat chip.")
            self?.executeCommandSequence(tag: miFareTag, session: session)
        }
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        print("DEBUG: Session invalidated – \(error.localizedDescription)")
        UserDefaults.standard.set(false, forKey: "isScanning")
    }
    
    // MARK: - Full Command Sequence Execution
    
    /// Executes the full sequence: setup, voltage update, then ADC polling.
    /// If the ADC value is zero, the entire sequence is restarted.
    private func executeCommandSequence(tag: NFCMiFareTag, session: NFCTagReaderSession) {
        // Reset state for a new iteration.
        adcReferenceValues.removeAll()
        bufferOffsets.removeAll()
        adcResponses.removeAll()
        
        let startTime = Date().timeIntervalSince1970
        
        // Execute the setup commands.
        executeCommands(buildSetupCommands(), tag: tag, session: session) { [weak self] in
            guard let self = self else { return }
            // Execute voltage update commands (which may be updated based on calibration data).
            self.executeCommands(self.buildVoltageCommands(), tag: tag, session: session) {
                // Finally, poll the ADC.
                self.pollAdcUntilNonZero(tag: tag, session: session, startTime: startTime)
            }
        }
    }
    
    /// Executes an array of commands sequentially.
    private func executeCommands(_ commands: [Data],
                                 tag: NFCMiFareTag,
                                 session: NFCTagReaderSession,
                                 completion: @escaping () -> Void) {
        func executeNext(index: Int) {
            guard index < commands.count else {
                completion()
                return
            }
            let command = commands[index]
            tag.sendMiFareCommand(commandPacket: command) { response, error in
                if let error = error {
                    print("DEBUG: Command \(command.toHexString()) failed – \(error.localizedDescription)")
                    session.invalidate(errorMessage: "Command failed.")
                    return
                }
                print("DEBUG: Command \(command.toHexString()) Response: \(response.toHexString())")
                self.processResponse(for: command, response: response)
                executeNext(index: index + 1)
            }
        }
        executeNext(index: 0)
    }
    
    /// Builds the setup commands (calibration, configuration, etc.).
    private func buildSetupCommands() -> [Data] {
        return [
            Data([0xB4, 0xFF]),         // Clear Error Flags
            Data([0x30, 0x00]),         // UID0, UID1, UID2, BBCO
            Data([0x30, 0x01]),         // UID3, UID4, UID5, UID6
            Data([0x30, 0x28]),         // EEPROM 0x28: Calibration for +16µA and +8µA
            Data([0x30, 0x29]),         // EEPROM 0x29: Calibration for 0µA and -8µA
            Data([0x30, 0x2A]),         // EEPROM 0x2A: Calibration for -16µA
            Data([0x30, 0x30]),         // EEPROM 0x30: Buffer Offsets for RE and WE
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
    
    /// Builds the voltage-setting commands.
    private func buildVoltageCommands() -> [Data] {
        return [
            Data([0xB6, 0x0E, VRE_HEX]), // Set VRE
            Data([0xB6, 0x0F, VWE_HEX])  // Set VWE
        ]
    }
    
    // MARK: - Response Processing
    
    /// Processes a response based on the sent command.
    private func processResponse(for command: Data, response: Data) {
        // Process calibration responses (commands starting with 0x30)
        if command.count == 2, command[0] == 0x30 {
            let page = command[1]
            switch page {
            case 0x00: // page 0: UID0, UID1, UID2, BCC0
                if response.count >= 4 {
                    // Reset the array or append accordingly
                    fullUID = []
                    fullUID.append(response[0])  // UID0
                    fullUID.append(response[1])  // UID1
                    fullUID.append(response[2])  // UID2
                    // Optionally, store BCC0 separately if needed
                    let bcc0 = response[3]
                    print("DEBUG: Page 0 => UID0=\(String(format: "%02X", response[0])), UID1=\(String(format: "%02X", response[1])), UID2=\(String(format: "%02X", response[2])), BCC0=\(String(format: "%02X", bcc0))")
                }
            case 0x01: // page 1: UID3, UID4, UID5, UID6
                if response.count >= 4 {
                    fullUID.append(response[0])  // UID3
                    fullUID.append(response[1])  // UID4
                    fullUID.append(response[2])  // UID5
                    fullUID.append(response[3])  // UID6
                    print("DEBUG: Page 1 => UID3=\(String(format: "%02X", response[0])), UID4=\(String(format: "%02X", response[1])), UID5=\(String(format: "%02X", response[2])), UID6=\(String(format: "%02X", response[3]))")
                }
            case 0x28:
                if response.count >= 4 {
                    let adc16 = parseInt16(from: response, start: 0)
                    let adc8  = parseInt16(from: response, start: 2)
                    adcReferenceValues[Int(adc16)] = 16
                    adcReferenceValues[Int(adc8)]  = 8
                    print("DEBUG: Calibration for +16µA -> ADC Value: \(adc16)")
                    print("DEBUG: Calibration for +8µA -> ADC Value: \(adc8)")
                }
            case 0x29:
                if response.count >= 4 {
                    let adc0  = parseInt16(from: response, start: 0)
                    let adcM8 = parseInt16(from: response, start: 2)
                    adcReferenceValues[Int(adc0)]  = 0
                    adcReferenceValues[Int(adcM8)] = -8
                    print("DEBUG: Calibration for 0µA -> ADC Value: \(adc0)")
                    print("DEBUG: Calibration for -8µA -> ADC Value: \(adcM8)")
                }
            case 0x2A:
                if response.count >= 2 {
                    let adcM16 = parseInt16(from: response, start: 0)
                    adcReferenceValues[Int(adcM16)] = -16
                    print("DEBUG: Calibration for -16µA -> ADC Value: \(adcM16)")
                }
            case 0x30:
                if response.count >= 4 {
                    let reOffset = Double(parseInt16(from: response, start: 0)) / 100.0
                    let weOffset = Double(parseInt16(from: response, start: 2)) / 100.0
                    bufferOffsets[0] = reOffset
                    bufferOffsets[1] = weOffset
                    updateVoltageValues(withREOffset: reOffset, weOffset: weOffset)
                }
            default:
                break
            }
        }
    }
    
    /// Computes new voltage register values based on calibration.
    private func updateVoltageValues(withREOffset reOffset: Double, weOffset: Double) {
        let expectedRE = 400.0  // in mV
        let expectedWE = 1200.0  // in mV
        VRE_HEX = UInt8(round((expectedRE - reOffset) / 5.0))
        VWE_HEX = UInt8(round((expectedWE - weOffset) / 5.0))
        print("DEBUG: Computed VRE=0x\(String(format:"%02X", VRE_HEX)), VWE=0x\(String(format:"%02X", VWE_HEX))")
    }
    
    // MARK: - ADC Polling Loop
    
    /// Polls the ADC by sending the ADC read command.
    /// If the returned ADC value is zero, the entire command sequence is restarted.
    private func pollAdcUntilNonZero(tag: NFCMiFareTag,
                                     session: NFCTagReaderSession,
                                     startTime: TimeInterval) {
        tag.sendMiFareCommand(commandPacket: Data([0xB8, 0x00])) { response, error in
            if let error = error {
                print("DEBUG: ADC read failed – \(error.localizedDescription)")
                session.invalidate(errorMessage: "ADC read failed.")
                return
            }
            let adcValue = self.parseADCResponse(response)
            print("DEBUG: ADC read: \(adcValue)")
            if adcValue == 0 {
                // Restart the full sequence from the beginning.
                print("DEBUG: ADC value is zero, restarting full command sequence.")
                self.executeCommandSequence(tag: tag, session: session)
            } else {
                self.adcResponses.append(adcValue)
                self.finalizeSequence(startTime: startTime, session: session)
            }
        }
    }
    
    // MARK: - Finalization and Calibration
    
    /// Finalizes the process: calculates the calibration polynomial, prints readings, and ends the session.
    private func finalizeSequence(startTime: TimeInterval, session: NFCTagReaderSession) {
        solvePolynomialForCurrent()
        print("DEBUG: ADC Readings: \(adcResponses)")
        for raw in adcResponses {
            print("DEBUG: ADC=\(raw) => Current≈\(currentFromAdc(adcValue: Double(raw))) µA")
        }
        
        let adc = adcResponses.isEmpty ? 0 : adcResponses.reduce(0, +) / adcResponses.count
        let current = currentFromAdc(adcValue: Double(adc))
        print("ADC Value: \(adc)")
        print("Current≈\(currentFromAdc(adcValue: Double(adc))) µA")
        
        UserDefaults.standard.set(adc, forKey: "Adc")
        UserDefaults.standard.set(current, forKey: "Current")
        
        let lactate = currentFromAdc(adcValue: Double(adc)) * 0.9
        UserDefaults.standard.set(lactate, forKey: "Lactate")
        print("Lactate Value: \(lactate) mM")
        
        let uidString = fullUID.map { String(format: "%02X", $0) }
            .joined(separator: ":")
        print("Full UID: \(uidString)")
        UserDefaults.standard.set(uidString, forKey: "uidString")
        
        UserDefaults.standard.set(polyCoeffs, forKey: "polyCoeffs")
        
        let elapsedTime = Date().timeIntervalSince1970 - startTime
        print("NFC Process Time: \(elapsedTime) seconds")
        
        
        session.alertMessage = "Done"
        session.invalidate()
        UserDefaults.standard.set(false, forKey: "isScanning")
    }
    
    /// Solves for the polynomial calibration curve based on five calibration points.
    private func solvePolynomialForCurrent() {
        guard adcReferenceValues.count == 5 else {
            print("DEBUG: Not enough calibration data (need 5).")
            return
        }
        let sortedKeys = adcReferenceValues.keys.sorted()
        let X = sortedKeys.map { Double($0) }
        let Y = sortedKeys.map { Double(adcReferenceValues[$0]!) }
        
        var S = [Double](repeating: 0, count: 7)  // S0...S6
        var T = [Double](repeating: 0, count: 4)  // T0...T3
        
        for i in 0..<X.count {
            let x = X[i]
            let y = Y[i]
            let x2 = x * x, x3 = x2 * x, x4 = x3 * x, x5 = x4 * x, x6 = x5 * x
            S[0] += 1; S[1] += x; S[2] += x2; S[3] += x3; S[4] += x4; S[5] += x5; S[6] += x6
            T[0] += y; T[1] += x * y; T[2] += x2 * y; T[3] += x3 * y
        }
        
        var M: [[Double]] = [
            [S[0], S[1], S[2], S[3]],
            [S[1], S[2], S[3], S[4]],
            [S[2], S[3], S[4], S[5]],
            [S[3], S[4], S[5], S[6]]
        ]
        var B = T
        
        let dim = 4
        for i in 0..<dim {
            var maxRow = i
            for r in (i+1)..<dim {
                if abs(M[r][i]) > abs(M[maxRow][i]) { maxRow = r }
            }
            if i != maxRow {
                M.swapAt(i, maxRow)
                B.swapAt(i, maxRow)
            }
            let pivot = M[i][i]
            if abs(pivot) < 1e-14 { M[i][i] = 1e-14 }
            for c in i..<dim { M[i][c] /= pivot }
            B[i] /= pivot
            for r in (i+1)..<dim {
                let factor = M[r][i]
                for c in i..<dim { M[r][c] -= factor * M[i][c] }
                B[r] -= factor * B[i]
            }
        }
        
        var coeffs = [Double](repeating: 0, count: dim)
        for i in stride(from: dim - 1, through: 0, by: -1) {
            var sum = 0.0
            for c in (i+1)..<dim { sum += M[i][c] * coeffs[c] }
            coeffs[i] = B[i] - sum
        }
        polyCoeffs = coeffs
        print("DEBUG: Polynomial coefficients: \(polyCoeffs)")
    }
    
    /// Computes the current (µA) from an ADC value using the calibration polynomial.
    private func currentFromAdc(adcValue: Double) -> Double {
        return polyCoeffs.enumerated().reduce(0) { sum, pair in
            let (index, coeff) = pair
            return sum + coeff * pow(adcValue, Double(index))
        }
    }
    
    // MARK: - Data Parsing Helpers
    
    /// Converts two bytes starting at a given offset into a signed 16-bit integer.
    private func parseInt16(from data: Data, start: Int) -> Int16 {
        let value = UInt16(data[start]) << 8 | UInt16(data[start + 1])
        return Int16(bitPattern: value)
    }
    
    /// Parses an ADC response by extracting the top 16 bits and converting from two's complement.
    private func parseADCResponse(_ response: Data) -> Int {
        let hexString = response.toHexString()
        var raw = Int(hexString, radix: 16) ?? 0
        raw &= 0xFFFF
        if (raw & 0x8000) != 0 { raw -= 65536 }
        return raw
    }
}

// MARK: - Data Extension

extension Data {
    func toHexString() -> String {
        return map { String(format: "%02x", $0) }.joined()
    }
}
