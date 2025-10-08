import SwiftUI

struct InsightDetailView: View {
    let insight: ScheduleInsight
    @Binding var events: [CalendarEvent]
    @Environment(\.dismiss) private var dismiss
    @State private var completedActions: Set<String> = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    impactSection
                    
                    actionItemsSection
                    
                    relatedEventsSection
                }
                .padding()
            }
            .navigationTitle("Insight Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Type and priority indicators
            ZStack {
                Circle()
                    .fill(insight.priority.color.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: insight.type.icon)
                    .font(.system(size: 36))
                    .foregroundColor(insight.priority.color)
            }
            
            VStack(spacing: 8) {
                Text(insight.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(insight.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Priority and type badges
            HStack(spacing: 12) {
                Text(insight.priority.displayName)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(insight.priority.color)
                    )
                
                Text(insight.type.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var impactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Expected Impact")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                Image(systemName: "target")
                    .font(.title2)
                    .foregroundColor(.green)
                
                Text(insight.impact)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green.opacity(0.1))
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var actionItemsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Action Items")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(completedActions.count)/\(insight.actionItems.count) completed")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(Array(insight.actionItems.enumerated()), id: \.offset) { index, action in
                    ActionItemView(
                        action: action,
                        index: index + 1,
                        isCompleted: completedActions.contains(action)
                    ) {
                        toggleActionCompletion(action)
                    }
                }
            }
            
            // Progress bar
            if !insight.actionItems.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Progress")
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("\(Int(Double(completedActions.count) / Double(insight.actionItems.count) * 100))%")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                    
                    ProgressView(value: Double(completedActions.count), total: Double(insight.actionItems.count))
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var relatedEventsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Related Events")
                .font(.headline)
                .fontWeight(.semibold)
            
            if relatedEvents.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    Text("No specific events related to this insight")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(relatedEvents, id: \.id) { event in
                        RelatedEventRow(event: event)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var relatedEvents: [CalendarEvent] {
        // Simple logic to find events that might be related to the insight
        // This could be made more sophisticated based on the insight type
        return Array(events.prefix(3))
    }
    
    private func toggleActionCompletion(_ action: String) {
        if completedActions.contains(action) {
            completedActions.remove(action)
        } else {
            completedActions.insert(action)
        }
    }
}

// MARK: - Supporting Views

struct ActionItemView: View {
    let action: String
    let index: Int
    let isCompleted: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                // Completion indicator
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: 28, height: 28)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Text("\(index)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(action)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primary)
                    .strikethrough(isCompleted)
                    .opacity(isCompleted ? 0.6 : 1.0)
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isCompleted ? Color.green.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isCompleted ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RelatedEventRow: View {
    let event: CalendarEvent
    
    var body: some View {
        HStack(spacing: 12) {
            // Color indicator
            RoundedRectangle(cornerRadius: 4)
                .fill(event.color)
                .frame(width: 6, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(event.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if !event.location.isEmpty {
                        Text("• \(event.location)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview {
    InsightDetailView(
        insight: ScheduleInsight(
            id: UUID(),
            type: .optimization,
            priority: .high,
            title: "Add Buffer Time",
            description: "Your events are very tightly scheduled. Consider adding buffer time.",
            impact: "Reduces stress and allows for unexpected delays",
            actionItems: [
                "Add 15-minute buffers between meetings",
                "Schedule transition time for location changes",
                "Block buffer time in your calendar"
            ]
        ),
        events: .constant([
            CalendarEvent(
                title: "Morning Meeting",
                date: Date(),
                notes: "Team standup",
                color: .blue,
                location: "Office"
            )
        ])
    )
}