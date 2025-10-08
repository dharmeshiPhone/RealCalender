import SwiftUI
import Charts
import CoreLocation
import Foundation

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.green)
                .frame(width: 16)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

struct HolographicMeasurementsView: View {
    let userProfile: UserProfile
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Body Measurements")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Track your progress over time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Simple summary cards instead of graphs
                VStack(spacing: 16) {
                    if userProfile.swimming50MLaps > 0 {
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "figure.pool.swim")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Swimming Endurance")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    Text("\(userProfile.swimming50MLaps) laps (50m)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text("\(getSwimmingPercentile())%")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    if userProfile.running5KTimeSec > 0 {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "figure.run")
                                    .font(.title2)
                                    .foregroundColor(.green)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("5K Running Progress")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    Text("Best: \(userProfile.running5KTimeFormatted)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(getRunningPercentile())%")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                    
                                    Text("Percentile")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            // Recent runs list
                            if !userProfile.recentRuns.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Recent Runs")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        Spacer()
                                        
                                        if userProfile.hasProgressGraph {
                                            Text("📈 Progress Graph Unlocked!")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.green)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.green.opacity(0.1))
                                                .cornerRadius(4)
                                        } else {
                                            Text("\(3 - userProfile.runningHistory.count) more for graph")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    // Progress graph (if unlocked)
                                    if userProfile.hasProgressGraph {
                                        RunningProgressGraph(runs: userProfile.recentRuns)
                                            .frame(height: 120)
                                    }
                                    
                                    // Recent runs list
                                    VStack(spacing: 8) {
                                        ForEach(Array(userProfile.recentRuns.prefix(5).enumerated()), id: \.element.id) { index, run in
                                            RunRecordRow(run: run, isLatest: index == 0)
                                        }
                                        
                                        if userProfile.runningHistory.count > 5 {
                                            Text("... and \(userProfile.runningHistory.count - 5) more runs")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                            
                            // Call to action for next run
                            NavigationLink(destination: RunningTrackerView(runningTracker: RunningTracker(), userProfile: .constant(userProfile))) {
                                HStack {
                                    Image(systemName: "location.fill")
                                        .font(.subheadline)
                                    Text("Track Next Run")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .foregroundColor(.green)
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    } else {
                        // 5K Running Challenge - Show when no time is recorded
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "figure.run")
                                    .font(.title2)
                                    .foregroundColor(.green)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("5K Running Challenge")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    
                                    Text("Ready to see how you compare?")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            
                            // Show what the average is for motivation
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Your age group average: \(String(format: "%.1f", getRunningAverageForAge())) minutes")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text("🎯 Beat the average and unlock your percentile ranking!")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                            }
                            
                            // GPS Tracking Features
                            VStack(alignment: .leading, spacing: 12) {
                                Text("📍 Our GPS Tracker Features:")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    FeatureRow(icon: "location.fill", text: "Real-time GPS distance tracking")
                                    FeatureRow(icon: "stopwatch.fill", text: "Live pace and time monitoring")
                                    FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Instant performance comparison")
                                    FeatureRow(icon: "trophy.fill", text: "Achievement unlocks and ranking")
                                }
                            }
                            
                            // Call to action
                            NavigationLink(destination: RunningTrackerView(runningTracker: RunningTracker(), userProfile: .constant(userProfile))) {
                                HStack {
                                    Image(systemName: "location.fill")
                                        .font(.title2)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Start Your 5K GPS Run")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                        
                                        Text("Track your pace, distance, and time with precision")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.title2)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.green.opacity(0.8),
                                            Color.green.opacity(0.6)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(color: .green.opacity(0.3), radius: 5, x: 0, y: 2)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // BMI Summary Card
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .font(.title2)
                                .foregroundColor(.purple)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Body Mass Index")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text(getBMICategory())
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(String(format: "%.1f", userProfile.bmi))
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.purple)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle("Measurements")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Swimming Distribution Functions
    
    private func getSwimmingDistribution() -> [(laps: Double, frequency: Double)] {
        let stats = AgeGroupDataGenerator.getSwimmingStats(age: userProfile.age, gender: userProfile.gender)
        return stats.generateNormalDistribution(points: 50).map { (laps: $0.0, frequency: $0.1) }
    }
    
    private func getSwimmingAverageForAge() -> Double {
        return AgeGroupDataGenerator.getSwimmingStats(age: userProfile.age, gender: userProfile.gender).mean
    }
    
    private func getSwimmingPercentile() -> Int {
        let stats = AgeGroupDataGenerator.getSwimmingStats(age: userProfile.age, gender: userProfile.gender)
        let zScore = (Double(userProfile.swimming50MLaps) - stats.mean) / stats.standardDeviation
        let percentile = normalCDF(zScore) * 100
        return Int(percentile)
    }
    
    private func getSwimmingRank() -> String {
        let percentile = getSwimmingPercentile()
        switch percentile {
        case 95...: return "Elite"
        case 85...: return "Excellent"
        case 70...: return "Good"
        case 50...: return "Average"
        case 30...: return "Below Average"
        default: return "Needs Work"
        }
    }
    
    private func getSwimmingRankColor() -> Color {
        let percentile = getSwimmingPercentile()
        switch percentile {
        case 95...: return .green
        case 85...: return .blue
        case 70...: return .cyan
        case 50...: return .orange
        case 30...: return .red
        default: return .red
        }
    }
    
    // MARK: - Running Distribution Functions
    
    private func getRunningDistribution() -> [(time: Double, frequency: Double)] {
        let stats = AgeGroupDataGenerator.getRunningStats(age: userProfile.age, gender: userProfile.gender)
        return stats.generateNormalDistribution(points: 50).map { (time: $0.0, frequency: $0.1) }
    }
    
    private func getRunningAverageForAge() -> Double {
        return AgeGroupDataGenerator.getRunningStats(age: userProfile.age, gender: userProfile.gender).mean
    }
    
    private func getRunningPercentile() -> Int {
        let stats = AgeGroupDataGenerator.getRunningStats(age: userProfile.age, gender: userProfile.gender)
        let userTime = Double(userProfile.running5KTimeSec) / 60 // Convert to minutes
        let zScore = (userTime - stats.mean) / stats.standardDeviation
        let percentile = (1.0 - normalCDF(zScore)) * 100 // Inverted because lower time is better
        return Int(percentile)
    }
    
    private func getRunningRank() -> String {
        let percentile = getRunningPercentile()
        switch percentile {
        case 95...: return "Elite"
        case 85...: return "Excellent"
        case 70...: return "Good"
        case 50...: return "Average"
        case 30...: return "Below Average"
        default: return "Needs Work"
        }
    }
    
    private func getRunningRankColor() -> Color {
        let percentile = getRunningPercentile()
        switch percentile {
        case 95...: return .green
        case 85...: return .blue
        case 70...: return .cyan
        case 50...: return .orange
        case 30...: return .red
        default: return .red
        }
    }
    
    // MARK: - BMI Distribution Functions
    
    private func getBMIDistribution() -> [(bmi: Double, frequency: Double)] {
        let stats = AgeGroupDataGenerator.getBMIStats(age: userProfile.age, gender: userProfile.gender)
        return stats.generateNormalDistribution(points: 50).map { (bmi: $0.0, frequency: $0.1) }
    }
    
    private func getBMICategory() -> String {
        let bmi = userProfile.bmi
        switch bmi {
        case ..<18.5: return "Underweight"
        case 18.5..<25: return "Normal"
        case 25..<30: return "Overweight"
        default: return "Obese"
        }
    }
    
    private func getBMICategoryColor() -> Color {
        let bmi = userProfile.bmi
        switch bmi {
        case ..<18.5: return .blue
        case 18.5..<25: return .green
        case 25..<30: return .orange
        default: return .red
        }
    }
    
    // MARK: - Helper Functions
    
    private func normalCDF(_ z: Double) -> Double {
        return 0.5 * (1.0 + erf(z / sqrt(2.0)))
    }
}

#Preview {
    NavigationView {
        let mockProfile = UserProfile(
            name: "Test User",
            age: 20,
            heightCM: 175,
            weightKG: 70,
            measurements: ["chest": 100, "waist": 80, "hips": 95],
            level: 1,
            xp: 0,
            stats: []
        )
        
        HolographicMeasurementsView(userProfile: mockProfile)
    }
}