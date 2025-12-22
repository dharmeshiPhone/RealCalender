import SwiftUI

// MARK: - Enhanced Analytics Tab
struct EnhancedAnalyticsTabView: View {
    @EnvironmentObject var questManager: QuestManager
    let events: [CalendarEvent]
    @State private var selectedTimeRange: AnalyticsTimeRange = .week
    @State private var selectedMetric: AnalyticsMetric = .eventCount
    @State private var user: UserProfile = UserProfile.shared
    
    enum AnalyticsTimeRange: String, CaseIterable {
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
    
    var body: some View {
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
            .onAppear {
                if questManager.currentBatch == 15{
                    questManager.completeQuestWithIncremnetForce(named: "Check Weekly Analytics",num:1,Quebatch:15)
                }
                
                if questManager.currentBatch == 24{
                    questManager.completeQuest(named:"Open analytics page")
                }
                
                if questManager.currentBatch == 26{
                    questManager.completeQuestWithIncremnetForce(named: "Check Weekly Analytics",num:1,Quebatch:26)
                }
                
                if questManager.currentBatch == 35{
                    questManager.completeQuestWithIncremnetForce(named: "Check Weekly Analytics",num:1,Quebatch:35)
                }
                
                if questManager.currentBatch == 38{
                    if user.weeklyAnalyticsStreak == 6 {
                        questManager.completeQuestWithIncremnetForce(named: "Check Weekly Analytics 6 weeks in a row",num:1,Quebatch:35)
                    }
                }
                
                if questManager.currentBatch == 49{
                    if user.weeklyAnalyticsStreak == 8 {
                        questManager.completeQuestWithIncremnetForce(named: "Check Weekly Analytics 8 weeks in a row",num:1,Quebatch:49)
                    }
                }
                
                if questManager.currentBatch == 52{
                    questManager.completeQuestWithIncremnetForce(named: "Check Weekly Analytics",num:1,Quebatch:52)
                }
                if questManager.currentBatch == 58{
                    if user.weeklyAnalyticsStreak == 10 {
                        questManager.completeQuestWithIncremnetForce(named: "Check Weekly Analytics 10 weeks in a row",num:1,Quebatch:58)
                    }
                }
                
                
                
                let result = updateWeeklyAnalyticsStreak(
                    lastWeek: user.lastAnalyticsWeek,
                    currentStreak: user.weeklyAnalyticsStreak
                )
                
                user.weeklyAnalyticsStreak = result.newStreak
                user.lastAnalyticsWeek = result.newLastWeek
                user.save()
                
            }
        }
    }
    // MARK: - update analytics streak
    private func updateWeeklyAnalyticsStreak(
        lastWeek: Date?,
        currentStreak: Int,
        today: Date = Date()
    ) -> (newStreak: Int, newLastWeek: Date) {
        
        let currentWeek = startOfWeek(for: today)
        
        // First time
        guard let lastWeek else {
            return (1, currentWeek)
        }
        
        // Same week → do nothing
        if Calendar.current.isDate(currentWeek, inSameDayAs: lastWeek) {
            return (currentStreak, lastWeek)
        }
        
        // Previous week → increment
        if let expectedWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentWeek),
           Calendar.current.isDate(expectedWeek, inSameDayAs: lastWeek) {
            return (currentStreak + 1, currentWeek)
        }
        
