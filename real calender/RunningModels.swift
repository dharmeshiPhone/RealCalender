import Foundation
import SwiftUI

// MARK: - Run Record Model 
struct RunRecord: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let timeSec: Int
    let distance: Double
    let averagePace: Double
    let isPersonalBest: Bool
    let improvementFromPrevious: Int?
    
    var timeFormatted: String {
        let minutes = timeSec / 60
        let seconds = timeSec % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var paceFormatted: String {
        let paceMinutes = Int(averagePace) / 60
        let paceSeconds = Int(averagePace) % 60
        return String(format: "%d:%02d/km", paceMinutes, paceSeconds)
    }
    
    var improvementText: String {
        guard let improvement = improvementFromPrevious else { return "First Run!" }
        
        if improvement > 0 {
            let minutes = improvement / 60
            let seconds = improvement % 60
            if minutes > 0 {
                return " +\(minutes):\(String(format: "%02d", seconds)) slower"
            } else {
                return " +\(seconds)s slower"
            }
        } else if improvement < 0 {
            let absImprovement = abs(improvement)
            let minutes = absImprovement / 60
            let seconds = absImprovement % 60
            if minutes > 0 {
                return " -\(minutes):\(String(format: "%02d", seconds)) faster!"
            } else {
                return " -\(seconds)s faster!"
            }
        } else {
            return " Same time"
        }
    }
    
    var improvementColor: Color {
        guard let improvement = improvementFromPrevious else { return .blue }
        return improvement <= 0 ? .green : .red
    }
}