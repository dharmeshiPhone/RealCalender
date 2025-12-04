import SwiftUI

// MARK: - Reusable Dashboard Components

struct DashboardEventRow: View {
    let event: CalendarEvent
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Enhanced color indicator
            ZStack {
                Rectangle()
                    .fill(event.color.opacity(0.3))
                    .frame(width: 8, height: 60)
                    .cornerRadius(4)
                
                Rectangle()
                    .fill(event.color)
                    .frame(width: 4, height: 60)
                    .cornerRadius(2)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                // Enhanced title with course code detection
                Text(event.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                // Time and duration
                HStack(spacing: 8) {
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
                }
                
                // Teacher and room in one line
                HStack(spacing: 12) {
                    if let teacher = event.teacher, !teacher.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "person.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text(teacher)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                        }
                    }
                    
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
                }
                
                // Class type and level if available
                if let classInfo = extractClassInfo(from: event.notes) {
                    HStack(spacing: 8) {
                        Text(classInfo.type)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(event.color)
                            .cornerRadius(4)
                        
                        if !classInfo.level.isEmpty {
                            Text(classInfo.level)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(.systemGray5))
                                .cornerRadius(4)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Course credits if available
            if let credits = extractCredits(from: event.notes) {
                VStack {
                    Text(credits)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(event.color)
                    
                    Text("credits")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    event.color.opacity(0.05)
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
    
    private func extractDuration(from notes: String) -> String? {
        let lines = notes.components(separatedBy: "\n")
        for line in lines {
            if line.contains("Duration:") {
                return line.replacingOccurrences(of: "⏱️ Duration:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return nil
    }
    
    private func extractClassInfo(from notes: String) -> (type: String, level: String)? {
        let lines = notes.components(separatedBy: "\n")
        var classType = ""
        var level = ""
        
        for line in lines {
            if line.contains("Class type:") || line.contains("Type:") {
                classType = line.replacingOccurrences(of: "🎓 Class type:", with: "")
                    .replacingOccurrences(of: "🎓 Type:", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            } else if line.contains("Level:") {
                level = line.replacingOccurrences(of: "🎓 Level:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        return classType.isEmpty ? nil : (type: classType, level: level)
    }
    
    private func extractCredits(from notes: String) -> String? {
        let lines = notes.components(separatedBy: "\n")
        for line in lines {
            if line.contains("Credits:") {
                return line.replacingOccurrences(of: "📊 Credits:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return nil
    }
}

//struct OverviewCard: View {
//    let title: String
//    let icon: String
//    let color: Color
//    let description: String
//    var islocked: Bool = false
//    let action: () -> Void
//    
//    var body: some View {
//        Button(action: action) {
//            VStack(spacing: 8) {
//                Image(systemName: icon)
//                    .font(.title2)
//                    .foregroundColor(color)
//                
//                Text(title)
//                    .font(.headline)
//                    .fontWeight(.semibold)
//                
//                Text(description)
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                    .multilineTextAlignment(.center)
//            }
//            .frame(width: 120, height: 100)
//            .padding()
//            .background(Color(.systemBackground))
//            .cornerRadius(12)
//            .shadow(radius: 2)
//        }
//        .buttonStyle(.plain)
//    }
//}

struct OverviewCard: View {
    let title: String
    let icon: String
    let color: Color
    let description: String
    var islocked: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            if !islocked {
                action()
            }
        }) {
            ZStack {
                // MAIN CARD
                VStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                    
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(width: 120, height: 100)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
                .opacity(islocked ? 0.4 : 1)   // dim card when locked
                
                // LOCK OVERLAY
                if islocked {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.black.opacity(0.35))
                        .blur(radius: 1)
                    
                    VStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("Locked")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.5))
                            .opacity(0.9)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}


struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.callout)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}
