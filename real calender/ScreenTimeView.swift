import SwiftUI

struct ScreenTimeView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dark mode background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color.gray.opacity(0.9),
                        Color.black
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        wellnessHeader
                        weeklyTrendSection
                        todaySummarySection
                        breakSummarySection
                        appUsageSection
                        wellnessActionsSection
                        infoSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Digital Wellness")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Wellness Header
    private var wellnessHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.pink)
                Text("Digital Wellness Coach")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Text("Smart suggestions to help you build healthier screen time habits")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.gray.opacity(0.3),
                    Color.gray.opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Weekly Trend Section
    private var weeklyTrendSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("📈 7-Day Wellness Trend")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                wellnessProgressIndicator
            }
            
            // Custom Line Chart
            let chartData = screenTimeManager.getWeeklyUsageData()
            ScreenTimeLineChart(data: chartData)
                .frame(height: 200)
            
            // Day labels
            dayLabelsRow
        }
        .padding()
        .background(
            Color.gray.opacity(0.1)
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var wellnessProgressIndicator: some View {
        let weeklyData = screenTimeManager.getWeeklyUsageData()
        let todayUsage = weeklyData.last ?? 0
        let yesterdayUsage = weeklyData.count > 1 ? weeklyData[weeklyData.count - 2] : 0
        let isImproving = todayUsage <= yesterdayUsage
        
        return HStack(spacing: 4) {
            Image(systemName: isImproving ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                .foregroundColor(isImproving ? .green : .orange)
            Text(isImproving ? "Improving" : "Trending Up")
                .font(.caption)
                .foregroundColor(isImproving ? .green : .orange)
        }
    }
    
    private var dayLabelsRow: some View {
        HStack {
            ForEach(0..<7, id: \.self) { index in
                Text(getDayLabel(for: index))
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    // MARK: - Today's Summary Section
    private var todaySummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📱 Today's Summary")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            todaySummaryContent
        }
        .padding()
        .background(
            Color.gray.opacity(0.1)
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var todaySummaryContent: some View {
        let totalMinutes = screenTimeManager.getTotalUsageToday()
        let goalMinutes = 120 // Suggested healthy limit
        let progress = min(Double(totalMinutes) / Double(goalMinutes), 1.0)
        let isHealthy = totalMinutes <= goalMinutes
        
        return HStack {
            VStack(alignment: .leading) {
                Text("Total Screen Time")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack(alignment: .bottom, spacing: 4) {
                    Text("\(totalMinutes)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(isHealthy ? .green : .orange)
                    
                    Text("min")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                
                Text("Suggested limit: \(goalMinutes) min")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            wellnessIndicator(progress: progress, isHealthy: isHealthy)
        }
    }
    
    private func wellnessIndicator(progress: Double, isHealthy: Bool) -> some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                .frame(width: 80, height: 80)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    isHealthy ? Color.green : Color.orange,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: progress)
            
            VStack(spacing: 2) {
                Image(systemName: isHealthy ? "heart.fill" : "exclamationmark.triangle.fill")
                    .font(.title3)
                    .foregroundColor(isHealthy ? .green : .orange)
                
                Text(isHealthy ? "Healthy" : "High")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(isHealthy ? .green : .orange)
            }
        }
    }
    
    // MARK: - Break Summary Section
    @ViewBuilder
    private var breakSummarySection: some View {
        if screenTimeManager.getBreaksToday() > 0 {
            VStack(alignment: .leading, spacing: 16) {
                Text("🌟 Today's Wellness Actions")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                breakSummaryContent
            }
            .padding()
            .background(
                Color.gray.opacity(0.1)
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    private var breakSummaryContent: some View {
        let totalBreaks = screenTimeManager.getBreaksToday()
        let totalBreakTime = screenTimeManager.getTotalBreakTime()
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Mindful Breaks")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack(alignment: .bottom, spacing: 4) {
                        Text("\(totalBreaks)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("today")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Rest Time")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack(alignment: .bottom, spacing: 4) {
                        Text("\(totalBreakTime)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("min")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                }
                
                // Wellness streak indicator
                VStack {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.green)
                    
                    Text("Mindful!")
                        .font(.caption)
                        .foregroundColor(.green)
                        .fontWeight(.bold)
                }
            }
            
            // Encouragement message
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                
                Text("Excellent! Taking breaks helps reduce eye strain and improves focus and creativity.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.top, 8)
        }
    }
    
    // MARK: - App Usage Section
    private var appUsageSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📊 App Usage Insights")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            appUsageContent
        }
        .padding()
        .background(
            Color.gray.opacity(0.1)
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private var appUsageContent: some View {
        if screenTimeManager.currentUsage.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Text("Generate Sample Data")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Get wellness insights with sample screen time data")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                Button("📈 Generate Wellness Report") {
                    screenTimeManager.generateMockData()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding()
        } else {
            ForEach(Array(screenTimeManager.currentUsage.sorted(by: { $0.value > $1.value })), id: \.key) { app, minutes in
                AppUsageRow(
                    appName: app,
                    minutes: minutes,
                    goal: screenTimeManager.dailyGoals[app],
                    isBlocked: screenTimeManager.suggestionsEnabled.contains(app),
                    icon: getAppIcon(for: app)
                )
            }
        }
    }
    
    // MARK: - Wellness Actions Section
    private var wellnessActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("💪 Wellness Actions")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ActionButton(
                    icon: "target",
                    title: "Set Goal",
                    color: .blue
                ) {
                    screenTimeManager.setGoal(for: "Instagram", minutes: 60)
                }
                
                ActionButton(
                    icon: "bell.fill",
                    title: "Reminder",
                    color: .orange
                ) {
                    screenTimeManager.sendNotification(
                        title: "🌟 Wellness Reminder",
                        body: "Remember to take breaks and stay mindful of your screen time!"
                    )
                }
                
                ActionButton(
                    icon: "heart.fill",
                    title: "Take Break",
                    color: .pink
                ) {
                    screenTimeManager.takeBreak(for: "Instagram")
                }
                
                ActionButton(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "View Insights",
                    color: .green
                ) {
                    screenTimeManager.sendNotification(
                        title: "📊 Wellness Insights",
                        body: "Your screen time trends are looking good! Keep up the mindful usage."
                    )
                }
            }
        }
        .padding()
        .background(
            Color.gray.opacity(0.1)
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Info Section
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("💡 About Digital Wellness")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 8) {
                infoRow(
                    icon: "lightbulb.fill",
                    color: .yellow,
                    text: "This feature provides gentle suggestions and reminders to help you build healthier screen time habits."
                )
                
                infoRow(
                    icon: "hand.raised.fill",
                    color: .blue,
                    text: "You're always in control - no apps are blocked, just helpful nudges when you might want to take a break."
                )
                
                infoRow(
                    icon: "heart.fill",
                    color: .pink,
                    text: "Focus on building awareness and making intentional choices about your device usage."
                )
            }
        }
        .padding()
        .background(
            Color.gray.opacity(0.1)
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func infoRow(icon: String, color: Color, text: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }

    // MARK: - Helper Functions
    private func getDayLabel(for index: Int) -> String {
        let calendar = Calendar.current
        let today = Date()
        let date = calendar.date(byAdding: .day, value: index - 6, to: today) ?? today
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private func getAppIcon(for appName: String) -> String {
        switch appName {
        case "Instagram": return "camera.fill"
        case "TikTok": return "music.note"
        case "Clash Royale": return "gamecontroller.fill"
        case "Safari": return "safari.fill"
        case "Messages": return "message.fill"
        case "Facebook": return "person.3.fill"
        case "YouTube": return "play.rectangle.fill"
        case "Twitter", "X": return "at"
        default: return "app.fill"
        }
    }
}

// MARK: - Custom Line Chart
struct ScreenTimeLineChart: View {
    let data: [Int]
    @State private var animationProgress: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let maxValue = data.max() ?? 1
            
            ZStack {
                // Background grid
                ForEach(0..<5, id: \.self) { index in
                    let y = height * CGFloat(index) / 4
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: width, y: y))
                    }
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                }
                
                // Goal line at 120 minutes
                let goalY = height - (height * CGFloat(120) / CGFloat(maxValue))
                Path { path in
                    path.move(to: CGPoint(x: 0, y: goalY))
                    path.addLine(to: CGPoint(x: width, y: goalY))
                }
                .stroke(Color.orange.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [5]))
                
                // Main line chart
                if data.count > 1 {
                    Path { path in
                        let points = data.enumerated().map { index, value in
                            let x = width * CGFloat(index) / CGFloat(data.count - 1)
                            let y = height - (height * CGFloat(value) / CGFloat(maxValue))
                            return CGPoint(x: x, y: y)
                        }
                        
                        path.move(to: points[0])
                        for i in 1..<points.count {
                            path.addLine(to: points[i])
                        }
                    }
                    .trim(from: 0, to: animationProgress)
                    .stroke(
                        LinearGradient(
                            colors: getGradientColors(),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .animation(.easeInOut(duration: 2.0), value: animationProgress)
                    
                    // Data points
                    ForEach(data.indices, id: \.self) { index in
                        let x = width * CGFloat(index) / CGFloat(data.count - 1)
                        let y = height - (height * CGFloat(data[index]) / CGFloat(maxValue))
                        let value = data[index]
                        let isOverGoal = value > 120
                        
                        Circle()
                            .fill(isOverGoal ? Color.red : Color.green)
                            .frame(width: 8, height: 8)
                            .position(x: x, y: y)
                            .scaleEffect(animationProgress > Double(index) / Double(data.count - 1) ? 1.0 : 0.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: animationProgress)
                    }
                }
            }
        }
        .onAppear {
            animationProgress = 1.0
        }
    }
    
    private func getGradientColors() -> [Color] {
        var colors: [Color] = []
        
        for i in 0..<data.count {
            let value = data[i]
            let previousValue = i > 0 ? data[i-1] : value
            
            if value > 120 {
                colors.append(.red)
            } else if value > previousValue {
                colors.append(.orange)
            } else {
                colors.append(.green)
            }
        }
        
        return colors.isEmpty ? [.blue] : colors
    }
}

// MARK: - App Usage Row
struct AppUsageRow: View {
    let appName: String
    let minutes: Int
    let goal: Int?
    let isBlocked: Bool
    let icon: String
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    
    var body: some View {
        HStack {
            // App icon
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(appName)
                    .font(.headline)
                    .foregroundColor(.white)
                
                if let goal = goal {
                    Text("Goal: \(goal) min")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Break reminder info for messaging apps
                if screenTimeManager.isMessagingApp(appName) {
                    if let breakStats = screenTimeManager.getBreakStats(for: appName) {
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text("\(breakStats.breaksToday)/3 breaks")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Usage bar and break controls
            VStack(alignment: .trailing) {
                if let goal = goal {
                    let progress = min(Double(minutes) / Double(goal), 1.0)
                    let isOverGoal = minutes > goal
                    
                    HStack(spacing: 4) {
                        Text("\(minutes)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(isOverGoal ? .red : .white)
                        Text("min")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    // Progress bar
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 60, height: 4)
                            .cornerRadius(2)
                        
                        Rectangle()
                            .fill(isOverGoal ? Color.red : Color.green)
                            .frame(width: 60 * progress, height: 4)
                            .cornerRadius(2)
                            .animation(.easeInOut(duration: 0.5), value: progress)
                    }
                    
                    // Break suggestion for messaging apps
                    if screenTimeManager.isMessagingApp(appName) && minutes >= 20 {
                        Button(action: {
                            screenTimeManager.takeBreak(for: appName)
                        }) {
                            HStack(spacing: 2) {
                                Image(systemName: "pause.circle.fill")
                                    .font(.caption)
                                Text("Take Break")
                                    .font(.caption)
                            }
                            .foregroundColor(.orange)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    if isBlocked {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.orange)
                            Text("Suggestions On")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                } else {
                    HStack(spacing: 4) {
                        Text("\(minutes)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("min")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    // Break suggestion for messaging apps without goals
                    if screenTimeManager.isMessagingApp(appName) && minutes >= 20 {
                        Button(action: {
                            screenTimeManager.takeBreak(for: appName)
                        }) {
                            HStack(spacing: 2) {
                                Image(systemName: "pause.circle.fill")
                                    .font(.caption)
                                Text("Break Time")
                                    .font(.caption)
                            }
                            .foregroundColor(.orange)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    if isBlocked {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.orange)
                            Text("Suggestions On")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}