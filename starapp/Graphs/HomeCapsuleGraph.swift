

import SwiftUI

struct HomeCapsuleGraph: View, Equatable {
    var index: Int
    var color: Color
    var height: CGFloat
    var range: Range<Double>
    var overallRange: Range<Double>
    
    var heightRatio: CGFloat {
            // Ensure that the ratio is not negative and has a minimum value
            let ratio = CGFloat(magnitude(of: range) / magnitude(of: overallRange))
            return max(ratio, 0.15) // Set a minimum ratio of 0.15
        }
    
    var offsetRatio: CGFloat {
        CGFloat((range.lowerBound - overallRange.lowerBound) / magnitude(of: overallRange))
    }
    
    var body: some View {
        Capsule()
            .fill(color)
            .frame(height: max(0, height * heightRatio))
            .offset(x: 0, y: height * -offsetRatio)
    }
}

func magnitude(of range: Range<Double>) -> Double {
    range.upperBound - range.lowerBound
}