        // Missed a week → reset
        return (1, currentWeek)
    }
    
    private func startOfWeek(for date: Date) -> Date {
        Calendar.current.dateInterval(of: .weekOfYear, for: date)!.start
    }
    
    
    
    @ViewBuilder
    private var timeRangeSelector: some View {
        Picker("Time Range", selection: $selectedTimeRange) {
            ForEach(AnalyticsTimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .onChange(of: selectedTimeRange) { oldValue, newValue in
            completeVisitTabQuest()
        }
    }
    
    private func completeVisitTabQuest(){
        if questManager.currentBatch == 62{
            questManager.completeQuestWithIncremnetForce(named: "Check all analytics tabs",num:1,Quebatch:62)
        }
        
        if questManager.currentBatch == 60{
            questManager.completeQuestWithIncremnetForce(named: "Check all analytics tabs",num:1,Quebatch:60)
        }
    }
    
    @ViewBuilder
    private var keyMetricsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.blue)
                Text("Key Metrics")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                AnalyticsMetricCard(
                    title: "Total Events",
                    value: "\(getEventCount())",
                    icon: "calendar",
                    color: .blue,
                    trend: "+12%"
                )
                
                AnalyticsMetricCard(
                    title: "Hours Scheduled",
                    value: String(format: "%.1f", getTotalHours()),
                    icon: "clock",
                    color: .green,
                    trend: "+8%"
                )
                
                AnalyticsMetricCard(
                    title: "Productivity Score",
                    value: "\(getProductivityScore())%",
                    icon: "target",
                    color: .orange,
                    trend: "+5%"
                )
                
                AnalyticsMetricCard(
                    title: "Work-Life Balance",
                    value: getWorkLifeBalance(),
                    icon: "scale.3d",
                    color: .purple,
                    trend: "Stable"
                )
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
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.green)
                Text("Trends")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                
                Picker("Metric", selection: $selectedMetric) {
                    ForEach(AnalyticsMetric.allCases, id: \.self) { metric in
                        Text(metric.rawValue).tag(metric)
                    }
                }
                .pickerStyle(.menu)
            }
            
            // Chart placeholder
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
        
        // Simple chart representation for now
        VStack {
            Text("Event Trends Over Time")
                .font(.headline)
                .padding()
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<min(data.count, 7), id: \.self) { index in
                    VStack {
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: 30, height: CGFloat(data[index].value * 10))
                            .cornerRadius(4)
                        
                        Text(data[index].date, formatter: dayFormatter)
                            .font(.caption2)
                            .rotationEffect(.degrees(-45))
                    }
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private var categoryBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundColor(.orange)
                Text("Category Breakdown")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            let categories = getCategoryBreakdown()
            
            LazyVStack(spacing: 8) {
                ForEach(categories, id: \.name) { category in
                    AnalyticsCategoryRow(category: category)
                }
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
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Productivity Insights")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            LazyVStack(spacing: 12) {
                AnalyticsInsightCard(
                    title: "Peak Productivity Time",
                    description: "Your most productive hours are between 9-11 AM",
                    icon: "sun.max.fill",
                    color: .orange
                )
                
                AnalyticsInsightCard(
                    title: "Schedule Optimization",
                    description: "Consider consolidating similar tasks for better focus",
                    icon: "arrow.triangle.2.circlepath",
                    color: .blue
                )
                
                AnalyticsInsightCard(
                    title: "Break Recommendation",
                    description: "Add 15-minute breaks between long meetings",
                    icon: "pause.circle.fill",
                    color: .green
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
                Image(systemName: "clock.arrow.2.circlepath")
                    .foregroundColor(.purple)
                Text("Time Patterns")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                AnalyticsTimePatternRow(
                    title: "Most Active Day",
                    value: getMostActiveDay(),
                    icon: "calendar.day.timeline.leading"
                )
                
                AnalyticsTimePatternRow(
                    title: "Average Events/Day",
                    value: String(format: "%.1f", getAverageEventsPerDay()),
                    icon: "chart.bar"
                )
                
                AnalyticsTimePatternRow(
                    title: "Longest Event",
                    value: getLongestEventDuration(),
                    icon: "clock"
                )
                
                AnalyticsTimePatternRow(
                    title: "Shortest Gap",
                    value: getShortestGap(),
                    icon: "timer"
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
        return Double(getEventsInTimeRange().count)
    }
    
    private func getProductivityScore() -> Int {
        return Int.random(in: 75...95)
    }
    
    private func getWorkLifeBalance() -> String {
        let eventsInRange = getEventsInTimeRange()
        guard !eventsInRange.isEmpty else { return "No Data" }
        
        let workEvents = eventsInRange.filter { isWorkEvent($0) }
        let workRatio = Double(workEvents.count) / Double(eventsInRange.count)
        
        if workRatio > 0.7 {
            return "Work Heavy"
        } else if workRatio < 0.3 {
            return "Life Heavy"
        } else {
            return "Balanced"
        }
    }
    
    private func getCategoryBreakdown() -> [AnalyticsCategoryData] {
        let allEvents = getEventsInTimeRange()
        guard !allEvents.isEmpty else { return [] }
        
        var categories: [String: Int] = [:]
        
        for event in allEvents {
            let category = categorizeEvent(event)
            categories[category, default: 0] += 1
        }
        
        let total = allEvents.count
        return categories.map { name, count in
            AnalyticsCategoryData(
                name: name,
                count: count,
                percentage: total > 0 ? Double(count) / Double(total) * 100 : 0
            )
        }.sorted { $0.count > $1.count }
    }
    
    private func getMostActiveDay() -> String {
        let eventsInRange = getEventsInTimeRange()
        guard !eventsInRange.isEmpty else { return "No Data" }
        
        let calendar = Calendar.current
        var dayCount: [Int: Int] = [:]
        
        for event in eventsInRange {
            let weekday = calendar.component(.weekday, from: event.date)
            dayCount[weekday, default: 0] += 1
        }
        
        guard let mostActiveWeekday = dayCount.max(by: { $0.value < $1.value })?.key else {
            return "No Data"
        }
        
        let safeIndex = max(0, min(mostActiveWeekday - 1, calendar.weekdaySymbols.count - 1))
        return calendar.weekdaySymbols[safeIndex]
    }
    
    private func getAverageEventsPerDay() -> Double {
        let eventsInRange = getEventsInTimeRange()
        let dayCount = getDayCount()
        return dayCount > 0 ? Double(eventsInRange.count) / Double(dayCount) : 0
    }
    
    private func getLongestEventDuration() -> String {
        return "2h 30m"
    }
    
    private func getShortestGap() -> String {
        return "15 min"
    }
    
    private func getEventsInTimeRange() -> [CalendarEvent] {
        let now = Date()
        let calendar = Calendar.current
        
        switch selectedTimeRange {
        case .week:
            guard let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now) else {
                return events
            }
            return events.filter { $0.date >= weekAgo && $0.date <= now }
        case .month:
            if questManager.currentBatch == 62{
                questManager.completeQuestWithIncremnetForce(named: "Check all analytics tabs",num:1,Quebatch:62)
            }
            
            if questManager.currentBatch == 60{
                questManager.completeQuestWithIncremnetForce(named: "Check all analytics tabs",num:1,Quebatch:60)
            }
            guard let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) else {
                return events
            }
            return events.filter { $0.date >= monthAgo && $0.date <= now }
        case .year:
            if questManager.currentBatch == 62{
                questManager.completeQuestWithIncremnetForce(named: "Check all analytics tabs",num:1,Quebatch:62)
            }
            
            if questManager.currentBatch == 60{
                questManager.completeQuestWithIncremnetForce(named: "Check all analytics tabs",num:1,Quebatch:60)
            }
            guard let yearAgo = calendar.date(byAdding: .year, value: -1, to: now) else {
                return events
            }
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
    
    private func generateChartData() -> [AnalyticsChartDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        var dataPoints: [AnalyticsChartDataPoint] = []
        
        let dayCount = getDayCount()
        for i in 0..<min(dayCount, 30) {
            if let date = calendar.date(byAdding: .day, value: -i, to: now) {
                let eventsForDay = events.filter { calendar.isDate($0.date, inSameDayAs: date) }
                dataPoints.append(AnalyticsChartDataPoint(date: date, value: Double(eventsForDay.count)))
            }
        }
        
        return dataPoints.reversed()
    }
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }
}

