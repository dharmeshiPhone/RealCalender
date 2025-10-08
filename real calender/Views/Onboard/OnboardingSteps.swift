import SwiftUI
import Foundation
import CoreGraphics

// MARK: - Welcome Step View
struct WelcomeStep: View {
    let userName: String
    @State private var animateTitle = false
    @State private var animateSubtitle = false
    @State private var animateIcon = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Animated icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(animateIcon ? 1.0 : 0.8)
                    .opacity(animateIcon ? 1.0 : 0.5)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(animateIcon ? 360 : 0))
            }
            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animateIcon)
            
            VStack(spacing: 16) {
                Text("Welcome to Your")
                    .font(.title)
                    .fontWeight(.light)
                    .opacity(animateTitle ? 1.0 : 0.0)
                    .offset(y: animateTitle ? 0 : 20)
                
                Text("TRANSFORMATION")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(animateTitle ? 1.0 : 0.0)
                    .offset(y: animateTitle ? 0 : 20)
                
                Text("This app will revolutionize your life by helping you track, optimize, and gamify every aspect of your personal development.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .opacity(animateSubtitle ? 1.0 : 0.0)
                    .offset(y: animateSubtitle ? 0 : 20)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateIcon = true
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                animateTitle = true
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(0.6)) {
                animateSubtitle = true
            }
        }
    }
}

// MARK: - Name Input Step View
struct NameInputStep: View {
    @Binding var userName: String
    @State private var isFieldFocused = false

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Text("What's Your Name?")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("We'll use this to personalize your journey")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                TextField("Enter your name", text: $userName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .scaleEffect(isFieldFocused ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isFieldFocused)
                    .onTapGesture {
                        isFieldFocused = true
                    }

                if !userName.isEmpty {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Perfect, \(userName)!")
                            .foregroundColor(.green)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 40)
        }
        .animation(.easeInOut(duration: 0.3), value: userName)
    }
}

