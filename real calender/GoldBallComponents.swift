import SwiftUI

// MARK: - Gold Ball Components
struct SimplifiedGoldBallOverlay: View {
    @Binding var showSwimmingBall: Bool
    @Binding var showRunningBall: Bool
    @Binding var showPullUpsBall: Bool
    @Binding var showIncomeBall: Bool
    @Binding var showBMIBall: Bool
    @Binding var showAcedemyBall: Bool
    let targetPosition: CGPoint
    let bmiBallXPosition: CGFloat
    let bmiBallPosition: CGFloat
    let bmiBallOpacity: Double
    let scrollBounds: CGRect
    let bmiChartCenterPosition: CGPoint  // BMI chart center position
  
    
    // NEW: Add start positions for each ball
    let swimmingStartPosition: CGPoint
    let runningStartPosition: CGPoint
    let pullUpsStartPosition: CGPoint
    let incomeStartPosition: CGPoint
    let acedemyStartPosition: CGPoint
    
    var body: some View {
        ZStack {
            // Debug indicator to show if overlay is working
            if targetPosition != .zero {
                Circle()
                    .fill(Color.red.opacity(0.3))
                    .frame(width: 10, height: 10)
                    .position(targetPosition)
                    .offset(y: -scrollBounds.minY)  // Adjust for scroll
                    .opacity(0.5)
                    .zIndex(1000)
            }
            
            // Swimming Gold Ball - PROPER ANIMATION TO TARGET
            if showSwimmingBall {
                ProperGoldBall(
                    ballId: "SWIMMING", 
                    isVisible: showSwimmingBall,
                    targetPosition: targetPosition,
                    scrollBounds: scrollBounds,
                    startDelay: 0.0,
                    startPosition: swimmingStartPosition  // NEW
                )
                .onAppear {
                    print("🟡 SWIMMING BALL APPEARED - Target: \(targetPosition)")
                }
            }
            
            // Running Gold Ball
            if showRunningBall {
                ProperGoldBall(
                    ballId: "RUNNING", 
                    isVisible: showRunningBall,
                    targetPosition: targetPosition,
                    scrollBounds: scrollBounds,
                    startDelay: 0.2,
                    startPosition: runningStartPosition  // NEW
                )
                .onAppear {
                    print("🟡 RUNNING BALL APPEARED - Target: \(targetPosition)")
                }
            }
            
            // Pull-ups Gold Ball
            if showPullUpsBall {
                ProperGoldBall(
                    ballId: "PULLUPS", 
                    isVisible: showPullUpsBall,
                    targetPosition: targetPosition,
                    scrollBounds: scrollBounds,
                    startDelay: 0.4,
                    startPosition: pullUpsStartPosition  // NEW
                )
                .onAppear {
                    print("🟡 PULLUPS BALL APPEARED - Target: \(targetPosition)")
                }
            }
            
            // Income Gold Ball
            if showIncomeBall {
                ProperGoldBall(
                    ballId: "INCOME", 
                    isVisible: showIncomeBall,
                    targetPosition: targetPosition,
                    scrollBounds: scrollBounds,
                    startDelay: 0.6,
                    startPosition: incomeStartPosition  // NEW
                )
                .onAppear {
                    print("🟡 INCOME BALL APPEARED - Target: \(targetPosition)")
                }
            }
            
            // BMI Ball Animation - SPECIAL CURVY ANIMATION (NOT the regular ProperGoldBall)
            if showBMIBall {
                // Use BMI chart center position if available, otherwise fall back to targetPosition
                let effectiveTargetPosition = bmiChartCenterPosition != .zero ? bmiChartCenterPosition : targetPosition
                
                // Calculate the actual position including the curvy animation offsets
                let ballGlobalX = effectiveTargetPosition.x + bmiBallXPosition
                let ballGlobalY = effectiveTargetPosition.y + bmiBallPosition
                
                // Adjust for scroll bounds - this is the key fix
                let localX = ballGlobalX
                let localY = ballGlobalY - scrollBounds.minY
                
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.yellow.opacity(0.4 * bmiBallOpacity), .clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: 50
                            )
                        )
                        .frame(width: 80, height: 80)
                        .opacity(bmiBallOpacity)
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    .white,
                                    Color(red: 1.0, green: 0.85, blue: 0.2),
                                    Color(red: 1.0, green: 0.65, blue: 0.0),
                                    Color(red: 0.8, green: 0.5, blue: 0.0)
                                ],
                                center: UnitPoint(x: 0.3, y: 0.3),
                                startRadius: 2,
                                endRadius: 20
                            )
                        )
                        .frame(width: 35, height: 35)
                        .shadow(color: .yellow.opacity(0.8 * bmiBallOpacity), radius: 15)
                        .shadow(color: .orange.opacity(0.6 * bmiBallOpacity), radius: 25)
                        .opacity(bmiBallOpacity)
                    
                    if bmiBallOpacity > 0.3 {
                        Image(systemName: "sparkles")
                            .foregroundColor(.white)
                            .font(.system(size: 12, weight: .bold))
                            .opacity(bmiBallOpacity)
                            .shadow(color: .white, radius: 3)
                    }
                }
                .position(x: localX, y: localY)
                .transition(.opacity.combined(with: .scale))
                .animation(.easeOut(duration: 0.3), value: showBMIBall)
                .zIndex(998)
                
                // Debug: Show target position for BMI ball
                if bmiChartCenterPosition != .zero {
                    Circle()
                        .fill(Color.blue.opacity(0.5))
                        .frame(width: 8, height: 8)
                        .position(bmiChartCenterPosition)
                        .offset(y: -scrollBounds.minY)
                        .zIndex(1000)
                }
            }
        }
        .allowsHitTesting(false) // Pass touches through
        .onAppear {
            print("🎯 SimplifiedGoldBallOverlay appeared with target: \(targetPosition)")
            print("🎯 BMI Chart Center Position: \(bmiChartCenterPosition)")
            print("🎯 Scroll Bounds: \(scrollBounds)")
        }
        .onChange(of: targetPosition) { oldValue, newValue in
            print("🎯 Target position updated from \(oldValue) to \(newValue)")
        }
        .onChange(of: bmiChartCenterPosition) { oldValue, newValue in
            print("🎯 BMI Chart Center Position updated from \(oldValue) to \(newValue)")
        }
    }
}

