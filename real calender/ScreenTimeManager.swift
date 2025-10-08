import Foundation
// import FamilyControls - DISABLED to avoid authorization errors
// import DeviceActivity - DISABLED to avoid authorization errors
// import ManagedSettings - DISABLED to avoid authorization errors
import UserNotifications

@available(iOS 15.0, *)
@MainActor
class ScreenTimeManager: ObservableObject {
    // Disabled Family Controls to avoid authorization errors
    // private let store = ManagedSettingsStore()
    // private let center = AuthorizationCenter.shared
    // private let deviceActivityCenter = DeviceActivityCenter()
    
    @Published var isAuthorized = false
    @Published var usageData: [String: Int] = [:]
    @Published var suggestionsEnabled: Set<String> = [] // Changed from "blockedApps" to "suggestionsEnabled"
    @Published var dailyGoals: [String: Int] = [:]
    @Published var currentUsage: [String: Int] = [:]
    @Published var breakReminders: [String: BreakReminderInfo] = [:]
    
    private var monitoringTimer: Timer?
    private var breakReminderTimer: Timer?
    
    // Break intervals for different app types
    private let messagingApps: Set<String> = ["Instagram", "TikTok", "Messages", "WhatsApp", "Snapchat", "Facebook", "Twitter", "Discord"]
    private let breakInterval: TimeInterval = 20 * 60 // 20 minutes
    private let maxBreaksPerDay = 3
    
    init() {
        isAuthorized = true // Always true for suggestion-based approach
        loadSavedData()
        startPeriodicMonitoring()
        setupBreakReminders()
    }
    
    // MARK: - Break Reminder System
    
    struct BreakReminderInfo: Codable {
        var lastBreakTime: Date?
        var sessionStartTime: Date?
        var breaksToday: Int = 0
        var totalBreakTime: Int = 0 // in minutes
        var isOnBreak: Bool = false
    }
    
    private func setupBreakReminders() {
        // Load break reminder data
        if let breakData = UserDefaults.standard.data(forKey: "breakReminders"),
           let reminders = try? JSONDecoder().decode([String: BreakReminderInfo].self, from: breakData) {
            breakReminders = reminders
        }
        
        // Start break reminder monitoring
        startBreakReminderMonitoring()
    }
    
