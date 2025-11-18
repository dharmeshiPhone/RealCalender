import SwiftUI
import Charts

struct CalendarAnalyticsView: View {
    @Binding var events: [CalendarEvent]
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    
    // MARK: - Computed Properties
    private var hasData: Bool {
        return !events.isEmpty
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    overviewSection
                    
                    trendsSection
                    
                    categoryBreakdownSection
                    
                    timeDistributionSection
                    
                    productivityInsightsSection
                }
                .padding()
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Overview")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !hasData {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            
            if hasData {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    AnalyticCard(
                        title: "Total Events",
                        value: "\(events.count)",
                        change: calculateTotalEventsChange(),
                        icon: "calendar",
                        color: .blue
                    )
                    
                    AnalyticCard(
                        title: "This Month",
                        value: "\(thisMonthEvents.count)",
                        change: calculateMonthlyChange(),
                        icon: "calendar.badge.checkmark",
                        color: .green
                    )
                    
                    AnalyticCard(
                        title: "Avg/Week",
                        value: String(format: "%.1f", averageEventsPerWeek),
                        change: nil,
                        icon: "chart.bar",
                        color: .orange
                    )
                }
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    LockedStatsCard(
                        title: "Total Events",
                        icon: "calendar",
                        color: .blue
                    )
                    
                    LockedStatsCard(
                        title: "This Month",
                        icon: "calendar.badge.checkmark",
                        color: .green
                    )
                    
