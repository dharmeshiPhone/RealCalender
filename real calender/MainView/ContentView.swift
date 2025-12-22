import SwiftUI
import Combine

struct ContentView: View {
    init() {
        print("ContentView: Initializing new ContentView instance")
    }
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @EnvironmentObject var aiChatManager: AIChatManager
    @EnvironmentObject var achievementManager: AchievementManager
    @State private var selectedTab = 0
    @State private var events: [CalendarEvent] = []
    @StateObject private var messageAnalyzer = MessageAnalyzer()
    @StateObject private var questManager = QuestManager()
    
    @State private var userProfile: UserProfile = UserProfile.shared
    @State private var hasCompletedOnboarding = false
    @State private var isCheckingOnboarding = true
    @State private var hasCompletedCalendarSetup = false
    
    // Crown Animation States
    @State private var showLevelUpCelebration = false
    @State private var levelUpAchievement: Achievement?
    @State private var crownScale: CGFloat = 0.1
    @State private var crownRotation: Double = 0
    @State private var overlayOpacity: Double = 0
    @State private var glowOpacity: Double = 0.0
    @State private var pulseScale: CGFloat = 1.0
    @State private var clickCount = 0
    @State private var showCongratulationsText = false
    
    // NEW: Additional state to track if crown has been tapped
    @State private var hasBeenTapped = false
    
    // Ambient Confetti States
    @State private var showAmbientConfetti = false
    @State private var confettiAnimationTime: Double = 0
    
    var body: some View {
        ZStack {
            mainContent
            // debugGesture
        }
        .onAppear {
            print("ContentView: onAppear called - setting up notification listeners")
            checkOnboardingStatus()
            checkCalendarSetup()
            setupInitialData()
            setupCalendarSetupListener()
            setupDevKeyboardShortcut()
            print("ContentView: onAppear completed")
        }
        .onChange(of: hasCompletedOnboarding) { oldValue, newValue in
            print("📱 ContentView: hasCompletedOnboarding changed from \(oldValue) to \(newValue)")
            
            if oldValue == true && newValue == false {
                print("📱 ContentView: ⚠️  CRITICAL - onboarding state was reset to false!")
                print("📱 ContentView: Current UserDefaults onboarding: \(UserDefaults.standard.bool(forKey: "hasCompletedOnboarding"))")
                
                // Print stack trace to see what caused this
                Thread.callStackSymbols.forEach { print("📱 ContentView: Stack: \($0)") }
            }
            
            if newValue {
                loadUserProfile()
                checkCalendarSetup()
            }
        }
        .onChange(of: hasCompletedCalendarSetup) { _, completed in
            if completed {
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("AchievementLevelUp"))) { notification in
            print("ContentView: ========================================")
            print("ContentView: Received AchievementLevelUp notification!")
            print("ContentView: Current thread: \(Thread.isMainThread ? "MAIN" : "BACKGROUND")")
            print("ContentView: Notification: \(notification)")
            print("ContentView: Notification.object: \(notification.object ?? "nil")")
            print("ContentView: Notification object type: \(type(of: notification.object))")
            
            if let achievement = notification.object as? Achievement {
                print("ContentView: Successfully cast to Achievement")
                print("ContentView: Achievement ID: \(achievement.id)")
                print("ContentView: Achievement Title: \(achievement.title)")
                print("ContentView: Achievement Level: \(achievement.level)")
                print("ContentView: Achievement Category: \(achievement.category)")
                
                // Show crown animation for ANY achievement reaching Level 2 (leveling up from 1 to 2)
                if achievement.level == 2 {
                    print("ContentView: Level is 2 - triggering celebration!")
                    print("ContentView: Current showLevelUpCelebration state: \(showLevelUpCelebration)")
                    print("ContentView: About to call showLevelUpAnimation...")
                    print("ContentView: showLevelUpAnimation call completed")
                    print("ContentView: New showLevelUpCelebration state: \(showLevelUpCelebration)")
                } else {
                    print("ContentView: Achievement level is \(achievement.level), not 2 - skipping animation")
                }
            } else {
                print("ContentView: Failed to cast notification.object as Achievement")
                if let obj = notification.object {
                    print("ContentView: Object is of type: \(type(of: obj))")
                    print("ContentView: Object description: \(obj)")
                } else {
                    print("ContentView: notification.object is nil")
                }
            }
            print("ContentView: ========================================")
        }
        .onReceive(NotificationCenter.default.publisher(for: .profileUpdated)) { notification in
            print("📱 ContentView: Received profileUpdated notification")
            
            if let updatedProfile = notification.object as? UserProfile {
                print("📱 ContentView: Updating userProfile with new data")
                userProfile = updatedProfile
                
                updatedProfile.save()
                
                print("📱 ContentView: Profile update completed successfully")
            } else {
                print("📱 ContentView: ERROR - Could not cast notification object to UserProfile")
            }
        }
    }
    
