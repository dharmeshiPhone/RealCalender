import SwiftUI

struct ConflictDetailView: View {
    let conflict: ConflictScheduleConflict
    @Binding var events: [CalendarEvent]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSolution: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    ConflictHeaderSection(conflict: conflict)
                    
                    AffectedEventsSection(events: conflict.affectedEvents)
                    
                    SolutionsSection(
                        solutions: conflict.suggestedSolutions,
                        selectedSolution: $selectedSolution
                    )
                    
                    ActionButtonsSection(
                        selectedSolution: selectedSolution,
                        onApply: applySolution,
                        onIgnore: { dismiss() }
                    )
                }
                .padding()
            }
            .navigationTitle("Conflict Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func applySolution(_ solution: String) {
        dismiss()
    }
}

// MARK: - Header Section

struct ConflictHeaderSection: View {
    let conflict: ConflictScheduleConflict
    
    var body: some View {
        VStack(spacing: 16) {
            SeverityIndicator(severity: conflict.severity)
            
            ConflictInfo(
                title: conflict.title,
                description: conflict.description
            )
            
            SeverityBadge(severity: conflict.severity)
        }
        .padding()
        .background(cardBackground)
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemGray6))
    }
}

struct SeverityIndicator: View {
    let severity: ConflictSeverity
    
    var body: some View {
        ZStack {
            Circle()
                .fill(severity.color.opacity(0.2))
                .frame(width: 80, height: 80)
            
            Image(systemName: severity.icon)
                .font(.system(size: 32))
                .foregroundColor(severity.color)
        }
    }
}

struct ConflictInfo: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

struct SeverityBadge: View {
    let severity: ConflictSeverity
    
    var body: some View {
        Text(severity.displayName)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(
                Capsule().fill(severity.color)
            )
    }
}

// MARK: - Affected Events Section

struct AffectedEventsSection: View {
    let events: [CalendarEvent]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Affected Events")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVStack(spacing: 12) {
                ForEach(events, id: \.id) { event in
                    ConflictEventCard(event: event)
                }
            }
        }
        .padding()
        .background(cardBackground)
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemGray6))
    }
}

// MARK: - Solutions Section

struct SolutionsSection: View {
    let solutions: [String]
    @Binding var selectedSolution: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Suggested Solutions")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVStack(spacing: 12) {
                ForEach(Array(solutions.enumerated()), id: \.offset) { index, solution in
                    SolutionCard(
                        solution: solution,
                        index: index + 1,
                        isSelected: selectedSolution == solution
                    ) {
                        selectedSolution = solution
                    }
                }
            }
        }
        .padding()
        .background(cardBackground)
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemGray6))
    }
}

// MARK: - Action Buttons Section

struct ActionButtonsSection: View {
    let selectedSolution: String?
    let onApply: (String) -> Void
    let onIgnore: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Button("Apply Selected Solution") {
                if let solution = selectedSolution {
                    onApply(solution)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(selectedSolution == nil)
            
            Button("Ignore This Conflict") {
                onIgnore()
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .padding()
        .background(cardBackground)
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemGray6))
    }
}

// MARK: - Supporting Views

struct ConflictEventCard: View {
    let event: CalendarEvent
    
    var body: some View {
        HStack(spacing: 12) {
            colorIndicator
            eventDetails
            Spacer()
        }
        .padding()
        .background(eventCardBackground)
    }
    
    private var colorIndicator: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(event.color)
            .frame(width: 6, height: 50)
    }
    
    private var eventDetails: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(event.title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            eventMetadata
        }
    }
    
    private var eventMetadata: some View {
        HStack(spacing: 16) {
            Label(
                event.date.formatted(date: .abbreviated, time: .shortened),
                systemImage: "clock"
            )
            .font(.caption)
            .foregroundColor(.secondary)
            
            if !event.location.isEmpty {
                Label(event.location, systemImage: "location")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var eventCardBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray5))
    }
}

struct SolutionCard: View {
    let solution: String
    let index: Int
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                solutionNumber
                solutionText
                Spacer()
                if isSelected { selectionCheckmark }
            }
            .padding()
            .background(solutionBackground)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var solutionNumber: some View {
        ZStack {
            Circle()
                .fill(isSelected ? Color.blue : Color.gray.opacity(0.3))
                .frame(width: 24, height: 24)
            
            Text("\(index)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(isSelected ? .white : .secondary)
        }
    }
    
    private var solutionText: some View {
        Text(solution)
            .font(.subheadline)
            .multilineTextAlignment(.leading)
            .foregroundColor(.primary)
    }
    
    private var selectionCheckmark: some View {
        Image(systemName: "checkmark.circle.fill")
            .foregroundColor(.blue)
            .font(.system(size: 20))
    }
    
    private var solutionBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray5))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
    }
}

// MARK: - Preview Data

private let sampleConflict = ConflictScheduleConflict(
    id: UUID(),
    type: .timeOverlap,
    severity: .high,
    title: "Time Conflict",
    description: "Math Class and Physics Class are scheduled too close together",
    affectedEvents: sampleEvents,
    suggestedSolutions: sampleSolutions
)

private let sampleEvents = [
    CalendarEvent(
        title: "Math Class",
        date: Date(),
        notes: "Algebra",
        color: .blue,
        location: "Room 101",
        isRespond: false,
        isCompleted: false
    ),
    CalendarEvent(
        title: "Physics Class", 
        date: Date().addingTimeInterval(1800),
        notes: "Mechanics",
        color: .red,
        location: "Room 205",
        isRespond: false,
        isCompleted: false
    )
]

private let sampleSolutions = [
    "Move Physics Class to start 30 minutes later",
    "Shorten Math Class to create buffer time",
    "Consider rescheduling one class to a different day"
]

#Preview {
    ConflictDetailView(
        conflict: sampleConflict,
        events: .constant([])
    )
}
