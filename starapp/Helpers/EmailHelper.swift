//
//  EmailHelper.swift
//  starapp
//
//  Created by Peter Tran on 18/07/2024.
//

import UIKit

struct EmailHelper {
    static func sendEmail(to recipient: String) {
        if let url = URL(string: "mailto:\(recipient)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: { success in
                    if !success {
                        print("Failed to open URL: \(url)")
                    }
                })
            } else {
                print("Cannot open mail URL: \(url)")
            }
        } else {
            print("Invalid email URL")
        }
    }
}
