//
//  ChartHelper.swift
//  starapp
//
//  Created by Peter Tran on 08/08/2025.
//

import Foundation

func paddedYRange(for values: [Double]) -> ClosedRange<Double> {
    guard let minVal = values.min(), let maxVal = values.max() else {
        return 0...1  // fallback for empty data
    }

    let range = max(maxVal - minVal, 1e-6)  // prevent zero-width range

    let paddedMin = minVal - range * 0.8     // fixed 80% bottom padding
    let paddedMax = maxVal + 1.0             // fixed +1 µA top padding

    return paddedMin...paddedMax
}



