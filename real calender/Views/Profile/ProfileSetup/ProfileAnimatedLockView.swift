import SwiftUI

struct ProfileAnimatedLockView: View {
    let pulseScale: CGFloat
    let glowOpacity: Double
    let lockRotation: Double
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            .blue.opacity(glowOpacity),
                            .purple.opacity(glowOpacity * 0.5),
                            .clear
                        ]),
                        center: .center,
                        startRadius: 20,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .scaleEffect(pulseScale)
                .blur(radius: 10)
            
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(.systemGray5), Color(.systemGray4)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)
                .scaleEffect(pulseScale)
            
            Image(systemName: "lock.fill")
                .font(.system(size: 50))
                .foregroundColor(.gray)
                .scaleEffect(pulseScale)
                .rotationEffect(.degrees(lockRotation))
        }
    }
}

#Preview {
    ProfileAnimatedLockView(pulseScale: 1.0, glowOpacity: 0.3, lockRotation: 0)
}