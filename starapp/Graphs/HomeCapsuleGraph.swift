import SwiftUI

struct HomeCapsuleGraph: View, Equatable {
    var index: Int
    var color: Color
    var height: CGFloat
    var range: Range<Double>
    var overallRange: Range<Double>
    var isPace: Bool = false
    
    var heightRatio: CGFloat {
        guard magnitude(of: overallRange) > 0 else { return 0 } // Avoid division by zero
        let ratio = CGFloat(magnitude(of: range) / magnitude(of: overallRange))
        return max(ratio, 0.15) // Ensure minimum ratio of 0.15
    }
    
    var offsetRatio: CGFloat {
        guard magnitude(of: overallRange) > 0 else { return 0 } // Avoid division by zero
        return isPace ?
        CGFloat((overallRange.upperBound - range.upperBound) / magnitude(of: overallRange)) :
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
    return range.upperBound - range.lowerBound
}

func rangeOfRanges<C: Collection>(_ ranges: C) -> Range<Double>
where C.Element == Range<Double> {
    guard let low = ranges.lazy.map({ $0.lowerBound }).min(),
          let high = ranges.lazy.map({ $0.upperBound }).max(),
          low < high else {
        return 0..<1 // Return a default valid range if invalid
    }
    return low..<high
}

extension Animation {
    static func ripple(index: Int) -> Animation {
        Animation.spring(dampingFraction: 0.5)
            .speed(2)
            .delay(0.03 * Double(index))
    }
}
