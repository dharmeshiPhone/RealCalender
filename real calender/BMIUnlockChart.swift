import SwiftUI
import Charts

struct BMIUnlockChart: View {
    let profile: UserProfile
    let unlockAnimationPhase: Int
    let countdown: Int
    var onAdd:(()-> Void)?
    
    private var isLocked: Bool {
        return unlockAnimationPhase == 0
    }
    
    private var isUnlocking: Bool {
        return unlockAnimationPhase == 1
    }
    
    private var shouldShowLockedView: Bool {
        return unlockAnimationPhase <= 1  // Show locked view for both locked (0) and unlocking (1) phases
    }
    
    private var ageGroupStats: AgeGroupStats {
        AgeGroupDataGenerator.getBMIStats(age: profile.age, gender: profile.gender)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            BMIChartHeader(isLocked: isLocked, profile: profile,onAdd:onAdd)
            
            // Chart content
            VStack(spacing: 12) {
                if shouldShowLockedView {
                    BMILockedView(
                        countdown: countdown,
                        isUnlocking: isUnlocking,
                        ageGroupStats: ageGroupStats
                    )
                } else {
                    BMIUnlockedChart(
                        profile: profile,
                        ageGroupStats: ageGroupStats
                    )
                }
                
                // Summary
                BMIChartSummary(
                    isLocked: isLocked,
                    profile: profile,
                    ageGroupStats: ageGroupStats
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
        .animation(.spring(response: 1.0, dampingFraction: 0.7), value: unlockAnimationPhase)
    }
}

struct BMIChartHeader: View {
    let isLocked: Bool
    let profile: UserProfile
    var onAdd:(()-> Void)?
    
    private var percentile: Double {
        guard profile.bmi > 0 else { return 0.0 }
        let ageGroupStats = AgeGroupDataGenerator.getBMIStats(age: profile.age, gender: profile.gender)
        let zScore = (profile.bmi - ageGroupStats.mean) / ageGroupStats.standardDeviation
        let percentile = normalCDF(zScore)
        return 1.0 - percentile // BMI is lower is better
    }
    
    private var rank: String {
        if profile.bmi == 0 { return "Locked" }
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
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2){
                HStack(spacing: 8) {
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.title3)
                            .foregroundColor(.gray)
                    } else {
                        // Show unlocked icon when not locked
                        Image(systemName: "chart.bar.fill")
                            .font(.title3)
                            .foregroundColor(.purple)
                    }
                    
                    Text("Body Mass Index")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                if !isLocked{
                    Button {
                        onAdd?()
                    } label: {
                        Text("Update Data")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
            }
           
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                if isLocked {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text("Locked")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                    }
                    
                    Text("Center chart to unlock")
                        .font(.caption)
                        .foregroundColor(.gray)
                } else {
                    Text("\(Int(percentile * 100))th percentile")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    
                    Text(rank)
                        .font(.caption)
                        .foregroundColor(.purple)
                }
            }
            .frame(minWidth: 110)
        }
        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: isLocked)
    }
}

struct BMILockedView: View {
    let countdown: Int
    let isUnlocking: Bool
    let ageGroupStats: AgeGroupStats
    
    // BMI is "lower is better"
    private func getAdjustedNormalDistribution() -> [(Double, Double)] {
        let originalData = ageGroupStats.generateNormalDistribution()
        // Flip for BMI (lower is better): high values on left, low on right
        let maxX = originalData.map { $0.0 }.max() ?? 0
        let minX = originalData.map { $0.0 }.min() ?? 0
        return originalData.map { (maxX + minX - $0.0, $0.1) }
    }
    
    private func getAdjustedMeanValue() -> Double {
        let originalData = ageGroupStats.generateNormalDistribution()
        let maxX = originalData.map { $0.0 }.max() ?? 0
        let minX = originalData.map { $0.0 }.min() ?? 0
        return maxX + minX - ageGroupStats.mean
    }
    
    var body: some View {
        ZStack {
            // Background chart
            Chart {
                ForEach(getAdjustedNormalDistribution(), id: \.0) { point in
                    AreaMark(
                        x: .value("Value", point.0),
                        y: .value("Frequency", point.1)
                    )
                    .foregroundStyle(Color.gray.opacity(isUnlocking ? 0.3 : 0.2))
                }
                
                RuleMark(x: .value("Average", getAdjustedMeanValue()))
                    .foregroundStyle(Color.gray.opacity(isUnlocking ? 0.5 : 0.4))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [6, 4]))
            }
            .frame(height: 150)
            .chartYAxis(.hidden)
            .chartXAxis {
                AxisMarks { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                        .foregroundStyle(.gray.opacity(isUnlocking ? 0.3 : 0.2))
                    AxisValueLabel()
                        .font(.caption2)
                        .foregroundStyle(.gray.opacity(isUnlocking ? 0.6 : 0.5))
                }
            }
            .disabled(true)
            .animation(.spring(response: 1.2, dampingFraction: 0.8), value: isUnlocking)
            
