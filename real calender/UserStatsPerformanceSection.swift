import SwiftUI
import Charts

struct UserStatsPerformanceSection: View {
    @EnvironmentObject var questManager: QuestManager
    @Binding var profile: UserProfile
    @Binding var swimmingUnlockPhase: Int
    @Binding var runningUnlockPhase: Int
    @Binding var pullUpsUnlockPhase: Int
    @Binding var incomeUnlockPhase: Int
    @Binding var acedeamyUnlockPhase: Int
    @Binding var bmiUnlockAnimationPhase: Int
    
    @Binding var showSwimmingBall: Bool
    @Binding var showRunningBall: Bool
    @Binding var showPullUpsBall: Bool
    @Binding var showIncomeBall: Bool
    @Binding var showAcedemyBall: Bool
    @Binding var showBMIBall: Bool
    
    @Binding var graphsCompletedTextPosition: CGPoint
    @Binding var bmiBallXPosition: CGFloat
    @Binding var bmiBallPosition: CGFloat
    @Binding var bmiBallOpacity: Double
    @Binding var bmiLockIconPosition: CGPoint
    @Binding var bmiChartCenterPosition: CGPoint
    
    // NEW: Add lock positions for each chart
    @Binding var swimmingLockPosition: CGPoint
    @Binding var runningLockPosition: CGPoint
    @Binding var pullUpsLockPosition: CGPoint
    @Binding var incomeLockPosition: CGPoint
    @Binding var acedemicLockPosition: CGPoint
    
    @Binding var completionProgress: Double
    @Binding var animatedCompletedCount: Int
    @Binding var showCompletionEffect: Bool
    @Binding var showSparklingBall: Bool
    @Binding var sparklingBallOffset: CGFloat
    
    let triggerGoldBallAnimation: (GraphType) -> Void
    let triggerUnlockAnimation: (GraphType) -> Void
    let triggerBMIUnlockAnimation: () -> Void
    let triggerBMIBallCurvyAnimation: () -> Void
    
