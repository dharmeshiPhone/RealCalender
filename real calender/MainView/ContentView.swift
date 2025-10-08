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
            debugGesture
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
                        print("📱 ContentView: Showing OnboardingView - hasCompletedOnboarding: \(hasCompletedOnboarding)")
                        let currentOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
                        print("📱 ContentView: UserDefaults onboarding flag: \(currentOnboarding)")
                    }
            } else {
                TabView(selection: $selectedTab) {
                    TabbedCalendarView(events: $events)
                        .environmentObject(screenTimeManager)
                        .environmentObject(aiChatManager)
                        .environmentObject(achievementManager)
                        .tabItem {
                            Image(systemName: "calendar")
                            Text("Calendar")
                        }
                        .tag(0)

                    AIChatView()
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

                    BadgesView()
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
                .overlay(alignment: .center) {
                    LevelUpCelebrationView(
                        isShowing: $achievementManager.showLevelUp,
                        achievementLevel: UserProfile.shared.level
                    )
//                    if achievementManager.showLevelUp {
//                        ZStack {
//                            Color.black.opacity(0.9)
//                                .ignoresSafeArea()
//                                .transition(.opacity)
//
//                            congratulationsView
//                                
//                        }
//                    }
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
    
    // MARK: - celebration View
    private var congratulationsView: some View {
        VStack(spacing: 16) {
            Text("🎉 LEVEL UP! 🎉")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.yellow)
                .shadow(color: .yellow.opacity(0.6), radius: 4)
            
            Text("You've reached level \(UserProfile.shared.level) 🎉")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Button("Continue Your Journey") {
                achievementManager.showLevelUp = false
            }
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.yellow, .orange]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: .yellow.opacity(0.4), radius: 10)
            .padding(.horizontal, 20)
        }
        .transition(.scale.combined(with: .opacity))
        .scaleEffect(achievementManager.showLevelUp ? 1.0 : 0.5)
        .opacity(achievementManager.showLevelUp ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: achievementManager.showLevelUp)
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

//    private func loadUserProfile() {
//        DispatchQueue.main.async {
//            do {
//                if let savedProfile = UserDefaults.standard.data(forKey: "userProfile"),
//                   let profile = try? JSONDecoder().decode(UserProfile.self, from: savedProfile) {
//                    self.userProfile = profile
//                    
//                    // Ensure onboarding state is preserved when loading profile
//                    let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
//                    let hasCompletedCalendarSetup = UserDefaults.standard.bool(forKey: "hasCompletedCalendarSetup")
//                    
//                    // If we have a valid profile but flags are missing, restore them
//                    if !hasCompletedOnboarding {
//                        print(" Profile loaded but onboarding flag missing - restoring")
//                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
//                        self.hasCompletedOnboarding = true
//                    }
//                    
//                } else {
//                    self.createDefaultUserProfile()
//                }
//            } catch {
//                print(" Error loading user profile: \(error)")
//                self.createDefaultUserProfile()
//            }
//        }
//    }

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
                }
            } catch {
                print("📅 ContentView: Error saving events: \(error)")
            }
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
        ) { _ in
            print(" ContentView: Events modified notification received - saving events")
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
        
        // Force synchronize UserDefaults to ensure changes are saved immediately
        UserDefaults.standard.synchronize()
        print("UserDefaults cleared and synchronized")
        
        // Reset achievement manager first (this clears UserDefaults too)
        achievementManager.resetAllAchievements()
        print("Achievement manager reset completed")
        
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
