import SwiftUI

struct TimetableProcessingView: View {
    @State private var animationOffset: CGFloat = 0
    @State private var scanLinePosition: CGFloat = 75  // Start at bottom
    @State private var processingDots = ""
    @State private var fakeProgress: Double = 0.0
    @State private var fakeStepProgress: Double = 0.0
    @State private var currentFakeStep = 0
    @State private var progressTimer: Timer?
    
    // CONTROLLED: Real processing state but we'll fake the visual progress
    var totalPhotos: Int = 1
    var processedPhotos: Int = 0
    var currentStep: Int = 0  
    var isComplete: Bool = false
    
    let steps = [
        ("🤖", "Processing your image..."),
        ("📊", "Analyzing content..."),
        ("🔍", "Extracting information..."),
        ("📅", "Organizing data..."),
        ("✨", "Almost done...")
    ]
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Multi-photo progress indicator (if more than 1 photo)
                if totalPhotos > 1 {
                    VStack(spacing: 12) {
                        Text("Processing \(min(Int(fakeProgress * Double(totalPhotos)) + 1, totalPhotos))/\(totalPhotos) photos")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        // Photo progress indicators - fake progress
                        HStack(spacing: 8) {
                            ForEach(0..<totalPhotos, id: \.self) { index in
                                ZStack {
                                    Circle()
                                        .fill(index < Int(fakeProgress * Double(totalPhotos)) ? Color.green : Color.white.opacity(0.3))
                                        .frame(width: 20, height: 20)
                                    
                                    if index < Int(fakeProgress * Double(totalPhotos)) {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                    } else if index == Int(fakeProgress * Double(totalPhotos)) && !isComplete {
                                        // Current photo being "processed"
                                        Circle()
                                            .stroke(Color.blue, lineWidth: 2)
                                            .frame(width: 20, height: 20)
                                            .scaleEffect(1.2)
                                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: scanLinePosition)
                                    }
                                }
                            }
                        }
                        
                        // Fake progress bar that slowly fills regardless of actual progress
                        ProgressView(value: isComplete ? 1.0 : fakeProgress, total: 1.0)
                            .progressViewStyle(LinearProgressViewStyle(tint: isComplete ? .green : .blue))
                            .frame(width: 250)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.ultraThinMaterial)
                    )
                }
                
                // Timetable scanning animation
                ZStack {
                    // Mock timetable background
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .frame(width: 200, height: 150)
                        .shadow(radius: 10)
                    
                    // Grid lines to simulate timetable
                    VStack(spacing: 0) {
                        ForEach(0..<5, id: \.self) { _ in
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                            Spacer()
                        }
                    }
                    .frame(width: 180, height: 130)
                    
                    HStack(spacing: 0) {
                        ForEach(0..<4, id: \.self) { _ in
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 1)
                            Spacer()
                        }
                    }
                    .frame(width: 180, height: 130)
                    
                    // Scanning line animation - only active when processing
                    if !isComplete {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.clear, .blue, .blue, .clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 200, height: 3)
                            .offset(y: scanLinePosition)
                            .opacity(0.8)
                    }
                    
                    // Completion checkmark
                    if isComplete {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                            .scaleEffect(1.2)
                    }
                }
                
                // Processing info
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text("This might take a bit, please wait...")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                        
                        Text(isComplete ? "🎉 Processing Complete!" : "🤖 AI Processing")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    
                    // Current step - only show if not complete
                    if !isComplete {
                        HStack(spacing: 15) {
                            Text(steps[min(currentFakeStep, steps.count - 1)].0)
                                .font(.title)
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text(steps[min(currentFakeStep, steps.count - 1)].1 + processingDots)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .animation(.easeInOut, value: processingDots)
                                
                                // Fake step progress bar that slowly fills regardless of actual progress
                                ProgressView(value: isComplete ? 1.0 : fakeStepProgress, total: 1.0)
                                    .progressViewStyle(LinearProgressViewStyle(tint: isComplete ? .green : .blue))
                                    .frame(width: 200)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.ultraThinMaterial)
                        )
                        
                        Text("Step \(min(currentFakeStep + 1, steps.count)) of \(steps.count)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    } else {
                        // Completion message
                        VStack(spacing: 12) {
                            Text("All photos processed successfully!")
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            Text("Your calendar events are ready to review")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.ultraThinMaterial)
                        )
                    }
                }
                
                // Tips for multi-photo processing
                if totalPhotos > 1 && !isComplete {
                    VStack(spacing: 8) {
                        Text("💡 Pro Tip")
                            .font(.headline)
                            .foregroundColor(.yellow)
                        
                        Text("Processing multiple photos helps capture your complete schedule across different timetables or pages!")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.yellow.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.yellow.opacity(0.3))
                            )
                    )
                }
            }
        }
        .onAppear {
            startAnimations()
        }
        .onChange(of: isComplete) { _, newValue in
            if newValue {
                // Jump to 100% when complete
                withAnimation(.easeInOut(duration: 0.5)) {
                    fakeProgress = 1.0
                    fakeStepProgress = 1.0
                }
                // Stop the progress timer
                progressTimer?.invalidate()
            }
        }
    }
    
    private func startAnimations() {
        // Scanning line animation - only if not complete
        if !isComplete {
            withAnimation(Animation.linear(duration: 0.8).repeatForever(autoreverses: true)) {
                scanLinePosition = -75  // Go all the way to the top (negative value)
            }
        }
        
        // Fake progress bar that continuously moves forward slowly
        if !isComplete {
            progressTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
                if self.isComplete {
                    timer.invalidate()
                    return
                }
                
                // Slowly increment fake progress (never reaches 100% until actually complete)
                if self.fakeProgress < 0.9 {
                    self.fakeProgress += Double.random(in: 0.005...0.02)
                }
                
                // Slowly increment step progress and cycle through steps
                if self.fakeStepProgress < 0.9 {
                    self.fakeStepProgress += Double.random(in: 0.01...0.03)
                } else {
                    // Move to next fake step
                    self.currentFakeStep = (self.currentFakeStep + 1) % self.steps.count
                    self.fakeStepProgress = 0.1 // Start the next step with some progress
                }
            }
        }
        
        // Processing dots animation - only if not complete
        if !isComplete {
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { timer in
                if self.isComplete {
                    timer.invalidate()
                    return
                }
                
                switch self.processingDots.count {
                case 0: self.processingDots = "."
                case 1: self.processingDots = ".."
                case 2: self.processingDots = "..."
                default: self.processingDots = ""
                }
            }
        }
    }
}

#Preview {
    TimetableProcessingView(
        totalPhotos: 3,
        processedPhotos: 1,
        currentStep: 2,
        isComplete: false
    )
}