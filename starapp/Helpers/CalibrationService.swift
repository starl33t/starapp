import Foundation

public struct CalibrationResult {
    public let coeffs: [Double]   // length = 4
    public let current: Double
    public let lactate: Double
}

public class CalibrationService {
    /// Computes calibration coefficients (cubic), current, and lactate from raw pages + ADC.
    public static func computeCalibration(page28: Data,
                                          page29: Data,
                                          page2A: Data,
                                          rawAdcValue: Int) -> CalibrationResult? {
        // 1️⃣ Read out your five (adc → µA) points
        let a16 = Int(parseInt16(from: page28, start: 0));  // +16 µA
        let a8  = Int(parseInt16(from: page28, start: 2));  //  +8 µA
        let a0  = Int(parseInt16(from: page29, start: 0));  //   0 µA
        let aM8 = Int(parseInt16(from: page29, start: 2));  //  -8 µA
        let aM16 = Int(parseInt16(from: page2A, start: 0));  // -16 µA
        
        let adcRef: [Int:Int] = [
            a16:  16,
            a8:    8,
            a0:    0,
            aM8:  -8,
            aM16: -16
        ]
        // 2️⃣ Solve the cubic via the same normal‐equation code you had before:
        let coeffs = solvePolynomialForCurrent(adcReferenceValues: adcRef)
        
        // 3️⃣ Current & lactate
        let current = coeffs.enumerated().reduce(0.0) { sum, pair in
            let (power, b) = pair
            return sum + b * pow(Double(rawAdcValue), Double(power))
        }
        let lactate = current * 0.9
        
        return CalibrationResult(coeffs: coeffs,
                                  current: current,
                                  lactate: lactate)
    }
    
    /// Solves the 3rd-order polynomial I(ADC)=b0+b1·ADC+b2·ADC²+b3·ADC³
    /// that best fits your five calibration points via normal equations.
    private static func solvePolynomialForCurrent(adcReferenceValues: [Int:Int]) -> [Double] {
        let X = adcReferenceValues.keys.sorted().map { Double($0) }
        let Y = X.map { adcReferenceValues[Int($0)]! }.map(Double.init)
        
        // Build sums S[k] = Σ xᵏ, T[k] = Σ xᵏ·y
        var S = [Double](repeating: 0, count: 7)
        var T = [Double](repeating: 0, count: 4)
        for i in 0..<X.count {
            let x = X[i], y = Y[i]
            let x2 = x*x, x3 = x2*x, x4 = x3*x, x5 = x4*x, x6 = x5*x
            S[0] += 1
            S[1] += x
            S[2] += x2
            S[3] += x3
            S[4] += x4
            S[5] += x5
            S[6] += x6
            
            T[0] += y
            T[1] += x * y
            T[2] += x2 * y
            T[3] += x3 * y
        }
        
        // Normal equations matrix M·b = B
        var M: [[Double]] = [
            [ S[0], S[1], S[2], S[3] ],
            [ S[1], S[2], S[3], S[4] ],
            [ S[2], S[3], S[4], S[5] ],
            [ S[3], S[4], S[5], S[6] ]
        ]
        var B = T
        let dim = 4
        
        // Gaussian elimination with partial pivoting
        for i in 0..<dim {
            // pivot row
            var maxRow = i
            for r in (i+1)..<dim where abs(M[r][i]) > abs(M[maxRow][i]) {
                maxRow = r
            }
            if maxRow != i {
                M.swapAt(i, maxRow)
                B.swapAt(i, maxRow)
            }
            let pivot = M[i][i]
            // mimic your old “tiny pivot hack”
            let safePivot = abs(pivot) < 1e-14 ? 1e-14 : pivot
            // normalize
            for c in i..<dim { M[i][c] /= safePivot }
            B[i] /= safePivot
            // eliminate below
            for r in (i+1)..<dim {
                let f = M[r][i]
                for c in i..<dim {
                    M[r][c] -= f * M[i][c]
                }
                B[r] -= f * B[i]
            }
        }
        
        // Back-substitution
        var coeffs = [Double](repeating: 0, count: dim)
        for i in stride(from: dim-1, through: 0, by: -1) {
            var sum = 0.0
            for c in (i+1)..<dim {
                sum += M[i][c] * coeffs[c]
            }
            coeffs[i] = B[i] - sum
        }
        
        print("DEBUG: Polynomial coefficients: \(coeffs)")
        return coeffs
    }
    
    // MARK: – Data parsing
    private static func parseInt16(from data: Data, start: Int) -> Int {
        let word = UInt16(data[start]) << 8 | UInt16(data[start+1])
        return Int(Int16(bitPattern: word))
    }
}