// MARK: - Commitment Step View
struct CommitmentStep: View {
    let userName: String
    @Binding var showReadyButton: Bool
    @Binding var isCriticalInteraction: Bool
    @Binding var contractAnimationCompleted: Bool
    @State private var animateTitle = false
    @State private var animateCards = false
    @State private var animateContract = false
    @State private var showContract = false
    @State private var countdown = 5
    @State private var countdownProgress: Double = 0.0
    @State private var isCountingDown = false
    @State private var countdownTimer: Timer?
    @State private var contractSigned = false
    @State private var checkmarkScale: CGFloat = 1.0
    @State private var checkmarkOffset: CGFloat = 222
    @State private var showCheckmarkText = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.purple, .blue]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .scaleEffect(animateTitle ? 1.0 : 0.8)
                            .opacity(animateTitle ? 1.0 : 0.0)

                        Text(String(userName.first?.uppercased() ?? "Y"))
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .scaleEffect(animateTitle ? 1.0 : 0.8)
                            .opacity(animateTitle ? 1.0 : 0.0)
                    }

                    VStack(spacing: 8) {
                        Text("LISTEN UP, \(userName.uppercased()) ")
                            .font(.title2)
                            .fontWeight(.black)
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [.purple, .blue, .cyan]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .multilineTextAlignment(.center)
                            .opacity(animateTitle ? 1.0 : 0.0)
                            .offset(y: animateTitle ? 0 : 20)

                        VStack(spacing: 6) {
                            Text("THIS APP WILL TRANSFORM YOU")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.cyan)
                                .opacity(animateTitle ? 1.0 : 0.0)
                                .offset(y: animateTitle ? 0 : 20)
                        }
                    }
                }

                if !showContract && animateCards {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "bolt.fill")
                                .font(.title2)
                                .foregroundColor(.cyan)

                            Text("THIS APP IS NOT LIKE OTHERS")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.purple, .cyan]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }

                        VStack(spacing: 8) {
                            Text("You could change your life.")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                        }
                    }
                    .padding(16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.purple.opacity(0.15),
                                Color.blue.opacity(0.1),
                                Color.cyan.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [.red, .orange, .yellow]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .transition(.scale.combined(with: .opacity))
                    .scaleEffect(animateCards ? 1.0 : 0.9)
                    .animation(.spring(response: 0.8, dampingFraction: 0.7), value: animateCards)
                }

                if showContract && !contractSigned {
                    VStack(spacing: 16) {
                        VStack(spacing: 12) {
                            Text("I COMMIT TO MY TRANSFORMATION")
                                .font(.title2)
                                .fontWeight(.black)
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.purple, .blue, .cyan]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )

                            VStack(spacing: 10) {
                                Text("This app helps you get a head of your compitition while improving yourself if you commit to it.")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                if isCountingDown {
                                    VStack(spacing: 6) {
                                        Text("If you agree to this, contract is auto-signing...")
                                            .font(.subheadline)
                                            .foregroundColor(.orange)
                                            .fontWeight(.semibold)
                                
                                        ZStack {
                                            Circle()
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                                                .frame(width: 80, height: 80)
                                            
                                            Circle()
                                                .trim(from: 0.0, to: CGFloat(countdownProgress))
                                                .stroke(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [.yellow, .orange]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                                )
                                                .frame(width: 80, height: 80)
                                                .rotationEffect(.degrees(-90))
                                                .animation(.linear(duration: 0.05), value: countdownProgress)
                                            
                                            Text("\(countdown)")
                                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                                .foregroundColor(.yellow)
                                                .shadow(color: .yellow.opacity(0.6), radius: 2)
                                        }
                                    }
                                    .padding(.top, 6)
                                }
                            }
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.purple.opacity(0.15),
                                    Color.blue.opacity(0.1),
                                    Color.cyan.opacity(0.05)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.purple, .blue, .cyan]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .scaleEffect(showContract ? 1.0 : 0.8)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: showContract)
                    }
                } else if contractSigned {
                    VStack(spacing: 12) {
                        // Green circle with checkmark - starts at 80x80, then animates to final size
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.green, .mint]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80) // Start at countdown circle size
                            
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 35)) // Proportional to 80x80 circle
                                .foregroundColor(.white)
                        }
                        .scaleEffect(checkmarkScale) // Will animate from 1.0 to 1.5 (80px to 120px)
                        .offset(y: checkmarkOffset) // Will animate from countdown position up

                        if showCheckmarkText {
                            VStack(spacing: 6) {
                                Text("CONTRACT SIGNED")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                    .transition(.scale.combined(with: .opacity))

                                Text("Your transformation begins now, \(userName)")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                    .multilineTextAlignment(.center)
                                    .transition(.scale.combined(with: .opacity))
                                
                                Text("THIS IS YOUR MOMENT")
                                    .font(.title2)
                                    .fontWeight(.black)
                                    .foregroundColor(.green)
                                    .transition(.scale.combined(with: .opacity))
                            }
                            .padding(.top, 30)
                        }
                    }
                }
            }
            .offset(y: 0)

            Spacer()
        }
        .padding(.horizontal, 30)
        .onAppear {
            startAnimations()
        }
        .onDisappear {
            countdownTimer?.invalidate()
            countdownTimer = nil
            isCriticalInteraction = false
        }
    }

    private func startAnimations() {
        print("CommitmentStep: Starting animations")
        withAnimation(.easeOut(duration: 0.6)) {
            animateTitle = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animateCards = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                showContract = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                startCountdown()
            }
        }
    }

    private func startCountdown() {
        print("CommitmentStep: Starting countdown")
        isCriticalInteraction = true
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isCountingDown = true
        }
        countdown = 5
        countdownProgress = 0.0

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            self.countdownProgress += 0.01
            
            let newCountdown = 5 - Int(self.countdownProgress * 5)
            if newCountdown != self.countdown && newCountdown >= 0 {
                self.countdown = newCountdown
                print("CommitmentStep: Countdown \(self.countdown)")
            }
            
            if self.countdownProgress >= 1.0 {
                print("CommitmentStep: Countdown complete, enabling ready button")
                timer.invalidate()
                self.countdownTimer = nil
                self.countdown = 0

                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    self.isCountingDown = false
                    self.contractSigned = true
                    self.showReadyButton = true
                    self.isCriticalInteraction = false
                }
                
                // Start the checkmark animation sequence
                self.animateCheckmark()
            }
        }
    }
    
    private func animateCheckmark() {
        // Step 1: Icon moves to position above green text and grows from 80px to 120px (1.5x scale)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                self.checkmarkScale = 1.5 // 80px * 1.5 = 120px
                self.checkmarkOffset = 30 // Reduced from 50 to 30 to bring checkmark up a bit
            }
            
            // Step 2: Show text after icon reaches final position
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    self.showCheckmarkText = true
                }
                
                // Mark animation as completed after text appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.contractAnimationCompleted = true
                }
            }
        }
    }
}

// MARK: - Unlock Step View
struct UnlockStep: View {
    let userName: String
    @Binding var isUnlocking: Bool
    @Binding var unlockProgress: Double
    @Binding var showingUnlockAnimation: Bool
    @Binding var glowIntensity: Double
    let onComplete: () -> Void
    
