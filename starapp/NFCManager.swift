import CoreNFC

class NFCManager: NSObject, NFCTagReaderSessionDelegate {
    var nfcSession: NFCTagReaderSession?

    // ✅ Start NFC scanning
    func beginScanning() {
        guard NFCTagReaderSession.readingAvailable else {
            print("NFC is not available on this device.")
            return
        }

        nfcSession = NFCTagReaderSession(pollingOption: .iso14443, delegate: self, queue: nil)
        nfcSession?.alertMessage = "Hold your iPhone near the NFC tag."
        nfcSession?.begin()
    }

    // ✅ REQUIRED: Called when the NFC session becomes active
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("NFC session is now active.")
    }

    // ✅ REQUIRED: Called when an NFC tag is detected
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let firstTag = tags.first else {
            session.invalidate(errorMessage: "No NFC tag found.")
            return
        }

        print("NFC Tag Detected.")

        switch firstTag {
        case .iso7816(let tag):
            session.connect(to: firstTag) { (error) in
                if let error = error {
                    print("Connection failed: \(error.localizedDescription)")
                    session.invalidate(errorMessage: "Connection failed.")
                    return
                }

                print("Connected to NFC tag.")

                // Example APDU Command (You may need to modify this for your wearable)
                let apduCommand = NFCISO7816APDU(
                    instructionClass: 0x00,
                    instructionCode: 0xA4,
                    p1Parameter: 0x04,
                    p2Parameter: 0x00,
                    data: Data([0xD2, 0x76, 0x00, 0x00, 0x85, 0x01, 0x01]),
                    expectedResponseLength: -1
                )

                tag.sendCommand(apdu: apduCommand) { (response, sw1, sw2, error) in
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

        default:
            session.invalidate(errorMessage: "Unsupported NFC tag type.")
        }
    }

    // ✅ REQUIRED: Handle NFC session errors
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        print("NFC session invalidated: \(error.localizedDescription)")
    }
}

// ✅ Helper: Convert Data to Hex String
extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02x", $0) }.joined()
    }
}
