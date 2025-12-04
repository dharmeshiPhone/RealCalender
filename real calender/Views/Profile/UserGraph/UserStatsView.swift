import Foundation
import SwiftUI
import Charts

// MARK: - User Stats View
struct UserStatsView: View {
    @AppStorage("showGlowIcon") private var showGlowQuestIcon: Bool = false
    @EnvironmentObject var questManager: QuestManager
    @Binding var profile: UserProfile
    @Namespace private var anim
    @State private var showingRunTracker = false
    @StateObject private var runningTracker = RunningTracker()
    
    // Unlock animation states for all graphs
    @State private var swimmingUnlockPhase = 0 // 0: locked, 1: unlocking, 2: unlocked
    @State private var runningUnlockPhase = 0
    @State private var pullUpsUnlockPhase = 0
    @State private var incomeUnlockPhase = 0
    @State private var acedeamyUnlockPhase = 0
    @State private var bmiUnlockAnimationPhase = 0 // 0: locked, 1: unlocking, 2: unlocked
    @State private var bmiHasBeenSeen = false
    
    // Ball animations
    @State private var showSparklingBall = false
    @State private var sparklingBallOffset: CGFloat = -200
    @State private var lastUnlockedCount = 0
    @State private var showBMIBall = false
    @State private var bmiBallXPosition: CGFloat = 0
    @State private var bmiBallPosition: CGFloat = 0
    @State private var bmiBallOpacity: Double = 1.0
    @State private var animatedCompletedCount = 0
    @State private var showCompletionEffect = false
    @State private var completionProgress: Double = 0.0
    @State private var graphsCompletedTextPosition: CGPoint = .zero
    @State private var bmiLockIconPosition: CGPoint = .zero
    @State private var bmiChartCenterPosition: CGPoint = .zero
    @State private var ballAnimationTimer: Timer?
    @State private var showAcedemyBall = false
    
    
    // NEW: Lock positions for each chart
    @State private var swimmingLockPosition: CGPoint = .zero
    @State private var runningLockPosition: CGPoint = .zero
    @State private var pullUpsLockPosition: CGPoint = .zero
    @State private var incomeLockPosition: CGPoint = .zero
    @State private var acedemicLockPosition: CGPoint = .zero
    
    // Individual gold ball states
    @State private var showSwimmingBall = false {
        didSet {
            print("🔴 showSwimmingBall changed from \(oldValue) to \(showSwimmingBall)")
        }
    }
    @State private var showRunningBall = false {
        didSet {
            print("🔴 showRunningBall changed from \(oldValue) to \(showRunningBall)")
        }
    }
    @State private var showPullUpsBall = false {
        didSet {
            print("🔴 showPullUpsBall changed from \(oldValue) to \(showPullUpsBall)")
        }
    }
    @State private var showIncomeBall = false {
        didSet {
            print("🔴 showIncomeBall changed from \(oldValue) to \(showIncomeBall)")
        }
    }
    
    @State private var showingSwimmingEditor = false
    @State private var showingIncomeEditor = false
    @State private var showingPullUpsEditor = false
    @State private var showingAcademicEditor = false
    
    
//    init(profile: UserProfile? = nil) {
//        var initialProfile: UserProfile
//        if let providedProfile = profile {
//            initialProfile = providedProfile
//        } else if let loadedProfile = UserProfile.load() {
//            initialProfile = loadedProfile
//        } else {
//            initialProfile = UserProfile.shared
//            initialProfile.name = "User"
//            initialProfile.age = 0
//            initialProfile.heightCM = 0
//            initialProfile.weightKG = 0
//            initialProfile.level = 1
//            initialProfile.xp = 0
//        }
//        
//        self._profile = State(initialValue: initialProfile)
//    }
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Animated Avatar
                UserStatsProfileHeaderSection(profile: profile, anim: anim)
                
                // Quick inputs for user metrics
                UserStatsProfileMetricsSection(profile: profile)
                