    private var mainContent: some View {
        Group {
            if isCheckingOnboarding {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading...")
                        .padding(.top)
                }
                .onAppear {
                    print("📱 ContentView: Showing loading screen - isCheckingOnboarding: \(isCheckingOnboarding)")
                }
            } else if !hasCompletedOnboarding {
                OnboardingView(isCompleted: $hasCompletedOnboarding)
                    .onAppear {
                        questManager.clearAllData()
                        print("📱 ContentView: Showing OnboardingView - hasCompletedOnboarding: \(hasCompletedOnboarding)")
                        let currentOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
                        print("📱 ContentView: UserDefaults onboarding flag: \(currentOnboarding)")
                    }
            } else {
                TabView(selection: $selectedTab) {
                    TabbedCalendarView(events: $events,userProfile: $userProfile)
                        .environmentObject(screenTimeManager)
                        .environmentObject(aiChatManager)
                        .environmentObject(achievementManager)
                        .tabItem {
                            Image(systemName: "calendar")
                            Text("Calendar")
                        }
                        .tag(0)
                    
                    AIChatView(events: $events,userProfile: $userProfile)
                        .environmentObject(aiChatManager)
                        .environmentObject(screenTimeManager)
                        .tabItem {
                            Image(systemName: "brain.head.profile")
                            Text("AI Assistant")
                        }
                        .tag(1)
                    
                    MessageAnalysisView()
                        .environmentObject(aiChatManager)
                        .environmentObject(messageAnalyzer)
                        .tabItem {
                            Image(systemName: "text.bubble.fill")
                                .foregroundColor(.primary)
                                .font(.system(size: 16, weight: .regular))
                            
                            Text("Text Analysis")
                                .foregroundColor(.primary)
                                .fontWeight(.regular)
                        }
                        .tag(2)
                    
                    // BadgesView()
                    BadgeScreen(userProfile: userProfile)
                        .environmentObject(achievementManager)
                        .tabItem {
                            ZStack {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(.yellow)
                                
                                if let calendarAchievement = achievementManager.getCalendarAchievement(),
                                   calendarAchievement.currentProgress > 0 {
                                    VStack {
                                        HStack {
                                            Spacer()
                                            Circle()
                                                .fill(Color.red)
                                                .frame(width: 8, height: 8)
                                        }
                                        Spacer()
                                    }
                                    .offset(x: 8, y: -8)
                                }
                            }
                            Text("Badges")
                        }
                        .tag(3)
                }
                .environmentObject(questManager)
                .overlay(alignment: .center) {
                    LevelUpCelebrationView(
                        isShowing: $questManager.showLevelUp,
                        userProfile: $userProfile,
                        achievementLevel: UserProfile.shared.level
                    )
                 
                }
                .onAppear {
                    print("📱 ContentView: Showing TabView - hasCompletedOnboarding: \(hasCompletedOnboarding)")
                }
                .onChange(of: selectedTab) { _, newTab in
                    print(" Tab changed to: \(newTab)")
                    if newTab == 0 {
                        print(" Calendar tab selected - updating progress")
                        achievementManager.updateCalendarProgress()
                    } else if newTab == 3 {
                        print(" Badges tab selected")
                    }
                }
            }
        }
        .overlay(
            ZStack {
                EmptyView()
            }
                .allowsHitTesting(false)
                .ignoresSafeArea()
        )
    }
    
   
    
    private var debugGesture: some View {
#if DEBUG
        VStack {
            HStack {
                Spacer()
                
                VStack(spacing: 8) {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 50, height: 50)
                        .onTapGesture(count: 5) {
                            resetAppDataViaGesture()
                        }
                    
                    // Add level-up test button
                    Button("LEVEL UP") {
                    }
                    .font(.caption)
                    .foregroundColor(.yellow)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(6)
                    
                    // Add events debug button
                    Button("EVENTS") {
                        deduplicateAllEvents()
                    }
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.3))
                    .cornerRadius(6)
                }
            }
            Spacer()
        }
#else
        EmptyView()