    @State private var longPressTimer: Timer?
    @State private var hasBeenTapped = false
    @State private var isCompleted = false
    @State private var pulseScale: Double = 1.0
    @State private var blurredNumbers: [String] = []
    @State private var numbersTimer: Timer?

    private let transformationOath = "I will not give up on my transformation journey and I commit to becoming the best version of myself"

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                Text("READ THIS OATH AS YOU SCAN")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [.orange, .red]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("\"\(transformationOath)\"")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.orange)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange.opacity(0.1))
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            Spacer(minLength: 10)

            ZStack {
                // Inner scanner circle
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.95),
                                Color.gray.opacity(0.8),
                                Color.black.opacity(0.98)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .scaleEffect(pulseScale)

                // Inner border
                Circle()
                    .stroke(hasBeenTapped ? 
                        LinearGradient(
                            gradient: Gradient(colors: [.yellow, .green]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) : 
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: hasBeenTapped ? 4 : 3
                    )
                    .frame(width: 240, height: 240)
                    .scaleEffect(pulseScale)

                // Text inside scanner
                VStack(spacing: 4) {
                    if !hasBeenTapped {
                        Text("TAP TO START")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.gray.opacity(0.7))
                            .opacity(0.8)
                    } else if isUnlocking && !isCompleted {
                        Text("SCANNING...")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.cyan.opacity(0.7))
                            .scaleEffect(1.1)
                    } else {
                        Text("UNLOCKED")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.cyan.opacity(0.8))
                    }
                }

                // Outer progress ring - thinner stroke, perfectly touching the inner circle edge
                Circle()
                    .trim(from: 0.0, to: CGFloat(unlockProgress))
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.orange, .yellow]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 246, height: 246) // Exactly 240 + (stroke width 6) = 246
                    .rotationEffect(.degrees(-90))
                    .shadow(color: .orange.opacity(0.2), radius: 6)
            }
            .onTapGesture {
                if !hasBeenTapped && !isCompleted {
                    hasBeenTapped = true
                    print("Scanner ACTIVATED")
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if hasBeenTapped && !isCompleted && !isUnlocking {
                            print("Starting scan via drag")
                            startScan()
                        }
                    }
                    .onEnded { _ in
                        if isUnlocking && !isCompleted {
                            print("Stopping scan via drag")
                            stopScan()
                        }
                    }
            )

            VStack(spacing: 12) {
                Text(hasBeenTapped ? "HOLD the scanner while reading the oath above" : "Tap the scanner to begin")
                    .font(.caption)
                    .foregroundColor(.cyan.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .fontWeight(.regular)
                    .padding(.horizontal, 20)
            }
            .padding()
        }
        .padding(.horizontal, 20)
        .onDisappear {
            longPressTimer?.invalidate()
            numbersTimer?.invalidate()
        }
    }
    
    private func startScan() {
        if isCompleted || isUnlocking { 
            print("Can't start scan - completed: \(isCompleted), unlocking: \(isUnlocking)")
            return 
        }
        
        print("STARTING SCAN")
        isUnlocking = true
        unlockProgress = 0.0
        
        longPressTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { timer in
            self.unlockProgress += 0.008 
            
            if self.unlockProgress >= 1.0 {
                print("SCAN COMPLETED AT 100%!")
                self.unlockProgress = 1.0
                timer.invalidate()
                self.completeScan()
            }
        }
        
        startBackgroundNumbers()
    }
    
    private func stopScan() {
        if isCompleted { 
            print("Can't stop scan - already completed")
            return 
        }
        
        print("STOPPING SCAN at \(Int(unlockProgress * 100))%")
        isUnlocking = false
        unlockProgress = 0.0
        
        longPressTimer?.invalidate()
        longPressTimer = nil
        
        numbersTimer?.invalidate()
        numbersTimer = nil
        blurredNumbers = []
    }
    
    private func completeScan() {
        print("SCAN COMPLETED!")
        isUnlocking = false
        isCompleted = true
        
        longPressTimer?.invalidate()
        numbersTimer?.invalidate()
        blurredNumbers = []
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.onComplete()
        }
    }
    
    private func startBackgroundNumbers() {
        numbersTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            if self.blurredNumbers.count > 8 {
                self.blurredNumbers.removeFirst()
            }
            
            let randomNum = Int.random(in: 0...100)
            self.blurredNumbers.append("\(randomNum)%")
        }
    }
}