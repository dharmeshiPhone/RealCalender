import SwiftUI

struct ProfileFeaturesPreviewSection: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("✨ What You'll Unlock")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.purple)
            
            VStack(alignment: .leading, spacing: 12) {
                PreviewFeatureRow(
                    icon: "person.circle.fill",
                    title: "Personal Profile",
                    description: "Customize your avatar and details"
                )
                
                PreviewFeatureRow(
                    icon: "chart.bar.fill",
                    title: "Performance Analytics",
                    description: "See how you compare to others your age"
                )
                
                PreviewFeatureRow(
                    icon: "trophy.fill",
                    title: "Achievement System",
                    description: "Unlock badges and track progress"
                )
                
                PreviewFeatureRow(
                    icon: "gearshape.fill",
                    title: "Advanced Settings",
                    description: "Personalize your app experience"
                )
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    ProfileFeaturesPreviewSection()
}