#endif
    }
    
    // MARK: - Setup Functions
    private func checkOnboardingStatus() {
        print(" checkOnboardingStatus() called")
        DispatchQueue.main.async {
            do {
                let onboardingValue = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
                print(" UserDefaults.hasCompletedOnboarding: \(onboardingValue)")
                
                let savedProfile = UserProfile.load()
                let hasSavedProfile = savedProfile != nil
                
                // Additional safety check: if we have a valid user profile, onboarding should be completed
                if !onboardingValue,  hasSavedProfile{//let data = UserDefaults.standard.data(forKey: "userProfile"),
                    // let _ = try? JSONDecoder().decode(UserProfile.self, from: data)
                    print(" Found valid user profile but onboarding flag was false - fixing this")
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    self.hasCompletedOnboarding = true
                } else {
                    self.hasCompletedOnboarding = onboardingValue
                }
                
                self.isCheckingOnboarding = false
                
                print(" State after checking:")
                print("   hasCompletedOnboarding: \(self.hasCompletedOnboarding)")
                print("   isCheckingOnboarding: \(self.isCheckingOnboarding)")
                
                if hasCompletedOnboarding {
                    print("➡️ Onboarding completed — loading saved user profile")
                    if let profile = savedProfile {
                        self.userProfile = profile
                    } else {
                        print("⚠️ No saved user profile found despite flag being true")
                    }
                } else {
                    print("🧭 Onboarding NOT completed — showing OnboardingView")
                }
                
                //                if self.hasCompletedOnboarding {
                //                    print(" Onboarding completed - loading user profile")
                //                    self.loadUserProfile()
                //                } else {
                //                    print(" Onboarding NOT completed - should show OnboardingView")
                //                }
            } catch {
                print(" Error checking onboarding status: \(error)")
                self.hasCompletedOnboarding = false
                self.isCheckingOnboarding = false
            }
        }
    }
    
    private func checkCalendarSetup() {
        DispatchQueue.main.async {
            do {
                self.hasCompletedCalendarSetup = UserDefaults.hasCompletedCalendarSetup
            } catch {
                print(" Error checking calendar setup: \(error)")
                self.hasCompletedCalendarSetup = false
            }
        }
    }
    
    private func setupCalendarSetupListener() {
        NotificationCenter.default.addObserver(
            forName: Notification.Name("CalendarSetupCompleted"),
            object: nil,
            queue: .main
        ) { _ in
            print(" ContentView: Calendar setup completed!")
            self.hasCompletedCalendarSetup = true
            self.loadUserProfile()
            
            print(" ContentView: Triggering achievement completion for calendar setup")
            self.achievementManager.completeCalendarSetup()
        }
        
        // Listen for app data reset notifications (from dev reset buttons)
        NotificationCenter.default.addObserver(
            forName: Notification.Name("appDataReset"),
            object: nil,
            queue: .main
        ) { _ in
            print("📱 ContentView: Received appDataReset notification - triggering full app reset")
            self.resetAppDataViaKeyboard()
        }
        
        // Listen for bulk events (from photo analysis, batch imports, etc.)
        NotificationCenter.default.addObserver(
            forName: Notification.Name("NewEventsCreated"),
            object: nil,
            queue: .main
        ) { notification in
            if let newEvents = notification.object as? [CalendarEvent] {
                print(" ContentView: Received bulk events notification with \(newEvents.count) events")
                
                // Use unified system instead of direct append
                self.addEventsToMain(newEvents, source: "Bulk Import/Photo Analysis")
            } else {
                print(" ContentView: NewEventsCreated notification with invalid object type")
            }
        }
        
        // Listen for individual event additions (from manual add, single voice command, etc.)
        NotificationCenter.default.addObserver(
            forName: Notification.Name("EventAdded"),
            object: nil,
            queue: .main
        ) { notification in
            if let newEvent = notification.object as? CalendarEvent {
                print(" ContentView: Received single event notification: '\(newEvent.title)'")
                
                // Check if this event is already in our array to avoid duplicates
                let existingEvent = self.events.first { existingEvent in
                    existingEvent.id == newEvent.id ||
                    (existingEvent.title == newEvent.title &&
                     abs(existingEvent.date.timeIntervalSince(newEvent.date)) < 60) // Same title within 1 minute
                }
                
                if existingEvent == nil {
                    self.addEventToMain(newEvent, source: "Manual Add/Single Event")
                } else {
                    print(" ContentView: Duplicate event detected, skipping: '\(newEvent.title)'")
                }
            } else {
                print(" ContentView: EventAdded notification with invalid object type")
            }
        }
        
        // Listen for events from voice commands specifically
        NotificationCenter.default.addObserver(
            forName: Notification.Name("VoiceEventCreated"),
            object: nil,
            queue: .main
        ) { notification in
            if let newEvent = notification.object as? CalendarEvent {
                print(" ContentView: Received voice-created event: '\(newEvent.title)'")
                self.addEventToMain(newEvent, source: "Voice Command")
            }
        }
        
        // Listen for events from photo analysis specifically
        NotificationCenter.default.addObserver(
            forName: Notification.Name("PhotoEventsCreated"),
            object: nil,
            queue: .main
        ) { notification in
            if let newEvents = notification.object as? [CalendarEvent] {
                print(" ContentView: Received photo-analyzed events: \(newEvents.count) events")
                self.addEventsToMain(newEvents, source: "Photo Analysis")
            } else if let singleEvent = notification.object as? CalendarEvent {
                print(" ContentView: Received single photo-analyzed event: '\(singleEvent.title)'")
                self.addEventToMain(singleEvent, source: "Photo Analysis")
            }
        }
    }
    
    private func loadUserProfile() {
        print("📥 loadUserProfile() called")
        
        DispatchQueue.main.async {
            if let savedProfile = UserProfile.load() {
                // Found a saved profile — use it
                self.userProfile = savedProfile
                print("✅ Loaded existing user profile for \(savedProfile.name)")
                
                // Ensure onboarding flags are consistent
                let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
                if !hasCompletedOnboarding {
                    print("⚙️ Profile exists but onboarding flag missing — fixing")
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    self.hasCompletedOnboarding = true
                }
            } else {
                // No saved profile found → use default shared
                print("🆕 No saved profile found — creating default shared profile")
                self.createDefaultUserProfile()
            }
        }
    }
    
    
    private func createDefaultUserProfile() {
        UserProfile.createTempuser()
    }
    
    
    private func loadEvents() {
        DispatchQueue.main.async {
            do {
                if let data = UserDefaults.standard.data(forKey: "calendarEvents"),
                   let savedEvents = try? JSONDecoder().decode([CalendarEvent].self, from: data) {
                    self.events = savedEvents
                    print("📅 ContentView: Loaded \(savedEvents.count) events from UserDefaults")
                    for (index, event) in savedEvents.enumerated() {
                        print("   [\(index + 1)] \(event.title) on \(event.date)")
                    }
                } else {
                    self.events = []
                    print("📅 ContentView: No saved events found, starting with empty array")
                }
            } catch {
                print("📅 ContentView: Error loading events: \(error)")
                self.events = []
            }
        }
    }
    
    private func saveEvents() {
        DispatchQueue.main.async {
            do {
                if let data = try? JSONEncoder().encode(self.events) {
                    UserDefaults.standard.set(data, forKey: "calendarEvents")
                    print("📅 ContentView: Saved \(self.events.count) events to UserDefaults")
                    setupCalenderLogEvent()
                }
            } catch {
                print("📅 ContentView: Error saving events: \(error)")
            }
        }
    }
    
    //    func setupCalenderLogEvent(){
    //        questManager.completeQuestWithIncremnetStaticForce(named: "Log 3 calendar event", num: events.count)
    //
    //        if events.count > 43 {
    //            questManager.completeQuestWithIncremnetStaticForce(named:  "Add 2 new events", num: events.count - 44,  Quebatch: 42)
    //        }
    //
    //        if events.count > 41 {
    //            questManager.completeQuestWithIncremnetStaticForce(named:  "Add 1 new event", num: events.count - 42,  Quebatch: 41)
    //        }
    //
    //        if events.count > 40 {
    //            questManager.completeQuestWithIncremnetStaticForce(named:  "Add 2 new events", num: events.count - 41,  Quebatch: 39)
    //        }
    //        if events.count > 38 {
    //            questManager.completeQuestWithIncremnetStaticForce(named: "Add 1 new event", num: events.count - 39,  Quebatch: 38)
    //        }
    //        if events.count > 37 {
    //            questManager.completeQuestWithIncremnetStaticForce(named: "Add 1 new event", num: events.count - 38,  Quebatch: 36)
    //        }
    //        if events.count > 36 {
    //            questManager.completeQuestWithIncremnetStaticForce(named: "Add 1 new event", num: events.count - 37,  Quebatch: 34)
    //        }
    //
    //        if events.count > 35 {
    //            questManager.completeQuestWithIncremnetStaticForce(named: "Add 1 new event", num: events.count - 36,  Quebatch: 33)
    //        }
    //
    //        if events.count > 34 {
    //            questManager.completeQuestWithIncremnetStaticForce(named: "Add 1 new event", num: events.count - 35,  Quebatch: 31)
    //        }
    //
    //        if events.count > 33 {
    //            questManager.completeQuestWithIncremnetStaticForce(named: "Add 1 new event", num: events.count - 34,  Quebatch: 28)
    //        }
    //
    //        if events.count > 32 {
    //            questManager.completeQuestWithIncremnetStaticForce(named: "Add 2 new events", num: events.count - 33,  Quebatch: 26)
    //        }
    //
    //        if events.count > 30 {
    //            questManager.completeQuestWithIncremnetStaticForce(named: "Add 2 new events", num: events.count - 31,  Quebatch: 24)
    //        }
    //
    //        if events.count > 28 {
    //            questManager.completeQuestWithIncremnetStaticForce(named: "Add 2 new events", num: events.count - 29,  Quebatch: 23)
    //        }
    //
    //        if events.count > 26 {
    //            questManager.completeQuestWithIncremnetStaticForce(named: "Add 1 new event", num: events.count - 27,  Quebatch: 22)
    //        }
    //
    //        if events.count > 25 {
    //            questManager.completeQuestWithIncremnetStaticForce(named: "Add 1 new event", num: events.count - 26,  Quebatch: 19)
    //        }
    //
    //        if events.count > 24 {
    //            questManager.completeQuestWithIncremnetStaticForce(named: "Add 3 new event", num: events.count - 25,  Quebatch: 17)
    //        }
    //
    //        if events.count > 21 {
    //            questManager.completeQuestWithIncremnetStaticForce(named: "Add 1 new event", num: events.count - 22,  Quebatch: 16)
    //        }
    //
    //        if events.count > 20 {
    //            questManager.completeQuestWithIncremnetStaticForce(named: "Add 3 new event", num: events.count - 21,  Quebatch: 15)
    //        }
    //
    //        if events.count > 17 {
    //            questManager.completeQuestWithIncremnetStaticForce(named: "Add 2 new event", num: events.count - 18,  Quebatch: 13)
    //        }
    //
    //        if events.count > 15 {
    //            questManager.completeQuestWithIncremnetStaticForce(named: "Add 2 new events", num: events.count - 16,  Quebatch: 12)
    //        }
    //
    //        if events.count > 13 {
    //            questManager.completeQuestWithIncremnetStaticForce(named: "Add 2 new event", num: events.count - 14,  Quebatch: 11)
    //        }
    //
    //        if events.count > 11 {
    //            questManager.completeQuestWithIncremnetStaticForce(named: "Add 2 new event", num: events.count - 12,  Quebatch: 10)
    //        }
    //
    //        if events.count > 9 {
    //            questManager.completeQuestWithIncremnetStaticForce(named: "Add 2 new event", num: events.count - 10,  Quebatch: 9)
    //        }
    //
    //        if events.count > 7 {
    //            questManager.completeQuestWithIncremnetStaticForce(named: "Add 3 new event", num: events.count - 8,  Quebatch: 8)
    //        }
    //
    //        if events.count > 2 {
    //            questManager.completeQuestWithIncremnetStaticForce(named: "Add 5 new event", num: events.count - 3,  Quebatch: 3)
    //        }
    //
    //
    //        // MARK: -  For CompletedEvents.
    //
    //        let respondedAndCompletedCount = events.filter { $0.isRespond && $0.isCompleted }.count
    //
    //
    //        // Batch 3 quest (needs 2 events)
    //        questManager.completeQuestWithIncremnetStaticForce(
    //            named: "Complete 2 scheduled event",
    //            num: respondedAndCompletedCount
    //        )
    //
    //        if respondedAndCompletedCount > 128{
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 1 scheduled event",
    //                num: respondedAndCompletedCount - 129,
    //                Quebatch: 42
    //            )
    //        }
    //
    //        if respondedAndCompletedCount > 127{
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 3 scheduled event",
    //                num: respondedAndCompletedCount - 128,
    //                Quebatch: 41
    //            )
    //        }
    //
    //
    //        if respondedAndCompletedCount > 124{
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 2 scheduled event",
    //                num: respondedAndCompletedCount - 125,
    //                Quebatch: 40
    //            )
    //        }
    //
    //        if respondedAndCompletedCount > 122{
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 4 scheduled event",
    //                num: respondedAndCompletedCount - 123,
    //                Quebatch: 39
    //            )
    //        }
    //
    //        if respondedAndCompletedCount > 118{
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 3 scheduled event",
    //                num: respondedAndCompletedCount - 119,
    //                Quebatch: 38
    //            )
    //        }
    //
    //        if respondedAndCompletedCount > 115{
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 3 scheduled event",
    //                num: respondedAndCompletedCount - 116,
    //                Quebatch: 37
    //            )
    //        }
    //
    //        if respondedAndCompletedCount > 112{
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 4 scheduled event",
    //                num: respondedAndCompletedCount - 113,
    //                Quebatch: 36
    //            )
    //        }
    //
    //        if respondedAndCompletedCount > 108{
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 3 scheduled event",
    //                num: respondedAndCompletedCount - 109,
    //                Quebatch: 35
    //            )
    //        }
    //        if respondedAndCompletedCount > 105{
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 3 scheduled event",
    //                num: respondedAndCompletedCount - 106,
    //                Quebatch: 34
    //            )
    //        }
    //
    //        if respondedAndCompletedCount > 102{
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 4 scheduled event",
    //                num: respondedAndCompletedCount - 103,
    //                Quebatch: 33
    //            )
    //        }
    //
    //        if respondedAndCompletedCount > 98{
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 3 scheduled event",
    //                num: respondedAndCompletedCount - 99,
    //                Quebatch: 32
    //            )
    //        }
    //
    //        if respondedAndCompletedCount > 95{
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named:  "Complete 4 scheduled event",
    //                num: respondedAndCompletedCount - 96,
    //                Quebatch: 31
    //            )
    //        }
    //
    //        if respondedAndCompletedCount > 91{
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 3 scheduled event",
    //                num: respondedAndCompletedCount - 92,
    //                Quebatch: 30
    //            )
    //        }
    //
    //        if respondedAndCompletedCount > 88{
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 4 scheduled event",
    //                num: respondedAndCompletedCount - 89,
    //                Quebatch: 29
    //            )
    //        }
    //
    //        if respondedAndCompletedCount > 84{
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 3 scheduled event",
    //                num: respondedAndCompletedCount - 85,
    //                Quebatch: 28
    //            )
    //        }
    //
    //        if respondedAndCompletedCount > 81{
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 3 scheduled event",
    //                num: respondedAndCompletedCount - 82,
    //                Quebatch: 27
    //            )
    //        }
    //
    //        if respondedAndCompletedCount > 78{
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 4 scheduled event",
    //                num: respondedAndCompletedCount - 79,
    //                Quebatch: 26
    //            )
    //        }
    //
    //        if respondedAndCompletedCount > 74 {
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 5 scheduled event",
    //                num: respondedAndCompletedCount - 75,
    //                Quebatch:25
    //            )
    //        }
    //
    //        if respondedAndCompletedCount > 69 {
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 3 scheduled event",
    //                num: respondedAndCompletedCount - 70,
    //                Quebatch:24
    //            )
    //        }
    //
    //        if respondedAndCompletedCount > 66 {
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 3 scheduled event",
    //                num: respondedAndCompletedCount - 67,
    //                Quebatch: 23
    //            )
    //        }
    //
    //        if respondedAndCompletedCount > 63 {
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 3 scheduled event",
    //                num: respondedAndCompletedCount - 64,
    //                Quebatch: 22
    //            )
    //        }
    //
    //        if respondedAndCompletedCount > 60 {
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 2 scheduled event",
    //                num: respondedAndCompletedCount - 61,
    //                Quebatch: 21
    //            )
    //        }
    //
    //
    //        if respondedAndCompletedCount > 58 {
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 5 scheduled event",
    //                num: respondedAndCompletedCount - 59,
    //                Quebatch: 20
    //            )
    //        }
    //
    //        if respondedAndCompletedCount > 53 {
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 2 scheduled event",
    //                num: respondedAndCompletedCount - 54,
    //                Quebatch: 19
    //            )
    //        }
    //
    //
    //
    //        if respondedAndCompletedCount > 51 {
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 5 scheduled event",
    //                num: respondedAndCompletedCount - 52,
    //                Quebatch: 18
    //            )
    //        }
    //
    //
    //        if respondedAndCompletedCount > 46 {
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 6 scheduled event",
    //                num: respondedAndCompletedCount - 47,
    //                Quebatch: 17
    //            )
    //        }
    //
    //        if respondedAndCompletedCount > 40 {
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 3 scheduled event",
    //                num: respondedAndCompletedCount - 41,
    //                Quebatch: 16
    //            )
    //        }
    //
    //
    //        if respondedAndCompletedCount > 37 {
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 2 scheduled event",
    //                num: respondedAndCompletedCount - 38,
    //                Quebatch: 15
    //            )
    //        }
    //
    //        if respondedAndCompletedCount > 35 {
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 2 scheduled event",
    //                num: respondedAndCompletedCount - 36,
    //                Quebatch: 14
    //            )
    //        }
    //
    //        if respondedAndCompletedCount > 33 {
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 3 scheduled event",
    //                num: respondedAndCompletedCount - 34,
    //                Quebatch: 13
    //            )
    //        }
    //
    //
    //        if respondedAndCompletedCount > 30 {
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 2 scheduled event",
    //                num: respondedAndCompletedCount - 31,
    //                Quebatch: 12
    //            )
    //        }
    //
    //
    //        if respondedAndCompletedCount > 28 {
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 3 scheduled event",
    //                num: respondedAndCompletedCount - 29,
    //                Quebatch: 11
    //            )
    //        }
    //
    //        if respondedAndCompletedCount > 25 {
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 5 scheduled event",
    //                num: respondedAndCompletedCount - 26,
    //                Quebatch: 10
    //            )
    //        }
    //
    //        if respondedAndCompletedCount > 20 {
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 5 scheduled event",
    //                num: respondedAndCompletedCount - 21,
    //                Quebatch: 9
    //            )
    //        }
    //
    //        if respondedAndCompletedCount > 15 {
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 4 scheduled event",
    //                num: respondedAndCompletedCount - 16,
    //                Quebatch: 8
    //            )
    //        }
    //
    //        if respondedAndCompletedCount > 11 {
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 4 scheduled event",
    //                num: respondedAndCompletedCount - 12,
    //                Quebatch: 7
    //            )
    //        }
    //
    //        if respondedAndCompletedCount > 7 {
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 4 scheduled event",
    //                num: respondedAndCompletedCount - 8,
    //                Quebatch: 6
    //            )
    //        }
    //
    //        if respondedAndCompletedCount > 4 {
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 3 scheduled event",
    //                num: respondedAndCompletedCount - 5,
    //                Quebatch: 5
    //            )
    //        }
    //
    //
    //        // Batch 4 quest (needs 3 events) → reduce by 2
    //        if respondedAndCompletedCount > 1 {
    //            questManager.completeQuestWithIncremnetStaticForce(
    //                named: "Complete 3 scheduled event",
    //                num: respondedAndCompletedCount - 2,
    //                Quebatch: 4
    //            )
    //        }
    //
    //    }
    
    func setupCalenderLogEvent() {
        
        let eventCount = events.count
        
        // MARK: - Log Calendar Event Quest
        questManager.completeQuestWithIncremnetStaticForce(
            named: "Log 3 calendar event",
            num: eventCount
        )
        
        // MARK: - Add Event Quests
        for rule in addEventRules where eventCount > rule.threshold {
            questManager.completeQuestWithIncremnetStaticForce(
                named: rule.name,
                num: eventCount - rule.offset,
                Quebatch: rule.batch
            )
        }
        
        // MARK: - Completed Scheduled Events
        let respondedAndCompletedCount = events.filter {
            $0.isRespond && $0.isCompleted
        }.count
        
        // Base quest
        //        questManager.completeQuestWithIncremnetStaticForce(
        //            named: "Complete 2 scheduled event",
        //            num: respondedAndCompletedCount
        //        )
        
        // Batch-based quests
        for rule in completedEventRules where respondedAndCompletedCount > rule.threshold {
            questManager.completeQuestWithIncremnetStaticForce(
                named: rule.name,
                num: respondedAndCompletedCount - rule.offset,
                Quebatch: rule.batch
            )
        }
    }
    
    
    
    
    private func setupInitialData() {
        loadEvents()
        print(" Setting up unified event creation system...")
        
        // AI Chat events (voice commands, text chat)
        aiChatManager.onEventCreated = { event in
            print(" AI Chat created event: '\(event.title)' at \(event.date)")
            self.addEventToMain(event, source: "AI Chat")
        }
        
        // Message/Photo Analyzer events (photo analysis, text analysis)
        messageAnalyzer.onEventCreated = { event in
            print(" Photo/Message Analyzer created event: '\(event.title)' at \(event.date)")
            self.addEventToMain(event, source: "Photo/Message Analysis")
        }
        
        // Add observer for when events are modified in child views
        NotificationCenter.default.addObserver(
            forName: Notification.Name("EventsModified"),
            object: nil,
            queue: .main
        ) { notification in
            let shouldReload = notification.userInfo?["shouldLoadEvent"] as? Bool ?? false
            
            print(" ContentView: Events modified notification received - saving events")
            if shouldReload{
                loadEvents()
            }
            self.saveEvents()
        }
        
        print(" Unified event system setup completed")
    }
    
    // MARK: - Unified Event Management
    private func addEventToMain(_ event: CalendarEvent, source: String) {
        DispatchQueue.main.async {
            print(" Adding event from \(source): '\(event.title)'")
            print("   Date: \(event.date)")
            print("   Location: \(event.location)")
            print("   Notes: \(event.notes)")
            
            // Check for duplicates before adding
            if self.isDuplicateEvent(event) {
                print(" Duplicate event detected from \(source), skipping: '\(event.title)'")
                return
            }
            
            // Add to main events array
            self.events.append(event)
            
            // Save immediately
            self.saveEvents()
            
            print(" Event added successfully from \(source). Total events: \(self.events.count)")
            
            // Update achievement progress
            self.achievementManager.updateCalendarProgress()
        }
    }
    
    private func addEventsToMain(_ newEvents: [CalendarEvent], source: String) {
        DispatchQueue.main.async {
            print(" Adding \(newEvents.count) events from \(source):")
            
            var addedCount = 0
            for (index, event) in newEvents.enumerated() {
                print("   \(index + 1). '\(event.title)' at \(event.date)")
                
                // Check for duplicates before adding each event
                if !self.isDuplicateEvent(event) {
                    self.events.append(event)
                    addedCount += 1
                    
                    // Update achievement progress for each new event
                    self.achievementManager.updateCalendarProgress()
                } else {
                    print("   Skipping duplicate: '\(event.title)'")
                }
            }
            
            // Save if any events were added
            if addedCount > 0 {
                self.saveEvents()
                print(" \(addedCount) new events added from \(source). Total events: \(self.events.count)")
            } else {
                print(" No new events added from \(source) (all were duplicates)")
            }
        }
    }
    
    private func isDuplicateEvent(_ newEvent: CalendarEvent) -> Bool {
        return events.contains { existingEvent in
            // Check for exact ID match first
            if existingEvent.id == newEvent.id {
                return true
            }
            
            // Check for similar events (same title, similar time, same location)
            let titleMatch = existingEvent.title.lowercased() == newEvent.title.lowercased()
            let timeMatch = abs(existingEvent.date.timeIntervalSince(newEvent.date)) < 300 // Within 5 minutes
            let locationMatch = existingEvent.location.lowercased() == newEvent.location.lowercased()
            
            return titleMatch && timeMatch && locationMatch
        }
    }
    
    // Method to manually refresh and deduplicate all events
    private func deduplicateAllEvents() {
        let originalCount = events.count
        var uniqueEvents: [CalendarEvent] = []
        
        for event in events {
            let isDuplicate = uniqueEvents.contains { existingEvent in
                let titleMatch = existingEvent.title.lowercased() == event.title.lowercased()
                let timeMatch = abs(existingEvent.date.timeIntervalSince(event.date)) < 300
                let locationMatch = existingEvent.location.lowercased() == event.location.lowercased()
                return titleMatch && timeMatch && locationMatch
            }
            
            if !isDuplicate {
                uniqueEvents.append(event)
            }
        }
        
        events = uniqueEvents
        saveEvents()
        
        let removedCount = originalCount - uniqueEvents.count
        if removedCount > 0 {
            print(" Removed \(removedCount) duplicate events. Total events: \(events.count)")
        }
    }
    
    private func setupDevKeyboardShortcut() {
#if DEBUG
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("DevResetApp"),
            object: nil,
            queue: .main
        ) { _ in
            self.resetAppDataViaKeyboard()
        }
