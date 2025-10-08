import SwiftUI

struct UnlockRequirementsSection: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("🎯 How to Unlock")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 12) {
                UnlockRequirementRow(
                    icon: "calendar.badge.plus",
                    title: "Complete Calendar Setup",
                    description: "Add your daily schedule and events",
                    xpReward: "Level Up!",
                    isCompleted: false
                )
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    UnlockRequirementsSection()
}