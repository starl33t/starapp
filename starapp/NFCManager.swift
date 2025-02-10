import CoreNFC
import SwiftUI

class NFCManager: NSObject, NFCTagReaderSessionDelegate {
    private var session: NFCTagReaderSession?
    
    func beginScanning() {
        guard NFCTagReaderSession.readingAvailable else {
            print("DEBUG: NFC not available")
            return
        }
        session = NFCTagReaderSession(pollingOption: [.iso14443], delegate: self, queue: nil)
        session?.alertMessage = "Hold steady on your wearable"
        session?.begin()
    }
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {}
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let tag = tags.first, case let .miFare(miFareTag) = tag else {
            session.invalidate(errorMessage: "Invalid tag")
            return
        }
        
        session.connect(to: tag) { [weak self] error in
            if let error = error {
                print("DEBUG: Connection failed - \(error.localizedDescription)")
                session.invalidate(errorMessage: "Connection failed.")
                return
            }
            
            print("DEBUG: Connected to NFC potentiostat chip.")
            self?.executeCommandSequence(tag: miFareTag, session: session)
        }
    }
    
    /// ✅ Executes a sequence of NFC commands in order
    private func executeCommandSequence(tag: NFCMiFareTag, session: NFCTagReaderSession) {
        let commandSequence: [Data] = [
            Data([0xB4, 0xFF]),  // Clear Error Flags (b4ff)
            Data([0x30, 0x28]),  // Read EEPROM Page 0x28 (3028) - uid
            Data([0x30, 0x2C]),  // Read EEPROM Page 0x2C (302c) - internal calibration
            Data([0x30, 0x30]),  // Read EEPROM Page 0x30 (3030)
            Data([0xB6, 0x04, 0x8F]),  // Write ADC Divisor Register (b6048f)
            Data([0xB6, 0x05, 0x00]),  // Write ADC Prescaler Register (b60500)-essential
            Data([0xB6, 0x09, 0x00]),  // Write ADC Mode Config Register (Single Conversion Mode) (b60900)-essential
            Data([0xB6, 0x11, 0x01]),  // Write Potentiostat Config (b61101)
            Data([0xB6, 0x18, 0x0F]),   // Write Sensor Config (Potentiostat ON, ADC ON, DAC ON) (b6180f)
            Data([0xB6, 0x0A, 0x01]),  // Set ADC LPF to 1250 kHz (b60a01)
            Data([0xB6, 0x08, 0x2D]),  // Write ADC Bit Config (b6082d), signed mode
            Data([0xB6, 0x10, 0x00]),  // Map RE, WE, CE to IO[0] (b6100)
            Data([0xB6, 0x07, 0x64]), // Warm_Clock = 104
            // First ADC Read at 700mV
            Data([0xB6, 0x0E, 0x00]),  // Set VRE = 0.00V (Ground)
            Data([0xB6, 0x0F, 0x8C]), // 0x8C (140 in decimal) → 140 × 5mV = 700mV
            Data([0xB8, 0x00]),  // Get ADC Reading (b800)
            Data([0xB8, 0x00]),  // Get ADC Reading (b800)
            Data([0xB8, 0x00])  // Get ADC Reading (b800)
        ]
        
        var adcResponses: [Int] = []
        var chipID = ""
        var second302C = 0
        var first3030 = 0
        
        let startTime = Date().timeIntervalSince1970
        
        func executeNextCommand(index: Int) {
            guard index < commandSequence.count else {
                let averageADC = adcResponses.isEmpty ? 0 : adcResponses.reduce(0, +) / adcResponses.count
                
                // ✅ Predict ADC zero-point using `302C` and `3030`
                let predictedBaseline = estimateBaselineFromCalibration(second302C, first3030)
                
                // ✅ Apply per-chip correction for lactate calculation
                let sensitivityADC = -0.009206
                let lactate = (Double(averageADC) - Double(predictedBaseline)) * sensitivityADC
                
                // ✅ Output results
                print("DEBUG: Chip ID: \(chipID)")
                print("DEBUG: Stored Calibration Zero-Point: \(predictedBaseline)")
                print("DEBUG: ADC Value: \(averageADC)")
                print("DEBUG: Estimated Lactate Concentration: \(lactate) mM")
                
                UserDefaults.standard.set(averageADC, forKey: "Adc")
                UserDefaults.standard.set(lactate, forKey: "Lactate")
                
                let elapsedTime = Date().timeIntervalSince1970 - startTime
                print("DEBUG: NFC Process Time: \(elapsedTime) seconds")
                
                session.alertMessage = "Done"
                session.invalidate()
                return
            }
            
            let command = commandSequence[index]
            tag.sendMiFareCommand(commandPacket: command) { response, error in
                if let error = error {
                    print("DEBUG: Command \(command.toHexString()) failed - \(error.localizedDescription)")
                    session.invalidate(errorMessage: "Command failed.")
                    return
                }
                
                let responseHex = response.toHexString()
                print("DEBUG: Command \(command.toHexString()) Response: \(responseHex)")
                
                if command == Data([0x30, 0x28]) {
                    chipID = String(responseHex.prefix(8))
                } else if command == Data([0x30, 0x2C]) {
                    let start = responseHex.index(responseHex.startIndex, offsetBy: 4)
                    let end = responseHex.index(responseHex.startIndex, offsetBy: 8)
                    second302C = Int(responseHex[start..<end], radix: 16) ?? 0
                } else if command == Data([0x30, 0x30]) {
                    let start = responseHex.startIndex
                    let end = responseHex.index(start, offsetBy: 4)
                    first3030 = Int(responseHex[start..<end], radix: 16) ?? 0
                } else if command == Data([0xB8, 0x00]) {
                    var adcValue = Int(responseHex, radix: 16) ?? 0
                    adcValue = adcValue & 0x7FF
                    if (adcValue & 0x400) != 0 { adcValue -= 2048 }
                    adcResponses.append(adcValue)
                }
                executeNextCommand(index: index + 1)
            }
        }
        
        executeNextCommand(index: 0)
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError _: Error) {}
}

// ✅ Polynomial Regression Function for ADC Zero-Point Prediction
func estimateBaselineFromCalibration(_ second302C: Int, _ first3030: Int) -> Int {
    let A = 6.589e-5
    let B = 4.918e-7
    let C = 1.089e-6
    let D = -0.000252
    let E = 0.0123
    
    let estimatedBaseline =
    (A * Double(second302C)) +
    (B * Double(first3030)) +
    (C * pow(Double(second302C), 2)) +
    (D * Double(second302C) * Double(first3030)) +
    (E * pow(Double(first3030), 2))
    
    return Int(estimatedBaseline.rounded())
}

// ✅ Helper function to convert Data to Hex String
extension Data {
    func toHexString() -> String {
        return self.map { String(format: "%02x", $0) }.joined()
    }
}