#endif
    }
    
    private func resetAppDataViaGesture() {
#if DEBUG
        print(" 5-tap gesture detected - resetting app data...")
        resetAppDataViaKeyboard()
#endif
    }
    
    private func resetAppDataViaKeyboard() {
        print("")
        print("===== STARTING APP RESET ======")
        print("Current state before reset:")
        print("  hasCompletedOnboarding: \(hasCompletedOnboarding)")
        print("  isCheckingOnboarding: \(isCheckingOnboarding)")
        print("  hasCompletedCalendarSetup: \(hasCompletedCalendarSetup)")
        
        // Clear all UserDefaults data
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: "hasCompletedCalendarSetup")
        UserDefaults.standard.removeObject(forKey: "userProfile")
        UserDefaults.standard.removeObject(forKey: "calendarEvents")
        UserDefaults.standard.removeObject(forKey: "userAchievements")
        UserDefaults.standard.removeObject(forKey: "hasSeenTextAnalysis")
        UserDefaults.standard.removeObject(forKey: "hasSeenProfileUnlock")
        UserDefaults.standard.removeObject(forKey: "lastMonthlyOverview")
        UserDefaults.standard.removeObject(forKey: "userLocation")
        UserDefaults.standard.removeObject(forKey: "morningPrepTime")
        UserDefaults.standard.removeObject(forKey: "userPets")
        UserDefaults.standard.removeObject(forKey: "petCosmeticTiers")
        UserDefaults.standard.removeObject(forKey: "userBadges")
        UserDefaults.standard.removeObject(forKey: "pendingRewardQuestIds")
        UserDefaults.standard.removeObject(forKey: "showGlowIcon")
        
        // clear streck
        UserDefaults.standard.removeObject(forKey: "hasUsedFreeze")
        UserDefaults.standard.removeObject(forKey: "currentStreak")
        UserDefaults.standard.removeObject(forKey: "totalDaysLogged")
        UserDefaults.standard.removeObject(forKey: "longestStreak")
        UserDefaults.standard.removeObject(forKey: "lastLoginDate")
        UserDefaults.standard.removeObject(forKey: "hasSaverAvailable")
        UserDefaults.standard.removeObject(forKey: "hasSeenDay7Offer")
        UserDefaults.standard.removeObject(forKey: "hasSeenDay30Offer")
        UserDefaults.standard.removeObject(forKey: "hasReceivedWelcomeBackGift")
        UserDefaults.standard.removeObject(forKey: "lastWelcomeBackGiftDate")
        
        
        UserDefaults.standard.removeObject(forKey: "hasShownCommitmentPopup")
        
        
        
        // Force synchronize UserDefaults to ensure changes are saved immediately
        UserDefaults.standard.synchronize()
        print("UserDefaults cleared and synchronized")
        
        // Reset achievement manager first (this clears UserDefaults too)
        achievementManager.resetAllAchievements()
        print("Achievement manager reset completed")
        
        QuestStorageManager().clearAllData()
        
        // Reset all state variables immediately on main queue
        DispatchQueue.main.async {
            print("Resetting state variables on main queue...")
            
            // Core onboarding states
            self.hasCompletedOnboarding = false
            self.hasCompletedCalendarSetup = false
            self.isCheckingOnboarding = true
            self.selectedTab = 0
            self.events = []
            
            print("Core states reset:")
            print("  hasCompletedOnboarding: \(self.hasCompletedOnboarding)")
            print("  isCheckingOnboarding: \(self.isCheckingOnboarding)")
            print("  hasCompletedCalendarSetup: \(self.hasCompletedCalendarSetup)")
            
            // Reset crown animation states
            self.showLevelUpCelebration = false
            self.levelUpAchievement = nil
            self.clickCount = 0
            self.crownScale = 0.1
            self.showCongratulationsText = false
            // Reset rotation states for next time
            self.crownRotation = 0
            self.hasBeenTapped = false
            self.showAmbientConfetti = false
            self.confettiAnimationTime = 0
            
            // Reset user profile to default
            self.userProfile = UserProfile.shared
            
            //            NotificationCenter.default.post(name: .profileUpdated, object: userProfile)
            
            print("All state variables reset, about to check onboarding status...")
            
            // Small delay to ensure state is fully updated
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                print("Final step: Checking onboarding status...")
                self.checkOnboardingStatus()
                print("===== APP RESET COMPLETED ======")
            }
        }
    }
}

