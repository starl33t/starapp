//
//  StringHelper.swift
//  starapp
//
//  Created by Peter Tran on 15/08/2024.
//

import SwiftUI

extension LocalizedStringKey.StringInterpolation {

    mutating func appendInterpolation(_ linkTitle: String, link url: URL) {
        var linkString = AttributedString(linkTitle)
        linkString.link = url
        self.appendInterpolation(linkString)
    }


    mutating func appendInterpolation(_ linkTitle: String, link urlString: String) {
        self.appendInterpolation(linkTitle, link: URL(string: urlString)!)
    }
}
