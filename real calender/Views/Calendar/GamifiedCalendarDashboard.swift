import SwiftUI
import UIKit
import Combine

struct GamifiedCalendarDashboard: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @EnvironmentObject var aiChatManager: AIChatManager
    @EnvironmentObject var achievementManager: AchievementManager
    @EnvironmentObject var questManager: QuestManager
    
    @AppStorage("showGlowIcon") private var showGlowQuestIcon: Bool = false

    @Binding var events: [CalendarEvent]
    @Binding var selectedDate: Date
    @State private var currentStreak = 7
    @State private var weeklyGoal = 5
    @State private var userAge = 20
    @State private var selectedTab = 0
    @State private var showingAddEvent = false
    @State private var showingProfile = false
    @State private var showingFirstTimeSetup = false
    @State private var showingDailyOverview = false
    @State private var showingCalendarReview = false
    @State private var showingProfileDropdown = false
    @State private var userProfile: UserProfile = UserProfile.shared
    
    
    @State private var showCustomPopover = false
    @State private var openPetView = false
    
    // Daily inspirational quotes that rotate every 24 hours
    private let inspirationalQuotes = GamifiedCalendarDashboard.inspirationalQuotes
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                GreetingAndQuoteSection(
                    userProfile: userProfile,
                    todaysQuote: todaysQuote,
                    showQuote: questManager.currentBatch > 8
                )
                .onChange(of: UserProfile.shared.level, { _, new in
                    if new > 1{
                        loadUserProfile()
                    }
                    
                })
                .onReceive(NotificationCenter.default.publisher(for: .profileUpdated)) { notification in
                    if let updatedProfile = notification.object as? UserProfile {
                        userProfile = updatedProfile
                    }
                }
                
                FirstTimeSetupSection(
                    userProfile: userProfile,
                    hasCompletedSetup: UserDefaults.hasCompletedCalendarSetup,
                    eventsEmpty: events.isEmpty
                ) {
                    showingFirstTimeSetup = true
                }
                
                CalendarSection(
                    selectedDate: $selectedDate,
                    eventsForSelectedDate: eventsForSelectedDate,
                    onAddEvent: { showingAddEvent = true },
                    onCalendarReview: { showingCalendarReview = true },
                    trackCalendarUsage: trackCalendarUsage
                )
                
                AIOverviewSection(
                    currentBatch: questManager.currentBatch ,
                    onCalendarReview: { showingCalendarReview = true },
                    onDailySummary: {
                        showingDailyOverview = true
                        if questManager.currentBatch == 9{
                            questManager.completeQuestWithIncremnetForce(named: "Check Daily Summary from yesterday",num:1,Quebatch:9)
                        }
                        
                        if questManager.currentBatch == 17 {
                            questManager.completeQuestWithIncremnetForce(named: "Check Daily Summary",num:1,Quebatch:17)
                        }
                        
                        if questManager.currentBatch == 27 {
                            questManager.completeQuestWithIncremnetForce(named:"Check Daily Summary days in a row",num:1,Quebatch:27)
                        }
                        
                        if questManager.currentBatch == 29 {
                            questManager.completeQuestWithIncremnetForce(named:"Check Daily Summary",num:1,Quebatch:29)
                        }
                        
                        if questManager.currentBatch == 32 {
                            questManager.completeQuestWithIncremnetForce(named: "Check Daily Summary 14 days in a row",num:1,Quebatch:32)
                        }
                        
                        if questManager.currentBatch == 40 {
                            questManager.completeQuestWithIncremnetForce(named:"Check Daily Summary",num:1,Quebatch:40)
                        }
                        
                        // 🔥 Update streak every time user checks Daily Summary
                        questManager.updateDailySummaryStreak()
                    },
                    onMonthlyReport: { }
                )
                
                ScreenshotAnalysisSection(
                    trackCalendarUsage: trackCalendarUsage
                )
                
                ProgressStatsSection(
                    userProfile: userProfile,
                    screenTimeManager: screenTimeManager,
                    achievementManager: achievementManager,
                    calculateBMI: calculateBMI,
                    getBMIColor: getBMIColor
                )
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                profileToolbarButton
                
            }
            
            ToolbarItemGroup(placement: .navigationBarLeading) {
                coinView
                QuestButton
                
            }
        }
