import SwiftUI

struct UnlockedFeatureBox: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            // Icon
            Text(icon)
                .font(.title2)
                .padding(.top, 8)
            
            // Title
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            // Description
            Text(description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [color.opacity(0.8), color.opacity(0.6)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.4), lineWidth: 1)
                )
        )
        .shadow(color: color.opacity(0.3), radius: 4)
    }
}