struct QuestRule {
    let threshold: Int
    let offset: Int
    let name: String
    let batch: Int?
}


// MARK: - Add Calendar Event Rules
private let addEventRules: [QuestRule] = [
    .init(threshold: 62, offset: 63, name: "Add 1 new event", batch: 64),
    .init(threshold: 61, offset: 62, name: "Add 2 new event", batch: 62),
    .init(threshold: 59, offset: 60, name: "Add 2 new events", batch: 59),
    .init(threshold: 57, offset: 58, name: "Add 1 new event", batch: 57),
    .init(threshold: 56, offset: 57, name: "Add 3 new events", batch: 56),
    .init(threshold: 53, offset: 54, name: "Add 2 new event", batch: 54),
    .init(threshold: 51, offset: 52, name: "Add 1 new event", batch: 51),
    .init(threshold: 50, offset: 51, name: "Add 2 new events", batch: 49),
    .init(threshold: 48, offset: 49, name: "Add 1 new event", batch: 48),
    .init(threshold: 47, offset: 48, name: "Add 1 new event", batch: 46),
    .init(threshold: 46, offset: 47, name: "Add 2 new events", batch: 44),
    .init(threshold: 44, offset: 45, name: "Add 1 new event", batch: 43),
    .init(threshold: 43, offset: 44, name: "Add 2 new events", batch: 42),
    .init(threshold: 41, offset: 42, name: "Add 1 new event",  batch: 41),
    .init(threshold: 40, offset: 41, name: "Add 2 new events", batch: 39),
    .init(threshold: 38, offset: 39, name: "Add 1 new event",  batch: 38),
    .init(threshold: 37, offset: 38, name: "Add 1 new event",  batch: 36),
    .init(threshold: 36, offset: 37, name: "Add 1 new event",  batch: 34),
    .init(threshold: 35, offset: 36, name: "Add 1 new event",  batch: 33),
    .init(threshold: 34, offset: 35, name: "Add 1 new event",  batch: 31),
    .init(threshold: 33, offset: 34, name: "Add 1 new event",  batch: 28),
    .init(threshold: 32, offset: 33, name: "Add 2 new events", batch: 26),
    .init(threshold: 30, offset: 31, name: "Add 2 new events", batch: 24),
    .init(threshold: 28, offset: 29, name: "Add 2 new events", batch: 23),
    .init(threshold: 26, offset: 27, name: "Add 1 new event",  batch: 22),
    .init(threshold: 25, offset: 26, name: "Add 1 new event",  batch: 19),
    .init(threshold: 24, offset: 25, name: "Add 3 new event",  batch: 17),
    .init(threshold: 21, offset: 22, name: "Add 1 new event",  batch: 16),
    .init(threshold: 20, offset: 21, name: "Add 3 new event",  batch: 15),
    .init(threshold: 17, offset: 18, name: "Add 2 new event",  batch: 13),
    .init(threshold: 15, offset: 16, name: "Add 2 new events", batch: 12),
    .init(threshold: 13, offset: 14, name: "Add 2 new event",  batch: 11),
    .init(threshold: 11, offset: 12, name: "Add 2 new event",  batch: 10),
    .init(threshold: 9,  offset: 10, name: "Add 2 new event",  batch: 9),
    .init(threshold: 7,  offset: 8,  name: "Add 3 new event",  batch: 8),
    .init(threshold: 2,  offset: 3,  name: "Add 5 new event",  batch: 3)
]