                    LockedStatsCard(
                        title: "Avg/Week",
                        icon: "chart.bar",
                        color: .orange
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var trendsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Event Trends")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !hasData {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            
            if hasData {
                if #available(iOS 16.0, *) {
                    Chart {
                        ForEach(monthlyTrends, id: \.month) { data in
                            LineMark(
                                x: .value("Month", data.month),
                                y: .value("Events", data.count)
                            )
                            .foregroundStyle(.blue)
                            .symbol(Circle().strokeBorder(lineWidth: 2))
                            
                            AreaMark(
                                x: .value("Month", data.month),
                                y: .value("Events", data.count)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue.opacity(0.3), .clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        }
                    }
                    .frame(height: 200)
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .chartXAxis {
                        AxisMarks(position: .bottom) { _ in
                            AxisValueLabel()
                            AxisTick()
                        }
                    }
                } else {
                    // Fallback for iOS 15
                    VStack(spacing: 8) {
                        ForEach(monthlyTrends, id: \.month) { data in
                            HStack {
                                Text(data.month)
                                    .font(.caption)
                                    .frame(width: 50, alignment: .leading)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .blue.opacity(0.6)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: CGFloat(data.count * 10), height: 20)
                                
                                Text("\(data.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                }
            } else {
                LockedGraphView(
                    title: "Event Trends",
                    description: "Track how your event scheduling changes over time",
                    icon: "chart.line.uptrend.xyaxis",
                    height: 200,
                    unlockMessage: "Add events across different months to see trend analysis"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var categoryBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Category Breakdown")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !hasData {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            
            if hasData {
                if #available(iOS 16.0, *) {
                    Chart {
                        ForEach(categoryData, id: \.category) { data in
                            SectorMark(
                                angle: .value("Count", data.count),
                                innerRadius: .ratio(0.5),
                                angularInset: 2
                            )
                            .foregroundStyle(data.color)
                            .opacity(0.8)
                        }
                    }
                    .frame(height: 200)
                    .chartBackground { _ in
                        VStack {
                            Text("Events")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(events.count)")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                    }
                } else {
                    // Fallback for iOS 15
                    VStack(spacing: 12) {
                        ForEach(categoryData, id: \.category) { data in
                            HStack {
                                Circle()
                                    .fill(data.color)
                                    .frame(width: 12, height: 12)
                                
                                Text(data.category)
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                Text("\(data.count)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text("(\(Int(Double(data.count) / Double(events.count) * 100))%)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                }
            } else {
                LockedGraphView(
                    title: "Category Distribution",
                    description: "See how your events are distributed across different categories",
                    icon: "chart.pie.fill",
                    height: 200,
                    unlockMessage: "Add events in different categories to unlock this breakdown"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var timeDistributionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Time Distribution")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !hasData {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            
            if hasData {
                if #available(iOS 16.0, *) {
                    Chart {
                        ForEach(hourlyDistribution, id: \.hour) { data in
                            BarMark(
                                x: .value("Hour", data.hour),
                                y: .value("Events", data.count)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .cornerRadius(4)
                        }
                    }
                    .frame(height: 150)
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .chartXAxis {
                        AxisMarks(position: .bottom, values: Array(stride(from: 0, through: 23, by: 3))) { value in
                            AxisValueLabel {
                                if let hour = value.as(Int.self) {
                                    Text("\(hour):00")
                                        .font(.caption2)
                                }
                            }
                            AxisTick()
                        }
                    }
                } else {
                    // Fallback for iOS 15
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(hourlyDistribution, id: \.hour) { data in
                                VStack {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(
                                            LinearGradient(
                                                colors: [.purple, .blue],
                                                startPoint: .bottom,
                                                endPoint: .top
                                            )
                                        )
                                        .frame(width: 16, height: CGFloat(data.count * 10 + 5))
                                    
                                    Text("\(data.hour)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                }
            } else {
                LockedGraphView(
                    title: "Hourly Activity",
                    description: "Discover what times of day you're most active",
                    icon: "clock.badge.checkmark",
                    height: 150,
                    unlockMessage: "Schedule events throughout the day to unlock time patterns"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var productivityInsightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Productivity Insights")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !hasData {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            
            if hasData {
                LazyVStack(spacing: 12) {
                    InsightRow(
                        icon: "clock.arrow.circlepath",
                        title: "Peak Hours",
                        description: peakHoursInsight,
                        color: .blue
                    )
                    
                    InsightRow(
                        icon: "calendar.badge.checkmark",
                        title: "Busiest Day",
                        description: busiestDayInsight,
                        color: .green
                    )
                    
                    InsightRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Trend",
                        description: trendInsight,
                        color: .orange
                    )
                    
                    InsightRow(
                        icon: "target",
                        title: "Recommendation",
                        description: recommendationInsight,
                        color: .purple
                    )
                }
            } else {
                LockedGraphView(
                    title: "AI-Powered Insights",
                    description: "Get personalized recommendations based on your scheduling patterns",
                    icon: "brain.head.profile",
                    height: 200,
                    unlockMessage: "Build your schedule to unlock personalized productivity insights"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Computed Properties
    
    private var thisMonthEvents: [CalendarEvent] {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        let endOfMonth = calendar.dateInterval(of: .month, for: now)?.end ?? now
        
        return events.filter { event in
            event.date >= startOfMonth && event.date < endOfMonth
        }
    }
    
    private var averageEventsPerWeek: Double {
        guard !events.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let sortedEvents = events.sorted { $0.date < $1.date }
        
        guard let firstEvent = sortedEvents.first,
              let lastEvent = sortedEvents.last else { return 0 }
        
        let timeSpan = lastEvent.date.timeIntervalSince(firstEvent.date)
        let weeks = max(1, timeSpan / (7 * 24 * 3600))
        
        return Double(events.count) / weeks
    }
    
    private var monthlyTrends: [(month: String, count: Int)] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        
        var monthCounts: [String: Int] = [:]
        
        for event in events {
            let monthString = formatter.string(from: event.date)
            monthCounts[monthString, default: 0] += 1
        }
        
        // Get last 6 months
        var trends: [(month: String, count: Int)] = []
        for i in 0..<6 {
            let date = calendar.date(byAdding: .month, value: -i, to: Date()) ?? Date()
            let monthString = formatter.string(from: date)
            let count = monthCounts[monthString] ?? 0
            trends.append((month: monthString, count: count))
        }
        
        return trends.reversed()
    }
    
    private var categoryData: [(category: String, count: Int, color: Color)] {
        var categories: [String: Int] = [:]
        
        for event in events {
            let category = categorizeEvent(event)
            categories[category, default: 0] += 1
        }
        
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink, .cyan, .yellow]
        
        return categories.sorted { $0.value > $1.value }.enumerated().map { index, item in
            (category: item.key, count: item.value, color: colors[index % colors.count])
        }
    }
    
    private var hourlyDistribution: [(hour: Int, count: Int)] {
        var hourCounts: [Int: Int] = [:]
        
        let calendar = Calendar.current
        for event in events {
            let hour = calendar.component(.hour, from: event.date)
            hourCounts[hour, default: 0] += 1
        }
        
        return (0...23).map { hour in
            (hour: hour, count: hourCounts[hour] ?? 0)
        }
    }
    
    private var peakHoursInsight: String {
        let maxCount = hourlyDistribution.map(\.count).max() ?? 0
        let peakHours = hourlyDistribution.filter { $0.count == maxCount }.map { $0.hour }
        
        if peakHours.isEmpty {
            return "No events scheduled yet"
        } else if peakHours.count == 1 {
            return "Most events at \(peakHours[0]):00"
        } else {
            return "Peak hours: \(peakHours.map { "\($0):00" }.joined(separator: ", "))"
        }
    }
    
    private var busiestDayInsight: String {
        let calendar = Calendar.current
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE"
        
        var dayCounts: [String: Int] = [:]
        
        for event in events {
            let dayString = dayFormatter.string(from: event.date)
            dayCounts[dayString, default: 0] += 1
        }
        
        guard let busiestDay = dayCounts.max(by: { $0.value < $1.value }) else {
            return "No events scheduled yet"
        }
        
        return "\(busiestDay.key) with \(busiestDay.value) events"
    }
    
    private var trendInsight: String {
        guard monthlyTrends.count >= 2 else {
            return "Need more data to analyze trends"
        }
        
        let recent = monthlyTrends.suffix(2)
        let previous = recent.first?.count ?? 0
        let current = recent.last?.count ?? 0
        
        if current > previous {
            return "Events increasing by \(current - previous)"
        } else if current < previous {
            return "Events decreasing by \(previous - current)"
        } else {
            return "Event count is stable"
        }
    }
    
    private var recommendationInsight: String {
        if events.count < 5 {
            return "Add more events to get better insights"
        } else if averageEventsPerWeek > 20 {
            return "Consider time blocking for better organization"
        } else if averageEventsPerWeek < 3 {
            return "You might benefit from more structured scheduling"
        } else {
            return "Your scheduling looks well-balanced!"
        }
    }
    
    // MARK: - Helper Functions
    
    private func categorizeEvent(_ event: CalendarEvent) -> String {
        let title = event.title.lowercased()
        
        if title.contains("class") || title.contains("lecture") || title.contains("course") {
            return "Education"
        } else if title.contains("meeting") || title.contains("call") || title.contains("conference") {
            return "Work"
        } else if title.contains("workout") || title.contains("gym") || title.contains("exercise") {
            return "Fitness"
        } else if title.contains("appointment") || title.contains("doctor") || title.contains("dentist") {
            return "Health"
        } else if title.contains("social") || title.contains("party") || title.contains("dinner") {
            return "Social"
        } else {
            return "Other"
        }
    }
    
    private func calculateTotalEventsChange() -> String? {
        // This would compare to previous period - simplified for now
        return "+12%"
    }
    
    private func calculateMonthlyChange() -> String? {
        // This would compare to previous month - simplified for now
        return "+5%"
    }
}

struct AnalyticCard: View {
    let title: String
    let value: String
    let change: String?
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                if let change = change {
                    Text(change)
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

struct InsightRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
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
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
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

#Preview {
    CalendarAnalyticsView(events: .constant([
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
            title: "Meeting",
            date: Date().addingTimeInterval(3600),
            notes: "Project discussion",
            color: .green,
            location: "Office",
            isRespond: false,
            isCompleted: false
        )
    ]))
    .environmentObject(ScreenTimeManager())
}
