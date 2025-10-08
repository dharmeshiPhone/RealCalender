import SwiftUI

struct LockedGraphView: View {
    let title: String
    let description: String
    let icon: String
    let height: CGFloat
    let unlockMessage: String
    
    init(
        title: String = "Locked Graph",
        description: String = "Add your first event to unlock this chart",
        icon: String = "lock.fill",
        height: CGFloat = 200,
        unlockMessage: String = "Start adding events to see your analytics"
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.height = height
        self.unlockMessage = unlockMessage
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Lock icon with glow effect
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.gray.opacity(0.3),
                                Color.gray.opacity(0.1),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 10,
                            endRadius: 40
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.gray)
            }
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Divider()
                    .padding(.horizontal, 20)
                
                Text(unlockMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .italic()
            }
            .padding(.horizontal)
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        .overlay(
                            // Subtle animated border
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.clear,
                                            Color.gray.opacity(0.1),
                                            Color.clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                                .opacity(0.6)
                        )
                )
        )
    }
}

struct LockedStatsCard: View {
    let title: String
    let icon: String
    let color: Color
    
    init(
        title: String,
        icon: String = "lock.fill",
        color: Color = .gray
    ) {
        self.title = title
        self.icon = icon
        self.color = color
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()
                Image(systemName: "lock.fill")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("--")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Text("Add events")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        LockedGraphView(
            title: "Event Trends",
            description: "Track your scheduling patterns over time",
            icon: "chart.line.uptrend.xyaxis",
            height: 250,
            unlockMessage: "Add your first calendar event to unlock trend analysis"
        )
        
        HStack(spacing: 12) {
            LockedStatsCard(
                title: "Total Events",
                icon: "calendar",
                color: .blue
            )
            
            LockedStatsCard(
                title: "Hours Scheduled",
                icon: "clock",
                color: .green
            )
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}