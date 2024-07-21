//
//  ColorLactate.swift
//  starapp
//
//  Created by Peter Tran on 21/07/2024.
//

import SwiftUI

struct ColorLactate {
    static func color(for lactate: Double?) -> Color {
        guard let lactate = lactate else { return .whiteOne }
        
        if lactate < 1.0 {
            return .blue
        } else if lactate <= 1.5 {
            return .green
        } else if lactate <= 3.0 {
            return .yellow
        } else if lactate <= 4.9 {
            return .orange
        } else {
            return .red
        }
    }
}
