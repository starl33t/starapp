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
        nfcSession?.begin()
    }

    // MARK: - NFCTagReaderSessionDelegate Methods
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("NFC session is now active.")
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let firstTag = tags.first else {
            session.invalidate(errorMessage: "No NFC tag found.")
            return
        }

        print("NFC Tag Detected.")

        session.connect(to: firstTag) { [weak self] error in
            guard let self = self else { return }

            if let error = error {
                print("Connection failed: \(error.localizedDescription)")
                session.invalidate(errorMessage: "Connection failed.")
                return
            }

            switch firstTag {
            case .miFare(let miFareTag):
                self.handleMiFareTag(session: session, miFareTag: miFareTag)
                
            case .iso7816(let iso7816Tag):
                self.handleISO7816Tag(session: session, iso7816Tag: iso7816Tag)
                
            default:
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

        miFareTag.sendMiFareCommand(commandPacket: commandPacket) { (response, error) in
            if let error = error {
                print("Failed to read pages: \(error.localizedDescription)")
                session.invalidate(errorMessage: "Read error.")
                return
            }

            print("Response Data (hex): \(response.hexEncodedString())")

            // Optionally, you might parse the response here.

            session.alertMessage = "MIFARE read successful!"
            session.invalidate()
        }
    }

    // MARK: - Handling ISO7816 Tags
    private func handleISO7816Tag(session: NFCTagReaderSession, iso7816Tag: NFCISO7816Tag) {
        print("Handling ISO7816 Tag.")

        // Example APDU command (this remains unchanged)
        let apduCommand = NFCISO7816APDU(
            instructionClass: 0x00,
            instructionCode: 0xA4,
            p1Parameter: 0x04,
            p2Parameter: 0x00,
            data: Data([0xD2, 0x76, 0x00, 0x00, 0x85, 0x01, 0x01]),
            expectedResponseLength: -1
        )

        iso7816Tag.sendCommand(apdu: apduCommand) { (response, sw1, sw2, error) in
            if let error = error {
                print("APDU command failed: \(error.localizedDescription)")
                session.invalidate(errorMessage: "APDU command failed.")
                return
            }

            print("Response Data: \(response.hexEncodedString())")
            print("Status Word: \(sw1) \(sw2)")

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
