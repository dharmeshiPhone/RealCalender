import SwiftUI

struct LockedProfileSetupView: View {
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.3
    @State private var lockRotation: Double = 0
    
    var body: some View {
            ScrollView {
                VStack(spacing: 40) {
                    Spacer().frame(height: 20)
                    
                    // Lock Icon with Animation
                    ProfileAnimatedLockView(
                        pulseScale: pulseScale,
                        glowOpacity: glowOpacity,
                        lockRotation: lockRotation
                    )
                    
                    VStack(spacing: 20) {
                        Text("Profile Locked")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Complete your calendar setup to unlock your personal profile!")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 40)
                    }
                    
                    // Unlock Requirements
                    ProfileUnlockRequirementsSection()
                    
                    // Features Preview
                    ProfileFeaturesPreviewSection()
                    
                    Spacer().frame(height: 40)
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                startAnimations()
            }
       
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            pulseScale = 1.1
            glowOpacity = 0.6
        }
        
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            lockRotation = 5
        }
    }
}

#Preview {
    LockedProfileSetupView()
}
