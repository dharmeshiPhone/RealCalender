import DeviceActivity
import Foundation
import UserNotifications

@available(iOS 15.0, *)
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        print("📱 Device activity monitoring started for: \(activity)")
        
        // Reset daily counters
        let today = DateFormatter.yyyyMMdd.string(from: Date())
        UserDefaults.standard.set([:], forKey: "usage-\(today)")
        
        // Send notification that tracking has started
        sendNotification(
            title: "📱 Daily Tracking Started", 
            body: "Screen time monitoring is now active for today"
        )
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        print("📱 Device activity monitoring ended for: \(activity)")
        
        // Get final usage data and save it
        let today = DateFormatter.yyyyMMdd.string(from: Date())
        let usageData = UserDefaults.standard.dictionary(forKey: "usage-\(today)") as? [String: Int] ?? [:]
        
        // Save to history
        saveDailyUsageToHistory(usageData)
        
        // Send daily summary notification
        let totalMinutes = usageData.values.reduce(0, +)
        let appCount = usageData.count
        
        sendNotification(
            title: "📊 Daily Summary", 
            body: "Total screen time: \(totalMinutes) minutes across \(appCount) apps"
        )
        
        // Check if any goals were exceeded
        checkGoalViolations(usageData)
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        print("⚠️ Threshold reached for event: \(event)")
        
        // Extract app name from event
        if let appName = extractAppName(from: event) {
            // Block the app
            blockAppInUserDefaults(appName)
            
            // Send notification
            sendNotification(
                title: "🚫 App Blocked", 
                body: "\(appName) has been blocked due to reaching your daily limit"
            )
            
            // Log the violation
            logGoalViolation(appName: appName)
        }
    }
    
    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
        
        print("⚠️ Approaching threshold for event: \(event)")
        
        if let appName = extractAppName(from: event) {
            sendNotification(
                title: "⚠️ Usage Warning", 
                body: "\(appName) is approaching your daily limit. Consider taking a break!"
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private func extractAppName(from event: DeviceActivityEvent.Name) -> String? {
        // Extract app name from event name
        let eventString = event.rawValue
        
        // Event names are typically formatted like "app-name-limit" or similar
        let components = eventString.components(separatedBy: "-")
        return components.first
    }
    
    private func blockAppInUserDefaults(_ appName: String) {
        var blockedApps = UserDefaults.standard.stringArray(forKey: "blockedApps") ?? []
        if !blockedApps.contains(appName) {
            blockedApps.append(appName)
            UserDefaults.standard.set(blockedApps, forKey: "blockedApps")
        }
        
        print("🚫 Added \(appName) to blocked apps list")
    }
    
    private func saveDailyUsageToHistory(_ usage: [String: Int]) {
        let today = DateFormatter.yyyyMMdd.string(from: Date())
        
        // Save individual day
        UserDefaults.standard.set(usage, forKey: "usage-\(today)")
        
        // Add to history array for analytics
        var history = UserDefaults.standard.array(forKey: "usageHistory") as? [[String: Any]] ?? []
        
        // Remove existing entry for today if it exists
        history.removeAll { entry in
            if let date = entry["date"] as? String {
                return date == today
            }
            return false
        }
        
        // Add new entry
        history.append([
            "date": today,
            "apps": usage,
            "totalMinutes": usage.values.reduce(0, +)
        ])
        
        // Keep only last 90 days
        if history.count > 90 {
            history = Array(history.suffix(90))
        }
        
        UserDefaults.standard.set(history, forKey: "usageHistory")
        
        print("💾 Saved usage data for \(today): \(usage)")
    }
    
    private func checkGoalViolations(_ usage: [String: Int]) {
        // Load goals from UserDefaults
        guard let goalsData = UserDefaults.standard.data(forKey: "dailyGoals"),
              let goals = try? JSONDecoder().decode([String: Int].self, from: goalsData) else {
            return
        }
        
        var violations: [String] = []
        
        for (appName, limit) in goals {
            let actualUsage = usage[appName] ?? 0
            if actualUsage > limit {
                violations.append("\(appName): \(actualUsage)/\(limit) min")
            }
        }
        
        if !violations.isEmpty {
            sendNotification(
                title: "🚨 Goals Exceeded",
                body: "You exceeded your limits for: \(violations.joined(separator: ", "))"
            )
        }
    }
    
    private func logGoalViolation(appName: String) {
        let today = DateFormatter.yyyyMMdd.string(from: Date())
        var violations = UserDefaults.standard.stringArray(forKey: "violations-\(today)") ?? []
        
        if !violations.contains(appName) {
            violations.append(appName)
            UserDefaults.standard.set(violations, forKey: "violations-\(today)")
        }
    }
    
    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        // Add action buttons for some notifications
        if title.contains("Blocked") {
            let unblockAction = UNNotificationAction(
                identifier: "UNBLOCK_ACTION",
                title: "Unblock for 15 min",
                options: []
            )
            
            let category = UNNotificationCategory(
                identifier: "APP_BLOCKED",
                actions: [unblockAction],
                intentIdentifiers: [],
                options: []
            )
            
            UNUserNotificationCenter.current().setNotificationCategories([category])
            content.categoryIdentifier = "APP_BLOCKED"
        }
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to send notification: \(error)")
            } else {
                print("✅ Notification sent: \(title)")
            }
        }
    }
}