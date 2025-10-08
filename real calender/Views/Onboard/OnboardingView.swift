import SwiftUI
import Combine
import Foundation
import CoreGraphics

// MARK: - Data Models
struct OnboardingView: View {
    @Binding var isCompleted: Bool
    @State private var userName = ""
    @State private var currentStep = 0
    @State private var isUnlocking = false
    @State private var unlockProgress: Double = 0.0
    @State private var showingUnlockAnimation = false
    @State private var glowIntensity: Double = 0.0
    @State private var showReadyButton = false
    @State private var showSubscriptionPopup = false
    @State private var scrollOffset: CGFloat = 0
    @State private var isScrolled = false
    @State private var isActive = true
    @State private var isCriticalInteraction = false
    @State private var contractAnimationCompleted = false

    let steps = [
        "Welcome to Your Transformation",
        "What's Your Name?",
        "Your Commitment",
        "Unlock Your Potential"
    ]

    var body: some View {
        ZStack {
            backgroundView
            contentView
            
            // Dev skip button
            VStack {
                HStack {
                    Spacer()
                    Button("DEV SKIP") {
                        completeOnboarding()
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(6)
                    .padding(.top, 10)
                    .padding(.trailing, 10)
                }
                Spacer()
            }
        }
        .sheet(isPresented: $showSubscriptionPopup) {
            subscriptionSheet
        }
        .onAppear {
            handleViewAppear()
        }
        .onDisappear {
            print("OnboardingView disappeared")
        }
        .onChange(of: currentStep) { oldStep, newStep in
            handleStepChange(from: oldStep, to: newStep)
        }
    }
    
    private var backgroundView: some View {
        Color.clear
    }
    
    private var contentView: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 20) {
                        scrollDetectionView
                        Spacer().frame(height: 10)
                        mainContent
                        Spacer().frame(height: 10)
                        navigationButtons
                    }
                    .coordinateSpace(name: "scroll")
                }
                .scrollDisabled(isCriticalInteraction || (currentStep == 2 && contractAnimationCompleted))
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    handleScrollOffset(value)
                }
            }
        }
    }
    
    private var scrollDetectionView: some View {
        Color.clear
            .frame(height: 1)
            .id("scrollDetection")
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .named("scroll")).minY)
                }
            )
    }
    
    private var mainContent: some View {
        VStack(spacing: 25) {
            stepIndicator
            currentStepView
        }
    }
    
    private var stepIndicator: some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                ForEach(0..<steps.count, id: \.self) { stepIndex in
                    Circle()
                        .fill(stepIndex <= currentStep ? 
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ) : 
                            LinearGradient(
                                gradient: Gradient(colors: [Color.gray.opacity(0.3)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 12, height: 12)
                        .scaleEffect(stepIndex == currentStep ? 1.3 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: currentStep)
                }
            }
        }
    }
    
    private var currentStepView: some View {
        Group {
            switch currentStep {
            case 0:
                WelcomeStep(userName: userName.isEmpty ? "Champion" : userName)
            case 1:
                NameInputStep(userName: $userName)
            case 2:
                CommitmentStep(
                    userName: userName,
                    showReadyButton: $showReadyButton,
                    isCriticalInteraction: $isCriticalInteraction,
                    contractAnimationCompleted: $contractAnimationCompleted
                )
            case 3:
                UnlockStep(
                    userName: userName,
                    isUnlocking: $isUnlocking,
                    unlockProgress: $unlockProgress,
                    showingUnlockAnimation: $showingUnlockAnimation,
                    glowIntensity: $glowIntensity,
                    onComplete: {
                        print("UnlockStep completed, showing subscription popup directly")
                        DispatchQueue.main.async {
                            handleSubscriptionSelection(plan: .trial)
                                            completeOnboarding()
                           // self.showSubscriptionPopup = true
                        }
                    }
                )
            default:
                defaultStepView
            }
        }
    }
    
    private var defaultStepView: some View {
        VStack(spacing: 20) {
            Text("Loading Step \(currentStep)...")
                .font(.title2)
                .foregroundColor(.primary)

            ProgressView()
                .scaleEffect(1.5)

            Button("Reset to Welcome") {
                resetToWelcome()
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private var navigationButtons: some View {
        HStack {
            if currentStep > 0 && currentStep < 3 {
                Button("Back") {
                    handleBackButton()
                }
                .foregroundColor(.secondary)

            }

            Spacer()

            if currentStep < 2 {
                Button(currentStep == 0 ? "Let's Begin" : "Continue") {
                    handleContinueButton()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            } else if currentStep == 2 {
                readyButton
            }
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 20)
        .opacity(currentStep == 2 && !contractAnimationCompleted ? 0 : 1)
    }
    
    private var readyButton: some View {
        Group {
            if showReadyButton {
                Button("I'm Ready") {
                    handleReadyButton()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .scaleEffect(showReadyButton ? 1.0 : 0.0)
                .opacity(showReadyButton ? 1.0 : 0.0)
                .transition(.scale.combined(with: .opacity))
            } else {
                Button("I'm Ready") {
                    // Button disabled while waiting for countdown
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(true)
                .opacity(0.5)
                .scaleEffect(0.95)
            }
        }
    }
    
    private var subscriptionSheet: some View {
        SubscriptionTimerPopupView(
            userName: userName,
            onSelectPlan: { plan in
                handleSubscriptionSelection(plan: plan)
                completeOnboarding()
            }
        )
        .interactiveDismissDisabled(true)
    }
    
    // MARK: - Helper Methods
    private func handleViewAppear() {
        print("OnboardingView appeared, currentStep: \(currentStep)")
        if isActive {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                
            }
        }
    }
    
    private func handleStepChange(from oldStep: Int, to newStep: Int) {
        print("Onboarding step changed from \(oldStep) to \(newStep)")

        switch newStep {
        case 2:
            showReadyButton = false
            contractAnimationCompleted = false
        case 3:
            isUnlocking = false
            unlockProgress = 0.0
            showingUnlockAnimation = false
            glowIntensity = 0.5
        default:
            break
        }
    }
    
    private func handleScrollOffset(_ value: CGFloat) {
        scrollOffset = value
        withAnimation(.easeInOut(duration: 0.2)) {
            isScrolled = value < -20
        }
    }
    
    private func resetToWelcome() {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentStep = 0
            showReadyButton = false
            isUnlocking = false
            unlockProgress = 0.0
            showingUnlockAnimation = false
            glowIntensity = 0.0
        }
    }
    
    private func handleBackButton() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = max(0, currentStep - 1)
            if currentStep == 2 {
                showReadyButton = false
                contractAnimationCompleted = false
            }
        }
    }
    
    private func handleContinueButton() {
        if currentStep == 1 && userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = min(3, currentStep + 1)
        }
    }
    
    private func handleReadyButton() {
        print("'I'm Ready' button tapped, moving to step 3")
        withAnimation(.easeInOut(duration: 0.5)) {
            currentStep = 3
            isUnlocking = false
            unlockProgress = 0.0
            showingUnlockAnimation = false
            glowIntensity = 0.5
        }
    }

    private func handleSubscriptionSelection(plan: SubscriptionPlan) {
        switch plan {
        case .trial:
            UserDefaults.standard.set(Date(), forKey: "trialStartDate")
            UserDefaults.standard.set(true, forKey: "isOnFreeTrial")
            UserDefaults.standard.set("trial", forKey: "subscriptionType")
        case .weekly:
            UserDefaults.standard.set(false, forKey: "isOnFreeTrial")
            UserDefaults.standard.set("weekly", forKey: "subscriptionType")
            UserDefaults.standard.set(Date(), forKey: "subscriptionStartDate")
        case .monthly:
            UserDefaults.standard.set(false, forKey: "isOnFreeTrial")
            UserDefaults.standard.set("monthly", forKey: "subscriptionType")
            UserDefaults.standard.set(Date(), forKey: "subscriptionStartDate")
        case .yearly:
            UserDefaults.standard.set(false, forKey: "isOnFreeTrial")
            UserDefaults.standard.set("yearly", forKey: "subscriptionType")
            UserDefaults.standard.set(Date(), forKey: "subscriptionStartDate")
        }

        UserDefaults.standard.removeObject(forKey: "discountTimerStartTime")
    }

    private func completeOnboarding() {// har
        // Create a proper UserProfile with all required fields
      var userProfile = UserProfile.shared
        userProfile.name = userName
        userProfile.age = 25
        userProfile.heightCM = 170
        userProfile.weightKG = 70
        userProfile.level = 1
        userProfile.xp = 0
        userProfile.stats = []
        userProfile.save()
        
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")

        withAnimation(.easeInOut(duration: 0.5)) {
            isCompleted = true
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
