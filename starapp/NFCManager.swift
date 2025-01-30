//
//  NFCManager.swift
//  starapp
//
//  Created by Peter Tran on 30/01/2025.
//

import CoreNFC

class NFCManager: NSObject, NFCNDEFReaderSessionDelegate {
    var nfcSession: NFCNDEFReaderSession?

    func beginScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
            print("NFC is not available on this device.")
            return
        }

        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.alertMessage = "Hold your iPhone near the NFC tag."
        nfcSession?.begin()
    }

    // Delegate method - Called when a tag is detected
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for record in message.records {
                if let text = String(data: record.payload, encoding: .utf8) {
                    print("NFC Data: \(text)")
                }
            }
        }
    }

    // Delegate method - Called when the session fails or is canceled
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("NFC session invalidated: \(error.localizedDescription)")
    }
}
