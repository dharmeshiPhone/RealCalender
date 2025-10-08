import SwiftUI

// MARK: - Dashboard View Sections
struct GreetingAndQuoteSection: View {
    let userProfile: UserProfile
    let todaysQuote: (quote: String, author: String)
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hi, \(userProfile.name)")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "quote.opening")
                            .font(.title3)
                            .foregroundColor(.blue)
                       
                        VStack(alignment: .leading, spacing: 6) {
                            Text(todaysQuote.quote)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .italic()
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                           
                            Text("- \(todaysQuote.author)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Spacer()
            }
            
            HStack {
                Text("Level \(userProfile.level)")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    let XprequriedToComplteLevel = UserProfile.xpRequiredForLevel(userProfile.level)// + 1
                    Text("XP: \(Int(userProfile.xp)) / \(Int(XprequriedToComplteLevel))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    let progress = Double(userProfile.xp) / Double(XprequriedToComplteLevel)
                    ProgressView(value: progress)//userProfile.progressToNextLevel
                        .frame(width: 100)
                        .tint(.blue)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

struct FirstTimeSetupSection: View {
    @AppStorage("basicCalenderSetupStepsCompleted") private var completedSteps = 0
    let userProfile: UserProfile
    let hasCompletedSetup: Bool
    let eventsEmpty: Bool
    let onSetupTapped: () -> Void
    
    var body: some View {
        if !hasCompletedSetup {
            VStack(spacing: 20) {
                // Enhanced header with animation
                HStack {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.title)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("🗓️ Set Up Your Schedule")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                
                                Text("Unlock your interactive calendar")
                                    .font(.caption)
                                    .foregroundColor(.blue.opacity(0.8))
                            }
                        }
                        
                        Text("Add your high school, university, or work schedule to unlock the zoomable calendar and start tracking your productivity!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineLimit(nil)
                    }
                    
                    Spacer()
                    
                    // Setup progress indicator
                    VStack(spacing: 6) {
                        ZStack {
                            let totalSteps = 4.0
                            let progress = max(0.0, min(Double(completedSteps) / totalSteps, 1.0))
                            Circle()
                                .stroke(Color.blue.opacity(0.2), lineWidth: 3)
                                .frame(width: 50, height: 50)
                            
                            Circle()
                                .trim(from: 0, to: progress) // 0% complete
                                .stroke(Color.blue, lineWidth: 3)
                                .frame(width: 50, height: 50)
                                .rotationEffect(.degrees(-90))
                            
                            Text("\(Int(progress  * 100))%")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        
                        Text("Setup")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Enhanced call-to-action button
                Button("📅 Set Up My Calendar Now") {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    onSetupTapped()
                }
                .buttonStyle(.plain)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                
                // Benefits list
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Interactive zoomable calendar views")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Smart travel time calculations")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Achievement system and progress tracking")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                }
                .padding(.horizontal, 8)
                
                Text("I'll help you add your daily schedule and set up automatic wake-up times! 🚀")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
            .padding(20)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .blue.opacity(0.1),
                        .purple.opacity(0.1),
                        .blue.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue.opacity(0.4), .purple.opacity(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: .blue.opacity(0.1), radius: 10, x: 0, y: 5)
        }
    }
}

struct AIOverviewSection: View {
    let onCalendarReview: () -> Void
    let onDailySummary: () -> Void
    let onMonthlyReport: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🤖 AI Overview")
                .font(.title2)
                .fontWeight(.bold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    OverviewCard(
                        title: "Review Calendar",
                        icon: "calendar.badge.clock",
                        color: .purple,
                        description: "View all events with times"
                    ) {
                        onCalendarReview()
                    }
                    
                    OverviewCard(
                        title: "Daily Summary",
                        icon: "sun.max.fill",
                        color: .orange,
                        description: "End of day insights"
                    ) {
                        onDailySummary()
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct CalendarSection: View {
    @Binding var selectedDate: Date
    let eventsForSelectedDate: [CalendarEvent]
    let onAddEvent: () -> Void
    let onCalendarReview: () -> Void
    let trackCalendarUsage: () -> Void
    @State private var allEvents: [CalendarEvent] = []
    
    // Check if calendar setup is completed
    private var hasCompletedSetup: Bool {
        UserDefaults.hasCompletedCalendarSetup
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("📅 Your Calendar")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                if hasCompletedSetup {
                    Button("Review All") {
                        onCalendarReview()
                        trackCalendarUsage()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            
            // Conditional calendar display based on setup completion
            if hasCompletedSetup {
                // Show the interactive calendar with finger tracking after setup
                InteractiveCalendarView(selectedDate: $selectedDate, events: allEvents)
                    .frame(height: 400)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 4)
                    .onChange(of: selectedDate) { _, _ in
                        trackCalendarUsage()
                    }
                
                // Quick stats section
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Today's Events")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(eventsForSelectedDate.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("This Week")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(weekEventCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    Button(action: {
                        onAddEvent()
                        trackCalendarUsage()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                }
            } else {
                // Show setup reminder before calendar is available
                calendarSetupPrompt
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("EventsModified"))) { _ in
            loadAllEvents()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CalendarSetupCompleted"))) { _ in
            // Reload events when setup is completed
            loadAllEvents()
        }
        .onAppear {
            if hasCompletedSetup {
                loadAllEvents()
            }
        }
    }
    
    // MARK: - Calendar Setup Prompt
    private var calendarSetupPrompt: some View {
        VStack(spacing: 20) {
            // Main setup illustration
            VStack(spacing: 16) {
                ZStack {
                    // Background circles for visual depth
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    // Calendar icon
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(.blue)
                }
                
                VStack(spacing: 12) {
                    Text("Calendar Setup Required")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Complete your calendar setup to unlock the interactive calendar with finger tracking animations")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
            }
            
            // Features preview
            VStack(spacing: 12) {
                Text("What you'll get:")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                VStack(spacing: 8) {
                    featureRow(
                        icon: "hand.tap.fill",
                        title: "Interactive Touch",
                        description: "Tap and drag to highlight days with smooth animations"
                    )
                    
                    featureRow(
                        icon: "calendar.day.timeline.left",
                        title: "Smart Highlighting",
                        description: "Adjacent days light up as you touch the calendar"
                    )
                    
                    featureRow(
                        icon: "chart.bar.fill",
                        title: "Smart Analytics",
                        description: "Track your calendar usage and productivity"
                    )
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Call to action
            VStack(spacing: 8) {
                Text("🎯 Ready to get started?")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                
                Text("Tap the setup button above to add your schedule")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.05),
                    Color.purple.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Feature Row Helper
    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    private var weekEventCount: Int {
        let calendar = Calendar.current
        let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date())!
        
        return allEvents.filter { event in
            weekInterval.contains(event.date)
        }.count
    }
    
    private func loadAllEvents() {
        // Load events from UserDefaults to pass to InteractiveCalendarView
        if let data = UserDefaults.standard.data(forKey: "calendarEvents"),
           let events = try? JSONDecoder().decode([CalendarEvent].self, from: data) {
            allEvents = events
        }
    }
}

struct ScreenshotAnalysisSection: View {
    let trackCalendarUsage: () -> Void
    @EnvironmentObject var aiChatManager: AIChatManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("AI Text Analysis")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("?") {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    aiChatManager.sendMessage("I want to analyze a screenshot to create calendar events. Please guide me through the process.")
                    trackCalendarUsage()
                }
                .frame(width: 24, height: 24)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Circle())
                .font(.caption)
                .fontWeight(.bold)
            }
            
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "camera.viewfinder")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading) {
                        Text("Screenshot Analysis")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Take a screenshot of any appointment or event and AI will analyze it to create calendar events automatically")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                Button("Analyze Screenshot") {
                    // Analysis logic goes here
                    trackCalendarUsage()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Perfect for:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text("Email invitations")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "message.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text("Text messages with dates")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("Meeting documents")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
}

struct ProgressStatsSection: View {
    let userProfile: UserProfile
    let screenTimeManager: ScreenTimeManager
    let achievementManager: AchievementManager
    let calculateBMI: () -> Double
    let getBMIColor: () -> Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Progress")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                NavigationLink(destination: UserStatsView(profile: .constant(userProfile))) {
                    HStack(spacing: 16) {
                        // Icon circle
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.15))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "chart.bar.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        
                        // Content
                        VStack(alignment: .leading, spacing: 6) {
                            Text("📊 Performance Analytics")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("See detailed analytics and comparisons")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Age-adjusted normal distributions")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .fontWeight(.medium)
                        }
                        
                        Spacer(minLength: 0)
                        
                        // Arrow
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color(.systemGray4), radius: 4, x: 0, y: 2)
                    )
                }
                .buttonStyle(.plain)
            }
            
            VStack(spacing: 8) {
                Text("Level Up Testing")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                
                HStack(spacing: 8) {
                    Button("Add Progress (+1)") {
                        print("📊 Manual progress button tapped")
                        achievementManager.updateCalendarProgress()
                        print("📊 Manual calendar progress added from Dashboard")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .font(.caption)
                    
                    Button("Complete Calendar Setup") {
                        print("📊 Manual completion button tapped")
                        achievementManager.completeCalendarSetup()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .font(.caption)
                    .foregroundColor(.orange)
        
                    Button("🔥 DIRECT TEST") {
                        print("🔥 Direct test button - bypassing everything")
                        DispatchQueue.main.async {
                            let directTestAchievement = Achievement(
                                title: "Direct Test",
                                description: "Direct test",
                                icon: "star.fill",
                                unlockedDate: Date(),
                                category: .calendar,
                                level: 2,
                                currentProgress: 0,
                                maxProgress: 3
                            )
                            
                            NotificationCenter.default.post(
                                name: NSNotification.Name("AchievementLevelUp"),
                                object: directTestAchievement
                            )
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .font(.caption)
                    .foregroundColor(.red)
                    
                    if let achievement = achievementManager.getCalendarAchievement() {
                        Text("L\(achievement.level) • \(achievement.currentProgress)/\(achievement.maxProgress)")
                            .font(.caption2)
                            .foregroundColor(.green)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                StatCard(
                    icon: "calendar.badge.plus",
                    title: "Events Created",
                    value: "127",
                    color: .blue
                )
                
                StatCard(
                    icon: "clock.badge.checkmark",
                    title: "On Time",
                    value: "94%",
                    color: .green
                )
                
                StatCard(
                    icon: "star.fill",
                    title: "Streak",
                    value: "12 days",
                    color: .yellow
                )
                
                StatCard(
                    icon: "trophy.fill",
                    title: "Achievements",
                    value: "8",
                    color: .orange
                )
                
                StatCard(
                    icon: "iphone",
                    title: "Screen Time",
                    value: "\(screenTimeManager.getTotalUsageToday()) min",
                    color: .purple
                )
                
                StatCard(
                    icon: "figure.walk",
                    title: "BMI",
                    value: String(format: "%.1f", calculateBMI()),
                    color: getBMIColor()
                )
            }
        }
    }
}
