import SwiftUI

struct InsightsView: View {
    @Binding var events: [CalendarEvent]
    @EnvironmentObject var aiChatManager: AIChatManager
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @State private var insights: [ScheduleInsight] = []
    @State private var isGeneratingInsights = false
    @State private var selectedInsight: ScheduleInsight?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    
                    if isGeneratingInsights {
                        generatingInsightsSection
                    } else if insights.isEmpty && !events.isEmpty {
                        noInsightsSection
                    } else if events.isEmpty {
                        emptyStateSection
                    } else {
                        insightsListSection
                    }
                    
                    aiInsightsSection
                }
                .padding()
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Generate") {
                        generateInsights()
                    }
                    .disabled(isGeneratingInsights || events.isEmpty)
                }
            }
            .onAppear {
                generateInsights()
            }
            .sheet(item: $selectedInsight) { insight in
                InsightDetailView(insight: insight, events: $events)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Smart Insights")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("AI-powered schedule optimization")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Insights status indicator
                ZStack {
                    Circle()
                        .fill(insightStatusColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "lightbulb.fill")
                        .font(.title2)
                        .foregroundColor(insightStatusColor)
                }
            }
            
            // Quick stats
            HStack(spacing: 16) {
                InsightStat(
                    title: "Insights",
                    value: "\(insights.count)",
                    color: .blue
                )
                
                InsightStat(
                    title: "Recommendations",
                    value: "\(recommendationCount)",
                    color: .green
                )
                
                InsightStat(
                    title: "Optimizations",
                    value: "\(optimizationCount)",
                    color: .purple
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var generatingInsightsSection: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Analyzing your schedule...")
                .font(.headline)
                .fontWeight(.medium)
            
            Text("Our AI is finding patterns and optimization opportunities")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var emptyStateSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Events to Analyze")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Add some events to your calendar to get personalized insights and recommendations.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var noInsightsSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Your Schedule Looks Optimal!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            Text("We couldn't find any major optimization opportunities. Your schedule appears well-balanced.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Analyze Again") {
                generateInsights()
            }
            .buttonStyle(.bordered)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var insightsListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Found \(insights.count) Insight\(insights.count == 1 ? "" : "s")")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVStack(spacing: 12) {
                ForEach(insights, id: \.id) { insight in
                    InsightRowView(insight: insight) {
                        selectedInsight = insight
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var aiInsightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AI-Powered Recommendations")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVStack(spacing: 12) {
                AIInsightCard(
                    icon: "brain.head.profile",
                    title: "Productivity Patterns",
                    description: productivityPattern,
                    color: .blue
                )
                
                AIInsightCard(
                    icon: "clock.arrow.circlepath",
                    title: "Time Optimization",
                    description: timeOptimization,
                    color: .green
                )
                
                AIInsightCard(
                    icon: "figure.walk",
                    title: "Energy Management",
                    description: energyManagement,
                    color: .orange
                )
                
                AIInsightCard(
                    icon: "target",
                    title: "Goal Alignment",
                    description: goalAlignment,
                    color: .purple
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
    
    private var insightStatusColor: Color {
        if insights.isEmpty {
            return .gray
        } else if insights.contains(where: { $0.priority == .high }) {
            return .red
        } else {
            return .blue
        }
    }
    
    private var recommendationCount: Int {
        insights.filter { $0.type == .recommendation }.count
    }
    
    private var optimizationCount: Int {
        insights.filter { $0.type == .optimization }.count
    }
    
    private var productivityPattern: String {
        let morningEvents = events.filter { Calendar.current.component(.hour, from: $0.date) < 12 }.count
        let afternoonEvents = events.filter { 
            let hour = Calendar.current.component(.hour, from: $0.date)
            return hour >= 12 && hour < 18 
        }.count
        let eveningEvents = events.filter { Calendar.current.component(.hour, from: $0.date) >= 18 }.count
        
        if morningEvents > afternoonEvents && morningEvents > eveningEvents {
            return "You're most active in the mornings. Consider scheduling important tasks early."
        } else if afternoonEvents > morningEvents && afternoonEvents > eveningEvents {
            return "You prefer afternoon activities. Your energy peaks after lunch."
        } else if eveningEvents > morningEvents && eveningEvents > afternoonEvents {
            return "You're a night owl! Most of your events are scheduled in the evening."
        } else {
            return "You have a balanced schedule throughout the day."
        }
    }
    
    private var timeOptimization: String {
        let avgGapBetweenEvents = calculateAverageGapBetweenEvents()
        
        if avgGapBetweenEvents < 30 {
            return "Your events are tightly packed. Consider adding buffer time between activities."
        } else if avgGapBetweenEvents > 120 {
            return "You have large gaps between events. Consider consolidating similar activities."
        } else {
            return "Your time spacing looks well-optimized with good buffer periods."
        }
    }
    
    private var energyManagement: String {
        let hasBreaks = events.contains { $0.title.lowercased().contains("break") || $0.title.lowercased().contains("lunch") }
        let consecutiveMeetings = countConsecutiveMeetings()
        
        if !hasBreaks && consecutiveMeetings > 3 {
            return "Schedule regular breaks to maintain energy and focus throughout the day."
        } else if hasBreaks {
            return "Great job including breaks! This helps maintain productivity and well-being."
        } else {
            return "Consider your energy levels when scheduling demanding activities."
        }
    }
    
    private var goalAlignment: String {
        let workEvents = events.filter { 
            $0.title.lowercased().contains("work") || 
            $0.title.lowercased().contains("meeting") ||
            $0.title.lowercased().contains("project")
        }.count
        
        let personalEvents = events.filter {
            $0.title.lowercased().contains("personal") ||
            $0.title.lowercased().contains("exercise") ||
            $0.title.lowercased().contains("hobby")
        }.count
        
        let workToPersonalRatio = Double(workEvents) / max(Double(personalEvents), 1)
        
        if workToPersonalRatio > 3 {
            return "Consider adding more personal time to maintain work-life balance."
        } else if workToPersonalRatio < 0.5 {
            return "Good balance! You're prioritizing personal time alongside work commitments."
        } else {
            return "Your work-life balance appears healthy and sustainable."
        }
    }
    
    // MARK: - Helper Functions
    
    private func generateInsights() {
        guard !events.isEmpty else {
            insights = []
            return
        }
        
        isGeneratingInsights = true
        insights = []
        
        DispatchQueue.global(qos: .userInitiated).async {
            let generatedInsights = self.analyzeScheduleForInsights()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.insights = generatedInsights
                self.isGeneratingInsights = false
            }
        }
    }
    
    private func analyzeScheduleForInsights() -> [ScheduleInsight] {
        var generatedInsights: [ScheduleInsight] = []
        
        // Analyze time gaps
        let avgGap = calculateAverageGapBetweenEvents()
        if avgGap < 15 {
            generatedInsights.append(ScheduleInsight(
                id: UUID(),
                type: .optimization,
                priority: .high,
                title: "Add Buffer Time",
                description: "Your events are very tightly scheduled. Consider adding 15-30 minute buffers between activities.",
                impact: "Reduces stress and allows for unexpected delays",
                actionItems: [
                    "Extend transition time between meetings",
                    "Schedule buffer blocks in your calendar",
                    "Avoid back-to-back scheduling when possible"
                ]
            ))
        }
        
        // Analyze productivity patterns
        let morningEvents = events.filter { Calendar.current.component(.hour, from: $0.date) < 12 }.count
        let afternoonEvents = events.filter { 
            let hour = Calendar.current.component(.hour, from: $0.date)
            return hour >= 12 && hour < 18 
        }.count
        
        if morningEvents < 2 && afternoonEvents > 5 {
            generatedInsights.append(ScheduleInsight(
                id: UUID(),
                type: .recommendation,
                priority: .medium,
                title: "Leverage Morning Hours",
                description: "You have few morning commitments. Consider scheduling important tasks during peak morning energy.",
                impact: "Improved focus and productivity for high-priority work",
                actionItems: [
                    "Schedule challenging tasks between 9-11 AM",
                    "Use mornings for deep work sessions",
                    "Reserve afternoons for meetings and collaboration"
                ]
            ))
        }
        
        // Check for work-life balance
        let workKeywords = ["work", "meeting", "project", "call", "conference"]
        let personalKeywords = ["gym", "exercise", "personal", "hobby", "family", "friend"]
        
        let workEvents = events.filter { event in
            workKeywords.contains { event.title.lowercased().contains($0) }
        }.count
        
        let personalEvents = events.filter { event in
            personalKeywords.contains { event.title.lowercased().contains($0) }
        }.count
        
        if workEvents > personalEvents * 3 {
            generatedInsights.append(ScheduleInsight(
                id: UUID(),
                type: .recommendation,
                priority: .high,
                title: "Improve Work-Life Balance",
                description: "Your schedule is heavily work-focused. Adding personal time can improve overall well-being.",
                impact: "Better mental health and sustainable productivity",
                actionItems: [
                    "Block time for personal activities",
                    "Schedule regular exercise or hobbies",
                    "Set boundaries for work hours"
                ]
            ))
        }
        
        // Check for travel time issues
        let locationChanges = countLocationChanges()
        if locationChanges > events.count / 2 {
            generatedInsights.append(ScheduleInsight(
                id: UUID(),
                type: .optimization,
                priority: .medium,
                title: "Minimize Location Changes",
                description: "You have many location changes throughout the day. Grouping activities by location could save time.",
                impact: "Reduced travel time and stress",
                actionItems: [
                    "Group activities by location when possible",
                    "Use video calls to reduce travel",
                    "Plan efficient routes between locations"
                ]
            ))
        }
        
        return generatedInsights
    }
    
    private func calculateAverageGapBetweenEvents() -> Double {
        let sortedEvents = events.sorted { $0.date < $1.date }
        guard sortedEvents.count > 1 else { return 60 }
        
        var totalGap: TimeInterval = 0
        for i in 0..<(sortedEvents.count - 1) {
            let gap = sortedEvents[i + 1].date.timeIntervalSince(sortedEvents[i].date)
            totalGap += gap
        }
        
        return totalGap / Double(sortedEvents.count - 1) / 60 // Return in minutes
    }
    
    private func countConsecutiveMeetings() -> Int {
        let sortedEvents = events.sorted { $0.date < $1.date }
        var maxConsecutive = 0
        var currentConsecutive = 1
        
        for i in 1..<sortedEvents.count {
            let timeBetween = sortedEvents[i].date.timeIntervalSince(sortedEvents[i-1].date)
            if timeBetween <= 3600 { // Within 1 hour
                currentConsecutive += 1
            } else {
                maxConsecutive = max(maxConsecutive, currentConsecutive)
                currentConsecutive = 1
            }
        }
        
        return max(maxConsecutive, currentConsecutive)
    }
    
    private func countLocationChanges() -> Int {
        let sortedEvents = events.sorted { $0.date < $1.date }
        guard sortedEvents.count > 1 else { return 0 }
        
        var changes = 0
        for i in 1..<sortedEvents.count {
            if sortedEvents[i].location != sortedEvents[i-1].location && 
               !sortedEvents[i].location.isEmpty && 
               !sortedEvents[i-1].location.isEmpty {
                changes += 1
            }
        }
        
        return changes
    }
}

// MARK: - Supporting Views

struct InsightRowView: View {
    let insight: ScheduleInsight
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Priority indicator
                ZStack {
                    Circle()
                        .fill(insight.priority.color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: insight.type.icon)
                        .font(.system(size: 18))
                        .foregroundColor(insight.priority.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(insight.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(insight.priority.displayName)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(insight.priority.color)
                            )
                    }
                    
                    Text(insight.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct InsightStat: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }
}

struct AIInsightCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
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

// MARK: - Preview
#Preview {
    InsightsView(events: .constant([
        CalendarEvent(
            title: "Morning Meeting",
            date: Date(),
            notes: "Team standup",
            color: .blue,
            location: "Office",
            isRespond: false,
            isCompleted: false
        ),
        CalendarEvent(
            title: "Project Work",
            date: Date().addingTimeInterval(900), // 15 minutes later
            notes: "Development tasks",
            color: .green,
            location: "Office",
            isRespond: false,
            isCompleted: false
        )
    ]))
    .environmentObject(AIChatManager())
    .environmentObject(ScreenTimeManager())
}
