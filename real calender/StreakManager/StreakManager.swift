//
//  StreakManager.swift
//  real calender
//
//  Created by Mac on 03/12/25.
//

import Foundation
import SwiftUI

//class StreakManager: ObservableObject {
//    @Published var currentStreak: Int = 0
//    @Published var lastLoginDate: Date?
//    @Published var shouldShowPopup: Bool = false
//    @Published var totalDaysLogged: Int = 0
//    @Published var longestStreak: Int = 0
//
//
//    init() {
//        loadStreakData()
//        checkDailyLogin()
//    }
//
//    private func loadStreakData() {
//        let defaults = UserDefaults.standard
//        currentStreak = defaults.integer(forKey: "currentStreak")
//        totalDaysLogged = defaults.integer(forKey: "totalDaysLogged")
//        longestStreak = defaults.integer(forKey: "longestStreak")
//
//        if let savedDate = defaults.object(forKey: "lastLoginDate") as? Date {
//            lastLoginDate = savedDate
//        }
//    }
//
//    private func saveStreakData() {
//        let defaults = UserDefaults.standard
//        defaults.set(currentStreak, forKey: "currentStreak")
//        defaults.set(totalDaysLogged, forKey: "totalDaysLogged")
//        defaults.set(longestStreak, forKey: "longestStreak")
//        defaults.set(lastLoginDate, forKey: "lastLoginDate")
//    }
//
//    func checkDailyLogin() {
//        let now = Date()
//        let calendar = Calendar.current
//
//        // If first time user
//        // First-time login
//        guard let lastDate = lastLoginDate else {
//            currentStreak = 1
//            totalDaysLogged = 1
//            longestStreak = 1
//            lastLoginDate = now
//            saveStreakData()
//            shouldShowPopup = true
//            return
//        }
//
//        // Check if already logged in today
//        if calendar.isDateInToday(lastDate) {
//            shouldShowPopup = false
//            return
//        }
//
//        // Check if logged in yesterday (maintain streak)
//        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
//           calendar.isDate(lastDate, inSameDayAs: yesterday) {
//            currentStreak += 1
//        } else {
//            // Reset streak if missed a day
//            currentStreak = 1
//        }
//
//        // Update longest streak if needed
//        if currentStreak > longestStreak {
//            longestStreak = currentStreak
//        }
//
//        // Update day counters
//        lastLoginDate = now
//        totalDaysLogged += 1
//        saveStreakData()
//        shouldShowPopup = true
//    }
//
//
//
//    func markPopupShown() {
//        shouldShowPopup = false
//    }
//}




// MARK: - Updated StreakManager
import Foundation
import SwiftUI

class StreakManager: ObservableObject {
    @Published var currentStreak: Int = 0
    @Published var lastLoginDate: Date?
    @Published var shouldShowStreakPopup: Bool = false
    @Published var shouldShowFreezePopup: Bool = false
    @Published var shouldShowSaverPopup: Bool = false
    @Published var shouldShowWelcomeBackPopup: Bool = false // Welcome back popup flag
    
    @Published var totalDaysLogged: Int = 0
    @Published var longestStreak: Int = 0
    
    // Streak saver state
    @Published var hasUsedFreeze: Bool = false
    @Published var hasSaverAvailable: Bool = false
    @Published var hasSeenDay7Offer: Bool = false
    @Published var hasSeenDay30Offer: Bool = false
    
    // Welcome back state
    @Published var hasReceivedWelcomeBackGift: Bool = false  // NEW: Prevent gift spam
    @Published var lastWelcomeBackGiftDate: Date?  // NEW: Track last gift date
    
    
    init() {
        loadStreakData()
        checkDailyLogin()
    }
    
    private func loadStreakData() {
        let defaults = UserDefaults.standard
        currentStreak = defaults.integer(forKey: "currentStreak")
        totalDaysLogged = defaults.integer(forKey: "totalDaysLogged")
        longestStreak = defaults.integer(forKey: "longestStreak")
        hasUsedFreeze = defaults.bool(forKey: "hasUsedFreeze")
        hasSaverAvailable = defaults.bool(forKey: "hasSaverAvailable")
        hasSeenDay7Offer = defaults.bool(forKey: "hasSeenDay7Offer")
        hasSeenDay30Offer = defaults.bool(forKey: "hasSeenDay30Offer")
        hasReceivedWelcomeBackGift = defaults.bool(forKey: "hasReceivedWelcomeBackGift")
        
        if let savedDate = defaults.object(forKey: "lastLoginDate") as? Date {
            lastLoginDate = savedDate
        }
        
        if let savedGiftDate = defaults.object(forKey: "lastWelcomeBackGiftDate") as? Date {
            lastWelcomeBackGiftDate = savedGiftDate
        }
    }
    