// MARK: - Completed Scheduled Event Rules
private let completedEventRules: [QuestRule] = [
    .init(threshold: 204, offset: 204, name: "Complete 4 scheduled event", batch: 64),
    .init(threshold: 199, offset: 199, name: "Complete 5 scheduled event", batch: 63),
    .init(threshold: 196, offset: 196, name: "Complete 3 scheduled event", batch: 62),
    .init(threshold: 192, offset: 192, name: "Complete 4 scheduled event", batch: 61),
    .init(threshold: 189, offset: 189, name: "Complete 3 scheduled event", batch: 60),
    .init(threshold: 185, offset: 185, name: "Complete 4 scheduled event", batch: 59),
    .init(threshold: 184, offset: 184, name: "Complete 1 scheduled event", batch: 58),
    .init(threshold: 179, offset: 179, name: "Complete 5 scheduled event", batch: 57),
    .init(threshold: 177, offset: 177, name: "Complete 2 scheduled event", batch: 56),
    .init(threshold: 174, offset: 174, name: "Complete 3 scheduled event", batch: 55),
    .init(threshold: 172, offset: 172, name: "Complete 2 scheduled event", batch: 54),
    .init(threshold: 168, offset: 168, name: "Complete 4 scheduled event", batch: 53),
    .init(threshold: 165, offset: 165, name: "Complete 3 scheduled event", batch: 52),
    .init(threshold: 162, offset: 162, name: "Complete 3 scheduled event", batch: 51),
    .init(threshold: 157, offset: 157, name: "Complete 5 scheduled event", batch: 50),
    .init(threshold: 153, offset: 153, name: "Complete 4 scheduled event", batch: 49),
    .init(threshold: 151, offset: 151, name: "Complete 2 scheduled event", batch: 48),
    .init(threshold: 147, offset: 147, name: "Complete 2 scheduled event", batch: 47),
    .init(threshold: 144, offset: 144, name: "Complete 3 scheduled event", batch: 46),
    .init(threshold: 141, offset: 141, name: "Complete 3 scheduled event", batch: 45),
    .init(threshold: 139, offset: 139, name: "Complete 2 scheduled event", batch: 44),
    .init(threshold: 135, offset: 135, name: "Complete 4 scheduled event", batch: 43),
    .init(threshold: 134, offset: 134, name: "Complete 1 scheduled event", batch: 42),
    .init(threshold: 131, offset: 131, name: "Complete 3 scheduled event", batch: 41),
    .init(threshold: 129, offset: 129, name: "Complete 2 scheduled event", batch: 40),
    .init(threshold: 125, offset: 125, name: "Complete 4 scheduled event", batch: 39),
    .init(threshold: 122, offset: 122, name: "Complete 3 scheduled event", batch: 38),
    .init(threshold: 119, offset: 119, name: "Complete 3 scheduled event", batch: 37),
    .init(threshold: 115, offset: 115, name: "Complete 4 scheduled event", batch: 36),
    .init(threshold: 112, offset: 112, name: "Complete 3 scheduled event", batch: 35),
    .init(threshold: 109, offset: 109, name: "Complete 3 scheduled event", batch: 34),
    .init(threshold: 105, offset: 105, name: "Complete 4 scheduled event", batch: 33),
    .init(threshold: 102, offset: 102, name: "Complete 3 scheduled event", batch: 32),
    .init(threshold: 98,  offset: 98,  name: "Complete 4 scheduled event", batch: 31),
    .init(threshold: 95,  offset: 95,  name: "Complete 3 scheduled event", batch: 30),
    .init(threshold: 91,  offset: 91,  name: "Complete 4 scheduled event", batch: 29),
    .init(threshold: 88,  offset: 88,  name: "Complete 3 scheduled event", batch: 28),
    .init(threshold: 85,  offset: 85,  name: "Complete 3 scheduled event", batch: 27),
    .init(threshold: 81,  offset: 81,  name: "Complete 4 scheduled event", batch: 26),
    .init(threshold: 76,  offset: 76,  name: "Complete 5 scheduled event", batch: 25),
    .init(threshold: 73,  offset: 73,  name: "Complete 3 scheduled event", batch: 24),
    .init(threshold: 70,  offset: 70,  name: "Complete 3 scheduled event", batch: 23),
    .init(threshold: 67,  offset: 67,  name: "Complete 3 scheduled event", batch: 22),
    .init(threshold: 65,  offset: 65,  name: "Complete 2 scheduled event", batch: 21),
    .init(threshold: 59,  offset: 59,  name: "Complete 5 scheduled event", batch: 20),
    .init(threshold: 57,  offset: 57,  name: "Complete 2 scheduled event", batch: 19),
    .init(threshold: 52,  offset: 52,  name: "Complete 5 scheduled event", batch: 18),
    .init(threshold: 46,  offset: 46,  name: "Complete 6 scheduled event", batch: 17),
    .init(threshold: 43,  offset: 43,  name: "Complete 3 scheduled event", batch: 16),
    .init(threshold: 41,  offset: 41,  name: "Complete 2 scheduled event", batch: 15),
    .init(threshold: 39,  offset: 39,  name: "Complete 2 scheduled event", batch: 14),
    .init(threshold: 36,  offset: 36,  name: "Complete 3 scheduled event", batch: 13),
    .init(threshold: 34,  offset: 34,  name: "Complete 2 scheduled event", batch: 12),
    .init(threshold: 31,  offset: 31,  name: "Complete 3 scheduled event", batch: 11),
    .init(threshold: 26,  offset: 26,  name: "Complete 5 scheduled event", batch: 10),
    .init(threshold: 21,  offset: 21,  name: "Complete 5 scheduled event", batch: 9),
    .init(threshold: 17,  offset: 17,  name: "Complete 4 scheduled event", batch: 8),
    .init(threshold: 13,  offset: 13,  name: "Complete 4 scheduled event", batch: 7),
    .init(threshold: 9,   offset: 9,   name: "Complete 4 scheduled event", batch: 6),
    .init(threshold: 6,   offset: 6,   name: "Complete 3 scheduled event", batch: 5),
    .init(threshold: 3,   offset: 3,   name: "Complete 3 scheduled event", batch: 4),
    .init(threshold: 1,   offset: 1,   name: "Complete 2 scheduled event", batch: 3),
]
