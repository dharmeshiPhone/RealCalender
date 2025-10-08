import SwiftUI
import Charts

struct AnalyticsView: View {
    @Binding var events: [CalendarEvent]
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedMetric: AnalyticsMetric = .eventCount
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    enum AnalyticsMetric: String, CaseIterable {
        case eventCount = "Event Count"
        case timeSpent = "Time Spent"
        case productivity = "Productivity"
        case balance = "Work-Life Balance"
    }
    
    // MARK: - Computed Properties
    private var hasData: Bool {
        return !events.isEmpty
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Time range selector
                    timeRangeSelector
                    
                    // Key metrics cards
                    keyMetricsSection
                    
                    // Main chart
                    mainChartSection
                    
                    // Category breakdown
                    categoryBreakdownSection
                    
                    // Productivity insights
                    productivityInsightsSection
                    
                    // Time patterns
                    timePatternsSection
                }
                .padding()
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    @ViewBuilder
    private var timeRangeSelector: some View {
        Picker("Time Range", selection: $selectedTimeRange) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .opacity(hasData ? 1.0 : 0.6)
        .disabled(!hasData)
    }
    
    @ViewBuilder
    private var keyMetricsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: hasData ? "chart.bar.fill" : "lock.fill")
                    .foregroundColor(hasData ? .blue : .gray)
                Text("Key Metrics")
                    .font(.title2)
                    .fontWeight(.bold)
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
                    GridItem(.flexible())
                ], spacing: 12) {
                    MetricCard(
                        title: "Total Events",
                        value: "\(getEventCount())",
                        icon: "calendar",
                        color: .blue,
                        trend: "+12%"
                    )
                    
                    MetricCard(
                        title: "Hours Scheduled",
                        value: String(format: "%.1f", getTotalHours()),
                        icon: "clock",
                        color: .green,
                        trend: "+8%"
                    )
                    
                    MetricCard(
                        title: "Productivity Score",
                        value: "\(getProductivityScore())%",
                        icon: "target",
                        color: .orange,
                        trend: "+5%"
                    )
                    
                    MetricCard(
                        title: "Work-Life Balance",
                        value: getWorkLifeBalance(),
                        icon: "scale.3d",
                        color: .purple,
                        trend: "Stable"
                    )
                }
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
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
                    
                    LockedStatsCard(
                        title: "Productivity Score",
                        icon: "target",
                        color: .orange
                    )
                    
                    LockedStatsCard(
                        title: "Work-Life Balance",
                        icon: "scale.3d",
                        color: .purple
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    @ViewBuilder
    private var mainChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: hasData ? "chart.line.uptrend.xyaxis" : "lock.fill")
                    .foregroundColor(hasData ? .green : .gray)
                Text("Trends")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                
                if hasData {
                    Picker("Metric", selection: $selectedMetric) {
                        ForEach(AnalyticsMetric.allCases, id: \.self) { metric in
                            Text(metric.rawValue).tag(metric)
                        }
                    }
                    .pickerStyle(.menu)
                } else {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            
            if hasData {
                // Chart placeholder - you can replace with actual Chart implementation
                VStack {
                    if #available(iOS 16.0, *) {
                        chartView
                    } else {
                        Text("Chart requires iOS 16.0+")
                            .foregroundColor(.secondary)
                            .frame(height: 200)
                    }
                }
                .frame(height: 250)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else {
                LockedGraphView(
                    title: "Event Trends",
                    description: "Track your scheduling patterns and productivity over time",
                    icon: "chart.line.uptrend.xyaxis",
                    height: 250,
                    unlockMessage: "Add your first calendar event to unlock trend analysis"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    @available(iOS 16.0, *)
    @ViewBuilder
    private var chartView: some View {
        let data = generateChartData()
        
        Chart(data, id: \.date) { item in
            LineMark(
                x: .value("Date", item.date),
                y: .value("Value", item.value)
            )
            .foregroundStyle(.blue)
            .symbol(Circle())
        }
        .padding()
    }
    
    @ViewBuilder
    private var categoryBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: hasData ? "chart.pie.fill" : "lock.fill")
                    .foregroundColor(hasData ? .orange : .gray)
                Text("Category Breakdown")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                
                if !hasData {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            
            if hasData {
                let categories = getCategoryBreakdown()
                
                LazyVStack(spacing: 8) {
                    ForEach(categories, id: \.name) { category in
                        CategoryRow(category: category)
                    }
                }
            } else {
                LockedGraphView(
                    title: "Category Analysis",
                    description: "See how your time is distributed across different types of events",
                    icon: "chart.pie.fill",
                    height: 200,
                    unlockMessage: "Add events with different categories to unlock this breakdown"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    @ViewBuilder
    private var productivityInsightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: hasData ? "lightbulb.fill" : "lock.fill")
                    .foregroundColor(hasData ? .yellow : .gray)
                Text("Productivity Insights")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                
                if !hasData {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            
            if hasData {
                LazyVStack(spacing: 12) {
                    InsightCard(
                        title: "Peak Productivity Time",
                        description: "Your most productive hours are between 9-11 AM",
                        icon: "sun.max.fill",
                        color: .orange
                    )
                    
                    InsightCard(
                        title: "Schedule Optimization",
                        description: "Consider consolidating similar tasks for better focus",
                        icon: "arrow.triangle.2.circlepath",
                        color: .blue
                    )
                    
                    InsightCard(
                        title: "Break Recommendation",
                        description: "Add 15-minute breaks between long meetings",
                        icon: "pause.circle.fill",
                        color: .green
                    )
                }
            } else {
                LockedGraphView(
                    title: "AI Insights",
                    description: "Get personalized recommendations to optimize your schedule",
                    icon: "lightbulb.fill",
                    height: 180,
                    unlockMessage: "Build your schedule to unlock AI-powered productivity insights"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    @ViewBuilder
    private var timePatternsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: hasData ? "clock.arrow.2.circlepath" : "lock.fill")
                    .foregroundColor(hasData ? .purple : .gray)
                Text("Time Patterns")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                
                if !hasData {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            
            if hasData {
                VStack(spacing: 12) {
                    TimePatternRow(
                        title: "Most Active Day",
                        value: getMostActiveDay(),
                        icon: "calendar.day.timeline.leading"
                    )
                    
                    TimePatternRow(
                        title: "Average Events/Day",
                        value: String(format: "%.1f", getAverageEventsPerDay()),
                        icon: "chart.bar"
                    )
                    
                    TimePatternRow(
                        title: "Longest Event",
                        value: getLongestEventDuration(),
                        icon: "clock"
                    )
                    
                    TimePatternRow(
                        title: "Shortest Gap",
                        value: getShortestGap(),
                        icon: "timer"
                    )
                }
            } else {
                LockedGraphView(
                    title: "Schedule Patterns",
                    description: "Discover your scheduling habits and time usage patterns",
                    icon: "clock.arrow.2.circlepath",
                    height: 180,
                    unlockMessage: "Add more events to reveal your time management patterns"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Data Processing Methods
    
    private func getEventCount() -> Int {
        return getEventsInTimeRange().count
    }
    
    private func getTotalHours() -> Double {
        // Assuming each event is 1 hour by default (you can modify this based on your event model)
        return Double(getEventsInTimeRange().count)
    }
    
    private func getProductivityScore() -> Int {
        // Simple productivity calculation based on event completion
        return Int.random(in: 75...95) // Placeholder
    }
    
    private func getWorkLifeBalance() -> String {
        let workEvents = getEventsInTimeRange().filter { isWorkEvent($0) }
        let personalEvents = getEventsInTimeRange().filter { !isWorkEvent($0) }
        
        let workRatio = Double(workEvents.count) / Double(max(1, getEventsInTimeRange().count))
        
        if workRatio > 0.7 {
            return "Work Heavy"
        } else if workRatio < 0.3 {
            return "Life Heavy"
        } else {
            return "Balanced"
        }
    }
    
    private func getCategoryBreakdown() -> [CategoryData] {
        let allEvents = getEventsInTimeRange()
        var categories: [String: Int] = [:]
        
        for event in allEvents {
            let category = categorizeEvent(event)
            categories[category, default: 0] += 1
        }
        
        let total = allEvents.count
        return categories.map { name, count in
            CategoryData(
                name: name,
                count: count,
                percentage: total > 0 ? Double(count) / Double(total) * 100 : 0
            )
        }.sorted { $0.count > $1.count }
    }
    
    private func getMostActiveDay() -> String {
        let calendar = Calendar.current
        var dayCount: [Int: Int] = [:]
        
        for event in getEventsInTimeRange() {
            let weekday = calendar.component(.weekday, from: event.date)
            dayCount[weekday, default: 0] += 1
        }
        
        let mostActiveWeekday = dayCount.max { $0.value < $1.value }?.key ?? 1
        return calendar.weekdaySymbols[mostActiveWeekday - 1]
    }
    
    private func getAverageEventsPerDay() -> Double {
        let events = getEventsInTimeRange()
        let dayCount = getDayCount()
        return dayCount > 0 ? Double(events.count) / Double(dayCount) : 0
    }
    
    private func getLongestEventDuration() -> String {
        return "2h 30m" // Placeholder
    }
    
    private func getShortestGap() -> String {
        return "15 min" // Placeholder
    }
    
    private func getEventsInTimeRange() -> [CalendarEvent] {
        let now = Date()
        let calendar = Calendar.current
        
        switch selectedTimeRange {
        case .week:
            let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
            return events.filter { $0.date >= weekAgo && $0.date <= now }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return events.filter { $0.date >= monthAgo && $0.date <= now }
        case .year:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            return events.filter { $0.date >= yearAgo && $0.date <= now }
        }
    }
    
    private func getDayCount() -> Int {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimeRange {
        case .week:
            return 7
        case .month:
            return calendar.range(of: .day, in: .month, for: now)?.count ?? 30
        case .year:
            return calendar.range(of: .day, in: .year, for: now)?.count ?? 365
        }
    }
    
    private func isWorkEvent(_ event: CalendarEvent) -> Bool {
        let workKeywords = ["meeting", "work", "office", "call", "conference", "project", "deadline"]
        let title = event.title.lowercased()
        return workKeywords.contains { title.contains($0) }
    }
    
    private func categorizeEvent(_ event: CalendarEvent) -> String {
        let title = event.title.lowercased()
        
        if title.contains("meeting") || title.contains("call") || title.contains("conference") {
            return "Meetings"
        } else if title.contains("workout") || title.contains("gym") || title.contains("exercise") {
            return "Fitness"
        } else if title.contains("personal") || title.contains("family") || title.contains("friend") {
            return "Personal"
        } else if title.contains("work") || title.contains("project") || title.contains("deadline") {
            return "Work"
        } else {
            return "Other"
        }
    }
    
    private func generateChartData() -> [ChartDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        var dataPoints: [ChartDataPoint] = []
        
        let dayCount = getDayCount()
        for i in 0..<min(dayCount, 30) {
            if let date = calendar.date(byAdding: .day, value: -i, to: now) {
                let eventsForDay = events.filter { calendar.isDate($0.date, inSameDayAs: date) }
                dataPoints.append(ChartDataPoint(date: date, value: Double(eventsForDay.count)))
            }
        }
        
        return dataPoints.reversed()
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                Spacer()
                Text(trend)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct CategoryData {
    let name: String
    let count: Int
    let percentage: Double
}

struct CategoryRow: View {
    let category: CategoryData
    
    var body: some View {
        HStack {
            Circle()
                .fill(categoryColor)
                .frame(width: 12, height: 12)
            
            Text(category.name)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            Text("\(category.count) events")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(String(format: "%.1f%%", category.percentage))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .frame(width: 50, alignment: .trailing)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private var categoryColor: Color {
        switch category.name {
        case "Meetings": return .blue
        case "Fitness": return .green
        case "Personal": return .purple
        case "Work": return .orange
        default: return .gray
        }
    }
}

struct InsightCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TimePatternRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.purple)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct ChartDataPoint {
    let date: Date
    let value: Double
}