            // Overlay
            BMILockOverlay(countdown: countdown, isUnlocking: isUnlocking)
        }
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    countdown > 0 ? Color.blue : (isUnlocking ? Color.green.opacity(0.6) : Color.gray.opacity(0.3)), 
                    lineWidth: countdown > 0 ? 4 : (isUnlocking ? 3 : 1)
                )
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: countdown)
                .animation(.spring(response: 0.8, dampingFraction: 0.6), value: isUnlocking)
        )
        .scaleEffect(countdown > 0 ? 1.02 : (isUnlocking ? 1.01 : 1.0))
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: countdown)
        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: isUnlocking)
    }
}

struct BMILockOverlay: View {
    let countdown: Int
    let isUnlocking: Bool
    
    @State private var shackleRotation: Double = 0
    @State private var shackleOffset: CGFloat = 0
    @State private var lockShake: Double = 0
    @State private var unlockGlow: Bool = false
    @State private var sparkleScale: Double = 0
    @State private var animationStarted: Bool = false
    @State private var lockOpacity: Double = 1.0
    @State private var showBMIGoldBall: Bool = false
    @State private var goldBallOpacity: Double = 0.0
    @State private var goldBallScale: Double = 0.0
    @State private var goldBallOffset: CGPoint = CGPoint(x: 0, y: 0)
    @State private var goldBallGlow: Double = 0.0
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon section
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 100, height: 100)
                    .shadow(color: .black.opacity(0.3), radius: 10)
                    .scaleEffect(isUnlocking ? 1.02 : 1.0) // REDUCED from 1.05 to 1.02
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: isUnlocking ? [.green, .blue, .green] : [.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isUnlocking ? 3 : 0
                            )
                            .scaleEffect(isUnlocking ? 1.02 : 1.0) // REDUCED from 1.05 to 1.02
                            .opacity(isUnlocking ? 1.0 : 0.0)
                    )
                    .animation(.spring(response: 1.2, dampingFraction: 0.8), value: isUnlocking) // SMOOTHER
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    // Store the global position of the lock icon center
                                    let frame = geometry.frame(in: .global)
                                    let lockCenter = CGPoint(x: frame.midX, y: frame.midY)
                                    print("🔒 BMI Lock icon global position: \(lockCenter)")
                                    // Post notification with the position
                                    NotificationCenter.default.post(
                                        name: .bmiLockPositionUpdated,
                                        object: lockCenter
                                    )
                                }
                                .onChange(of: geometry.frame(in: .global)) { oldValue, newValue in
                                    // Update position when layout changes
                                    let lockCenter = CGPoint(x: newValue.midX, y: newValue.midY)
                                    NotificationCenter.default.post(
                                        name: .bmiLockPositionUpdated,
                                        object: lockCenter
                                    )
                                }
                        }
                    )
                
                // Gold ball animation on the BMI chart itself
                if showBMIGoldBall {
                    ZStack {
                        // Enhanced outer glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [.yellow.opacity(0.4 * goldBallOpacity), .clear],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 50
                                )
                            )
                            .frame(width: 80, height: 80)
                            .opacity(goldBallGlow)
                        
                        // Main gold ball
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        .white,
                                        Color(red: 1.0, green: 0.85, blue: 0.2), // Gold
                                        Color(red: 1.0, green: 0.65, blue: 0.0), // Darker gold
                                        Color(red: 0.8, green: 0.5, blue: 0.0)   // Bronze edge
                                    ],
                                    center: UnitPoint(x: 0.3, y: 0.3),
                                    startRadius: 2,
                                    endRadius: 20
                                )
                            )
                            .frame(width: 35, height: 35)
                            .shadow(color: .yellow.opacity(0.8 * goldBallOpacity), radius: 15)
                            .shadow(color: .orange.opacity(0.6 * goldBallOpacity), radius: 25)
                            .opacity(goldBallOpacity)
                            .scaleEffect(goldBallScale)
                        
                        // Sparkle effect
                        if goldBallOpacity > 0.3 {
                            Image(systemName: "sparkles")
                                .foregroundColor(.white)
                                .font(.system(size: 12, weight: .bold))
                                .opacity(goldBallOpacity)
                                .shadow(color: .white, radius: 3)
                                .scaleEffect(goldBallScale)
                        }
                    }
                    .offset(x: goldBallOffset.x, y: goldBallOffset.y)
                    .transition(.opacity.combined(with: .scale))
                    .zIndex(5)
                }
                
                if countdown > 0 {
                    Text("\(countdown)")
                        .font(.system(size: 50, weight: .black))
                        .foregroundColor(.blue)
                        .opacity(lockOpacity)
                } else if isUnlocking {
                    // Custom animated lock that stays visible
                    BMILockAnimationView(
                        shackleRotation: shackleRotation,
                        shackleOffset: shackleOffset,
                        lockShake: lockShake,
                        unlockGlow: unlockGlow,
                        sparkleScale: sparkleScale
                    )
                    .opacity(lockOpacity)
                    .onAppear {
                        guard !animationStarted else { return }
                        animationStarted = true
                        startSmoothUnlockAnimation()
                    }
                } else {
                    // Static locked state
                    BMILockAnimationView(
                        shackleRotation: 0,
                        shackleOffset: 0,
                        lockShake: 0,
                        unlockGlow: false,
                        sparkleScale: 0
                    )
                    .opacity(lockOpacity)
                }
            }
            
            // Text section - REMOVED jarring scale effects
            VStack(spacing: 12) {
                if countdown > 0 {
                    Text("🔓 UNLOCKING IN \(countdown)...")
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                    
                    Text("Get ready to see your BMI analysis!")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                        
                } else if isUnlocking {
                    if showBMIGoldBall && goldBallOpacity > 0.8 {
                        Text("✨ BMI CHART UNLOCKED! ✨")
                            .font(.title2)
                            .fontWeight(.black)
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                            .shadow(color: .green.opacity(0.3), radius: 8)
                    } else {
                        Text("🔓 UNLOCKING BMI CHART...")
                            .font(.title2)
                            .fontWeight(.black)
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                    }
                        
                } else {
                    Text("🔒 BMI CHART LOCKED")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    Text("Scroll down until this chart is centered to unlock")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .animation(.easeInOut(duration: 0.6), value: showBMIGoldBall) // SMOOTHER text transitions
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    countdown > 0 ? Color.blue.opacity(0.2) : (isUnlocking ? Color.green.opacity(0.3) : Color.gray.opacity(0.1)),
                    countdown > 0 ? Color.purple.opacity(0.1) : (isUnlocking ? Color.blue.opacity(0.2) : Color.clear)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .animation(.easeInOut(duration: 1.0), value: isUnlocking) // SMOOTHER background transitions
        .onChange(of: isUnlocking) { oldValue, newValue in
            if !oldValue && newValue {
                // Reset all animation states for fresh start
                DispatchQueue.main.async {
                    shackleRotation = 0
                    shackleOffset = 0
                    lockShake = 0
                    unlockGlow = false
                    sparkleScale = 0
                    lockOpacity = 1.0
                    showBMIGoldBall = false
                    goldBallOpacity = 0.0
                    goldBallScale = 0.0
                    goldBallOffset = CGPoint(x: 0, y: 0)
                    goldBallGlow = 0.0
                    animationStarted = false
                }
            }
        }
    }
    
    private func startSmoothUnlockAnimation() {
        // Step 1: Shake the lock (0.8 seconds) - GENTLER shake
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).repeatCount(3, autoreverses: true)) {
            lockShake = 1.5 // REDUCED from 2 to 1.5
        }
        
        // Step 2: After 1.0 seconds, start wiggling the lock with smooth spring
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 1.2, dampingFraction: 0.8)) {
                shackleRotation = 12 // REDUCED from 15 to 12
            }
        }
        
        // Step 3: After 1.8 seconds, show gold ball appearing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            showBMIGoldBall = true
            
            // Start gold ball animation - GENTLER appearance
            withAnimation(.easeOut(duration: 0.5)) { // SLOWER from 0.3 to 0.5
                goldBallGlow = 1.0
                goldBallOpacity = 1.0
            }
            
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) { // MORE damping
                goldBallScale = 1.0
            }
        }
        
        // Step 4: After 2.2 seconds, open the lock
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) { // MORE damping
                unlockGlow = true // This switches to the open lock
            }
        }
        
        // Step 5: After 2.5 seconds, make gold ball fly away and trigger main animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            // Animate gold ball flying away - GENTLER movement
            withAnimation(.spring(response: 1.0, dampingFraction: 0.9)) { // MORE damping
                goldBallOffset = CGPoint(x: 50, y: -50) // REDUCED movement from 60 to 50
            }
            
            // Start fade out - SLOWER fade
            withAnimation(.easeOut(duration: 1.0)) { // SLOWER from 0.8 to 1.0
                goldBallOpacity = 0.0
                goldBallGlow = 0.0
            }
            
            // Send notification to trigger the main gold ball animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                NotificationCenter.default.post(name: .bmiUnlocked, object: nil)
            }
            
            // Hide the local gold ball
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { // LONGER delay
                showBMIGoldBall = false
            }
        }
    }
}

