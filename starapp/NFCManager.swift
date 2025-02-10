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
            Data([0x30, 0x28]),  // Read EEPROM Page 0x28 (3028)
            Data([0x30, 0x2C]),  // Read EEPROM Page 0x2C (302c)
            Data([0x30, 0x30]),  // Read EEPROM Page 0x30 (3030)
            Data([0xB6, 0x04, 0x8F]),  // Write ADC Divisor Register (b6048f)
            Data([0xB6, 0x05, 0x00]),  // Write ADC Prescaler Register (b60500)-essential
            Data([0xB6, 0x09, 0x00]),  // Write ADC Mode Config Register (Single Conversion Mode) (b60900)-essential
            Data([0xB6, 0x11, 0x01]),  // Write Potentiostat Config (b61101)
            Data([0xB6, 0x18, 0x0F]),   // Write Sensor Config (Potentiostat ON, ADC ON, DAC ON) (b6180f)
            Data([0xB6, 0x0A, 0x01]),  // Set ADC LPF to 1250 kHz (b60a01)
            Data([0xB6, 0x08, 0x29]),  // Write ADC Bit Config (b6082d), unsigned (only positive)
            Data([0xB6, 0x10, 0x00]),  // Map RE, WE, CE to IO[0] (b6100)
            Data([0xB6, 0x07, 0x64]), // Warm_Clock = 104
            // First ADC Read at 700mV
            Data([0xB6, 0x0E, 0x00]),  // Set VRE = 0.00V (Ground)
            Data([0xB6, 0x0F, 0x8C]), // 0x8C (140 in decimal) → 140 × 5mV = 700mV
            Data([0xB8, 0x00]),  // Get ADC Reading (b800)
            Data([0xB8, 0x00]),  // Get ADC Reading (b800)
            Data([0xB8, 0x00])  // Get ADC Reading (b800)
        ]
        
        // Array to accumulate ADC responses from each 0xB8, 0x00 command.
        var adcResponses: [Int] = []
        let startTime = Date().timeIntervalSince1970 //start timer
        
        func executeNextCommand(index: Int) {
            guard index < commandSequence.count else {
                // Calculate the average from the accumulated ADC responses.
                let average: Int
                if adcResponses.isEmpty {
                    average = 0
                } else {
                    let total = adcResponses.reduce(0, +)
                    average = total / adcResponses.count
                }
                
                // Constants (update with real calibration values)
                let baselineADC = 160  // ADC value at 0 mM lactate
                let sensitivityADC = 140.0  // Sensitivity in ADC counts per mM lactate
                
                // Convert ADC to lactate concentration
                let lactate = (Double(average) - Double(baselineADC)) / sensitivityADC

                // Output results
                print("DEBUG: ADC Value: \(average)")
                print("DEBUG: Estimated Lactate Concentration: \(lactate) mM")

                UserDefaults.standard.set(average, forKey: "Adc")
                UserDefaults.standard.set(lactate, forKey: "Lactate")
                print("DEBUG: Average ADC Value: \(average)")
                let endTime = Date().timeIntervalSince1970 // ✅ End timing after final command
                let elapsedTime = endTime - startTime
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
                // Only save responses from the ADC Read command (0xB8, 0x00)
                // If this is an ADC reading command (0xB8, 0x00),
                // convert the response from hex to an integer and add it to the list.
                if command.count == 2,
                   command[0] == 0xB8,
                   command[1] == 0x00 {

                    // Convert raw hex response to integer
                    var adcValue = Int(responseHex, radix: 16) ?? 0

                    // Extract only the last 11 bits
                    adcValue = adcValue & 0x7FF  // 0x7FF = 2047 (11-bit mask)

                    // Convert from two’s complement (if MSB (bit 10) is 1, it's negative)
                    if (adcValue & 0x400) != 0 {  // 0x400 = 1024 (bit 10 in 11-bit numbers)
                        adcValue -= 2048  // Convert from two’s complement
                    }

                    adcResponses.append(adcValue)
                }

                
                // ✅ Execute the next command in the sequence
                executeNextCommand(index: index + 1)
            }
        }
        
        // Start execution of the first command
        executeNextCommand(index: 0)
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError _: Error) {}
    
}

// ✅ Helper function to convert Data to Hex String
extension Data {
    func toHexString() -> String {
        return self.map { String(format: "%02x", $0) }.joined()
    }
}
