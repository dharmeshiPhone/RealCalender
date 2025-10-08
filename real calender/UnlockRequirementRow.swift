import SwiftUI

struct UnlockRequirementRow: View {
    let icon: String
    let title: String
    let description: String
    let xpReward: String
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isCompleted ? .green : .blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(xpReward)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(6)
                
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isCompleted ? .green : .gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCompleted ? Color.green.opacity(0.3) : Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    UnlockRequirementRow(
        icon: "calendar.badge.plus",
        title: "Complete Calendar Setup",
        description: "Add your daily schedule and events",
        xpReward: "Level Up!",
        isCompleted: false
    )
}