// MARK: - Enhanced Conflicts Tab
struct EnhancedConflictsTabView: View {
    let events: [CalendarEvent]
    @State private var detectedConflicts: [ConflictScheduleConflict] = []
    @State private var isAnalyzing = false
    @State private var selectedConflictType: ConflictTypeFilter = .all
    @State private var showingResolutionSheet = false
    @State private var selectedConflict: ConflictScheduleConflict?
    
    enum ConflictTypeFilter: String, CaseIterable {
        case all = "All"
        case timeOverlap = "Time Overlap"
        case travelTime = "Travel Time"
        case locationConflict = "Location"
        case resourceConflict = "Resource"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with conflict summary
            conflictSummaryHeader
            
            // Filter picker
            conflictTypeFilter
            
            // Main content
            ScrollView {
                LazyVStack(spacing: 16) {
                    if isAnalyzing {
                        analyzingView
                    } else if filteredConflicts.isEmpty {
                        noConflictsView
                    } else {
                        ForEach(filteredConflicts) { conflict in
                            ConflictCard(conflict: conflict) {
                                selectedConflict = conflict
                                showingResolutionSheet = true
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            analyzeConflicts()
        }
        .sheet(isPresented: $showingResolutionSheet) {
            if let conflict = selectedConflict {
                ConflictResolutionSheet(
                    conflict: conflict,
                    events: .constant(events),
                    onResolved: {
                        analyzeConflicts()
                        showingResolutionSheet = false
                    }
                )
            }
        }
    }
    
    @ViewBuilder
    private var conflictSummaryHeader: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(detectedConflicts.count)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(conflictSeverityColor)
                    Text("Conflicts Detected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !detectedConflicts.isEmpty {
                    conflictSeverityIndicator
                }
            }
            
            if !detectedConflicts.isEmpty {
                conflictBreakdown
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    @ViewBuilder
    private var conflictSeverityIndicator: some View {
        VStack {
            Image(systemName: conflictSeverityIcon)
                .font(.title2)
                .foregroundColor(conflictSeverityColor)
            
            Text(conflictSeverityText)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(conflictSeverityColor)
        }
    }
    
    @ViewBuilder
    private var conflictBreakdown: some View {
        HStack(spacing: 16) {
            ConflictTypeCount(
                count: detectedConflicts.filter { $0.type == .timeOverlap }.count,
                type: "Overlaps",
                color: .red
            )
            
            ConflictTypeCount(
                count: detectedConflicts.filter { $0.type == .travelTime }.count,
                type: "Travel",
                color: .orange
            )
            
            ConflictTypeCount(
                count: detectedConflicts.filter { $0.type == .locationConflict }.count,
                type: "Location",
                color: .purple
            )
            
            ConflictTypeCount(
                count: detectedConflicts.filter { $0.type == .resourceConflict }.count,
                type: "Resource",
                color: .yellow
            )
        }
    }
    
    @ViewBuilder
    private var conflictTypeFilter: some View {
        Picker("Conflict Type", selection: $selectedConflictType) {
            ForEach(ConflictTypeFilter.allCases, id: \.self) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .pickerStyle(.segmented)
        .padding()
        .background(Color(.systemBackground))
    }
    
    @ViewBuilder
    private var analyzingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Analyzing your schedule for conflicts...")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text("Checking for time overlaps, travel constraints, and schedule balance")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }
    
    @ViewBuilder
    private var noConflictsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("No Conflicts Found!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Your schedule looks well-organized with no overlapping events or travel issues.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Optimize Further") {
                // Navigate to optimization suggestions
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 40)
    }
    
    private var filteredConflicts: [ConflictScheduleConflict] {
        if selectedConflictType == .all {
            return detectedConflicts
        } else {
            return detectedConflicts.filter { conflict in
                switch selectedConflictType {
                case .timeOverlap:
                    return conflict.type == .timeOverlap
                case .travelTime:
                    return conflict.type == .travelTime
                case .locationConflict:
                    return conflict.type == .locationConflict
                case .resourceConflict:
                    return conflict.type == .resourceConflict
                case .all:
                    return true
                }
            }
        }
    }
    
    private var conflictSeverityColor: Color {
        let highSeverityCount = detectedConflicts.filter { $0.severity == .high }.count
        let mediumSeverityCount = detectedConflicts.filter { $0.severity == .medium }.count
        
        if highSeverityCount > 0 {
            return .red
        } else if mediumSeverityCount > 0 {
            return .orange
        } else {
            return .yellow
        }
    }
    
    private var conflictSeverityIcon: String {
        let highSeverityCount = detectedConflicts.filter { $0.severity == .high }.count
        let mediumSeverityCount = detectedConflicts.filter { $0.severity == .medium }.count
        
        if highSeverityCount > 0 {
            return "exclamationmark.triangle.fill"
        } else if mediumSeverityCount > 0 {
            return "exclamationmark.circle.fill"
        } else {
            return "info.circle.fill"
        }
    }
    
    private var conflictSeverityText: String {
        let highSeverityCount = detectedConflicts.filter { $0.severity == .high }.count
        let mediumSeverityCount = detectedConflicts.filter { $0.severity == .medium }.count
        
        if highSeverityCount > 0 {
            return "Critical"
        } else if mediumSeverityCount > 0 {
            return "Warning"
        } else {
            return "Minor"
        }
    }
    
    private func analyzeConflicts() {
        isAnalyzing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            detectConflicts()
            isAnalyzing = false
        }
    }
    
    private func detectConflicts() {
        var conflicts: [ConflictScheduleConflict] = []
        let sortedEvents = events.sorted { $0.date < $1.date }
        
        // Check for time overlaps
        for i in 0..<sortedEvents.count {
            for j in (i+1)..<sortedEvents.count {
                let event1 = sortedEvents[i]
                let event2 = sortedEvents[j]
                
                if eventsOverlap(event1, event2) {
                    conflicts.append(ConflictScheduleConflict(
                        id: UUID(),
                        type: .timeOverlap,
                        severity: .high,
                        title: "Time Overlap Detected",
                        description: "'\(event1.title)' and '\(event2.title)' are scheduled at the same time",
                        affectedEvents: [event1, event2],
                        suggestedSolutions: ["Move one event to a different time slot", "Shorten the duration of one event"]
                    ))
                }
            }
        }
        
        // Check for travel time conflicts
        if sortedEvents.count > 0{
            for i in 0..<sortedEvents.count - 1 {
                let currentEvent = sortedEvents[i]
                let nextEvent = sortedEvents[i + 1]
                
                if hasTravelTimeConflict(from: currentEvent, to: nextEvent) {
                    conflicts.append(ConflictScheduleConflict(
                        id: UUID(),
                        type: .travelTime,
                        severity: .medium,
                        title: "Insufficient Travel Time",
                        description: "Not enough time to travel from '\(currentEvent.title)' to '\(nextEvent.title)'",
                        affectedEvents: [currentEvent, nextEvent],
                        suggestedSolutions: ["Add buffer time between events", "Reschedule one of the events", "Consider virtual alternative"]
                    ))
                }
            }
        }
        detectedConflicts = conflicts
    }
    
    private func eventsOverlap(_ event1: CalendarEvent, _ event2: CalendarEvent) -> Bool {
        let event1End = event1.date.addingTimeInterval(3600)
        let event2End = event2.date.addingTimeInterval(3600)
        
        return (event1.date < event2End && event2.date < event1End)
    }
    
    private func hasTravelTimeConflict(from: CalendarEvent, to: CalendarEvent) -> Bool {
        let timeDifference = to.date.timeIntervalSince(from.date)
        
        if !from.location.isEmpty && !to.location.isEmpty && from.location != to.location {
            return timeDifference < 1800
        }
        
        return false
    }
    
    private func isWorkEvent(_ event: CalendarEvent) -> Bool {
        let workKeywords = ["meeting", "work", "office", "call", "conference", "project", "deadline"]
        let title = event.title.lowercased()
        return workKeywords.contains { title.contains($0) }
    }
}

// MARK: - Enhanced Insights Tab
struct EnhancedInsightsTabView: View {
    let events: [CalendarEvent]
    @State private var selectedInsightCategory: InsightCategory = .productivity
    @State private var insights: [CalendarInsight] = []
    @State private var isLoadingInsights = false
    
    enum InsightCategory: String, CaseIterable {
        case productivity = "Productivity"
        case patterns = "Patterns"
        case optimization = "Optimization"
        case wellness = "Wellness"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Category selector
            categorySelector
            
            // Main content
            ScrollView {
                LazyVStack(spacing: 20) {
                    if isLoadingInsights {
                        loadingView
                    } else {
                        // Summary cards
                        summarySection
                        
                        // Insights list
                        insightsSection
                        
                        // Recommendations
                        recommendationsSection
                    }
                }
                .padding()
            }
        }
        .onAppear {
            if insights.isEmpty {
                generateInsights()
            }
        }
    }
    
    @ViewBuilder
    private var categorySelector: some View {
        Picker("Category", selection: $selectedInsightCategory) {
            ForEach(InsightCategory.allCases, id: \.self) { category in
                Text(category.rawValue).tag(category)
            }
        }
        .pickerStyle(.segmented)
        .padding()
        .background(Color(.systemBackground))
        .onChange(of: selectedInsightCategory) { _, _ in
            generateInsights()
        }
    }
    
    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Analyzing your schedule...")
                .font(.headline)
            
            Text("Generating personalized insights based on your activity patterns")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }
    
