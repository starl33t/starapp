import CoreNFC

class NFCManager: NSObject, NFCTagReaderSessionDelegate {
    var nfcSession: NFCTagReaderSession?

    // MARK: - Start Scanning
    func beginScanning() {
        guard NFCTagReaderSession.readingAvailable else {
            print("NFC is not available on this device.")
            return
        }
        
        nfcSession = NFCTagReaderSession(pollingOption: .iso14443, delegate: self, queue: nil)
        nfcSession?.alertMessage = "Hold your iPhone near the NFC tag."
        print("Starting NFC scanning session...")
        nfcSession?.begin()
    }

    // MARK: - NFCTagReaderSessionDelegate Methods
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("NFC session did become active.")
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        print("didDetect called with \(tags.count) tag(s).")
        
        // Log details about each detected tag
        for tag in tags {
            switch tag {
            case .miFare(let miFareTag):
                print("Detected MiFare tag with identifier: \(miFareTag.identifier.hexEncodedString())")
            default:
                print("Detected unsupported tag type.")
            }
        }
        
        guard let firstTag = tags.first else {
            session.invalidate(errorMessage: "No NFC tag found.")
            return
        }
        
        print("Attempting to connect to the first detected tag...")
        session.connect(to: firstTag) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("Connection failed: \(error.localizedDescription)")
                session.invalidate(errorMessage: "Connection failed.")
                return
            }
            
            print("Successfully connected to tag!")
            // Since we only support MiFare tags, we check only for that case.
            if case .miFare(let miFareTag) = firstTag {
                self.handleMiFareTag(session: session, miFareTag: miFareTag)
            } else {
                session.invalidate(errorMessage: "Unsupported NFC tag type.")
            }
        }
    }

    // MARK: - Handling MIFARE (Type 2) Tags
    private func handleMiFareTag(session: NFCTagReaderSession, miFareTag: NFCMiFareTag) {
        print("Handling MIFARE Tag (Type 2)")
        print("MIFARE Family: \(miFareTag.mifareFamily)")
        
        // Build the command packet to read from page 4.
        // 0x30 is the READ command for MIFARE Ultralight.
        // 0x04 is the starting page number.
        let commandPacket = Data([0x30, 0x04])
        print("Sending MiFare command: \(commandPacket.hexEncodedString())")
        
        miFareTag.sendMiFareCommand(commandPacket: commandPacket) { (response, error) in
            if let error = error {
                print("Failed to read pages: \(error.localizedDescription)")
                session.invalidate(errorMessage: "Read error.")
                return
            }
            
            print("Response Data (hex): \(response.hexEncodedString())")
            session.alertMessage = "MIFARE read successful!"
            session.invalidate()
        }
    }

    // MARK: - Session Invalidation Handler
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        print("NFC session invalidated: \(error.localizedDescription)")
    }
}

// MARK: - Data Extension for Hex String Conversion
extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02x", $0) }.joined()
    }
}

