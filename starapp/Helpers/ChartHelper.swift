//
//  ChartHelper.swift
//  starapp
//
//  Created by Peter Tran on 08/08/2025.
//

import Foundation

func paddedYRangeResearch(for values: [Double]) -> ClosedRange<Double> {
    guard let minVal = values.min(), let maxVal = values.max() else {
        return 0...1  // fallback for empty data
    }

    let range = max(maxVal - minVal, 1e-6)  // prevent zero-width range

    let paddedMin = minVal - range * 0.8     // fixed 80% bottom padding
    let paddedMax = maxVal + 1.0             // fixed +1 µA top padding

    return paddedMin...paddedMax
}

// For lactate (mM) in normal mode: same bottom padding as original, but +0.1 mM top
func paddedYRangeLactate(for values: [Double]) -> ClosedRange<Double> {
    guard let minVal = values.min(), let maxVal = values.max() else {
        return 0...1
    }

    let range = max(maxVal - minVal, 1e-6)   // prevent zero-width
    var paddedMin = minVal - range * 0.8      // big bottom pad (like original)
    let paddedMax = maxVal + 0.5              // smaller, fixed +0.1 mM top

    // keep above zero if all data are nonnegative
    if minVal >= 0, paddedMin < 0 { paddedMin = 0 }

    return paddedMin...paddedMax
}


