import SwiftUI
import Charts

// MARK: - Distribution Chart Components
struct DistributionUnlockChart: View {
    let title: String
    let userValue: Double
    let ageGroupStats: AgeGroupStats
    let unit: String
    let color: Color
    let isHigherBetter: Bool
    let unlockPhase: Int
    let showGoldBall: Bool
    let profile: UserProfile
    let onAddData: () -> Void
    
    // NEW: Closure to notify lock position
    let onLockPosition: (CGPoint) -> Void  // NEW
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    if isLocked {
                        Image(systemName: "pencil")
                            .font(.title3)
                            .foregroundColor(.blue)
                    } else {
                        // FIXED: Show chart icon when unlocked
                        Image(systemName: "chart.bar.fill")
                            .font(.title3)
                            .foregroundColor(color)
                    }
                    
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    VStack(alignment: .trailing, spacing: 2) {
                        if isLocked {
                            HStack(spacing: 4) {
                                Image(systemName: "pencil.circle")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                                Text("No Data")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                            
                            Text("Tap to add")
                                .font(.caption)
                                .foregroundColor(.blue)
                        } else {
                            Text("\(Int(percentile * 100))th percentile")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(color)
                            
                            Text(rank)
                                .font(.caption)
                                .foregroundColor(color)
                        }
                    }
                    .frame(minWidth: 110)
                }
            }
            
            VStack(spacing: 12) {
                if shouldShowLockedView {
                    ZStack {
                        Chart {
                            ForEach(getAdjustedNormalDistribution(), id: \.0) { point in
                                AreaMark(
                                    x: .value("Value", point.0),
                                    y: .value("Frequency", point.1)
                                )
                                .foregroundStyle(color.opacity(isUnlocking ? 0.3 : 0.2))
                            }
                            
                            RuleMark(x: .value("Average", getAdjustedMeanValue()))
                                .foregroundStyle(color.opacity(isUnlocking ? 0.5 : 0.4))
                                .lineStyle(StrokeStyle(lineWidth: 2, dash: [6, 4]))
                        }
                        .frame(height: 150)
                        .chartYAxis(.hidden)
                        .chartXAxis {
                            AxisMarks { _ in
                                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                                    .foregroundStyle(color.opacity(isUnlocking ? 0.3 : 0.2))
                                AxisValueLabel()
                                    .font(.caption2)
                                    .foregroundStyle(.gray.opacity(isUnlocking ? 0.6 : 0.5))
                            }
                        }
                        .disabled(true)
                        .animation(.spring(response: 1.2, dampingFraction: 0.8), value: isUnlocking)
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .onAppear {
                                        // NEW: Notify lock position when chart appears
                                        let frame = geometry.frame(in: .global)
                                        let lockCenter = CGPoint(x: frame.midX, y: frame.midY)
                                        onLockPosition(lockCenter)
                                    }
                                    .onChange(of: geometry.frame(in: .global)) { oldValue, newValue in
                                        // NEW: Update lock position when layout changes
                                        let lockCenter = CGPoint(x: newValue.midX, y: newValue.midY)
                                        onLockPosition(lockCenter)
                                    }
                            }
                        )
                        
                        DistributionLockOverlay(
                            isUnlocking: isUnlocking,
                            showGoldBall: showGoldBall,
                            color: color
                        )
                    }
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isUnlocking ? color.opacity(0.6) : Color.gray.opacity(0.3), 
                                lineWidth: isUnlocking ? 3 : 1
                            )
                            .animation(.spring(response: 0.8, dampingFraction: 0.6), value: isUnlocking)
                    )
                    .scaleEffect(isUnlocking ? 1.005 : 1.0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: isUnlocking)
                    .background(
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                    )
                    .onTapGesture {
                        if isLocked {
                            onAddData()
                        }
                    }
                } else {
                    DistributionUnlockedChart(
                        userValue: userValue,
                        ageGroupStats: ageGroupStats,
                        unit: unit,
                        color: color,
                        isHigherBetter: isHigherBetter,
                        shouldShowUserAnnotationOnTop: shouldShowUserAnnotationOnTop
                    )
                    .transition(.opacity.combined(with: .scale))
                    .animation(.spring(response: 1.2, dampingFraction: 0.8), value: userValue)
                }
                
                DistributionChartSummary(
                    isLocked: isLocked,
                    userValue: userValue,
                    ageGroupStats: ageGroupStats,
                    unit: unit
                )
            }
        }
        .padding(16)
        .background(isLocked ? Color(.systemGray5) : Color(.systemGray6))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isLocked ? Color.gray.opacity(0.5) : Color.clear, lineWidth: isLocked ? 2 : 0)
        )
        .animation(.spring(response: 1.0, dampingFraction: 0.7), value: unlockPhase)
        .allowsHitTesting(true)
    }
    
    private var isLocked: Bool {
        return unlockPhase == 0
    }
    
    private var isUnlocking: Bool {
        return unlockPhase == 1
    }
    
    private var shouldShowLockedView: Bool {
        return unlockPhase <= 1
    }
    
    private var percentile: Double {
        guard userValue > 0 else { return 0.0 }
        let zScore = (userValue - ageGroupStats.mean) / ageGroupStats.standardDeviation
        let percentile = normalCDF(zScore)
        return isHigherBetter ? percentile : (1.0 - percentile)
    }
    
    private var rank: String {
        if userValue == 0 { return "Locked" }
        let p = percentile
        switch p {
        case 0.95...: return "Top 5%"
        case 0.90...: return "Top 10%"
        case 0.75...: return "Top 25%"
        case 0.50...: return "Above Average"
        case 0.25...: return "Below Average"
        default: return "Bottom 25%"
        }
    }
    
    private var shouldShowUserAnnotationOnTop: Bool {
        guard userValue > 0 else { return false }
        let distanceFromMean = abs(userValue - ageGroupStats.mean)
        return distanceFromMean < (ageGroupStats.standardDeviation * 0.5)
    }
    
    private func getAdjustedNormalDistribution() -> [(Double, Double)] {
        let originalData = ageGroupStats.generateNormalDistribution()
        
        if isHigherBetter {
            return originalData
        } else {
            let maxX = originalData.map { $0.0 }.max() ?? 0
            let minX = originalData.map { $0.0 }.min() ?? 0
            return originalData.map { (maxX + minX - $0.0, $0.1) }
        }
    }
    
    private func getAdjustedMeanValue() -> Double {
        if isHigherBetter {
            return ageGroupStats.mean
        } else {
            let originalData = ageGroupStats.generateNormalDistribution()
            let maxX = originalData.map { $0.0 }.max() ?? 0
            let minX = originalData.map { $0.0 }.min() ?? 0
            return maxX + minX - ageGroupStats.mean
        }
    }
}