    @ViewBuilder
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.doc.horizontal")
                    .foregroundColor(.blue)
                Text("Summary")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                InsightsSummaryCard(
                    title: getInsightSummaryTitle(),
                    value: getInsightSummaryValue(),
                    icon: getInsightSummaryIcon(),
                    color: getInsightSummaryColor()
                )
                
                InsightsSummaryCard(
                    title: "Improvement Areas",
                    value: "\(getImprovementAreasCount())",
                    icon: "arrow.up.circle.fill",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    @ViewBuilder
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Key Insights")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            LazyVStack(spacing: 12) {
                ForEach(filteredInsights) { insight in
                    CalendarInsightCard(insight: insight)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    @ViewBuilder
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.purple)
                Text("Recommendations")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            LazyVStack(spacing: 12) {
                ForEach(getRecommendations(), id: \.title) { recommendation in
                    CalendarRecommendationCard(recommendation: recommendation)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var filteredInsights: [CalendarInsight] {
        insights.filter { insight in
            switch selectedInsightCategory {
            case .productivity:
                return insight.category == .productivity
            case .patterns:
                return insight.category == .patterns
            case .optimization:
                return insight.category == .optimization
            case .wellness:
                return insight.category == .wellness
            }
        }
    }
    
    private func generateInsights() {
        isLoadingInsights = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            var newInsights: [CalendarInsight] = []
            
            // Add error handling to prevent crashes
            do {
                switch selectedInsightCategory {
                case .productivity:
                    newInsights = generateProductivityInsights()
                case .patterns:
                    newInsights = generatePatternInsights()
                case .optimization:
                    newInsights = generateOptimizationInsights()
                case .wellness:
                    newInsights = generateWellnessInsights()
                }
            } catch {
                print("Error generating insights: \(error)")
                // Provide fallback insights on error
                newInsights = [
                    CalendarInsight(
                        
                        category: .productivity,
                        title: "Analysis Available",
                        description: "Your calendar insights are being prepared. Please try again.",
                        impact: .neutral,
                        priority: .low,
                        suggestion: "Keep using your calendar to generate more insights.",
                        metricValue: "—"
                    )
                ]
            }
            
            insights = newInsights
            isLoadingInsights = false
        }
    }
    
    // MARK: - Insight Generation Methods
    
    private func getInsightSummaryTitle() -> String {
        return "Calendar Insights"
    }
    
    private func getInsightSummaryValue() -> String {
        return "\(generateAllInsights().count)"
    }
    
    private func getInsightSummaryIcon() -> String {
        return "lightbulb.fill"
    }
    
    private func getInsightSummaryColor() -> Color {
        return .blue
    }
    
    private func getImprovementAreasCount() -> Int {
        return generateAllInsights().filter { $0.priority > 1 }.count
    }
    
    private func getRecommendations() -> [CalendarRecommendation] {
        return [
            CalendarRecommendation(
                title: "Schedule Optimization",
                description: "Consider grouping similar events together",
                priority: "Medium",
                actionType: "optimization"
            ),
            CalendarRecommendation(
                title: "Break Time",
                description: "Add buffer time between meetings",
                priority: "High",
                actionType: "wellness"
            )
        ]
    }
    
    private func generateAllInsights() -> [CalendarInsight] {
        return generateProductivityInsights() + generateTimeManagementInsights()
    }
    
    private func getEventsInTimeRange() -> [CalendarEvent] {
        let calendar = Calendar.current
        let now = Date()
        let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        
        return events.filter { event in
            event.date >= oneMonthAgo && event.date <= now
        }
    }
    
    private func isWorkEvent(_ event: CalendarEvent) -> Bool {
        let workKeywords = ["work", "job", "office", "meeting", "shift", "conference", "client", "project", "team", "department", "company"]
        let title = event.title.lowercased()
        let location = event.location.lowercased()
        let notes = event.notes.lowercased()
        
        return workKeywords.contains { keyword in
            title.contains(keyword) || location.contains(keyword) || notes.contains(keyword)
        }
    }
    
    private func generateProductivityInsights() -> [CalendarInsight] {
        var insights: [CalendarInsight] = []
        
        let eventsInRange = getEventsInTimeRange()
        guard !eventsInRange.isEmpty else {
            return [getNoDataInsight(for: .productivity)]
        }
        
        let workEvents = eventsInRange.filter { isWorkEvent($0) }
        let totalEvents = eventsInRange.count
        
        if workEvents.count > totalEvents / 2 {
            insights.append(CalendarInsight(
                
                category: .productivity,
                title: "High Work Focus",
                description: "You have \(workEvents.count) work-related events out of \(totalEvents) total events. Your schedule is work-focused.",
                impact: .positive,
                priority: .medium,
                suggestion: "Consider scheduling more personal time to maintain work-life balance.",
                metricValue: "\(Int(Double(workEvents.count) / Double(totalEvents) * 100))%"
            ))
        }
        
        let morningEvents = eventsInRange.filter { Calendar.current.component(.hour, from: $0.date) < 12 }
        if !morningEvents.isEmpty {
            insights.append(CalendarInsight(
                
                category: .productivity,
                title: "Morning Activity",
                description: "You had \(morningEvents.count) events in the morning.",
                impact: .positive,
                priority: .low,
                suggestion: "Keep building healthy morning routines for higher productivity.",
                metricValue: "\(morningEvents.count)"
            ))
        }
        
        // Add a fallback if no major insight exists
        if insights.isEmpty {
            insights.append(CalendarInsight(
                
                category: .productivity,
                title: "Keep Logging Events",
                description: "Not enough data for a personalized productivity summary.",
                impact: .neutral,
                priority: .low,
                suggestion: "Add more events and come back tomorrow!",
                metricValue: "—"
            ))
        }
        
        return insights
    }
    
    private func generateTimeManagementInsights() -> [CalendarInsight] {
        // Add implementation here
        return []
    }
    
    // Dummy stub implementations for other categories for now
    private func generatePatternInsights() -> [CalendarInsight] {
        return [getNoDataInsight(for: .patterns)]
    }
    private func generateOptimizationInsights() -> [CalendarInsight] {
        return [getNoDataInsight(for: .optimization)]
    }
    private func generateWellnessInsights() -> [CalendarInsight] {
        return [getNoDataInsight(for: .wellness)]
    }
    
    private func getNoDataInsight(for cat: CalendarInsightCategory) -> CalendarInsight {
        return CalendarInsight(
            
            category: cat,
            title: "Not Enough Data",
            description: "Log more events to unlock meaningful insights.",
            impact: .neutral,
            priority: .low,
            suggestion: "Keep logging your schedule for deeper analysis.",
            metricValue: "—"
        )
    }
}