// MARK: - Proper Gold Ball Component
struct ProperGoldBall: View {
    let ballId: String
    let isVisible: Bool
    let targetPosition: CGPoint
    let scrollBounds: CGRect
    let startDelay: TimeInterval
    let startPosition: CGPoint  // NEW: Accept start position instead of defaulting
    
    @State private var ballPosition: CGPoint = .zero
    @State private var ballOpacity: Double = 0.0
    @State private var ballScale: Double = 0.0
    @State private var animationStarted: Bool = false
    @State private var ballGlow: Double = 0.0
    
    var body: some View {
        if animationStarted && ballOpacity > 0 {
            ZStack {
                // Enhanced outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.yellow.opacity(0.4 * ballOpacity), .clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 50
                        )
                    )
                    .frame(width: 80, height: 80)
                    .opacity(ballGlow)
                
                // Main gold ball with premium gradient
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .white,
                                Color(red: 1.0, green: 0.85, blue: 0.2),
                                Color(red: 1.0, green: 0.65, blue: 0.0),
                                Color(red: 0.8, green: 0.5, blue: 0.0)
                            ],
                            center: UnitPoint(x: 0.3, y: 0.3),
                            startRadius: 2,
                            endRadius: 20
                        )
                    )
                    .frame(width: 35, height: 35)
                    .shadow(color: .yellow.opacity(0.8 * ballOpacity), radius: 15)
                    .shadow(color: .orange.opacity(0.6 * ballOpacity), radius: 25)
                    .opacity(ballOpacity)
                    .scaleEffect(ballScale)
                
                // Sparkle effect
                if ballOpacity > 0.3 {
                    Image(systemName: "sparkles")
                        .foregroundColor(.white)
                        .font(.system(size: 12, weight: .bold))
                        .opacity(ballOpacity)
                        .shadow(color: .white, radius: 3)
                        .scaleEffect(ballScale)
                }
            }
            .position(ballPosition)
            .offset(y: -scrollBounds.minY)  // Adjust for scroll position
            .zIndex(999) // Ensure it's on top
            .allowsHitTesting(false)
        }
        
        Color.clear
            .onAppear {
                print("🟡 \(ballId) BALL: onAppear called, isVisible: \(isVisible)")
                if isVisible && !animationStarted {
                    startProperAnimation()
                }
            }
            .onChange(of: isVisible) { oldValue, newValue in
                print("🟡 \(ballId) BALL: isVisible changed from \(oldValue) to \(newValue)")
                if newValue && !animationStarted {
                    startProperAnimation()
                } else if !newValue {
                    resetAnimation()
                }
            }
            .onChange(of: targetPosition) { oldValue, newValue in
                print("🟡 \(ballId) BALL: targetPosition changed from \(oldValue) to \(newValue)")
            }
    }
    
    private func startProperAnimation() {
        guard targetPosition != .zero else {
            print("🟡 \(ballId) BALL: Target position is zero, delaying animation")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                startProperAnimation()
            }
            return
        }
        
        print("🟡 \(ballId) BALL: Starting animation with target: \(targetPosition)")
        animationStarted = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
            // NEW: Start from provided startPosition instead of screen center
            ballPosition = startPosition != .zero ? startPosition : CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
            
            print("🟡 \(ballId) BALL: Setting initial position: \(ballPosition)")
            
            // Calculate distance to determine animation duration
            let startX = ballPosition.x
            let startY = ballPosition.y
            let distance = sqrt(pow(targetPosition.x - startX, 2) + pow(targetPosition.y - startY, 2))
            let baseDuration: Double = 1.5
            let maxDistance: CGFloat = UIScreen.main.bounds.height
            let durationMultiplier = min(distance / maxDistance, 1.0) * 0.8 + 0.2 // Range: 0.2 to 1.0
            let moveDuration = baseDuration * Double(durationMultiplier)
            
            print("🟡 \(ballId) BALL: Distance: \(distance), Duration: \(moveDuration)")
            
            // Fade in and scale up with glow
            withAnimation(.easeOut(duration: 0.6)) {
                ballOpacity = 1.0
                ballScale = 1.0
                ballGlow = 1.0
            }
            
            // Move to target with distance-adjusted duration
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                print("🟡 \(ballId) BALL: Moving to target: \(targetPosition)")
                withAnimation(.spring(response: moveDuration, dampingFraction: 0.8)) {
                    ballPosition = targetPosition
                }
            }
            
            // Fade out at target (adjusted timing based on movement duration)
            let fadeOutDelay = 0.6 + moveDuration + 0.3
            DispatchQueue.main.asyncAfter(deadline: .now() + fadeOutDelay) {
                withAnimation(.easeOut(duration: 1.0)) {
                    ballOpacity = 0.0
                    ballScale = 0.8
                    ballGlow = 0.0
                }
            }
            
            // Reset after animation (adjusted timing)
            DispatchQueue.main.asyncAfter(deadline: .now() + fadeOutDelay + 1.5) {
                resetAnimation()
            }
        }
    }
    
    private func resetAnimation() {
        print("🟡 \(ballId) BALL: Resetting animation")
        animationStarted = false
        ballOpacity = 0.0
        ballScale = 0.0
        ballGlow = 0.0
        ballPosition = .zero
    }
}