#if DEBUG
        .overlay(alignment: .topLeading, content: {
            devResetButton
                .padding(.top)
        })
#endif
        .overlay(content: {
            if questManager.showNotificationPopup{
                NotificationPopupView {
                    DispatchQueue.main.async(execute: {
                        questManager.completeQuest(named: "Turn on notifications")
                        questManager.showNotificationPopup = false
                    })
                } onSkip: {
                    DispatchQueue.main.async(execute: {
                        questManager.showNotificationPopup = false
                    })
                }
            }
        })
        .onAppear {
            loadUserProfile()
            checkForScheduledOverviews()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CalendarSetupCompleted"))) { _ in
            loadUserProfile()
        }
        .sheet(isPresented: $showingFirstTimeSetup) {
            FirstTimeCalendarSetup(isPresented: $showingFirstTimeSetup, userProfile: $userProfile) { newEvents in
                print("􀄰 DEBUG: === SETUP CALLBACK ANALYSIS ===")
                print("􀄰 DEBUG: FirstTimeCalendarSetup returned \(newEvents.count) events!")
                print("􀄰 DEBUG: Detailed event breakdown:")
                for (index, event) in newEvents.enumerated() {
                    print("  📚 Event \(index + 1):")
                    print("      ID: \(event.id)")
                    print("      Title: '\(event.title)'")
                    print("      Date: \(event.date)")
                    print("      Location: '\(event.location)'")
                    print("      Teacher: '\(event.teacher ?? "None")'")
                    print("      Notes preview: \(event.notes.prefix(100))...")
                    print("      Color: \(event.color)")
                    print("      Full notes: '\(event.notes)'")
                    print("")
                }
                
                print("􀄰 DEBUG: Current calendar events before adding: \(events.count)")
                for (index, existingEvent) in events.enumerated() {
                    print("    Existing [\(index + 1)]: '\(existingEvent.title)' on \(existingEvent.date)")
                }
                
                // SIMPLIFIED: Just add directly to the binding - this should propagate to ContentView
                events.append(contentsOf: newEvents)
                
                print("􀄰 DEBUG: Current calendar events after adding: \(events.count)")
                print("􀄰 DEBUG: All events now in calendar (this is what CalendarReviewView should receive):")
                for (index, event) in events.enumerated() {
                    print("    FINAL [\(index + 1)] \(event.title) on \(event.date)")
                    print("        Location: '\(event.location)'")
                    print("        Teacher: '\(event.teacher ?? "None")'")
                }
                
                // Save the events to UserDefaults immediately
                if let data = try? JSONEncoder().encode(events) {
                    UserDefaults.standard.set(data, forKey: "calendarEvents")
                    print("✅ DEBUG: Events saved to UserDefaults with \(events.count) total events")
                }
                
                // MARK: - LEVEL UP USER PROFILE
                print("🎮 DEBUG: Leveling up user profile...")
                questManager.completeQuest(named: "Set up the basics of your calendar")
                
                //                // Update user profile with level 2 and 400 XP
                //                userProfile.level = 2
                //                userProfile.xp = 400
                //
                //                // Save the updated profile
                //                userProfile.save()
                print("✅ DEBUG: User profile updated to Level \(userProfile.level) with \(userProfile.xp) XP")
                
                // Mark setup as complete
                
                UserDefaults.hasCompletedCalendarSetup = true
                print("✅ DEBUG: Calendar setup marked as complete")
                
                // Trigger achievements
                achievementManager.completeCalendarSetup()
                print("✅ DEBUG: Achievement system notified of completion")
                
                // Post notification that setup is complete
                NotificationCenter.default.post(name: NSNotification.Name("CalendarSetupCompleted"), object: nil)
                print("✅ DEBUG: Posted CalendarSetupCompleted notification")
                
                // Also notify ContentView about the new events (for its internal tracking)
                NotificationCenter.default.post(
                    name: Notification.Name("NewEventsCreated"),
                    object: newEvents
                )
                print("✅ DEBUG: Posted NewEventsCreated notification with \(newEvents.count) events")
                print("􀄰 DEBUG: === END SETUP CALLBACK ANALYSIS ===")
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.34) {
//                    withAnimation(.easeOut(duration: 0.3)){
//                        questManager.showLevelUp = true
//                    }
//                }
                //showGlowQuestIcon = true
                
            }
        }
        .sheet(isPresented: $showingAddEvent) {
            AddEventView(
                selectedDate: selectedDate,
                events: $events,
                isPresented: $showingAddEvent
            ).onDisappear {
                // Notify ContentView that events were modified
                NotificationCenter.default.post(name: Notification.Name("EventsModified"), object: nil)
                
                if UserDefaults.hasCompletedCalendarSetup {
                    trackCalendarUsage()
                }
            }
        }
        .sheet(isPresented: $showingDailyOverview) {
            DailySummaryView(
                events: events,
                userProfile: userProfile,
                isPresented: $showingDailyOverview
            )
        }
        .sheet(isPresented: $showingCalendarReview) {
            CalendarReviewView(
                events: events,
                isPresented: $showingCalendarReview,
                onEventUpdated: { updatedEvent in
                    if let index = events.firstIndex(where: { $0.id == updatedEvent.id }) {
                        events[index] = updatedEvent
                        
                        // Save updated events
                        if let data = try? JSONEncoder().encode(events) {
                            UserDefaults.standard.set(data, forKey: "calendarEvents")
                        }
                        
                        // Notify ContentView of changes
                        NotificationCenter.default.post(name: Notification.Name("EventsModified"), object: nil)
                    }
                },
                onEventDeleted: { eventToDelete in
                    events.removeAll { $0.id == eventToDelete.id }
                    
                    // Save updated events
                    if let data = try? JSONEncoder().encode(events) {
                        UserDefaults.standard.set(data, forKey: "calendarEvents")
                    }
                    
                    // Notify ContentView of changes
                    NotificationCenter.default.post(name: Notification.Name("EventsModified"), object: nil)
                }
            )
        }
        .sheet(isPresented: $showingProfileDropdown) {
            EnhancedProfileView(userProfile: $userProfile)
                .onAppear {
                    if UserDefaults.hasCompletedCalendarSetup {
                        UserDefaults.standard.set(true, forKey: "hasSeenProfileUnlock")
                    }
                }
        }
        .fullScreenCover(isPresented: $openPetView) {
            PetDetailView(questManager:questManager)
        }
    }
    
    // MARK: - Computed Properties
    private var todaysQuote: (quote: String, author: String) {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let quoteIndex = (dayOfYear - 1) % inspirationalQuotes.count
        let (quote, author) = inspirationalQuotes[quoteIndex]
        return (quote: quote, author: author)
    }
    
    private var eventsWithTravel: [CalendarEvent] {
        // Return events as is since the withTravelEvents() extension
        // might not be available
        return events
    }
    
    private var eventsForSelectedDate: [CalendarEvent] {
        let calendar = Calendar.current
        return eventsWithTravel.filter { event in
            calendar.isDate(event.date, inSameDayAs: selectedDate)
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    // MARK: - Helper Functions
    private func loadUserProfile() {
        if let profile = UserProfile.load() {
            userProfile = profile
            print("📊 Loaded userProfile - Level: \(profile.level), XP: \(profile.xp)")
        } else {
            UserProfile.createTempuser()
            print("🆕 Created default userProfile (Champion)")
        }
    }
    
    private func trackCalendarUsage() {
        // Don't track progress during initial calendar setup
        if !UserDefaults.hasCompletedCalendarSetup {
            print("📊 Dashboard: Skipping progress tracking - still in initial setup phase")
            return
        }
        
        print("📊 Dashboard: trackCalendarUsage() called - triggering achievement progress")
        achievementManager.updateCalendarProgress()
        print("📊 Dashboard: trackCalendarUsage() completed")
    }
    
    private func checkForScheduledOverviews() {
        // Users can access reports manually via the AI Overview section
    }
    
    private func calculateBMI() -> Double {
        let heightM = userProfile.heightCM / 100.0
        return userProfile.weightKG / (heightM * heightM)
    }
    
    private func getBMIColor() -> Color {
        let bmi = calculateBMI()
        switch bmi {
        case ..<18.5: return .blue
        case 18.5..<25: return .green
        case 25..<30: return .orange
        default: return .red
        }
    }
    
    // MARK: - Toolbar Buttons
    private var profileToolbarButton: some View {
        Button {
            showingProfileDropdown = true
        } label: {
            HStack(spacing: 6) {
                ZStack {
                    if !UserDefaults.standard.bool(forKey: "hasSeenProfileUnlock") && UserDefaults.hasCompletedCalendarSetup {
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        .yellow.opacity(0.8),
                                        .orange.opacity(0.6),
                                        .clear
                                    ]),
                                    center: .center,
                                    startRadius: 2,
                                    endRadius: 20
                                )
                            )
                            .frame(width: 30, height: 30)
                            .blur(radius: 1)
                            .scaleEffect(1.2)
                    }
                    
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundColor(UserDefaults.hasCompletedCalendarSetup && !UserDefaults.standard.bool(forKey: "hasSeenProfileUnlock") ? .yellow : .blue)
                        .shadow(color: UserDefaults.hasCompletedCalendarSetup && !UserDefaults.standard.bool(forKey: "hasSeenProfileUnlock") ? .yellow.opacity(0.8) : .clear, radius: 4)
                }
                
                if UserDefaults.hasCompletedCalendarSetup && !UserDefaults.standard.bool(forKey: "hasSeenProfileUnlock") {
                    Text("Profile Unlocked!")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                }
            }
        }
    }
    
    private var QuestButton: some View {
        Button(action: {
//            if showGlowQuestIcon{
//                showGlowQuestIcon = false
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
//                    withAnimation(.easeOut(duration: 0.3)){
//                        questManager.showLevelUp = true
//                    }
//                }
//            }else{
//                showCustomPopover.toggle()
//            }
            showCustomPopover.toggle()
        }) {
            ZStack {
                let quests = questManager.getCurrentBatchQuests()
                let totalCompleted = quests.reduce(0) { $0 + $1.completedCount }
                let totalRequired = quests.reduce(0) { $0 + $1.totalCount }
                let progress = totalRequired > 0 ? Double(totalCompleted) / Double(totalRequired) : 0.0
                Circle()
                    .stroke(lineWidth: 2)
                    .foregroundColor(.yellow.opacity(0.3))
                    .frame(width: 28, height: 28)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .foregroundColor(.yellow)
                    .rotationEffect(.degrees(-90))
                    .frame(width: 28, height: 28)
                    .animation(.easeInOut(duration: 0.3), value: progress)
                // glow effect
                if showGlowQuestIcon{
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    .yellow.opacity(0.8),
                                    .orange.opacity(0.6),
                                    .clear
                                ]),
                                center: .center,
                                startRadius: 2,
                                endRadius: 20
                            )
                        )
                        .frame(width: 30, height: 30)
                        .blur(radius: 1)
                        .scaleEffect(1.2)
                }
                
                
                Image(systemName: "document.circle")
                    .foregroundColor(.orange)
                    .font(.system(size: 17, weight: .regular))
            }
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showCustomPopover) {
            QuestPopoverView(questManager: questManager)
                .presentationCompactAdaptation(.popover)
        }
    }
    
    private var coinView: some View {
        Button(action: {
            openPetView.toggle()
        }) {
            Image(systemName:"pawprint.circle.fill")//"dollarsign.ring"
                .foregroundColor(.blue)
                .font(.system(size: 20, weight: .regular))
        }
        .buttonStyle(.plain)
        
    }
    
    