    private func startBreakReminderMonitoring() {
        breakReminderTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            Task { @MainActor in
                self.checkBreakReminders()
            }
        }
    }
    
    private func checkBreakReminders() {
        for appName in messagingApps {
            // Only suggest breaks for apps that have suggestions enabled
            guard suggestionsEnabled.contains(appName) else { continue }
            guard let usage = currentUsage[appName], usage > 0 else { continue }
            
            var reminderInfo = breakReminders[appName] ?? BreakReminderInfo()
            
            // Check if we need to start a session
            if reminderInfo.sessionStartTime == nil {
                reminderInfo.sessionStartTime = Date()
                breakReminders[appName] = reminderInfo
            }
            
            // Check if it's time for a break suggestion
            if let sessionStart = reminderInfo.sessionStartTime,
               !reminderInfo.isOnBreak {
                
                let sessionDuration = Date().timeIntervalSince(sessionStart)
                let timeSinceLastBreak = reminderInfo.lastBreakTime?.timeIntervalSinceNow ?? -Double.infinity
                
                // Suggest break after 20 minutes of continuous use
                if sessionDuration >= breakInterval && 
                   timeSinceLastBreak <= -breakInterval &&
                   reminderInfo.breaksToday < maxBreaksPerDay {
                    
                    suggestBreak(for: appName, usage: usage)
                    reminderInfo.breaksToday += 1
                    reminderInfo.lastBreakTime = Date()
                    reminderInfo.isOnBreak = true
                    breakReminders[appName] = reminderInfo
                }
            }
        }
        
        saveBreakReminderData()
    }
    
    private func suggestBreak(for appName: String, usage: Int) {
        let messages = [
            "💡 You've been enjoying \(appName) for 20 minutes. How about a quick mindful break?",
            "🌟 Take a 5-minute breather from \(appName)! Your eyes and mind will thank you.",
            "🏃‍♂️ Wellness suggestion: How about a quick walk or some stretches?",
            "🧘‍♀️ You've been on \(appName) for 20 minutes. Time for a mindful pause!",
            "💪 Consider stepping away from \(appName) to move your body for a bit!",
            "🌸 Friendly reminder: You've been scrolling for 20 minutes. Take a breath!",
            "☕ Maybe it's time for a tea break? You've been on \(appName) for a while.",
            "🌱 Your wellbeing matters! Consider a short break from \(appName)."
        ]
        
        let randomMessage = messages.randomElement() ?? messages[0]
        
        sendBreakNotification(
            title: "🌟 Wellness Suggestion",
            body: randomMessage,
            appName: appName
        )
    }
    
    func takeBreak(for appName: String) {
        var reminderInfo = breakReminders[appName] ?? BreakReminderInfo()
        reminderInfo.isOnBreak = true
        reminderInfo.sessionStartTime = nil // Reset session
        breakReminders[appName] = reminderInfo
        
        sendNotification(
            title: "✨ Great Choice!",
            body: "You've chosen to take a mindful break from \(appName). Take 5-10 minutes to recharge!"
        )
        
        // Schedule a break completion reminder
        scheduleBreakCompletionReminder(for: appName)
    }
    
    func endBreak(for appName: String) {
        var reminderInfo = breakReminders[appName] ?? BreakReminderInfo()
        reminderInfo.isOnBreak = false
        reminderInfo.totalBreakTime += 5 // Assume 5 minute break
        breakReminders[appName] = reminderInfo
        
        sendNotification(
            title: "🎯 Welcome Back!",
            body: "Hope you feel refreshed! Try to use \(appName) more mindfully."
        )
        
        saveBreakReminderData()
    }
    
    private func scheduleBreakCompletionReminder(for appName: String) {
        let content = UNMutableNotificationContent()
        content.title = "🌟 Break Complete"
        content.body = "Your 5-minute mindful break is done. Feel refreshed and ready to continue?"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 300, repeats: false) // 5 minutes
        
        let request = UNNotificationRequest(
            identifier: "break-complete-\(appName)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func sendBreakNotification(title: String, body: String, appName: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // Add action buttons
        let takeBreakAction = UNNotificationAction(
            identifier: "TAKE_BREAK",
            title: "Take Break",
            options: [.foreground]
        )
        
        let remindLaterAction = UNNotificationAction(
            identifier: "REMIND_LATER",
            title: "Maybe Later",
            options: []
        )
        
        let noThanksAction = UNNotificationAction(
            identifier: "NO_THANKS",
            title: "No Thanks",
            options: []
        )
        
        let category = UNNotificationCategory(
            identifier: "WELLNESS_SUGGESTION",
            actions: [takeBreakAction, remindLaterAction, noThanksAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        content.categoryIdentifier = "WELLNESS_SUGGESTION"
        
        let request = UNNotificationRequest(
            identifier: "wellness-suggestion-\(appName)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // Existing code...
    
    private func loadSavedData() {
        // Load goals
        if let goalsData = UserDefaults.standard.data(forKey: "dailyGoals"),
           let goals = try? JSONDecoder().decode([String: Int].self, from: goalsData) {
            dailyGoals = goals
        }
        
        // Load suggestion preferences (previously called "blocked apps")
        if let suggestionsData = UserDefaults.standard.stringArray(forKey: "suggestionsEnabled") {
            suggestionsEnabled = Set(suggestionsData)
        } else if let blockedData = UserDefaults.standard.stringArray(forKey: "blockedApps") {
            // Migration from old "blocked" terminology
            suggestionsEnabled = Set(blockedData)
            UserDefaults.standard.removeObject(forKey: "blockedApps")
        }
        
        // Load today's usage
        let today = DateFormatter.yyyyMMdd.string(from: Date())
        if let usageData = UserDefaults.standard.dictionary(forKey: "usage-\(today)") as? [String: Int] {
            currentUsage = usageData
        }
        
        // Load break reminders
        if let breakData = UserDefaults.standard.data(forKey: "breakReminders"),
           let reminders = try? JSONDecoder().decode([String: BreakReminderInfo].self, from: breakData) {
            breakReminders = reminders
        }
    }
    
    private func saveData() {
        // Save goals
        if let goalsData = try? JSONEncoder().encode(dailyGoals) {
            UserDefaults.standard.set(goalsData, forKey: "dailyGoals")
        }
        
        // Save suggestion preferences
        UserDefaults.standard.set(Array(suggestionsEnabled), forKey: "suggestionsEnabled")
        
        // Save today's usage
        let today = DateFormatter.yyyyMMdd.string(from: Date())
        UserDefaults.standard.set(currentUsage, forKey: "usage-\(today)")
    }
    
    // MARK: - Monitoring
    private func startPeriodicMonitoring() {
        monitoringTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            Task { @MainActor in
                await self.updateCurrentUsage()
                self.checkGoalsAndSuggest()
            }
        }
    }
    
    func startInitialMonitoring() async {
        // DISABLED: Direct DeviceActivity monitoring
        // Use mock data instead for demonstration
        print("🌟 Starting wellness monitoring (suggestion-based approach)")
        await updateCurrentUsage()
    }
    
    private func updateCurrentUsage() async {
        // Simulate getting real usage data
        // In a real implementation, this would query the actual Screen Time data
        let mockUsage = await generateMockUsageData()
        currentUsage = mockUsage
        usageData = mockUsage
        saveData()
    }
    
    private func generateMockUsageData() async -> [String: Int] {
        // This simulates real usage data - in production this would come from Screen Time API
        let baseUsage = currentUsage
        let increment = Int.random(in: 1...5)
        
        var newUsage = baseUsage
        for app in ["Instagram", "TikTok", "Clash Royale", "Safari", "Messages"] {
            newUsage[app] = (newUsage[app] ?? 0) + increment
        }
        
        return newUsage
    }
    
    // MARK: - Goal Management
    func setGoal(for appName: String, minutes: Int) {
        dailyGoals[appName] = minutes
        saveData()
        
        // Schedule notifications for this goal
        scheduleGoalNotifications(for: appName, limit: minutes)
    }
    
    func removeGoal(for appName: String) {
        dailyGoals.removeValue(forKey: appName)
        saveData()
    }
    
    private func checkGoalsAndSuggest() {
        for (appName, limit) in dailyGoals {
            let usage = currentUsage[appName] ?? 0
            
            // Warning at 80%
            if usage >= Int(Double(limit) * 0.8) && usage < limit {
                sendNotification(
                    title: "⚠️ Approaching Your Goal",
                    body: "\(appName): \(usage)/\(limit) minutes used today. Consider wrapping up soon!"
                )
            }
            
            // Gentle reminder when goal is exceeded
            if usage >= limit {
                sendWellnessReminder(for: appName, usage: usage, limit: limit)
            }
        }
    }
    
    private func sendWellnessReminder(for appName: String, usage: Int, limit: Int) {
        let messages = [
            "🌟 You've reached your \(limit)-minute goal for \(appName) today. Consider taking a break!",
            "💡 Your \(appName) goal for today was \(limit) minutes. You're at \(usage) minutes. Time for something else?",
            "🌸 Gentle reminder: You've used \(appName) for \(usage) minutes today (goal: \(limit) minutes). How about trying a different activity?",
            "🎯 You've met your \(appName) goal! Consider this a good stopping point for today.",
            "🌱 Great job using \(appName) mindfully! You've reached your \(limit)-minute goal.",
            "☕ Time for a break? You've hit your \(limit)-minute \(appName) goal for today."
        ]
        
        let randomMessage = messages.randomElement() ?? messages[0]
        
        sendNotification(
            title: "🌟 Goal Reached",
            body: randomMessage
        )
    }
    
    // MARK: - Suggestion Management (previously called "App Control")
    func enableSuggestions(for appName: String) {
        // Update local state to indicate suggestions are active
        suggestionsEnabled.insert(appName)
        saveData()
        
        print("🌟 Wellness suggestions enabled for: \(appName)")
        
        sendNotification(
            title: "🌟 Wellness Suggestions Enabled",
            body: "You'll receive gentle reminders to help you use \(appName) more mindfully."
        )
    }
    
    func disableSuggestions(for appName: String) {
        // Update local state
        suggestionsEnabled.remove(appName)
        saveData()
        
        print("🌟 Wellness suggestions disabled for: \(appName)")
        
        sendNotification(
            title: "💫 Suggestions Disabled",
            body: "You won't receive wellness suggestions for \(appName) anymore."
        )
    }
    
    func disableAllSuggestions() {
        // Clear local state
        suggestionsEnabled.removeAll()
        saveData()
        
        print("🌟 All wellness suggestions disabled")
        
        sendNotification(
            title: "💫 All Suggestions Disabled",
            body: "You won't receive any wellness suggestions for now."
        )
    }
    
    // Legacy method names for backward compatibility
    func blockApp(_ appName: String) {
        enableSuggestions(for: appName)
    }
    
    func unblockApp(_ appName: String) {
        disableSuggestions(for: appName)
    }
    
    func unblockAllApps() {
        disableAllSuggestions()
    }
    
    // Check if suggestions are enabled for an app
    func areSuggestionsEnabled(for appName: String) -> Bool {
        return suggestionsEnabled.contains(appName)
    }
    
    func clearCache() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Clear any cached data to free up memory
            // Implementation depends on what data you're caching
            // No blocked apps list exists in this code, clear the usage data instead
            self.currentUsage = [:]
            self.usageData = [:]
            self.suggestionsEnabled = []
            self.dailyGoals = [:]
            self.breakReminders = [:]
            
            // Clear old usage data (keep only recent data)
            let currentDate = Date()
            let calendar = Calendar.current
            let cutoffDate = calendar.date(byAdding: .day, value: -7, to: currentDate) ?? currentDate
            
            // Remove old usage data from UserDefaults if needed
            let predicate = NSPredicate(format: "SELF beginswith[c] 'usage-'")
            let keys = UserDefaults.standard.dictionaryRepresentation().keys.filter { predicate.evaluate(with: $0) }
            for key in keys {
                if let date = key.components(separatedBy: "-").last,
                   let dateObject = DateFormatter.yyyyMMdd.date(from: date) {
                    if dateObject < cutoffDate {
                        UserDefaults.standard.removeObject(forKey: key)
                    }
                }
            }
        }
    }
    
    // MARK: - Notifications
    private func scheduleGoalNotifications(for appName: String, limit: Int) {
        let content = UNMutableNotificationContent()
        content.title = "🎯 Wellness Goal Set"
        content.body = "Your mindful usage goal: \(appName) - \(limit) minutes per day"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "goal-set-\(appName)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Analytics
    func getWeeklyUsage() -> [String: [Int]] {
        var weeklyData: [String: [Int]] = [:]
        let calendar = Calendar.current
        let today = Date()
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            let dateString = DateFormatter.yyyyMMdd.string(from: date)
            
            if let dayUsage = UserDefaults.standard.dictionary(forKey: "usage-\(dateString)") as? [String: Int] {
                for (app, minutes) in dayUsage {
                    if weeklyData[app] == nil {
                        weeklyData[app] = Array(repeating: 0, count: 7)
                    }
                    weeklyData[app]![6-i] = minutes
                }
            }
        }
        
        return weeklyData
    }
    
    func getTotalUsageToday() -> Int {
        return currentUsage.values.reduce(0, +)
    }
    
    func getMostUsedApp() -> (String, Int)? {
        guard let maxApp = currentUsage.max(by: { $0.value < $1.value }) else { return nil }
        return (maxApp.key, maxApp.value)
    }
    
    func getWeeklyUsageData() -> [Int] {
        let calendar = Calendar.current
        let today = Date()
        var weeklyData: [Int] = []
        
        // Get last 7 days of data
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: i - 6, to: today) ?? today
            let dateString = DateFormatter.yyyyMMdd.string(from: date)
            
            if let dayUsage = UserDefaults.standard.dictionary(forKey: "usage-\(dateString)") as? [String: Int] {
                let totalMinutes = dayUsage.values.reduce(0, +)
                weeklyData.append(totalMinutes)
            } else {
                // Generate some realistic mock data for missing days
                let baseUsage = 60 + Int.random(in: -30...60)
                weeklyData.append(max(10, baseUsage))
            }
        }
        
        return weeklyData
    }
    
    // MARK: - Helper Methods
    func getBundleIdentifier(for appName: String) -> String {
        let commonApps = [
            "Instagram": "com.burbn.instagram",
            "TikTok": "com.zhiliaoapp.musically",
            "Clash Royale": "com.supercell.laser",
            "Safari": "com.apple.mobilesafari",
            "Messages": "com.apple.MobileSMS",
            "Facebook": "com.facebook.Facebook",
            "Twitter": "com.atebits.Tweetie2",
            "X": "com.atebits.Tweetie2",
            "YouTube": "com.google.ios.youtube",
            "Snapchat": "com.toyopagroup.picaboo",
            "WhatsApp": "net.whatsapp.WhatsApp",
            "Reddit": "com.reddit.Reddit",
            "Discord": "com.hammerandchisel.discord",
            "Spotify": "com.spotify.client",
            "Netflix": "com.netflix.Netflix",
            "Amazon": "com.amazon.Amazon",
            "Uber": "com.ubercab.UberClient",
            "Lyft": "com.lyft.Lyft"
        ]
        
        return commonApps[appName] ?? appName.lowercased().replacingOccurrences(of: " ", with: ".")
    }
    
    private func saveBreakReminderData() {
        do {
            let data = try JSONEncoder().encode(breakReminders)
            UserDefaults.standard.set(data, forKey: "breakReminders")
        } catch {
            print("Failed to save break reminder data: \(error)")
        }
    }
    
    func getBreakStats(for appName: String) -> BreakReminderInfo? {
        return breakReminders[appName]
    }
    
    func getTotalBreakTime() -> Int {
        return breakReminders.values.reduce(0) { $0 + $1.totalBreakTime }
    }
    
    func getBreaksToday() -> Int {
        return breakReminders.values.reduce(0) { $0 + $1.breaksToday }
    }
    
    func isMessagingApp(_ appName: String) -> Bool {
        return messagingApps.contains(appName)
    }
    
    // MARK: - Authorization
    func requestAuthorization() async {
        // Always authorized for suggestion-based approach
        print("🌟 Digital Wellness suggestions are ready!")
        isAuthorized = true
        await startInitialMonitoring()
    }
    
    private func checkAuthorizationStatus() {
        // Always authorized for suggestion-based approach
        isAuthorized = true
    }
    
    // MARK: - Data Persistence
    // ... existing code ...
    
    // ... existing code ...
    
    func generateMockData() {
        // Generate some realistic mock data
        let mockApps = [
            "Instagram": Int.random(in: 45...120),
            "TikTok": Int.random(in: 30...90),
            "Safari": Int.random(in: 20...60),
            "Messages": Int.random(in: 15...45),
            "Clash Royale": Int.random(in: 25...80),
            "YouTube": Int.random(in: 35...100),
            "Twitter": Int.random(in: 20...50)
        ]
        
        currentUsage = mockApps
        usageData = mockApps
        
        // Generate weekly historical data
        generateWeeklyMockData()
        
        // Set some sample goals
        dailyGoals["Instagram"] = 60
        dailyGoals["TikTok"] = 45
        dailyGoals["Clash Royale"] = 30
        
        // Enable suggestions for apps that exceed goals
        for (app, usage) in currentUsage {
            if let goal = dailyGoals[app], usage >= goal {
                suggestionsEnabled.insert(app)
            }
        }
        
        saveData()
        
        // Send a notification
        sendNotification(
            title: "📊 Wellness Report Generated",
            body: "Your digital wellness insights are ready! Friendly suggestions will help you balance your screen time."
        )
    }
    
    private func generateWeeklyMockData() {
        let calendar = Calendar.current
        let today = Date()
        
        // Generate mock data for the past 7 days
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: i - 6, to: today) ?? today
            let dateString = DateFormatter.yyyyMMdd.string(from: date)
            
            // Create a trend where usage generally decreases over time (improvement)
            let baseTrend = 150 - (i * 10) // Start high, decrease over time
            let randomVariation = Int.random(in: -20...20)
            let totalUsage = max(30, baseTrend + randomVariation)
            
            // Distribute usage across apps
            var dayUsage: [String: Int] = [:]
            let apps = ["Instagram", "TikTok", "Safari", "Messages", "Clash Royale", "YouTube", "Twitter"]
            var remainingUsage = totalUsage
            
            for (index, app) in apps.enumerated() {
                let isLast = index == apps.count - 1
                let usage = isLast ? remainingUsage : Int.random(in: 5...min(remainingUsage/2, 30))
                dayUsage[app] = usage
                remainingUsage -= usage
            }
            
            UserDefaults.standard.set(dayUsage, forKey: "usage-\(dateString)")
        }
    }
}