import SwiftUI

// MARK: - Insights Tab View
struct InsightsTabView: View {
    let events: [CalendarEvent]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if events.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "lightbulb.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No Events to Analyze")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Add some events to your calendar to get personalized insights and AI recommendations!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                } else {
                    // Schedule Health Score
                    VStack(alignment: .leading, spacing: 12) {
                        Text("📊 Schedule Health Score")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        let healthScore = calculateScheduleHealthScore()
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("\(Int(healthScore))%")
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundColor(getHealthScoreColor(healthScore))
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(getHealthScoreLabel(healthScore))
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(getHealthScoreColor(healthScore))
                                    
                                    Text("Schedule Health")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            ProgressView(value: healthScore / 100)
                                .tint(getHealthScoreColor(healthScore))
                                .scaleEffect(y: 2)
                        }
                        .padding()
                        .background(getHealthScoreColor(healthScore).opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Productivity insights
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🎯 Schedule Insights")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            VStack(spacing: 12) {
                                SharedInsightCard(
                                    title: "Peak Activity Time",
                                    description: getBusiestTimeInsight(),
                                    icon: "clock.fill",
                                    color: .blue
                                )
                                
                                SharedInsightCard(
                                    title: "Work-Life Balance",
                                    description: getBalanceInsight(),
                                    icon: "calendar.badge.checkmark",
                                    color: .green
                                )
                                
                                SharedInsightCard(
                                    title: "Scheduling Pattern",
                                    description: getSchedulePatternInsight(),
                                    icon: "calendar.circle.fill",
                                    color: .orange
                                )
                                
                                SharedInsightCard(
                                    title: "Free Time",
                                    description: getFreeTimeInsight(),
                                    icon: "clock.arrow.circlepath",
                                    color: .purple
                                )
                                
                                SharedInsightCard(
                                    title: "Productivity Peak",
                                    description: getProductivityInsight(),
                                    icon: "chart.line.uptrend.xyaxis",
                                    color: .red
                                )
                            }
                        }
                    }
                    
                    // Time utilization breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        Text("⏰ Time Utilization")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        let timeBreakdown = getTimeUtilizationBreakdown()
                        
                        VStack(spacing: 8) {
                            ForEach(timeBreakdown.sorted(by: { $0.value > $1.value }), id: \.key) { category, percentage in
                                HStack {
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(getCategoryColor(category))
                                            .frame(width: 12, height: 12)
                                        
                                        Text(category)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(Int(percentage))%")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.blue)
                                    
                                    Rectangle()
                                        .fill(getCategoryColor(category))
                                        .frame(width: max(CGFloat(percentage) * 2, 4), height: 8)
                                        .cornerRadius(4)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                    
                    // AI recommendations
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🤖 AI Recommendations")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 8) {
                            ForEach(getSmartRecommendations(), id: \.self) { recommendation in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(.yellow)
                                        .font(.title3)
                                    
                                    Text(recommendation)
                                        .font(.body)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color.yellow.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                    }
                    
                    // Schedule optimization tips
                    VStack(alignment: .leading, spacing: 12) {
                        Text("💡 Optimization Tips")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 8) {
                            ForEach(getOptimizationTips(), id: \.self) { tip in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.orange)
                                        .font(.caption)
                                    
                                    Text(tip)
                                        .font(.subheadline)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Helper Functions
    
    private func calculateScheduleHealthScore() -> Double {
        guard !events.isEmpty else { return 0 }
        
        var score: Double = 0
        let maxScore: Double = 100
        
        // Factor 1: Event distribution (25 points)
        let uniqueDays = Set(events.map { Calendar.current.startOfDay(for: $0.date) }).count
        let distributionScore = min(Double(uniqueDays) / 7.0 * 25, 25)
        score += distributionScore
        
        // Factor 2: Work-life balance (25 points)
        let workEvents = events.filter { !isBreakEvent($0) }
        let breakEvents = events.filter { isBreakEvent($0) }
        let balanceRatio = Double(breakEvents.count) / Double(max(workEvents.count, 1))
        let balanceScore = min(balanceRatio * 100, 25)
        score += balanceScore
        
        // Factor 3: Schedule conflicts (25 points)
        let conflicts = getConflictCount()
        let conflictScore = max(25 - Double(conflicts) * 5, 0)
        score += conflictScore
        
        // Factor 4: Schedule variety (25 points)
        let categories = Set(events.map { extractEventCategory(from: $0) }).count
        let varietyScore = min(Double(categories) / 5.0 * 25, 25)
        score += varietyScore
        
        return min(score, maxScore)
    }
    
    private func getHealthScoreColor(_ score: Double) -> Color {
        switch score {
        case 80...100: return .green
        case 60..<80: return .orange
        case 40..<60: return .yellow
        default: return .red
        }
    }
    
    private func getHealthScoreLabel(_ score: Double) -> String {
        switch score {
        case 80...100: return "Excellent"
        case 60..<80: return "Good"
        case 40..<60: return "Fair"
        default: return "Needs Work"
        }
    }
    
    private func getTimeUtilizationBreakdown() -> [String: Double] {
        guard !events.isEmpty else { return [:] }
        
        let categoryGroups = Dictionary(grouping: events) { event in
            extractEventCategory(from: event)
        }
        
        let totalEvents = Double(events.count)
        
        return categoryGroups.mapValues { eventGroup in
            (Double(eventGroup.count) / totalEvents) * 100
        }
    }
    
    private func getBusiestTimeInsight() -> String {
        guard !events.isEmpty else { return "No events to analyze." }
        
        let hourCounts = Dictionary(grouping: events) { event in
            Calendar.current.component(.hour, from: event.date)
        }.mapValues { $0.count }
        
        guard let busiestHour = hourCounts.max(by: { $0.value < $1.value }) else {
            return "Unable to determine busiest time."
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        
        let hourString = formatter.string(from: Calendar.current.date(bySettingHour: busiestHour.key, minute: 0, second: 0, of: Date()) ?? Date())
        
        return "Your peak activity time is around \(hourString) with \(busiestHour.value) events. Consider scheduling important tasks during this time."
    }
    
    private func getBalanceInsight() -> String {
        guard !events.isEmpty else { return "No events to analyze." }
        
        let workEvents = events.filter { !isBreakEvent($0) }
        let breakEvents = events.filter { isBreakEvent($0) }
        
        let ratio = Double(breakEvents.count) / Double(max(workEvents.count, 1))
        
        if breakEvents.isEmpty {
            return "You have no breaks scheduled. Consider adding some downtime for better productivity and well-being."
        } else if ratio < 0.15 {
            return "Your schedule is quite packed with only \(breakEvents.count) breaks for \(workEvents.count) work events. Consider adding more buffer time."
        } else if ratio > 0.4 {
            return "Great balance! You have adequate break time with \(breakEvents.count) breaks for \(workEvents.count) work events."
        } else {
            return "Good work-life balance with a healthy ratio of breaks to work events."
        }
    }
    
    private func getSchedulePatternInsight() -> String {
        guard !events.isEmpty else { return "No events to analyze." }
        
        let weekdayEvents = events.filter { !Calendar.current.isDateInWeekend($0.date) }
        let weekendEvents = events.filter { Calendar.current.isDateInWeekend($0.date) }
        
        if weekendEvents.isEmpty {
            return "You keep weekends completely free - excellent for work-life balance and recharging!"
        } else if weekendEvents.count > weekdayEvents.count / 2 {
            return "Your weekends are quite busy with \(weekendEvents.count) events. Consider reserving some weekend time for relaxation."
        } else {
            return "Good balance with \(weekdayEvents.count) weekday events and \(weekendEvents.count) weekend activities."
        }
    }
    
    private func getFreeTimeInsight() -> String {
        guard !events.isEmpty else { return "No events to analyze." }
        
        let calendar = Calendar.current
        let uniqueDays = Set(events.map { calendar.startOfDay(for: $0.date) })
        let averageEventsPerDay = Double(events.count) / Double(uniqueDays.count)
        
        if averageEventsPerDay > 8 {
            return "High schedule density with \(String(format: "%.1f", averageEventsPerDay)) events per day. Consider consolidating or spacing out activities."
        } else if averageEventsPerDay > 5 {
            return "Moderate schedule density with \(String(format: "%.1f", averageEventsPerDay)) events per day. Good balance of activity and flexibility."
        } else if averageEventsPerDay > 2 {
            return "Light schedule density with \(String(format: "%.1f", averageEventsPerDay)) events per day. Room for additional activities if desired."
        } else {
            return "Very light schedule with \(String(format: "%.1f", averageEventsPerDay)) events per day. Consider adding more structured activities."
        }
    }
    
    private func getProductivityInsight() -> String {
        let academicEvents = events.filter { isAcademicEvent($0) }
        let totalEvents = events.count
        
        guard totalEvents > 0 else { return "No events to analyze." }
        
        let academicPercentage = (Double(academicEvents.count) / Double(totalEvents)) * 100
        
        if academicPercentage > 70 {
            return "Strong academic focus with \(Int(academicPercentage))% of events being educational. Excellent dedication to learning!"
        } else if academicPercentage > 40 {
            return "Good learning balance with \(Int(academicPercentage))% academic events. Well-rounded schedule."
        } else if academicPercentage > 20 {
            return "Moderate learning focus at \(Int(academicPercentage))%. Consider adding more educational activities."
        } else {
            return "Limited academic focus at \(Int(academicPercentage))%. Consider incorporating more learning opportunities."
        }
    }
    
    private func getSmartRecommendations() -> [String] {
        var recommendations: [String] = []
        
        guard !events.isEmpty else {
            return ["Start by adding some events to your calendar to get personalized recommendations!"]
        }
        
        // Check for scheduling conflicts
        if getConflictCount() > 0 {
            recommendations.append("⚠️ You have scheduling conflicts. Review your calendar and adjust overlapping events.")
        }
        
        // Check for back-to-back events
        let sortedEvents = events.sorted { $0.date < $1.date }
        var hasBackToBack = false
        
        for i in 0..<sortedEvents.count-1 {
            let timeDiff = sortedEvents[i+1].date.timeIntervalSince(sortedEvents[i].date)
            if timeDiff < 900 { // Less than 15 minutes
                hasBackToBack = true
                break
            }
        }
        
        if hasBackToBack {
            recommendations.append("🕐 Add 15-minute buffers between events to reduce stress and allow for transitions.")
        }
        
        // Check for break balance
        let breakEvents = events.filter { isBreakEvent($0) }
        let workEvents = events.filter { !isBreakEvent($0) }
        let breakRatio = Double(breakEvents.count) / Double(max(workEvents.count, 1))
        
        if breakRatio < 0.15 {
            recommendations.append("😴 Schedule more breaks! Your current ratio is low - breaks boost productivity and prevent burnout.")
        }
        
        // Check for weekend balance
        let weekendEvents = events.filter { Calendar.current.isDateInWeekend($0.date) }
        if weekendEvents.count > events.count / 3 {
            recommendations.append("🏖️ Consider reducing weekend commitments to maintain better work-life balance.")
        }
        
        // Check for variety
        let categories = Set(events.map { extractEventCategory(from: $0) })
        if categories.count < 3 {
            recommendations.append("🎨 Add variety to your schedule with different types of activities for better engagement.")
        }
        
        // Check for early morning or late evening events
        let earlyEvents = events.filter { Calendar.current.component(.hour, from: $0.date) < 7 }
        let lateEvents = events.filter { Calendar.current.component(.hour, from: $0.date) > 21 }
        
        if !earlyEvents.isEmpty || !lateEvents.isEmpty {
            recommendations.append("🌅 You have very early or late events. Ensure you're maintaining healthy sleep patterns.")
        }
        
        if recommendations.isEmpty {
            recommendations.append("🎉 Your schedule looks well-balanced! Keep maintaining this healthy routine.")
        }
        
        return Array(recommendations.prefix(4)) // Limit to 4 recommendations
    }
    
    private func getOptimizationTips() -> [String] {
        return [
            "Color-code your events by category for better visual organization",
            "Set reminders 15 minutes before important events",
            "Block time for email and administrative tasks",
            "Schedule your most important work during your peak energy hours",
            "Keep Friday afternoons lighter for week wrap-up and planning",
            "Use travel time between locations productively (podcasts, calls)",
            "Batch similar activities together to reduce context switching"
        ]
    }
    
    private func getConflictCount() -> Int {
        var conflicts = 0
        
        for i in 0..<events.count {
            for j in (i+1)..<events.count {
                let event1 = events[i]
                let event2 = events[j]
                
                let calendar = Calendar.current
                if calendar.isDate(event1.date, inSameDayAs: event2.date) {
                    let timeDiff = abs(event1.date.timeIntervalSince(event2.date))
                    if timeDiff < 3600 { // Within 1 hour
                        conflicts += 1
                    }
                }
            }
        }
        
        return conflicts
    }
    
    private func isBreakEvent(_ event: CalendarEvent) -> Bool {
        let title = event.title.lowercased()
        return title.contains("lunch") || title.contains("break") || title.contains("rest") || 
               title.contains("free") || title.contains("recess")
    }
    
    private func isAcademicEvent(_ event: CalendarEvent) -> Bool {
        let title = event.title.lowercased()
        return title.contains("class") || title.contains("lecture") || title.contains("lab") ||
               title.contains("study") || title.contains("math") || title.contains("science") ||
               title.contains("english") || title.contains("history") || title.contains("physics") ||
               title.contains("chemistry") || title.contains("biology") || title.contains("course")
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
