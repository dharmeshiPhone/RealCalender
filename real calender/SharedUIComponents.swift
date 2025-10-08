import SwiftUI

// MARK: - Shared UI Components to prevent duplicates

struct SharedStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: String?
    
    init(title: String, value: String, icon: String, color: Color, trend: String? = nil) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
        self.trend = trend
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
                if let trend = trend {
                    Text(trend)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(trend.contains("+") ? .green : (trend.contains("-") ? .red : .secondary))
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SharedQuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct SharedInsightCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let priority: String?
    
    init(title: String, description: String, icon: String, color: Color, priority: String? = nil) {
        self.title = title
        self.description = description
        self.icon = icon
        self.color = color
        self.priority = priority
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if let priority = priority {
                        Text(priority)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(color))
                    }
                }
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Missing Support Views for Analytics

struct AnalyticsMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: String
    
    var body: some View {
        SharedStatCard(title: title, value: value, icon: icon, color: color, trend: trend)
    }
}

struct AnalyticsCategoryRow: View {
    let category: AnalyticsCategoryData
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(category.count) events")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.1f%%", category.percentage))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 4)
                        
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: geometry.size.width * CGFloat(category.percentage / 100), height: 4)
                    }
                }
                .frame(height: 4)
            }
            .frame(width: 80)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct AnalyticsInsightCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        SharedInsightCard(title: title, description: description, icon: icon, color: color)
    }
}

struct AnalyticsTimePatternRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(value)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Missing Support Views for Conflicts

struct ConflictCard: View {
    let conflict: ConflictScheduleConflict
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(conflict.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(conflict.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(conflict.severity.color.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: conflict.severity.icon)
                            .font(.system(size: 18))
                            .foregroundColor(conflict.severity.color)
                    }
                }
                
                HStack {
                    Text("\(conflict.affectedEvents.count) events affected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("View Solutions")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            )
        }
        .buttonStyle(.plain)
    }
}

struct ConflictTypeCount: View {
    let count: Int
    let type: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(type)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ConflictResolutionSheet: View {
    let conflict: ConflictScheduleConflict
    @Binding var events: [CalendarEvent]
    let onResolved: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Conflict Resolution")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(conflict.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Suggested Solutions:")
                            .font(.headline)
                        
                        ForEach(Array(conflict.suggestedSolutions.enumerated()), id: \.offset) { index, solution in
                            Button(solution) {
                                // Apply solution logic here
                                onResolved()
                            }
                            .buttonStyle(.bordered)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding()
            }
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
}

// MARK: - Missing Support Views for Insights

struct InsightsSummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        SharedStatCard(title: title, value: value, icon: icon, color: color)
    }
}

struct CalendarInsightCard: View {
    let insight: CalendarInsight
    
    var body: some View {
        SharedInsightCard(
            title: insight.title,
            description: insight.description,
            icon: "lightbulb.fill",
            color: .blue,
            priority: insight.priority > 2 ? "High" : (insight.priority > 1 ? "Medium" : "Low")
        )
    }
}

struct CalendarRecommendationCard: View {
    let recommendation: CalendarRecommendation
    
    var body: some View {
        SharedInsightCard(
            title: recommendation.title,
            description: recommendation.description,
            icon: "star.fill",
            color: .purple,
            priority: recommendation.priority
        )
    }
}

// MARK: - Date Formatter Extensions

extension DateFormatter {
    static let conflictDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}