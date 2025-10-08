import Foundation
import SwiftUI

// MARK: - Performance Metric Model
struct PerformanceMetric: Identifiable {
    let id = UUID()
    let name: String
    let userValue: Double
    let ageGroupStats: AgeGroupStats
    let unit: String
    let isHigherBetter: Bool
    
    var percentile: Double {
        let mean = ageGroupStats.mean
        let stdDev = ageGroupStats.standardDeviation
        let zScore = (userValue - mean) / stdDev
        let percentile = normalCDF(zScore)
        return isHigherBetter ? percentile : (1.0 - percentile)
    }
    
    var rank: String {
        let p = percentile
        switch p {
        case 0.95...: return "Top 5%"
        case 0.90...: return "Top 10%"
        case 0.75...: return "Top 25%"
        case 0.50...: return "Above Average"
        case 0.25...: return "Below Average"
        case 0.10...: return "Bottom 25%"
        default: return "Bottom 10%"
        }
    }
    
    var color: Color {
        let p = percentile
        switch p {
        case 0.90...: return .green
        case 0.75...: return .blue
        case 0.50...: return .orange
        case 0.25...: return .red
        default: return .red
        }
    }
}

// MARK: - Age Group Statistics
struct AgeGroupStats {
    let mean: Double
    let standardDeviation: Double
    let min: Double
    let max: Double
    
    func generateNormalDistribution(points: Int = 100) -> [(Double, Double)] {
        let range = max - min
        let step = range / Double(points)
        
        var distribution: [(Double, Double)] = []
        
        for i in 0..<points {
            let x = min + Double(i) * step
            let y = normalPDF(x: x, mean: mean, stdDev: standardDeviation)
            distribution.append((x, y))
        }
        
        return distribution
    }
}

// MARK: - Statistical Functions
func normalPDF(x: Double, mean: Double, stdDev: Double) -> Double {
    let coefficient = 1.0 / (stdDev * sqrt(2.0 * Double.pi))
    let exponent = -0.5 * pow((x - mean) / stdDev, 2)
    return coefficient * exp(exponent)
}