struct DistributionLockOverlay: View {
    let isUnlocking: Bool
    let showGoldBall: Bool
    let color: Color
    
    var body: some View {
        VStack {
            Spacer() // Push content to center
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 100, height: 100)
                        .shadow(color: .black.opacity(0.3), radius: 10)
                        .scaleEffect(isUnlocking ? 1.005 : 1.0)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: isUnlocking ? [color, .blue, color] : [.clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: isUnlocking ? 3 : 0
                                )
                                .scaleEffect(isUnlocking ? 1.005 : 1.0)
                                .opacity(isUnlocking ? 1.0 : 0.0)
                        )
                        .animation(.spring(response: 1.2, dampingFraction: 0.8), value: isUnlocking)
                    
                    // FIXED: Show lock icon for both locked AND unlocking states
                    if isUnlocking {
                        Image(systemName: "lock.open.fill")
                            .font(.system(size: 40))
                            .foregroundColor(color)
                            .shadow(color: color.opacity(0.6), radius: 12)
                            .shadow(color: color.opacity(0.3), radius: 20)
                            .scaleEffect(1.05)
                            .transition(.opacity)
                    } else {
                        // FIXED: Show static lock when fully locked
                        Image(systemName: "lock.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                            .shadow(color: .gray.opacity(0.3), radius: 5)
                    }
                }
                .frame(width: 100, height: 100)
                
