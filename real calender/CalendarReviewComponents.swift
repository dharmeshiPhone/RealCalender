import SwiftUI

// MARK: - Enhanced Calendar Event Row
struct EnhancedCalendarEventRow: View {
    let event: CalendarEvent
    let onTap: () -> Void
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Enhanced color indicator with pattern
                ZStack {
                    Rectangle()
                        .fill(event.color.opacity(0.3))
                        .frame(width: 8, height: 80)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(event.color)
                        .frame(width: 4, height: 80)
                        .cornerRadius(2)
                    
                    // Status indicator
                    Circle()
                        .fill(event.color)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .offset(x: 8, y: -30)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    // Title and urgency
                    HStack {
                        Text(event.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if isUpcoming(event.date) {
                            Text("Soon")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange)
                                .cornerRadius(4)
                        }
                    }
                    
                    // Time and duration
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                            
                            Text(timeFormatter.string(from: event.date))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                        
                        if let duration = extractDuration(from: event.notes) {
                            HStack(spacing: 4) {
                                Image(systemName: "timer")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                
                                Text(duration)
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        Spacer()
                        
                        // Event type badge
                        Text(getEventType(event))
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(event.color)
                            .cornerRadius(4)
                    }
                    
                    // Location and teacher
                    HStack(spacing: 12) {
                        if !event.location.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "location.fill")
                                    .font(.caption)
                                    .foregroundColor(.purple)
                                
                                Text(event.location)
                                    .font(.caption)
                                    .foregroundColor(.purple)
                                    .lineLimit(1)
                            }
                        }
                        
                        if let teacher = event.teacher, !teacher.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "person.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                
                                Text(teacher)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.green)
                                    .lineLimit(1)
                            }
                        }
                    }
                    
                    // Notes preview
                    if !event.notes.isEmpty {
                        Text(event.notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                // Chevron indicator
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
        .padding(12)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    event.color.opacity(0.03)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(event.color.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func isUpcoming(_ date: Date) -> Bool {
        let timeInterval = date.timeIntervalSinceNow
        return timeInterval > 0 && timeInterval < 3600 // Within next hour
    }
    
    private func extractDuration(from notes: String) -> String? {
        let lines = notes.components(separatedBy: "\n")
        for line in lines {
            if line.contains("Duration:") {
                return line.replacingOccurrences(of: "⏱️ Duration:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return nil
    }
    
    private func getEventType(_ event: CalendarEvent) -> String {
        let title = event.title.lowercased()
        if title.contains("lecture") || title.contains("class") {
            return "Class"
        } else if title.contains("lab") {
            return "Lab"
        } else if title.contains("meeting") {
            return "Meeting"
        } else if title.contains("exam") || title.contains("test") {
            return "Exam"
        } else if title.contains("break") || title.contains("lunch") {
            return "Break"
        } else {
            return "Event"
        }
    }
}

// MARK: - Review Insight Card
struct ReviewInsightCard: View {
    let icon: String
    let title: String
    let insight: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(insight)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}