    private func saveStreakData() {
        let defaults = UserDefaults.standard
        defaults.set(currentStreak, forKey: "currentStreak")
        defaults.set(totalDaysLogged, forKey: "totalDaysLogged")
        defaults.set(longestStreak, forKey: "longestStreak")
        defaults.set(hasUsedFreeze, forKey: "hasUsedFreeze")
        defaults.set(hasSaverAvailable, forKey: "hasSaverAvailable")
        defaults.set(hasSeenDay7Offer, forKey: "hasSeenDay7Offer")
        defaults.set(hasSeenDay30Offer, forKey: "hasSeenDay30Offer")
        defaults.set(lastLoginDate, forKey: "lastLoginDate")
        
        defaults.set(hasReceivedWelcomeBackGift, forKey: "hasReceivedWelcomeBackGift")
        defaults.set(lastWelcomeBackGiftDate, forKey: "lastWelcomeBackGiftDate")
    }
    
    func checkDailyLogin() {
        let now = Date()
        let calendar = Calendar.current
        
        // First-time login
        guard let lastDate = lastLoginDate else {
            currentStreak = 1
            totalDaysLogged = 1
            longestStreak = 1
            lastLoginDate = now
            saveStreakData()
            shouldShowStreakPopup = true
            return
        }
        
        // Check if already logged in today
        if calendar.isDateInToday(lastDate) {
            shouldShowStreakPopup = false
            shouldShowFreezePopup = false
            shouldShowSaverPopup = false
            shouldShowWelcomeBackPopup = false
            return
        }
        
        
        
        // Check how many days since last login
        let daysSinceLastLogin = calendar.dateComponents([.day], from: lastDate, to: now).day ?? 0
        
        
        //  Checked for welcome back (more than 3 days away)
        if daysSinceLastLogin > 3 {
            // Only show welcome back if we haven't given a gift in this return cycle
            if !hasReceivedWelcomeBackGift {
                shouldShowWelcomeBackPopup = true
                hasReceivedWelcomeBackGift = true
                lastWelcomeBackGiftDate = now
            }
        } else {
            // Reset gift flag if it's been less than 3 days since last gift
            if let lastGiftDate = lastWelcomeBackGiftDate {
                let daysSinceLastGift = calendar.dateComponents([.day], from: lastGiftDate, to: now).day ?? 0
                if daysSinceLastGift <= 3 {
                    hasReceivedWelcomeBackGift = false
                }
            }
        }
        
        if daysSinceLastLogin == 1 {
            // Consecutive login
            currentStreak += 1
            shouldShowStreakPopup = true
        } else if daysSinceLastLogin == 2 && !hasUsedFreeze {
            // Missed one day, use freeze
            currentStreak += 1 // Don't break streak
            hasUsedFreeze = true
            shouldShowFreezePopup = true
        } else if daysSinceLastLogin == 2 && hasSaverAvailable {
            // Use streak saver
            currentStreak += 1
            hasSaverAvailable = false
            shouldShowFreezePopup = true // Show similar popup for saver
        } else {
            // Break streak
            currentStreak = 1
            shouldShowStreakPopup = true
        }
        
        // Check for special offers
        if currentStreak == 7 && !hasSeenDay7Offer {
            shouldShowSaverPopup = true
            hasSeenDay7Offer = true
        } else if currentStreak == 30 && !hasSeenDay30Offer {
            shouldShowSaverPopup = true
            hasSeenDay30Offer = true
        }
        
        // Update longest streak if needed
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
        
        // Update day counters
        lastLoginDate = now
        totalDaysLogged += 1
        saveStreakData()
    }
    
    func markPopupShown() {
        shouldShowStreakPopup = false
        shouldShowFreezePopup = false
        shouldShowSaverPopup = false
        shouldShowWelcomeBackPopup = false
    }
    
    func buybuyStreakSaver(){
        hasSaverAvailable = true
        saveStreakData()
    }
    
    func claimWelcomeBackGift() {
        shouldShowWelcomeBackPopup = false
        // Reset flag so user can get gift on next qualifying return
        hasReceivedWelcomeBackGift = false
        saveStreakData()
    }
    
}