                // Individual Performance Analytics
                UserStatsPerformanceSection(
                    profile: $profile,
                    swimmingUnlockPhase: $swimmingUnlockPhase,
                    runningUnlockPhase: $runningUnlockPhase,
                    pullUpsUnlockPhase: $pullUpsUnlockPhase,
                    incomeUnlockPhase: $incomeUnlockPhase,
                    acedeamyUnlockPhase: $acedeamyUnlockPhase,
                    bmiUnlockAnimationPhase: $bmiUnlockAnimationPhase,
                    showSwimmingBall: $showSwimmingBall,
                    showRunningBall: $showRunningBall,
                    showPullUpsBall: $showPullUpsBall,
                    showIncomeBall: $showIncomeBall, showAcedemyBall: $showAcedemyBall,
                    showBMIBall: $showBMIBall,
                    graphsCompletedTextPosition: $graphsCompletedTextPosition,
                    bmiBallXPosition: $bmiBallXPosition,
                    bmiBallPosition: $bmiBallPosition,
                    bmiBallOpacity: $bmiBallOpacity,
                    bmiLockIconPosition: $bmiLockIconPosition,
                    bmiChartCenterPosition: $bmiChartCenterPosition,
                    swimmingLockPosition: $swimmingLockPosition,
                    runningLockPosition: $runningLockPosition,
                    pullUpsLockPosition: $pullUpsLockPosition,
                    incomeLockPosition: $incomeLockPosition,
                    acedemicLockPosition: $acedemicLockPosition,
                    completionProgress: $completionProgress,
                    animatedCompletedCount: $animatedCompletedCount,
                    showCompletionEffect: $showCompletionEffect,
                    showSparklingBall: $showSparklingBall,
                    sparklingBallOffset: $sparklingBallOffset,
                    triggerGoldBallAnimation: triggerGoldBallAnimation,
                    triggerUnlockAnimation: triggerUnlockAnimation,
                    triggerBMIUnlockAnimation: triggerBMIUnlockAnimation,
                    triggerBMIBallCurvyAnimation: triggerBMIBallCurvyAnimation,
                    showingSwimmingEditor: $showingSwimmingEditor,
                    showingRunTracker: $showingRunTracker,
                    showingPullUpsEditor: $showingPullUpsEditor,
                    showingIncomeEditor: $showingIncomeEditor,
                    showingAcademicEditor:$showingAcademicEditor
                )
                
                // 5K Run Tracker
                UserStatsRunTrackingSection(
                    profile: $profile,
                    showingRunTracker: $showingRunTracker
                )
                
                // Achievement Section
                UserStatsAchievementsSection(profile: $profile)
                
