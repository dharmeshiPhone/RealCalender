import SwiftUI

// MARK: - Conflicts Tab View
struct CalendarConflictsTabView: View {
    let events: [CalendarEvent]
    
    private var conflicts: [(CalendarEvent, CalendarEvent)] {
        var conflictPairs: [(CalendarEvent, CalendarEvent)] = []
        
        for i in 0..<events.count {
            for j in (i+1)..<events.count {
                let event1 = events[i]
                let event2 = events[j]
                
                // Check if events are on the same day and time
                let calendar = Calendar.current
                if calendar.isDate(event1.date, inSameDayAs: event2.date) {
                    let timeDiff = abs(event1.date.timeIntervalSince(event2.date))
                    if timeDiff < 3600 { // Within 1 hour
                        conflictPairs.append((event1, event2))
                    }
                }
            }
        }
        
        return conflictPairs
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if conflicts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                        
                        Text("No Conflicts Found")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Your schedule looks great! No overlapping events detected.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            
                            Text("Scheduling Conflicts")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                        
                        ForEach(conflicts.indices, id: \.self) { index in
                            ConflictRow(
                                event1: conflicts[index].0,
                                event2: conflicts[index].1
                            )
                        }
                    }
                }
                
                // Scheduling tips
                VStack(alignment: .leading, spacing: 12) {
                    Text("📋 Scheduling Tips")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        TipRow(
                            icon: "clock.fill",
                            tip: "Add buffer time between back-to-back events",
                            color: .blue
                        )
                        
                        TipRow(
                            icon: "location.fill",
                            tip: "Consider travel time for events at different locations",
                            color: .green
                        )
                        
                        TipRow(
                            icon: "bell.fill",
                            tip: "Set reminders for important events",
                            color: .orange
                        )
                        
                        TipRow(
                            icon: "calendar.badge.plus",
                            tip: "Block prep time before important meetings",
                            color: .purple
                        )
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
            }
            .padding()
        }
    }
}

struct ConflictRow: View {
    let event1: CalendarEvent
    let event2: CalendarEvent
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                
                Text("Scheduling Conflict")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(timeFormatter.string(from: event1.date))
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(6)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ConflictEventView(event: event1, color: .red)
                
                HStack {
                    Rectangle()
                        .fill(Color.orange.opacity(0.3))
                        .frame(width: 2, height: 20)
                    
                    Text("overlaps with")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .italic()
                }
                
                ConflictEventView(event: event2, color: .red)
            }
            
            // Suggestion
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                
                Text("Consider rescheduling one of these events or adding buffer time")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color.orange.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ConflictEventView: View {
    let event: CalendarEvent
    let color: Color
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(color)
                .frame(width: 4, height: 30)
                .cornerRadius(2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                HStack(spacing: 8) {
                    Text(timeFormatter.string(from: event.date))
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    if !event.location.isEmpty {
                        Text("• \(event.location)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
        }
    }
}

struct TipRow: View {
    let icon: String
    let tip: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(tip)
                .font(.body)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
    }
}