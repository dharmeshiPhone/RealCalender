import SwiftUI

struct UserStatsGoalsSection: View {
    @Binding var profile: UserProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🎯 Goals & Targets")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                if profile.running5KTimeSec == 0 {
                    GoalCard(
                        title: "Complete First 5K",
                        description: "Track your first 5K run with GPS",
                        icon: "figure.run",
                        color: .green,
                        isCompleted: false
                    )
                }
                
                if profile.swimming50MLaps == 0 {
                    GoalCard(
                        title: "Swimming Endurance Test",
                        description: "Record how many 50m laps you can swim",
                        icon: "figure.pool.swim", 
                        color: .blue,
                        isCompleted: false
                    )
                }
                
                if profile.annualIncomeThousands == 0 {
                    GoalCard(
                        title: "Income Tracking",
                        description: "Add your annual income data",
                        icon: "dollarsign.circle.fill",
                        color: .orange,
                        isCompleted: false
                    )
                }
            }
        }
    }
}