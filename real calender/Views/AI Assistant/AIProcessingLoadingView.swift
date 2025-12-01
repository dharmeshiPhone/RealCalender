import SwiftUI

struct AIProcessingLoadingView: View {
    @State private var rotationAngle: Double = 0
    @State private var scaleEffect: Double = 1.0
    @State private var currentFakeStep = 0
    @State private var dots = ""
    @State private var fakeProgress: Double = 0.0
    @State private var progressTimer: Timer?
    
    let steps = [
        "🤖 Processing your image...",
        "📊 Analyzing content...", 
        "🔍 Extracting information...", 
        "📅 Creating events...",
        "✨ Almost finished..."
    ]
    
    var body: some View {
        ZStack {
            // Background with gradient
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.1),
                    Color.cyan.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Main loading animation
                ZStack {
                    // Outer rotating ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .purple, .cyan, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(rotationAngle))
                    
                    // Inner pulsing circle
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.white, .blue.opacity(0.3)],
                                center: .center,
                                startRadius: 10,
                                endRadius: 50
                            )
                        )
                        .frame(width: 80, height: 80)
                        .scaleEffect(scaleEffect)
                    
                    // AI Brain icon
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 30))
                        .foregroundColor(.blue)
                        .scaleEffect(scaleEffect * 0.8)
                }
                
                // Progress steps
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text("This might take a bit, please wait...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Text("AI Processing")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    
                    // Current step indicator - cycles through fake steps
                    Text(steps[currentFakeStep] + dots)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(height: 50)
                        .animation(.easeInOut(duration: 0.5), value: currentFakeStep)
                    
                    // Fake progress bar that slowly fills
                    ProgressView(value: fakeProgress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .frame(width: 200)
                    
                    Text("Processing... Please wait")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Tips section
                VStack(spacing: 10) {
                    Text("💡 Please Wait")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    Text("AI is working to extract information from your image")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(15)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .onAppear {
            startAnimations()
        }
        .onDisappear {
            progressTimer?.invalidate()
        }
    }
    
    private func startAnimations() {
        // Rotation animation
        withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Pulsing animation
        withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            scaleEffect = 1.2
        }
        
        // Fake step progression - cycles through steps slowly
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { timer in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentFakeStep = (currentFakeStep + 1) % steps.count
            }
        }
        
        // Dots animation
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            switch dots.count {
            case 0: dots = "."
            case 1: dots = ".."
            case 2: dots = "..."
            default: dots = ""
            }
        }
        
        // Fake progress that continuously moves forward slowly (never reaches 100%)
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { timer in
            if self.fakeProgress < 0.85 {
                self.fakeProgress += Double.random(in: 0.01...0.03)
            }
        }
    }
}

#Preview {
    AIProcessingLoadingView()
}