struct BMILockAnimationView: View {
    let shackleRotation: Double
    let shackleOffset: CGFloat
    let lockShake: Double
    let unlockGlow: Bool
    let sparkleScale: Double

    var body: some View {
        ZStack {
            if unlockGlow {
                Image(systemName: "lock.open.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
                    .shadow(color: .green.opacity(0.6), radius: 12)
                    .shadow(color: .green.opacity(0.3), radius: 20)
                    .scaleEffect(1.05)
                    .transition(.opacity)
            } else {
                Image(systemName: "lock.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
                    .rotationEffect(.degrees(shackleRotation * 0.5))
                    .scaleEffect(1.0 + (shackleRotation / 300))
                    .offset(x: lockShake)
                    .shadow(color: .gray.opacity(0.3), radius: 5)
            }
            
            if unlockGlow {
                ForEach(0..<6, id: \.self) { i in
                    Image(systemName: "sparkle")
                        .foregroundColor(.yellow)
                        .font(.system(size: 6))
                        .offset(
                            x: cos(Double(i) * .pi / 3) * 25,
                            y: sin(Double(i) * .pi / 3) * 25
                        )
                        .opacity(0.6)
                        .scaleEffect(sparkleScale * 0.8)
                        .animation(
                            .easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.15),
                            value: sparkleScale
                        )
                }
            }
        }
        .animation(.spring(response: 1.0, dampingFraction: 0.8), value: unlockGlow)
    }
}

struct BMIUnlockedChart: View {
    let profile: UserProfile
    let ageGroupStats: AgeGroupStats
    
