import SwiftUI
import Charts

struct SwimmingChartView: View {
    let userProfile: UserProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Swimming Endurance (50m laps)")
                .font(.headline)
                .fontWeight(.semibold)
            
            Chart {
                // Normal distribution curve
                ForEach(getSwimmingDistribution(), id: \.laps) { data in
                    AreaMark(
                        x: .value("Laps", data.laps),
                        y: .value("Frequency", data.frequency)
                    )
                    .foregroundStyle(.blue.opacity(0.3))
                }
                
                // User's performance line
                RuleMark(x: .value("Your Performance", userProfile.swimming50MLaps))
                    .foregroundStyle(.red)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .annotation(position: .top) {
                        Text("You: \(userProfile.swimming50MLaps) laps")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(4)
                            .background(.white)
                            .cornerRadius(4)
                    }
                
                // Age group average line
                RuleMark(x: .value("Age Average", getSwimmingAverageForAge()))
                    .foregroundStyle(.green)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                    .annotation(position: .bottom) {
                        Text("Avg: \(Int(getSwimmingAverageForAge())) laps")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(4)
                            .background(.white)
                            .cornerRadius(4)
                    }
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            
            // Performance summary
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Percentile")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(getSwimmingPercentile())%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Performance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(getSwimmingRank())
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(getSwimmingRankColor())
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
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
}