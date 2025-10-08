import SwiftUI

// MARK: - Analytics Tab View
struct AnalyticsTabView: View {
    let events: [CalendarEvent]
    
    private var eventsByCategory: [String: Int] {
        Dictionary(grouping: events) { event in
            extractEventCategory(from: event)
        }.mapValues { $0.count }
    }
    
    private var eventsByWeekday: [String: Int] {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        
        return Dictionary(grouping: events) { event in
            formatter.string(from: event.date)
        }.mapValues { $0.count }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Summary cards
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    AnalyticsCard(
                        title: "Total Events",
                        value: "\(events.count)",
                        icon: "calendar",
                        color: .blue
                    )
                    
                    AnalyticsCard(
                        title: "This Week",
                        value: "\(getEventsThisWeek())",
                        icon: "calendar.badge.clock",
                        color: .green
                    )
                    
                    AnalyticsCard(
                        title: "Categories",
                        value: "\(eventsByCategory.keys.count)",
                        icon: "folder.fill",
                        color: .orange
                    )
                    
                    AnalyticsCard(
                        title: "Avg/Day",
                        value: String(format: "%.1f", getAverageEventsPerDay()),
                        icon: "chart.bar.fill",
                        color: .purple
                    )
                }
                
                // Category breakdown
                VStack(alignment: .leading, spacing: 12) {
                    Text("Events by Category")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    ForEach(eventsByCategory.sorted(by: { $0.value > $1.value }), id: \.key) { category, count in
                        HStack {
                            Text(category)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("\(count)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                            
                            Rectangle()
                                .fill(getCategoryColor(category))
                                .frame(width: CGFloat(count) / CGFloat(events.count) * 100, height: 8)
                                .cornerRadius(4)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
                
                // Weekly pattern
                VStack(alignment: .leading, spacing: 12) {
                    Text("Weekly Pattern")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    ForEach(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"], id: \.self) { day in
                        let count = eventsByWeekday[day] ?? 0
                        HStack {
                            Text(day)
                                .font(.subheadline)
                                .frame(width: 80, alignment: .leading)
                            
                            Rectangle()
                                .fill(Color.blue.opacity(0.7))
                                .frame(width: max(CGFloat(count) * 10, 4), height: 12)
                                .cornerRadius(6)
                            
                            Spacer()
                            
                            Text("\(count)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
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
    
    private func extractEventCategory(from event: CalendarEvent) -> String {
        let title = event.title.lowercased()
        
        if title.contains("math") || title.contains("calculus") || title.contains("algebra") {
            return "Mathematics"
        } else if title.contains("chemistry") || title.contains("physics") || title.contains("biology") {
            return "Science"
        } else if title.contains("english") || title.contains("literature") || title.contains("writing") {
            return "Language Arts"
        } else if title.contains("history") || title.contains("social") {
            return "Social Studies"
        } else if title.contains("art") || title.contains("music") || title.contains("drama") {
            return "Arts"
        } else if title.contains("gym") || title.contains("pe") || title.contains("physical") {
            return "Physical Education"
        } else if title.contains("lunch") || title.contains("break") {
            return "Break"
        } else if title.contains("meeting") || title.contains("conference") {
            return "Meeting"
        } else {
            return "Other"
        }
    }
    
    private func getEventsThisWeek() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let weekEnd = calendar.date(byAdding: .weekOfYear, value: 1, to: weekStart) ?? now
        
        return events.filter { $0.date >= weekStart && $0.date < weekEnd }.count
    }
    
    private func getAverageEventsPerDay() -> Double {
        guard !events.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let uniqueDays = Set(events.map { calendar.startOfDay(for: $0.date) })
        
        return Double(events.count) / Double(uniqueDays.count)
    }
    
    private func getCategoryColor(_ category: String) -> Color {
        switch category {
        case "Mathematics": return .blue
        case "Science": return .green
        case "Language Arts": return .purple
        case "Social Studies": return .orange
        case "Arts": return .pink
        case "Physical Education": return .red
        case "Break": return .yellow
        case "Meeting": return .indigo
        default: return .gray
        }
    }
}

struct AnalyticsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}