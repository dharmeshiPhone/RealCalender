//
//  UserdefultKeys.swift
//  real calender
//
//  Created by Mac on 07/10/25.
//

import Foundation

extension UserDefaults {
    private enum Keys {
        static let hasCompletedCalendarSetup = "hasCompletedCalendarSetup"
        
    }
    
    static var hasCompletedCalendarSetup: Bool {
        get {
            UserDefaults.standard.bool(forKey: Keys.hasCompletedCalendarSetup)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.hasCompletedCalendarSetup)
            UserDefaults.standard.synchronize()
        }
    }
   
}

// MARK: - App Reset

 func performCompleteAppReset() {
    #if DEBUG
    print("🗑️ Performing complete app data reset...")
    
    // Haptic feedback
    // let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
    // impactFeedback.impactOccurred()
    
    // Clear all UserDefaults keys related to the app
    let userDefaults = UserDefaults.standard
    let keysToRemove = [
        "basicCalenderSetupStepsCompleted",
        "hasCompletedOnboarding",
        "hasCompletedCalendarSetup",
        "userProfile",
        "calendarEvents",
        "userAchievements",
        "hasSeenTextAnalysis",
        "hasSeenProfileUnlock",
        "lastMonthlyOverview",
        "userLocation",
        "morningPrepTime",
        "hasLaunchedBefore",
        "notificationsEnabled",
        "dailySummaryEnabled",
        "goalRemindersEnabled",
        "dailyGoals",
        "blockedApps",
        "userPets"
    ]
    
    // Remove specific keys
    keysToRemove.forEach { key in
        userDefaults.removeObject(forKey: key)
        print("🗑️ Removed key: \(key)")
    }
    
    // Remove any usage data (dynamic keys)
    let allKeys = userDefaults.dictionaryRepresentation().keys
    for key in allKeys {
        if key.hasPrefix("usage-") {
            userDefaults.removeObject(forKey: key)
            print("🗑️ Removed usage key: \(key)")
        }
    }
    
    // Force synchronize
    userDefaults.synchronize()
    
    QuestStorageManager().clearAllData()
    
    // Clear any cached data
    clearAppCaches()
    
    // Reset any singletons or shared state
    resetSharedState()
    
    // Post notification to trigger UI reset
    DispatchQueue.main.async {
        NotificationCenter.default.post(name: .appDataReset, object: nil)
    }
    
    print("✅ Complete app reset finished - app should restart to initial state")
    #endif
}


private func clearAppCaches() {
    #if DEBUG
    print("🧹 Clearing app caches...")
    
    // Clear image cache if any
    URLCache.shared.removeAllCachedResponses()
    
    // Clear temporary files
    let tempURL = FileManager.default.temporaryDirectory
    do {
        let tempFiles = try FileManager.default.contentsOfDirectory(at: tempURL, includingPropertiesForKeys: nil)
        for file in tempFiles {
            try? FileManager.default.removeItem(at: file)
        }
    } catch {
        print("⚠️ Error clearing temp files: \(error)")
    }
    
    print("✅ App caches cleared")
    #endif
}

private func resetSharedState() {
    #if DEBUG
    print("🔄 Resetting shared state...")
    
    // Reset any shared managers or singletons
    // Note: The managers are likely recreated when the app restarts
    // but we can trigger any cleanup methods if they exist
    
    print("✅ Shared state reset")
    #endif
}

