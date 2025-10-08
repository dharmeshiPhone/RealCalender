import SwiftUI

struct UserStatsAchievementsSection: View {
    @Binding var profile: UserProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🏆 Achievements")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                AchievementCard(
                    title: "Swimming Endurance",
                    value: "\(profile.swimming50MLaps) laps",
                    isUnlocked: profile.swimming50MLaps > 0,
                    icon: "figure.pool.swim",
                    color: .blue
                )
                
                AchievementCard(
                    title: "5K Runner",
                    value: profile.running5KTimeSec > 0 ? profile.running5KTimeFormatted : "Not set",
                    isUnlocked: profile.running5KTimeSec > 0,
                    icon: "figure.run",
                    color: .green
                )
                
                AchievementCard(
                    title: "Health Score",
                    value: String(format: "%.1f BMI", profile.bmi),
                    isUnlocked: profile.bmi > 0,
                    icon: "heart.fill",
                    color: .red
                )
                
                AchievementCard(
                    title: "Academic",
                    value: profile.educationLevel.displayName,
                    isUnlocked: profile.educationLevel != .notSet,
                    icon: "graduationcap.fill",
                    color: .purple
                )
            }
        }
    }
}