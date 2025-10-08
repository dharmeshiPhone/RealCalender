import SwiftUI

struct MeasurementPromptView: View {
    @Binding var userProfile: UserProfile
    @Binding var isPresented: Bool
    let onComplete: () -> Void
    
    @State private var tempHeight: Double = 170
    @State private var tempWeight: Double = 70
    @State private var tempWaist: Double = 80
    @State private var currentStep = 0
    @State private var showingConfetti = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        Color.blue.opacity(0.05),
                        Color.purple.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Confetti overlay
                if showingConfetti {
                    MeasurementConfettiView()
                        .allowsHitTesting(false)
                }
                
                VStack(spacing: 30) {
                    // Progress indicator
                    HStack {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(index <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: 12, height: 12)
                                .scaleEffect(index == currentStep ? 1.2 : 1.0)
                                .animation(.spring(), value: currentStep)
                        }
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Main content
                    VStack(spacing: 40) {
                        // Header
                        VStack(spacing: 20) {
                            Image(systemName: "ruler.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                            
                            Text("🎯 Complete Your Measurements")
                                .font(.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text("We need a few measurements for accurate fitness tracking and health analytics")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        // Step content
                        switch currentStep {
                        case 0:
                            HeightStep(height: $tempHeight)
                        case 1:
                            WeightStep(weight: $tempWeight)
                        case 2:
                            WaistStep(waist: $tempWaist)
                        default:
                            EmptyView()
                        }
                    }
                    
                    Spacer()
                    
                    // Navigation buttons
                    HStack {
                        if currentStep > 0 {
                            Button("Back") {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentStep -= 1
                                }
                            }
                            .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if currentStep < 2 {
                            Button("Continue") {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentStep += 1
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                        } else {
                            Button("🚀 Unlock 3D Model") {
                                completeSetup()
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Body Measurements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        // Set default values and continue
                        userProfile.heightCM = 170
                        userProfile.weightKG = 70
                        userProfile.waistCM = 80
                        saveAndComplete()
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func completeSetup() {
        // Save measurements
        userProfile.heightCM = tempHeight
        userProfile.weightKG = tempWeight
        userProfile.waistCM = tempWaist
        
        // Show confetti
        showingConfetti = true
        
        // Complete after confetti
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            saveAndComplete()
        }
    }
    
    private func saveAndComplete() {
        userProfile.save()
        // Close this view and show profile
        isPresented = false
        onComplete()
    }
}

// MARK: - Height Step
struct HeightStep: View {
    @Binding var height: Double
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Text("📏 What's your height?")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("This helps us provide accurate fitness and health analytics")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 20) {
                // Height display
                VStack(spacing: 8) {
                    Text("\(Int(height)) cm")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                    
                    Text("≈ \(Int(height / 30.48)) ft \(Int((height / 2.54).truncatingRemainder(dividingBy: 12))) in")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Height slider
                VStack(spacing: 12) {
                    Slider(value: $height, in: 120...220, step: 1)
                        .tint(.blue)
                    
                    HStack {
                        Text("120 cm")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("220 cm")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
            }
            
            // Quick selection buttons
            VStack(spacing: 12) {
                Text("Common heights:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach([160, 170, 180], id: \.self) { quickHeight in
                        Button("\(quickHeight) cm") {
                            withAnimation(.spring()) {
                                height = Double(quickHeight)
                            }
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(height == Double(quickHeight) ? .blue : .primary)
                    }
                }
            }
        }
    }
}

// MARK: - Weight Step
struct WeightStep: View {
    @Binding var weight: Double
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Text("⚖️ What's your weight?")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("This helps us calculate your BMI and body proportions")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 20) {
                // Weight display
                VStack(spacing: 8) {
                    Text("\(Int(weight)) kg")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                    
                    Text("≈ \(Int(weight * 2.20462)) lbs")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Weight slider
                VStack(spacing: 12) {
                    Slider(value: $weight, in: 40...150, step: 1)
                        .tint(.green)
                    
                    HStack {
                        Text("40 kg")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("150 kg")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
            }
            
            // Quick selection buttons
            VStack(spacing: 12) {
                Text("Common weights:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach([60, 70, 80], id: \.self) { quickWeight in
                        Button("\(quickWeight) kg") {
                            withAnimation(.spring()) {
                                weight = Double(quickWeight)
                            }
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(weight == Double(quickWeight) ? .green : .primary)
                    }
                }
            }
        }
    }
}

// MARK: - Waist Step
struct WaistStep: View {
    @Binding var waist: Double
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Text("📐 What's your waist measurement?")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Measure around your natural waistline for accurate health metrics")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 20) {
                // Waist display
                VStack(spacing: 8) {
                    Text("\(Int(waist)) cm")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                    
                    Text("≈ \(Int(waist / 2.54)) inches")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Waist slider
                VStack(spacing: 12) {
                    Slider(value: $waist, in: 50...120, step: 1)
                        .tint(.orange)
                    
                    HStack {
                        Text("50 cm")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("120 cm")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
            }
            
            // Quick selection buttons
            VStack(spacing: 12) {
                Text("Common waist sizes:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach([75, 85, 95], id: \.self) { quickWaist in
                        Button("\(quickWaist) cm") {
                            withAnimation(.spring()) {
                                waist = Double(quickWaist)
                            }
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(waist == Double(quickWaist) ? .orange : .primary)
                    }
                }
            }
            
            // Help text
            VStack(spacing: 8) {
                Text("💡 How to measure:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                Text("Place a measuring tape around your waist at the narrowest point, usually just above your hip bones")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

// MARK: - Measurement Confetti View
struct MeasurementConfettiView: View {
    @State private var confettiPieces: [MeasurementConfettiPiece] = []
    @State private var isActive = false
    
    var body: some View {
        ZStack {
            ForEach(confettiPieces) { piece in
                Text(piece.emoji)
                    .font(.system(size: piece.size))
                    .position(piece.position)
                    .rotationEffect(.degrees(piece.rotation))
                    .opacity(piece.opacity)
            }
        }
        .onAppear {
            startConfetti()
        }
    }
    
    private func startConfetti() {
        isActive = true
        
        let emojis = ["🎉", "🎊", "⭐", "✨", "🎈", "🎁", "🏆", "💪", "🔥", "🚀"]
        
        // Create confetti pieces
        for _ in 0..<30 {
            let piece = MeasurementConfettiPiece(
                position: CGPoint(
                    x: UIScreen.main.bounds.width / 2 + Double.random(in: -150...150),
                    y: UIScreen.main.bounds.height / 2 - 300
                ),
                velocity: CGPoint(
                    x: Double.random(in: -200...200),
                    y: Double.random(in: -400...(-100))
                ),
                emoji: emojis.randomElement()!,
                size: Double.random(in: 20...35),
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: -15...15),
                opacity: 1.0
            )
            confettiPieces.append(piece)
        }
        
        // Animate the confetti
        animateConfetti()
        
        // Stop after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            isActive = false
            confettiPieces.removeAll()
        }
    }
    
    private func animateConfetti() {
        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            guard isActive else {
                timer.invalidate()
                return
            }
            
            for i in 0..<confettiPieces.count {
                // Update position
                confettiPieces[i].position.x += confettiPieces[i].velocity.x * 0.03
                confettiPieces[i].position.y += confettiPieces[i].velocity.y * 0.03
                
                // Apply gravity
                confettiPieces[i].velocity.y += 600 * 0.03
                
                // Air resistance
                confettiPieces[i].velocity.x *= 0.997
                
                // Update rotation
                confettiPieces[i].rotation += confettiPieces[i].rotationSpeed * 0.03
                
                // Fade out
                confettiPieces[i].opacity *= 0.994
                
                // Remove off-screen pieces
                if confettiPieces[i].position.y > UIScreen.main.bounds.height + 100 {
                    confettiPieces.remove(at: i)
                    break
                }
            }
        }
    }
}

struct MeasurementConfettiPiece: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGPoint
    let emoji: String
    let size: Double
    var rotation: Double
    let rotationSpeed: Double
    var opacity: Double
}

#Preview {
    MeasurementPromptView(
        userProfile: .constant(UserProfile(name: "Test", age: 20, heightCM: 170, weightKG: 70, measurements: [:], level: 1, xp: 0, stats: [])),
        isPresented: .constant(true),
        onComplete: {}
    )
}
