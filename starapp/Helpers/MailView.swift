//
//  MailView.swift
//  starapp
//
//  Created by Peter Tran on 07/03/2025.
//

import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
    var recipient: String
    var subject: String
    var csvData: Data
    var csvFilename: String = "sessions.csv"
    
    typealias UIViewControllerType = UIViewController
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView
        
        init(parent: MailView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            controller.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        if MFMailComposeViewController.canSendMail() {
            // ✅ Mail available → use MFMailCompose
            let mailVC = MFMailComposeViewController()
            mailVC.mailComposeDelegate = context.coordinator
            mailVC.setToRecipients([recipient])
            mailVC.setSubject(subject)
            mailVC.addAttachmentData(csvData, mimeType: "text/csv", fileName: csvFilename)
            return mailVC
        } else {
            // ❌ Mail not available → fallback to Share Sheet
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(csvFilename)
            try? csvData.write(to: tempURL)
            
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            return activityVC
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
}