#if DEBUG
    private var devResetButton: some View {
        Button {
            performCompleteAppReset()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .font(.title3)
                    .foregroundColor(.red)
                
                Text("DEV")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.red.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private func performDevReset() {
        print("📊 DEV: Dashboard reset triggered...")
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        performCompleteAppReset()
    }
    
    
#endif
}

// MARK: - Constants
extension GamifiedCalendarDashboard {
    static let inspirationalQuotes = [
        ("Hardships often prepare ordinary people for an extraordinary destiny.", "C.S. Lewis"),
        ("The best way out is always through.", "Robert Frost"),
        ("It's not whether you get knocked down. It's whether you get up.", "Vince Lombardi"),
        ("If you believe it will work out, you'll see opportunities. If you believe it won't, you will see obstacles.", "Wayne Dyer"),
        ("Most of the important things in the world have been accomplished by people who have kept on trying when there seemed to be no hope at all.", "Dale Carnegie"),
        ("I attribute my success to this: I never gave or took any excuse.", "Florence Nightingale"),
        ("Hard times don't create heroes. It is during the hard times when the 'hero' within us is revealed.", "Bob Riley"),
        ("Don't let the bastards grind you down.", "Margaret Atwood"),
        ("Character cannot be developed in ease and quiet. Only through experience of trial and suffering can the soul be strengthened, ambition inspired, and success achieved.", "Helen Keller"),
        ("We must believe that we are gifted for something and that this thing must be attained.", "Marie Curie"),
        ("If you hit the target every time, it's too near or too big.", "Tom Hirshfield"),
        ("I am not a product of my circumstances. I am a product of my decisions.", "Stephen Covey"),
        ("Failure is the condiment that gives success its flavor.", "Truman Capote"),
        ("It is by going down into the abyss that we recover the treasures of life. Where you stumble, there lies your treasure.", "Joseph Campbell"),
        ("Be undeniable.", "Ralphie May"),
        ("It is never too late to be what you might have been.", "George Eliot"),
        ("Once you've accepted your flaws, no one can use them against you.", "George R.R. Martin"),
        ("You be greater than your feelings. I don't demand this of you—life does. Otherwise, you'll be washed away by feelings. You'll be washed out to sea and never seen again.", "Phillip Roth"),
        ("Life is 10% what happens to you and 90% how you react to it.", "Charles R. Swindoll"),
        ("If you light a lamp for someone else, it will also brighten your path.", "Buddha"),
        ("Intelligence is the ability to adapt to change.", "Stephen Hawking")
    ]
}

// MARK: - Daily Summary View
struct DailySummaryView: View {
    let events: [CalendarEvent]
    let userProfile: UserProfile
    @Binding var isPresented: Bool
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    
    private var todaysEvents: [CalendarEvent] {
        events.filter { Calendar.current.isDateInToday($0.date) }
            .sorted { $0.date < $1.date }
    }
    
    private var todaysWorkEvents: [CalendarEvent] {
        todaysEvents.filter { event in
            let workKeywords = ["work", "job", "office", "meeting", "shift", "conference", "client", "project", "team", "department", "company"]
            let title = event.title.lowercased()
            let location = event.location.lowercased()
            let notes = event.notes.lowercased()
            
            return workKeywords.contains { keyword in
                title.contains(keyword) || location.contains(keyword) || notes.contains(keyword)
            }
        }
    }
    
    private var totalWorkHoursToday: Double {
        return Double(todaysWorkEvents.count)
    }
    
    private var hourlyWage: Double {
        guard userProfile.annualIncomeThousands > 0 else { return 0 }
        let annualSalary = Double(userProfile.annualIncomeThousands) * 1000
        let workingHoursPerYear = 52.0 * 40.0
        return annualSalary / workingHoursPerYear
    }
    
    private var todaysEarnings: Double {
        return totalWorkHoursToday * hourlyWage
    }
    
    private var expectedDailyEarnings: Double {
        return 8.0 * hourlyWage
    }
    
    private var earningsProgress: Double {
        guard expectedDailyEarnings > 0 else { return 0 }
        return min(todaysEarnings / expectedDailyEarnings, 1.0)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero section with today's earnings
                    todaysEarningsCard
                    
                    // Work activity breakdown
                    workActivityCard
                    
                    // Daily stats summary
                    dailyStatsCard
                }
                .padding()
            }
            .navigationTitle("Daily Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var todaysEarningsCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.title)
                    .foregroundColor(.green)
                
                Text("Today's Earnings")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                if todaysEarnings > 0 {
                    Image(systemName: "arrow.up.right")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
            
            if userProfile.annualIncomeThousands > 0 {
                VStack(spacing: 12) {
                    // Main earnings display
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("$")
                            .font(.title)
                            .foregroundColor(.green)
                        
                        Text(String(format: "%.0f", todaysEarnings))
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.green)
                    }
                    
                    // Progress bar
                    VStack(spacing: 8) {
                        HStack {
                            Text("Daily Goal Progress")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(Int(earningsProgress * 100))%")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(earningsProgress >= 1.0 ? .green : .orange)
                        }
                        
                        ProgressView(value: earningsProgress)
                            .progressViewStyle(LinearProgressViewStyle(tint: earningsProgress >= 1.0 ? .green : .blue))
                            .frame(height: 8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(4)
                    }
                    
                    // Target earnings
                    HStack {
                        Text("Daily Target:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("$\(String(format: "%.0f", expectedDailyEarnings))")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    
                    Text("Set Your Salary")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Add your annual salary in your profile to see earnings calculations")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    @ViewBuilder
    private var workActivityCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "briefcase.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("Work Activity")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(totalWorkHoursToday, specifier: "%.1f")h")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            
            if !todaysWorkEvents.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(todaysWorkEvents.prefix(5), id: \.id) { event in
                        HStack {
                            Circle()
                                .fill(Color.blue.opacity(0.3))
                                .frame(width: 8, height: 8)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(event.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                if !event.location.isEmpty {
                                    Text(event.location)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            if userProfile.annualIncomeThousands > 0 {
                                Text("+$\(String(format: "%.0f", hourlyWage))")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    if todaysWorkEvents.count > 5 {
                        Text("... and \(todaysWorkEvents.count - 5) more work activities")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading, 16)
                    }
                }
            } else {
                HStack {
                    Image(systemName: "moon.zzz.fill")
                        .foregroundColor(.gray)
                    
                    Text("No work activities detected today")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    @ViewBuilder
    private var dailyStatsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
                    .foregroundColor(.purple)
                
                Text("Daily Stats")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            VStack(spacing: 12) {
                statRow(
                    icon: "calendar",
                    title: "Total Events",
                    value: "\(todaysEvents.count)",
                    color: .blue
                )
                
                statRow(
                    icon: "clock",
                    title: "Work Hours",
                    value: String(format: "%.1fh", totalWorkHoursToday),
                    color: .blue
                )
                
                if userProfile.annualIncomeThousands > 0 {
                    statRow(
                        icon: "dollarsign.circle",
                        title: "Hourly Rate",
                        value: "$\(String(format: "%.0f", hourlyWage))",
                        color: .green
                    )
                }
                
                statRow(
                    icon: "percent",
                    title: "Goal Progress",
                    value: "\(Int(earningsProgress * 100))%",
                    color: .purple
                )
                
                statRow(
                    icon: "iphone",
                    title: "Screen Time",
                    value: "\(screenTimeManager.getTotalUsageToday()) min",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    @ViewBuilder
    private func statRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .padding(.vertical, 4)
    }
}