    // BMI is "lower is better"
    private func getAdjustedNormalDistribution() -> [(Double, Double)] {
        let originalData = ageGroupStats.generateNormalDistribution()
        // Flip for BMI (lower is better): high values on left, low on right
        let maxX = originalData.map { $0.0 }.max() ?? 0
        let minX = originalData.map { $0.0 }.min() ?? 0
        return originalData.map { (maxX + minX - $0.0, $0.1) }
    }
    
    private func getAdjustedUserValue() -> Double {
        let originalData = ageGroupStats.generateNormalDistribution()
        let maxX = originalData.map { $0.0 }.max() ?? 0
        let minX = originalData.map { $0.0 }.min() ?? 0
        return maxX + minX - profile.bmi
    }
    
    private func getAdjustedMeanValue() -> Double {
        let originalData = ageGroupStats.generateNormalDistribution()
        let maxX = originalData.map { $0.0 }.max() ?? 0
        let minX = originalData.map { $0.0 }.min() ?? 0
        return maxX + minX - ageGroupStats.mean
    }
    
    private var shouldShowUserAnnotationOnTop: Bool {
        guard profile.bmi > 0 else { return false }
        let distanceFromMean = abs(profile.bmi - ageGroupStats.mean)
        return distanceFromMean < (ageGroupStats.standardDeviation * 0.5)
    }
    
    var body: some View {
        Chart {
            // Normal distribution curve with smooth transition
            ForEach(getAdjustedNormalDistribution(), id: \.0) { point in
                AreaMark(
                    x: .value("Value", point.0),
                    y: .value("Frequency", point.1)
                )
                .foregroundStyle(Color.purple.opacity(0.3))
            }
            
            // User's BMI line
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
                        Text(String(format: "%.1f BMI", profile.bmi))
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
            
            // Age group average line
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
                        Text(String(format: "%.1f BMI", ageGroupStats.mean))
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
        .transition(.opacity.combined(with: .scale))
        .animation(.spring(response: 1.2, dampingFraction: 0.8), value: profile.bmi)
    }
}

struct BMIChartSummary: View {
    let isLocked: Bool
    let profile: UserProfile
    let ageGroupStats: AgeGroupStats
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                // Your value
                HStack(spacing: 4) {
                    Circle()
                        .fill(isLocked ? Color.gray.opacity(0.4) : Color.red)
                        .frame(width: 8, height: 8)
                    
                    if isLocked {
                        Text("Your Value: Locked")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .fontWeight(.medium)
                    } else {
                        Text("Your Value: \(String(format: "%.1f", profile.bmi)) BMI")
                            .font(.caption)
                            .foregroundColor(.primary)
                            .fontWeight(.medium)
                    }
                }
                
                Spacer()
                
                // Age group average
                HStack(spacing: 4) {
                    Rectangle()
                        .fill(isLocked ? Color.gray.opacity(0.4) : Color.blue)
                        .frame(width: 12, height: 2)
                    
                    Text("Age Group Avg: \(String(format: "%.1f", ageGroupStats.mean)) BMI")
                        .font(.caption)
                        .foregroundColor(isLocked ? .gray : .secondary)
                }
            }
            
            // Info message
            if isLocked {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text("Center this chart on screen to unlock")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .fontWeight(.medium)
                    
                    Spacer()
                }
                .padding(.top, 4)
            }
        }
        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: isLocked)
    }
}