                // Goals and Targets Section
                UserStatsGoalsSection(profile: $profile)
            }
            .padding()
        }
        .overlay(
            GeometryReader { geometry in
                let scrollBounds = geometry.frame(in: .global)
                
                SimplifiedGoldBallOverlay(
                    showSwimmingBall: $showSwimmingBall,
                    showRunningBall: $showRunningBall,
                    showPullUpsBall: $showPullUpsBall,
                    showIncomeBall: $showIncomeBall,
                    showBMIBall: $showBMIBall,
                    showAcedemyBall: $showAcedemyBall,
                    targetPosition: graphsCompletedTextPosition,
                    bmiBallXPosition: bmiBallXPosition,
                    bmiBallPosition: bmiBallPosition,
                    bmiBallOpacity: bmiBallOpacity,
                    scrollBounds: scrollBounds,
                    bmiChartCenterPosition: bmiChartCenterPosition,
                    swimmingStartPosition: swimmingLockPosition,  // NEW
                    runningStartPosition: runningLockPosition,    // NEW
                    pullUpsStartPosition: pullUpsLockPosition,    // NEW
                    incomeStartPosition: incomeLockPosition,       // NEW
                    acedemyStartPosition: acedemicLockPosition       // NEW
                )
            }
                .allowsHitTesting(false)
                .zIndex(998)
        )
        .sheet(isPresented: $showingRunTracker) {
            RunningTrackerView(runningTracker: runningTracker, userProfile: $profile)
        }
        .sheet(isPresented: $showingSwimmingEditor) {
            SwimmingEditor(userProfile: $profile) {
                // check Quest complete logic
                
            }
        }
        .sheet(isPresented: $showingIncomeEditor) {
            IncomeEditor(userProfile: $profile)
        }
        .sheet(isPresented: $showingPullUpsEditor) {
            PullUpsEditor(userProfile: $profile)
        }
        .sheet(isPresented: $showingAcademicEditor) {
            AcedemicEditor(userProfile: $profile)
        }
        .onReceive(NotificationCenter.default.publisher(for: .profileUpdated)) { notification in
            print("🔔🔔🔔 UserStatsView: NOTIFICATION RECEIVED 🔔🔔🔔")
            
            if let updatedProfile = notification.object as? UserProfile {
                print("🔔🔔🔔 UserStatsView: Notification profile - swimming: \(updatedProfile.swimming50MLaps), income: \(updatedProfile.annualIncomeThousands) 🔔🔔🔔")
                print("🔔🔔🔔 UserStatsView: Current profile - swimming: \(profile.swimming50MLaps), income: \(profile.annualIncomeThousands) 🔔🔔🔔")
                
                // CRITICAL FIX: Since binding updates happen immediately, we need to detect what changed
                // by comparing unlock phases rather than profile values
                
                // Check if any graphs should unlock based on current data vs unlock phases
                checkForNewUnlocks()
                
                print("🔔🔔🔔 UserStatsView: Animation check complete 🔔🔔🔔")
                
                
            } else {
                print("🔔🔔🔔 UserStatsView: Could not cast notification object to UserProfile 🔔🔔🔔")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .bmiUnlocked)) { _ in
            triggerBMIBallCurvyAnimation()
        }
        .onReceive(NotificationCenter.default.publisher(for: .bmiLockPositionUpdated)) { notification in
            if let position = notification.object as? CGPoint {
                bmiLockIconPosition = position
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .swimmingUnlocked)) { _ in
            print("🔴 SWIMMING NOTIFICATION RECEIVED - triggering gold ball")
            triggerGoldBallAnimation(for: .swimming)
            checkQuestComplition()
        }
        .onReceive(NotificationCenter.default.publisher(for: .runningUnlocked)) { _ in
            print("🔴 RUNNING NOTIFICATION RECEIVED - triggering gold ball")
            triggerGoldBallAnimation(for: .running)
            checkQuestComplition()
            
        }
        .onReceive(NotificationCenter.default.publisher(for: .pullUpsUnlocked)) { _ in
            print("🔴 PULLUPS NOTIFICATION RECEIVED - triggering gold ball")
            triggerGoldBallAnimation(for: .pullUps)
            checkQuestComplition()
        }
        .onReceive(NotificationCenter.default.publisher(for: .incomeUnlocked)) { _ in
            print("🔴 INCOME NOTIFICATION RECEIVED - triggering gold ball")
            triggerGoldBallAnimation(for: .income)
            checkQuestComplition()
        }
        .onAppear {
            print("📱 UserStatsView: onAppear called")
            print("📱 UserStatsView: Current profile - name: \(profile.name), swimming: \(profile.swimming50MLaps)")
            
            // CRITICAL: Reload profile from UserDefaults to ensure we have latest data
            reloadProfileFromUserDefaults()
            
            // CRITICAL FIX: Start lastUnlockedCount at 0 to match animated counters
            lastUnlockedCount = 0
            
            // Start BOTH progress indicators from 0
            animatedCompletedCount = 0
            completionProgress = 0.0
            
            // Initialize unlock phases based on current data
            initializeUnlockPhases()
            
            // Keep both at 0 on initial load - they'll increment as graphs unlock
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                // Don't animate to current state - let them increment naturally
                animatedCompletedCount = 0
                completionProgress = 0.0
            }
        }
        .onDisappear {
            print("📱 UserStatsView: onDisappear called - View is being deallocated")
            
            // Clean up any running timers
            ballAnimationTimer?.invalidate()
            ballAnimationTimer = nil
        }
    }
    
    // MARK: - Check Quest complition logic
    
    func checkQuestComplition(){
        if !questManager.checkQuestWasCompleted("Complete two graphs in your profile"){
            questManager.completeQuest(named: "Complete two graphs in your profile")
        }
    }
    
    
    // MARK: - Helper Functions
    private func initializeUnlockPhases() {
        swimmingUnlockPhase = profile.swimming50MLaps > 0 ? 2 : 0
        runningUnlockPhase = profile.running5KTimeSec > 0 ? 2 : 0
        
        let hasPullUps = profile.customStats.contains { stat in
            (stat.name.lowercased().contains("pull") || stat.name.lowercased().contains("pullup")) && stat.value > 0
        }
        pullUpsUnlockPhase = hasPullUps ? 2 : 0
        
        incomeUnlockPhase = profile.annualIncomeThousands > 0 ? 2 : 0
        bmiUnlockAnimationPhase = profile.bmi > 0 ? 2 : 0
        
        if profile.isStudent {
            acedeamyUnlockPhase =
                (profile.highSchoolGPA > 0.0 || profile.universityGPA > 0.0) ? 2 : 0
        }

    }
    
    private func checkForNewUnlocks() {
        print("💡💡💡 CHECK FOR NEW UNLOCKS - Current unlock phases: swim=\(swimmingUnlockPhase), run=\(runningUnlockPhase), pullups=\(pullUpsUnlockPhase), income=\(incomeUnlockPhase) 💡💡💡")
        
        if profile.swimming50MLaps > 0 && swimmingUnlockPhase == 0 {
            triggerUnlockAnimation(for: .swimming)
        }
        
        if profile.running5KTimeSec > 0 && runningUnlockPhase == 0 {
            triggerUnlockAnimation(for: .running)
        }
        
        let hasPullUps = profile.customStats.contains { stat in
            (stat.name.lowercased().contains("pull") || stat.name.lowercased().contains("pullup")) && stat.value > 0
        }
        if hasPullUps && pullUpsUnlockPhase == 0 {
            triggerUnlockAnimation(for: .pullUps)
        }
        
        if profile.annualIncomeThousands > 0 && incomeUnlockPhase == 0 {
            triggerUnlockAnimation(for: .income)
        }
    }
    
    func triggerUnlockAnimation(for graphType: GraphType) {
        switch graphType {
        case .swimming:
            withAnimation(.easeInOut(duration: 2.0)) {
                swimmingUnlockPhase = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                NotificationCenter.default.post(name: .swimmingUnlocked, object: nil)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                withAnimation(.spring(response: 1.0, dampingFraction: 0.7)) {
                    swimmingUnlockPhase = 2
                }
            }
            
        case .running:
            withAnimation(.easeInOut(duration: 2.0)) {
                runningUnlockPhase = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                NotificationCenter.default.post(name: .runningUnlocked, object: nil)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                withAnimation(.spring(response: 1.0, dampingFraction: 0.7)) {
                    runningUnlockPhase = 2
                }
            }
            
        case .pullUps:
            withAnimation(.easeInOut(duration: 2.0)) {
                pullUpsUnlockPhase = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                NotificationCenter.default.post(name: .pullUpsUnlocked, object: nil)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                withAnimation(.spring(response: 1.0, dampingFraction: 0.7)) {
                    pullUpsUnlockPhase = 2
                }
            }
            
        case .income:
            withAnimation(.easeInOut(duration: 2.0)) {
                incomeUnlockPhase = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                NotificationCenter.default.post(name: .incomeUnlocked, object: nil)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                withAnimation(.spring(response: 1.0, dampingFraction: 0.7)) {
                    incomeUnlockPhase = 2
                }
            }
            
        case .bmi:
            triggerBMIUnlockAnimation()
        case .acedemic:
            withAnimation(.easeInOut(duration: 2.0)) {
                acedeamyUnlockPhase = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                NotificationCenter.default.post(name: .acedemicUnlocked, object: nil)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                withAnimation(.spring(response: 1.0, dampingFraction: 0.7)) {
                    acedeamyUnlockPhase = 2
                }
            }
        }
    }
    
    func triggerGoldBallAnimation(for graphType: GraphType) {
        print("🚀 TRIGGERING GOLD BALL for \(graphType)")
        print("🚀 Current target position: \(graphsCompletedTextPosition)")
        
        // Add haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // NEW: Get the correct start position based on graph type
        let startPosition: CGPoint
        switch graphType {
        case .swimming:
            startPosition = swimmingLockPosition
        case .running:
            startPosition = runningLockPosition
        case .pullUps:
            startPosition = pullUpsLockPosition
        case .income:
            startPosition = incomeLockPosition
        case .bmi:
            startPosition = .zero // BMI uses a different animation
        case .acedemic:
            startPosition = acedemicLockPosition
        }
        
        print("🚀 Start position for \(graphType): \(startPosition)")
        
        switch graphType {
        case .swimming:
            print("🚀 Setting showSwimmingBall = true")
            showSwimmingBall = true
            updateProgressWithAnimation(to: lastUnlockedCount + 1)
            lastUnlockedCount = lastUnlockedCount + 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showSwimmingBall = false
                }
            }
            
        case .running:
            print("🚀 Setting showRunningBall = true")
            showRunningBall = true
            updateProgressWithAnimation(to: lastUnlockedCount + 1)
            lastUnlockedCount = lastUnlockedCount + 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showRunningBall = false
                }
            }
            
        case .pullUps:
            print("🚀 Setting showPullUpsBall = true")
            showPullUpsBall = true
            updateProgressWithAnimation(to: lastUnlockedCount + 1)
            lastUnlockedCount = lastUnlockedCount + 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showPullUpsBall = false
                }
            }
            
        case .income:
            print("🚀 Setting showIncomeBall = true")
            showIncomeBall = true
            updateProgressWithAnimation(to: lastUnlockedCount + 1)
            lastUnlockedCount = lastUnlockedCount + 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showIncomeBall = false
                }
            }
            
        case .bmi:
            break
        case .acedemic:
            print("🚀 Setting showAcedemy = true")
            showAcedemyBall = true
            updateProgressWithAnimation(to: lastUnlockedCount + 1)
            lastUnlockedCount = lastUnlockedCount + 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showAcedemyBall = false
                }
            }
        }
        
        print("🚀 Gold ball states after trigger: swimming=\(showSwimmingBall), running=\(showRunningBall), pullups=\(showPullUpsBall), income=\(showIncomeBall)")
    }
    
    func updateProgressWithAnimation(to newCount: Int) {
        let isStudent = profile.isStudent
        withAnimation(.spring(response: 1.0, dampingFraction: 0.6)) {
            animatedCompletedCount = newCount
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 1.2, dampingFraction: 0.6)) {
                completionProgress = Double(newCount) / (isStudent ? 6.0 : 5.0)
            }
        }
        
        if newCount > 0 {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        }
        
        if newCount >=  (isStudent ? 6 : 5){
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
        }
    }
    
    func triggerBMIBallCurvyAnimation() {
        // Use the BMI chart center position instead of graphsCompletedTextPosition if available
        let targetPosition = bmiChartCenterPosition != .zero ? bmiChartCenterPosition : graphsCompletedTextPosition
        
        print("🎯 BMI BALL TARGET POSITION: \(targetPosition)")
        print("🎯 BMI LOCK ICON POSITION: \(bmiLockIconPosition)")
        
        if targetPosition == .zero {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.triggerBMIBallCurvyAnimation()
            }
            return
        }
        
        let startOffsetX = bmiLockIconPosition.x - targetPosition.x
        let startOffsetY = bmiLockIconPosition.y - targetPosition.y
        
        print("🎯 BMI BALL START OFFSET: X=\(startOffsetX), Y=\(startOffsetY)")
        
        bmiBallXPosition = startOffsetX
        bmiBallPosition = startOffsetY
        bmiBallOpacity = 0.0
        
        showBMIBall = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeIn(duration: 1.0)) {
                bmiBallOpacity = 1.0
            }
            
            let waypoint1X = startOffsetX * 0.4 + 60
            let waypoint1Y = startOffsetY * 0.8
            
            let waypoint2X = startOffsetX * 0.1 + 40
            let waypoint2Y = startOffsetY * 0.4
            
            withAnimation(.easeOut(duration: 0.8)) {
                bmiBallXPosition = waypoint1X
                bmiBallPosition = waypoint1Y
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    bmiBallXPosition = waypoint2X
                    bmiBallPosition = waypoint2Y
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeIn(duration: 0.8)) {
                    bmiBallXPosition = 0
                    bmiBallPosition = 0
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.7)) {
                    bmiBallOpacity = 0.0
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                showBMIBall = false
                bmiBallOpacity = 1.0
                
                updateProgressWithAnimation(to: lastUnlockedCount + 1)
                lastUnlockedCount = lastUnlockedCount + 1
                
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                    showCompletionEffect = true
                }
                
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showCompletionEffect = false
                    }
                }
            }
        }
    }
    
    func triggerBMIUnlockAnimation() {
        withAnimation(.easeInOut(duration: 2.5)) {
            bmiUnlockAnimationPhase = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation(.spring(response: 1.5, dampingFraction: 0.7)) {
                bmiUnlockAnimationPhase = 2
            }
        }
    }
    
    func reloadProfileFromUserDefaults() {
        print("📱 UserStatsView: Reloading profile from UserDefaults")
        
        if let loadedProfile = UserProfile.load() {
            profile = loadedProfile
            print("📱 UserStatsView: Successfully loaded fresh profile")
            print("📱 UserStatsView: Loaded - name: \(loadedProfile.name), swimming: \(loadedProfile.swimming50MLaps)")
            print("📱 UserStatsView: Loaded - gender: \(loadedProfile.gender), hasBasic: \(loadedProfile.hasBasicProfileSetup)")
        } else {
            print("📱 UserStatsView: Failed to reload profile from UserDefaults")
        }
    }
}