                VStack(spacing: 12) {
                    if isUnlocking {
                        Text("🔓 UNLOCKING...")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(color)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("🔒 Add Data to Unlock")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Text("Tap anywhere on this card to enter your information")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            
            Spacer() // Push content to center
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .background(
            LinearGradient(
                colors: [
                    isUnlocking ? color.opacity(0.3) : Color.gray.opacity(0.1),
                    isUnlocking ? Color.blue.opacity(0.2) : Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .animation(.easeInOut(duration: 1.0), value: isUnlocking)
    }
}

struct DistributionUnlockedChart: View {
    let userValue: Double
    let ageGroupStats: AgeGroupStats
    let unit: String
    let color: Color
    let isHigherBetter: Bool
    let shouldShowUserAnnotationOnTop: Bool
    
    var body: some View {
        Chart {
            ForEach(getAdjustedNormalDistribution(), id: \.0) { point in
                AreaMark(
                    x: .value("Value", point.0),
                    y: .value("Frequency", point.1)
                )
                .foregroundStyle(color.opacity(0.3))
            }
            
            RuleMark(x: .value("Your Value", getAdjustedUserValue()))
                .foregroundStyle(Color.red)
                .lineStyle(StrokeStyle(lineWidth: 3))
                .annotation(
                    position: shouldShowUserAnnotationOnTop ? .top : .bottom,
                    alignment: .center,
                    spacing: 8
                ) {
                    VStack(spacing: 2) {
                        Text("You")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        Text(String(format: "%.1f \(userValue > 0 ? unit : "")", userValue))
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(.white)
                    .cornerRadius(4)
                    .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
                }
            
            RuleMark(x: .value("Average", getAdjustedMeanValue()))
                .foregroundStyle(Color.blue)
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [6, 4]))
                .annotation(
                    position: shouldShowUserAnnotationOnTop ? .bottom : .top,
                    alignment: .center,
                    spacing: 8
                ) {
                    VStack(spacing: 2) {
                        Text("Average")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        Text(String(format: "%.1f \(userValue > 0 ? unit : "")", ageGroupStats.mean))
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(.white)
                    .cornerRadius(4)
                    .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
                }
        }
        .frame(height: 150)
        .chartYAxis(.hidden)
        .chartXAxis {
            AxisMarks { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                    .foregroundStyle(.gray.opacity(0.3))
                AxisValueLabel()
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 20)
    }
    
    private func getAdjustedNormalDistribution() -> [(Double, Double)] {
        let originalData = ageGroupStats.generateNormalDistribution()
        
        if isHigherBetter {
            return originalData
        } else {
            let maxX = originalData.map { $0.0 }.max() ?? 0
            let minX = originalData.map { $0.0 }.min() ?? 0
            return originalData.map { (maxX + minX - $0.0, $0.1) }
        }
    }
    
    private func getAdjustedUserValue() -> Double {
        if isHigherBetter {
            return userValue
        } else {
            let originalData = ageGroupStats.generateNormalDistribution()
            let maxX = originalData.map { $0.0 }.max() ?? 0
            let minX = originalData.map { $0.0 }.min() ?? 0
            return maxX + minX - userValue
        }
    }
    
    private func getAdjustedMeanValue() -> Double {
        if isHigherBetter {
            return ageGroupStats.mean
        } else {
            let originalData = ageGroupStats.generateNormalDistribution()
            let maxX = originalData.map { $0.0 }.max() ?? 0
            let minX = originalData.map { $0.0 }.min() ?? 0
            return maxX + minX - ageGroupStats.mean
        }
    }
}

struct DistributionChartSummary: View {
    let isLocked: Bool
    let userValue: Double
    let ageGroupStats: AgeGroupStats
    let unit: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                    
                    Text("Your Value: \(userValue >= 0 ? String(format: "%.1f", userValue) : "Locked") \(unit)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 12, height: 2)
                    
                    Text("Age Group Avg: \(String(format: "%.1f", ageGroupStats.mean)) \(unit)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            if isLocked {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text("Tap anywhere on this card to enter your information")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .fontWeight(.medium)
                    
                    Spacer()
                }
                .padding(.top, 4)
            }
        }
    }
}