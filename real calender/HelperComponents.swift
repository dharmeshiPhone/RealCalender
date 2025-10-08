import SwiftUI

// MARK: - Helper Components
struct AchievementCard: View {
    let title: String
    let value: String
    let isUnlocked: Bool
    let icon: String
    let color: Color
    
    var body: some View {
        VStack {
            ZStack {
                if !isUnlocked {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isUnlocked ? color : .gray)
                    .opacity(isUnlocked ? 1.0 : 0.5)
            }
            
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(isUnlocked ? .secondary : .gray)
            
            Text(isUnlocked ? value : "Locked")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(isUnlocked ? .primary : .gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(isUnlocked ? color.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isUnlocked ? Color.clear : Color.gray.opacity(0.3), lineWidth: isUnlocked ? 0 : 1)
        )
        .opacity(isUnlocked ? 1.0 : 0.7)
    }
}

struct GoalCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let isCompleted: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isCompleted ? .green : color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundColor(isCompleted ? .green : .gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}