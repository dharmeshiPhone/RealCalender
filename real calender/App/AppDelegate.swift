import UIKit
import UserNotifications
import BackgroundTasks

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    // Reference to MessageAnalyzer for URL handling
    var messageAnalyzer: MessageAnalyzer?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        // Google Places initialization (currently disabled)
        // Uncomment when Google Places SDK is properly integrated:
        // GooglePlacesConfig.validateConfiguration()
        // GMSServices.provideAPIKey(GooglePlacesConfig.apiKey)
        
        // Configure notifications
        setupNotifications()
        
        // Register background tasks
        registerBackgroundTasks()
        
        // Set up initial app state
        setupInitialState()
        
        // Set up development keyboard shortcuts
        setupDevKeyboardShortcuts()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session
    }
    
    
    
    // MARK: - URL Scheme Handling
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Handle URL scheme for Shortcuts integration
        if url.scheme == "realcalendar" {
            handleShortcutURL(url)
            return true
        }
        return false
    }
    
    private func handleShortcutURL(_ url: URL) {
        // Post notification to handle URL in the app
        NotificationCenter.default.post(
            name: Notification.Name("shortcutURLReceived"),
            object: nil,
            userInfo: ["url": url]
        )
    }
    
    // MARK: - Background Tasks
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleBackgroundTasks()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Refresh data when app comes to foreground
        NotificationCenter.default.post(name: Notification.Name("appWillEnterForeground"), object: nil)
    }
    
    // MARK: - Setup Methods
    
    private func setupNotifications() {
        UNUserNotificationCenter.current().delegate = self
        
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("🚫 Notification authorization error: \(error)")
            } else {
                print("✅ Notification authorization granted: \(granted)")
            }
        }
        
        // Set up notification categories
        setupNotificationCategories()
    }
    
    private func setupNotificationCategories() {
        // App Blocked category with actions
        let unblockAction = UNNotificationAction(
            identifier: "UNBLOCK_ACTION",
            title: "Unblock for 15 min",
            options: []
        )
        
        let extendAction = UNNotificationAction(
            identifier: "EXTEND_ACTION",
            title: "Extend limit by 30 min",
            options: []
        )
        
        let appBlockedCategory = UNNotificationCategory(
            identifier: "APP_BLOCKED",
            actions: [unblockAction, extendAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        // Goal Achievement category
        let celebrateAction = UNNotificationAction(
            identifier: "CELEBRATE_ACTION",
            title: "🎉 Awesome!",
            options: []
        )
        
        let goalAchievedCategory = UNNotificationCategory(
            identifier: "GOAL_ACHIEVED",
            actions: [celebrateAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([
            appBlockedCategory,
            goalAchievedCategory
        ])
    }
    
    private func registerBackgroundTasks() {
        // Usage monitoring task
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.yourname.screentimecalendar.usage-check",
            using: nil
        ) { task in
            self.handleUsageCheck(task: task as! BGAppRefreshTask)
        }
        
        // Goal checking task
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.yourname.screentimecalendar.goal-check",
            using: nil
        ) { task in
            self.handleGoalCheck(task: task as! BGAppRefreshTask)
        }
        
        // Daily summary task
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.yourname.screentimecalendar.daily-summary",
            using: nil
        ) { task in
            self.handleDailySummary(task: task as! BGAppRefreshTask)
        }
    }
    
    private func setupInitialState() {
        // Initialize default settings if first launch
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            
            // Set default notification preferences
            UserDefaults.standard.set(true, forKey: "notificationsEnabled")
            UserDefaults.standard.set(true, forKey: "dailySummaryEnabled")
            UserDefaults.standard.set(true, forKey: "goalRemindersEnabled")
            
            print("✅ First launch setup completed")
        }
    }
    
    private func setupDevKeyboardShortcuts() {
        print("📱 Setting up development keyboard shortcuts...")
        
        // Note: In iOS 13+ with scene-based apps, keyboard shortcuts are handled in SceneDelegate
        // This is kept for compatibility and additional setup if needed
        
        // Set up notification listeners for keyboard shortcuts
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("DevResetApp"),
            object: nil,
            queue: .main
        ) { _ in
            performCompleteAppReset()
        }
    }
    
    @objc private func resetAppViaKeyboard() {
        print("🔄 Keyboard shortcut triggered - performing complete app reset")
        performCompleteAppReset()
    }
    
  

    
    // MARK: - Background Task Scheduling
    
    private func scheduleBackgroundTasks() {
        scheduleUsageCheck()
        scheduleGoalCheck()
        scheduleDailySummary()
    }
    
    private func scheduleUsageCheck() {
        let request = BGAppRefreshTaskRequest(identifier: "com.yourname.screentimecalendar.usage-check")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ Usage check task scheduled")
        } catch {
            print("❌ Failed to schedule usage check: \(error)")
        }
    }
    
    private func scheduleGoalCheck() {
        let request = BGAppRefreshTaskRequest(identifier: "com.yourname.screentimecalendar.goal-check")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 30 * 60) // 30 minutes
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ Goal check task scheduled")
        } catch {
            print("❌ Failed to schedule goal check: \(error)")
        }
    }
    
    private func scheduleDailySummary() {
        let request = BGAppRefreshTaskRequest(identifier: "com.yourname.screentimecalendar.daily-summary")
        
        // Schedule for 9 PM today or tomorrow if past 9 PM
        let calendar = Calendar.current
        let now = Date()
        var summaryTime = calendar.date(bySettingHour: 21, minute: 0, second: 0, of: now)!
        
        if summaryTime <= now {
            summaryTime = calendar.date(byAdding: .day, value: 1, to: summaryTime)!
        }
        
        request.earliestBeginDate = summaryTime
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ Daily summary task scheduled for \(summaryTime)")
        } catch {
            print("❌ Failed to schedule daily summary: \(error)")
        }
    }
    
    // MARK: - Background Task Handlers
    
    private func handleUsageCheck(task: BGAppRefreshTask) {
        // Schedule next background refresh
        scheduleUsageCheck()
        
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        // Check current usage and enforce limits
        Task {
            await performUsageCheck()
            task.setTaskCompleted(success: true)
        }
    }
    
    private func handleGoalCheck(task: BGAppRefreshTask) {
        // Schedule next goal check
        scheduleGoalCheck()
        
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        // Check goals and send notifications
        Task {
            await performGoalCheck()
            task.setTaskCompleted(success: true)
        }
    }
    
    private func handleDailySummary(task: BGAppRefreshTask) {
        // Schedule next daily summary
        scheduleDailySummary()
        
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        // Generate and send daily summary
        Task {
            await performDailySummary()
            task.setTaskCompleted(success: true)
        }
    }
    
    // MARK: - Background Task Logic
    
    private func performUsageCheck() async {
        print("🔍 Performing background usage check...")
        
        // Get current usage data
        let today = DateFormatter.yyyyMMdd.string(from: Date())
        let currentUsage = UserDefaults.standard.dictionary(forKey: "usage-\(today)") as? [String: Int] ?? [:]
        
        // Load goals
        guard let goalsData = UserDefaults.standard.data(forKey: "dailyGoals"),
              let goals = try? JSONDecoder().decode([String: Int].self, from: goalsData) else {
            return
        }
        
        // Check for violations
        for (appName, limit) in goals {
            let usage = currentUsage[appName] ?? 0
            
            if usage >= limit {
                // Block the app and send notification
                await blockAppAndNotify(appName: appName, usage: usage, limit: limit)
            } else if usage >= Int(Double(limit) * 0.8) {
                // Send warning notification
                await sendWarningNotification(appName: appName, usage: usage, limit: limit)
            }
        }
    }
    
    private func performGoalCheck() async {
        print("🎯 Performing background goal check...")
        
        // Check if user is meeting their goals
        let today = DateFormatter.yyyyMMdd.string(from: Date())
        let currentUsage = UserDefaults.standard.dictionary(forKey: "usage-\(today)") as? [String: Int] ?? [:]
        
        guard let goalsData = UserDefaults.standard.data(forKey: "dailyGoals"),
              let goals = try? JSONDecoder().decode([String: Int].self, from: goalsData) else {
            return
        }
        
        var goalsAchieved = 0
        var totalGoals = goals.count
        
        for (appName, limit) in goals {
            let usage = currentUsage[appName] ?? 0
            if usage < limit {
                goalsAchieved += 1
            }
        }
        
        // Send encouragement notification if doing well
        if goalsAchieved == totalGoals && totalGoals > 0 {
            await sendGoalAchievementNotification(goalsAchieved: goalsAchieved)
        }
    }
    
    private func performDailySummary() async {
        print("📊 Performing daily summary...")
        
        let today = DateFormatter.yyyyMMdd.string(from: Date())
        let currentUsage = UserDefaults.standard.dictionary(forKey: "usage-\(today)") as? [String: Int] ?? [:]
        
        let totalMinutes = currentUsage.values.reduce(0, +)
        let appCount = currentUsage.count
        let mostUsedApp = currentUsage.max(by: { $0.value < $1.value })
        
        var summaryText = "📱 Daily Summary\n"
        summaryText += "Total screen time: \(totalMinutes) minutes\n"
        summaryText += "Apps used: \(appCount)\n"
        
        if let mostUsed = mostUsedApp {
            summaryText += "Most used: \(mostUsed.key) (\(mostUsed.value) min)"
        }
        
        await sendDailySummaryNotification(summary: summaryText)
    }
    
    // MARK: - Notification Helpers
    
    private func blockAppAndNotify(appName: String, usage: Int, limit: Int) async {
        // Add to blocked apps
        var blockedApps = UserDefaults.standard.stringArray(forKey: "blockedApps") ?? []
        if !blockedApps.contains(appName) {
            blockedApps.append(appName)
            UserDefaults.standard.set(blockedApps, forKey: "blockedApps")
        }
        
        // Send notification
        let content = UNMutableNotificationContent()
        content.title = "🚫 App Blocked"
        content.body = "\(appName) blocked - you've used \(usage)/\(limit) minutes today"
        content.sound = .default
        content.categoryIdentifier = "APP_BLOCKED"
        
        let request = UNNotificationRequest(
            identifier: "block-\(appName)-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        
        try? await UNUserNotificationCenter.current().add(request)
    }
    
    private func sendWarningNotification(appName: String, usage: Int, limit: Int) async {
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Approaching Limit"
        content.body = "\(appName): \(usage)/\(limit) minutes used - consider taking a break!"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "warning-\(appName)-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        
        try? await UNUserNotificationCenter.current().add(request)
    }
    
    private func sendGoalAchievementNotification(goalsAchieved: Int) async {
        let content = UNMutableNotificationContent()
        content.title = "🎉 Goals Achieved!"
        content.body = "Great job! You're meeting all \(goalsAchieved) of your daily goals!"
        content.sound = .default
        content.categoryIdentifier = "GOAL_ACHIEVED"
        
        let request = UNNotificationRequest(
            identifier: "achievement-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        
        try? await UNUserNotificationCenter.current().add(request)
    }
    
    private func sendDailySummaryNotification(summary: String) async {
        let content = UNMutableNotificationContent()
        content.title = "📊 Daily Summary"
        content.body = summary
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "summary-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        
        try? await UNUserNotificationCenter.current().add(request)
    }
    
    private func handleUnblockAction(notification: UNNotification) {
        // Extract app name from notification
        let body = notification.request.content.body
        // Implementation would unblock the app temporarily
        print("🔓 Temporary unblock requested")
    }
    
    private func handleExtendAction(notification: UNNotification) {
        // Extend the limit for the app
        print("⏰ Limit extension requested")
    }
    
    private func handleCelebrateAction() {
        // User acknowledged goal achievement
        print("🎉 User celebrated goal achievement")
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let actionIdentifier = response.actionIdentifier
        let notification = response.notification
        
        switch actionIdentifier {
        case "UNBLOCK_ACTION":
            handleUnblockAction(notification: notification)
            
        case "EXTEND_ACTION":
            handleExtendAction(notification: notification)
            
        case "CELEBRATE_ACTION":
            handleCelebrateAction()
            
        default:
            // Default tap action - open app
            break
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
}