    @Binding var showingSwimmingEditor: Bool
    @Binding var showingRunTracker: Bool
    @Binding var showingPullUpsEditor: Bool
    @Binding var showingIncomeEditor: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("📊 Normal Distribution Analysis")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                if getLockedGraphsCount() > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Text("\(getLockedGraphsCount()) locked")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            Text("See how your performance compares to age \(profile.age) population")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 20) {
                DistributionUnlockChart(
                    title: "Swimming Endurance (50m laps)",
                    userValue: Double(profile.swimming50MLaps),
                    ageGroupStats: AgeGroupDataGenerator.getSwimmingStats(age: profile.age, gender: profile.gender),
                    unit: "laps",
                    color: .blue,
                    isHigherBetter: true,
                    unlockPhase: swimmingUnlockPhase,
                    showGoldBall: showSwimmingBall,
                    profile: profile,
                    onAddData: {
                        showingSwimmingEditor = true
                    },
                    onLockPosition: { position in  // NEW
                        swimmingLockPosition = position
                    }
                )
                
                DistributionUnlockChart(
                    title: "5K Running Time",
                    userValue: profile.running5KTimeSec > 0 ? Double(profile.running5KTimeSec) / 60.0 : 0.0,
                    ageGroupStats: AgeGroupDataGenerator.getRunningStats(age: profile.age, gender: profile.gender),
                    unit: "min",
                    color: .green,
                    isHigherBetter: false,
                    unlockPhase: runningUnlockPhase,
                    showGoldBall: showRunningBall,
                    profile: profile,
                    onAddData: {
                        showingRunTracker = true
                    },
                    onLockPosition: { position in  // NEW
                        runningLockPosition = position
                    }
                )
                
                let hasPullUps = profile.customStats.contains { stat in
                    (stat.name.lowercased().contains("pull") || stat.name.lowercased().contains("pullup")) && stat.value > 0
                }
                
                let pullUpValue: Double = hasPullUps ? 
                    (profile.customStats.first { stat in
                        (stat.name.lowercased().contains("pull") || stat.name.lowercased().contains("pullup")) && stat.value > 0
                    }?.value ?? 0.0) : 0.0
                
                DistributionUnlockChart(
                    title: "Pull-ups",
                    userValue: pullUpValue,
                    ageGroupStats: AgeGroupDataGenerator.getPullUpStats(age: profile.age, gender: profile.gender),
                    unit: "reps",
                    color: .red,
                    isHigherBetter: true,
                    unlockPhase: pullUpsUnlockPhase,
                    showGoldBall: showPullUpsBall,
                    profile: profile,
                    onAddData: {
                        showingPullUpsEditor = true
                    },
                    onLockPosition: { position in  // NEW
                        pullUpsLockPosition = position
                    }
                )
                
                DistributionUnlockChart(
                    title: "Annual Income",
                    userValue: Double(profile.annualIncomeThousands),
                    ageGroupStats: AgeGroupDataGenerator.getIncomeStats(age: profile.age, gender: profile.gender),
                    unit: "k",
                    color: .orange,
                    isHigherBetter: true,
                    unlockPhase: incomeUnlockPhase,
                    showGoldBall: showIncomeBall,
                    profile: profile,
                    onAddData: {
                        showingIncomeEditor = true
                    },
                    onLockPosition: { position in  // NEW
                        incomeLockPosition = position
                    }
                )
                
                DistributionUnlockChart(
                    title: "Academic Graph",
                    userValue: Double(profile.annualIncomeThousands),
                    ageGroupStats: AgeGroupDataGenerator.getIncomeStats(age: profile.age, gender: profile.gender),
                    unit: "grade",
                    color: .indigo,
                    isHigherBetter: true,
                    unlockPhase: acedeamyUnlockPhase,
                    showGoldBall: showAcedemyBall,
                    profile: profile,
                    onAddData: {
                        showingIncomeEditor = true
                    },
                    onLockPosition: { position in  // NEW
                        acedemicLockPosition = position
                    }
                )
                
                GeometryReader { geometry in
                    let frame = geometry.frame(in: .global)
                    let screenHeight = UIScreen.main.bounds.height
                    let screenCenter = screenHeight / 2
                    let chartCenter = frame.midY
                    let isChartCentered = abs(chartCenter - screenCenter) < 150
                    
                    BMIUnlockChart(
                        profile: profile,
                        unlockAnimationPhase: bmiUnlockAnimationPhase,
                        countdown: 0
                    )
                    .background(
                        GeometryReader { chartGeometry in
                            Color.clear
                                .onAppear {
                                    let chartFrame = chartGeometry.frame(in: .global)
                                    bmiChartCenterPosition = CGPoint(x: chartFrame.midX, y: chartFrame.midY)
                                    print("🎯 BMI CHART CENTER POSITION SET: \(bmiChartCenterPosition)")
                                }
                                .onChange(of: chartGeometry.frame(in: .global)) { oldValue, newValue in
                                    bmiChartCenterPosition = CGPoint(x: newValue.midX, y: newValue.midY)
                                    print("🎯 BMI CHART CENTER POSITION UPDATED: \(bmiChartCenterPosition)")
                                }
                        }
                    )
                    .onChange(of: isChartCentered) { oldValue, newValue in
                        if newValue && !oldValue && bmiUnlockAnimationPhase == 0 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                if bmiUnlockAnimationPhase == 0 {
                                    triggerBMIUnlockAnimation()
                                }
                            }
                        }
                    }
                    .onAppear {
                        bmiUnlockAnimationPhase = 0
                    }
                }
                .frame(height: 320)
                
                if getLockedGraphsCount() > 0 {
                    completionBoxSection
                }
            }
        }
    }
    
    private var completionBoxSection: some View {
        ZStack {
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(completionProgress > 0.8 ? .green : .blue)
                    Text("Complete Your Analytics")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(completionProgress > 0.8 ? .green : .blue)
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("• Tap any locked graph to enter your information")
                    Text("• See exactly where you rank compared to people your age")
                    Text("• Track your progress over time")
                    Text("• Discover your strengths and areas to improve")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                HStack {
                    ZStack {
                        Text("Graphs completed: \(animatedCompletedCount)/6")
                            .font(.caption)
                            .foregroundColor(completionProgress > 0.8 ? .green : .secondary)
                            .fontWeight(completionProgress > 0.8 ? .semibold : .regular)
                            .background(
                                GeometryReader { geometry in
                                    Color.clear
                                        .onAppear {
                                            let frame = geometry.frame(in: .global)
                                            graphsCompletedTextPosition = CGPoint(x: frame.midX, y: frame.midY)
                                            print("🎯 TARGET POSITION SET: \(graphsCompletedTextPosition)")
                                        }
                                        .onChange(of: geometry.frame(in: .global)) { oldValue, newValue in
                                            graphsCompletedTextPosition = CGPoint(x: newValue.midX, y: newValue.midY)
                                            print("🎯 TARGET POSITION UPDATED: \(graphsCompletedTextPosition)")
                                        }
                                }
                            )
                        
                        if showCompletionEffect {
                            Text("Graphs completed: \(animatedCompletedCount)/6")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                                .scaleEffect(1.3)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.green.opacity(0.3))
                                        .scaleEffect(1.8)
                                        .blur(radius: 2)
                                )
                                .shadow(color: .green.opacity(0.8), radius: 15)
                                .transition(.scale.combined(with: .opacity))
                                .animation(.spring(response: 0.4, dampingFraction: 0.5), value: showCompletionEffect)
                        }
                    }
                    
                    Spacer()
                    
                    ProgressView(value: completionProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: completionProgress > 0.8 ? .green : .blue))
                        .frame(width: 100)
                        .animation(.spring(response: 1.2, dampingFraction: 0.6), value: completionProgress) 
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: completionProgress > 0.8 ?
                                [Color.green.opacity(0.15), Color.green.opacity(0.08)] :
                                [Color.blue.opacity(0.1), Color.blue.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        completionProgress > 0.8 ?
                            Color.green.opacity(0.4) :
                            Color.blue.opacity(0.3),
                        lineWidth: completionProgress > 0.8 ? 2 : 1
                    )
                    .opacity(completionProgress > 0.8 ? 1.0 : 0.6)
            )
            .animation(.spring(response: 1.0, dampingFraction: 0.7), value: completionProgress)
            
            if showSparklingBall && sparklingBallOffset != -200 {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white, .yellow, .orange],
                            center: .center,
                            startRadius: 2,
                            endRadius: 20
                        )
                    )
                    .frame(width: 35, height: 35)
                    .shadow(color: .yellow.opacity(0.8), radius: 15)
                    .offset(y: sparklingBallOffset)
                    .animation(.easeInOut(duration: 2.0), value: sparklingBallOffset)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            sparklingBallOffset = 0
                        }
                    }
            }
        }
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        // Ensure we have a valid target position for gold balls
                        let frame = geometry.frame(in: .global)
                        if graphsCompletedTextPosition == .zero {
                            graphsCompletedTextPosition = CGPoint(x: frame.midX, y: frame.midY - 50)
                            print("🎯 COMPLETION BOX TARGET POSITION SET: \(graphsCompletedTextPosition)")
                        }
                    }
                    .onChange(of: geometry.frame(in: .global)) { oldValue, newValue in
                        if graphsCompletedTextPosition == .zero {
                            graphsCompletedTextPosition = CGPoint(x: newValue.midX, y: newValue.midY - 50)
                            print("🎯 COMPLETION BOX TARGET POSITION UPDATED: \(graphsCompletedTextPosition)")
                        }
                    }
            }
        )
    }
    
    // MARK: - Helper Functions
    private func getLockedGraphsCount() -> Int {
        var lockedCount = 0
        
        if profile.swimming50MLaps == 0 { lockedCount += 1 }
        if profile.running5KTimeSec == 0 { lockedCount += 1 }
        
        let hasPullUps = profile.customStats.contains { stat in
            (stat.name.lowercased().contains("pull") || stat.name.lowercased().contains("pullup")) && stat.value > 0
        }
        if !hasPullUps { lockedCount += 1 }
        
        if profile.annualIncomeThousands == 0 { lockedCount += 1 }
        if profile.bmi == 0 { lockedCount += 1 }
        
        return lockedCount
    }
}
