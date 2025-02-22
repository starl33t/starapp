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
        session?.alertMessage = "Tap phone's speaker over wearable"
        session?.begin()
        UserDefaults.standard.set(true, forKey: "isScanning")
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
    
    /// ✅ Executes a sequence of NFC commands until b60f8c returns "1a1a", then reads ADC
    private func executeCommandSequence(tag: NFCMiFareTag, session: NFCTagReaderSession) {
        let commandSequence: [Data] = [
            Data([0xB4, 0xFF]),  // Clear Error Flags
            Data([0x30, 0x28]),  // Read EEPROM Page 0x28
            Data([0x30, 0x2C]),  // Read EEPROM Page 0x2C
            Data([0x30, 0x30]),  // Read EEPROM Page 0x30
            Data([0xB6, 0x04, 0x8F]),  // Write ADC Divisor Register
            Data([0xB6, 0x05, 0x00]),  // Write ADC Prescaler Register
            Data([0xB6, 0x09, 0x00]),  // Write ADC Mode Config Register
            Data([0xB6, 0x11, 0x01]),  // Write Potentiostat Config
            Data([0xB6, 0x18, 0x0F]),  // Write Sensor Config
            Data([0xB6, 0x0A, 0x01]),  // Set ADC LPF
            Data([0xB6, 0x08, 0x2D]),  // Write ADC Bit Config
            Data([0xB6, 0x10, 0x00]),  // Map RE, WE, CE to IO[0]
            Data([0xB6, 0x07, 0x64]),  // Warm_Clock = 104
            Data([0xB6, 0x0E, 0x00]),  // Set VRE = 0.00V
            Data([0xB6, 0x0F, 0x8C])   // Command that we need to check response for
        ]

        let adcCommand = Data([0xB8, 0x00]) // Get ADC Reading
        
        let startTime = Date().timeIntervalSince1970 // Start timer

        func executeCommandLoop() {
            func executeNextCommand(index: Int) {
                guard index < commandSequence.count else {
                    print("DEBUG: Command sequence completed. Restarting...")
                    executeCommandLoop() // Restart sequence
                    return
                }
                
                let command = commandSequence[index]
                tag.sendMiFareCommand(commandPacket: command) { response, error in
                    if let error = error {
                        print("DEBUG: Command \(command.toHexString()) failed - \(error.localizedDescription)")
                        session.invalidate(errorMessage: "Try again!")
                        return
                    }
                    
                    let responseHex = response.toHexString()
                    print("DEBUG: Command \(command.toHexString()) Response: \(responseHex)")

                    // ✅ Handle response for b60f8c
                    if command == Data([0xB6, 0x0F, 0x8C]) {
                        if responseHex == "1a1a" {
                            print("DEBUG: Received expected response '1a1a'. Reading ADC next.")
                            readADCValue()
                            return
                        } else if responseHex == "8383" {
                            print("DEBUG: Response is '8383'. Asking user to hold closer...")
                            session.alertMessage = "Closer behind the speaker"
                            executeCommandLoop() // Restart the sequence
                            return
                        } else {
                            print("DEBUG: Unexpected response. Restarting command sequence.")
                            executeCommandLoop() // Restart the sequence
                            return
                        }
                    }

                    // ✅ Execute the next command
                    executeNextCommand(index: index + 1)
                }
            }
            
            // Start execution of the first command
            executeNextCommand(index: 0)
        }
        
        /// ✅ Function to read ADC value once b60f8c is "1a1a"
        func readADCValue() {
            tag.sendMiFareCommand(commandPacket: adcCommand) { response, error in
                if let error = error {
                    print("DEBUG: ADC command failed - \(error.localizedDescription)")
                    session.invalidate(errorMessage: "ADC command failed.")
                    return
                }
                
                let responseHex = response.toHexString()
                print("DEBUG: ADC Command Response: \(responseHex)")
                
                var adcValue = Int(responseHex, radix: 16) ?? 0
                adcValue = adcValue & 0x7FF  // Mask last 11 bits
                
                if (adcValue & 0x400) != 0 {  // Two's complement conversion
                    adcValue -= 2048
                }

                print("DEBUG: ADC Value: \(adcValue)")
                UserDefaults.standard.set(adcValue, forKey: "Adc")

                let elapsedTime = Date().timeIntervalSince1970 - startTime
                print("DEBUG: NFC Process Time: \(elapsedTime) seconds")

                session.alertMessage = "ADC Read Complete"
                session.invalidate()
                UserDefaults.standard.set(false, forKey: "isScanning")
            }
        }
        
        // Start looping execution
        executeCommandLoop()
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError _: Error) {
        UserDefaults.standard.set(false, forKey: "isScanning")
    }
}

// ✅ Helper function to convert Data to Hex String
extension Data {
    func toHexString() -> String {
        return self.map { String(format: "%02x", $0) }.joined()
    }
}
