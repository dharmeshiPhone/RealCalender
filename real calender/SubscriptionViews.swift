import SwiftUI
import Foundation

// MARK: - Subscription Timer Popup View
struct SubscriptionTimerPopupView: View {
    let userName: String
    let onSelectPlan: (SubscriptionPlan) -> Void
    
    @State private var selectedPlan: SubscriptionPlan = .trial 
    @State private var animateTitle = false
    @State private var animateCards = false
    @State private var animateButton = false
    @State private var sparkleAnimation = false
    @State private var timeRemaining: TimeInterval = 1380
    @State private var timerActive = true
    @State private var timer: Timer?
    @State private var isActive = true
    
    private let discountTimerDuration:TimeInterval = 1380 
    
    var timeString: String {
        let hours = Int(timeRemaining) / 3600
        let minutes = Int(timeRemaining) % 3600 / 60
        let seconds = Int(timeRemaining) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    HStack(spacing: 20) {
                        HStack(spacing: 12) {
                            Image(systemName: "hourglass")
                                .foregroundColor(.orange)
                                .font(.title3)
                                .scaleEffect(timeRemaining > 0 ? 1.1 : 1.0)
                            
                            Text("Limited offer:")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text(timeString)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                                .monospacedDigit()
                        }
                        
                        Spacer()
                        
                        Text("25% OFF")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.orange.opacity(0.9))
                            )
                            .shadow(color: .orange.opacity(0.4), radius: 4)

                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.8),
                                Color.purple.opacity(0.15)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        VStack {
                            Spacer()
                            Rectangle()
                                .fill(Color.white.opacity(0.15))
                                .frame(height: 0.5)
                            
                            HStack(spacing: 0) {
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.clear, .yellow.opacity(0.6), .yellow]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(height: 1)
                                
                                Rectangle()
                                    .fill(Color.yellow)
                                    .frame(width: 40, height: 1)
                                
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.yellow, .yellow.opacity(0.6), .clear]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(height: 1)
                            }
                            .padding(.horizontal, 24)
                        }
                    )
                }

                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            Text("Contract Signed, \(userName)!")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .opacity(animateTitle ? 1.0 : 0.0)

                            Text("Your transformation begins NOW!")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.yellow, .orange]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .opacity(animateTitle ? 1.0 : 0.0)
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 16) {
                            Text("Choose Your Plan")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            ForEach(SubscriptionPlan.allCases, id: \.self) { plan in
                                TimerPlanCard(
                                    plan: plan,
                                    isSelected: selectedPlan == plan,
                                    onSelect: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            selectedPlan = plan
                                        }
                                    }
                                )
                                .opacity(animateCards ? 1.0 : 0.0)
                                .offset(y: animateCards ? 0 : 30)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(SubscriptionPlan.allCases.firstIndex(of: plan) ?? 0) * 0.1), value: animateCards)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 16) {
                            Button(action: {
                                onSelectPlan(selectedPlan)
                            }) {
                                HStack {
                                    Image(systemName: selectedPlan == .trial ? "rocket.fill" : "crown.fill")
                                        .font(.title2)

                                    Text(getButtonText(for: selectedPlan))
                                        .font(.title3)
                                        .fontWeight(.bold)

                                    Spacer()

                                    VStack(alignment: .trailing, spacing: 2) {
                                        if let originalPrice = selectedPlan.originalPrice {
                                            Text(originalPrice)
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.7))
                                                .strikethrough()
                                        }
                                        Text(selectedPlan.price)
                                            .font(.headline)
                                            .fontWeight(.black)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(8)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(getButtonBackground(for: selectedPlan))
                                .foregroundColor(.white)
                                .cornerRadius(15)
                                .shadow(color: getShadowColor(for: selectedPlan), radius: 15)
                            }
                            .scaleEffect(animateButton ? 1.0 : 0.9)
                            .opacity(animateButton ? 1.0 : 0.0)
                            .padding(.horizontal, 30)
                            
                            VStack(spacing: 8) {
                                HStack {
                                    Image(systemName: "shield.checkered")
                                        .foregroundColor(.green)
                                    Text("30-Day Money Back Guarantee")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.green)
                                }
                                .opacity(animateButton ? 1.0 : 0.0)

                                if selectedPlan != .trial {
                                    Button("Start Free Trial Instead") {
                                        onSelectPlan(.trial)
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .underline()
                                    .opacity(animateButton ? 0.8 : 0.0)
                                }
                            }

                            VStack(spacing: 4) {
                                Text("Price increases automatically when timer expires")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            .opacity(animateButton ? 1.0 : 0.0)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
        }
        .onAppear {
            startTimer()
            startAnimations()
            if timerActive {
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                    sparkleAnimation = true
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
            timerActive = false
        }
    }
    
    private func startTimer() {
        if let savedStartTime = UserDefaults.standard.object(forKey: "discountTimerStartTime") as? Date {
            let elapsed = Date().timeIntervalSince(savedStartTime)
            timeRemaining = max(0, discountTimerDuration - elapsed)
        } else {
            UserDefaults.standard.set(Date(), forKey: "discountTimerStartTime")
            timeRemaining = discountTimerDuration
        }
        
        if timeRemaining <= 0 {
            timerActive = false
            return
        } else {
            timerActive = true
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                timer = nil
                timerActive = false
            }
        }
    }

    private func startAnimations() {
        withAnimation(.easeInOut(duration: 0.4)) {
            sparkleAnimation = true
            animateTitle = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.8)) {
                animateCards = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateButton = true
            }
        }
    }

    private func getButtonText(for plan: SubscriptionPlan) -> String {
        switch plan {
        case .trial: return "Start Free Trial"
        case .weekly: return "Begin Transformation"
        case .monthly: return "Unlock Full Potential"
        case .yearly: return "Master Your Journey"
        }
    }
    
    private func getButtonBackground(for plan: SubscriptionPlan) -> LinearGradient {
        switch plan {
        case .trial:
            return LinearGradient(
                gradient: Gradient(colors: [.blue, .cyan]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .weekly:
            return LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.2, green: 0.6, blue: 0.2), Color(red: 0.15, green: 0.5, blue: 0.15)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .monthly:
            return LinearGradient(
                gradient: Gradient(colors: [.purple, .purple.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .yearly:
            return LinearGradient(
                gradient: Gradient(colors: [.orange, .orange.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private func getShadowColor(for plan: SubscriptionPlan) -> Color {
        switch plan {
        case .trial: return .blue.opacity(0.5)
        case .weekly: return .pink.opacity(0.5)
        case .monthly: return .purple.opacity(0.5)
        case .yearly: return .orange.opacity(0.5)
        }
    }
}

// MARK: - Timer Plan Card View
struct TimerPlanCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let onSelect: () -> Void
    @State private var glowOpacity: Double = 0.0
    @State private var rippleScale: CGFloat = 0
    @State private var rippleOpacity: Double = 0
    @State private var tapLocation: CGPoint = .zero
    @State private var showRipple = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.clear)
                .overlay(
                    Group {
                        if showRipple {
                            Circle()
                                .fill(Color.white.opacity(rippleOpacity))
                                .frame(width: rippleScale, height: rippleScale)
                                .position(tapLocation)
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(isSelected ? 0.15 : 0.08),
                            Color.white.opacity(isSelected ? 0.1 : 0.05)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isSelected
                            ? LinearGradient(
                                gradient: Gradient(colors: [.yellow, .green]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            : LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.2)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth:isSelected ? 3 : 1
                        )
                )
            
            VStack(spacing: 16) {
                if let badge = plan.badge {
                    HStack {
                        Text(badge)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(plan.badgeColor)
                            .cornerRadius(12)

                        Spacer()
                    }
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(plan.title)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)

                        Text(plan.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        if let originalPrice = plan.originalPrice {
                            Text(originalPrice)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .strikethrough()
                        }

                        Text(plan.price)
                            .font(.title2)
                            .fontWeight(.black)
                    }
                }
            }
            .padding(20)
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .shadow(
            color: isSelected ? plan.shadowColor : .clear, 
            radius: isSelected ? 10 : 0
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture { location in
            tapLocation = location
            triggerRipple()
            onSelect()
        }
    }
    
    private func triggerRipple() {
        withAnimation(.linear(duration: 0.05)) {
            showRipple = true
            rippleScale = 10
            rippleOpacity = 0.4
        }
        
        withAnimation(.easeOut(duration: 0.5)) {
            rippleScale = 150
            rippleOpacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showRipple = false
        }
    }
}