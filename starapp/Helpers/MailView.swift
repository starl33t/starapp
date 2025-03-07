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
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = context.coordinator
        mailVC.setToRecipients([recipient])
        mailVC.setSubject(subject)
        mailVC.addAttachmentData(csvData, mimeType: "text/csv", fileName: csvFilename)
        return mailVC
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) { }
}
