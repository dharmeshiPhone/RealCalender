//
//  StreakManager.swift
//  real calender
//
//  Created by Mac on 03/12/25.
//

import Foundation
import SwiftUI

class StreakManager: ObservableObject {
    @Published var currentStreak: Int = 0
    @Published var lastLoginDate: Date?
    @Published var shouldShowPopup: Bool = false
    @Published var totalDaysLogged: Int = 0
    @Published var longestStreak: Int = 0
    
    private let userDefaultsKey = "StreakData"
    
    init() {
        loadStreakData()
        checkDailyLogin()
    }
    
    private func loadStreakData() {
        let defaults = UserDefaults.standard
        currentStreak = defaults.integer(forKey: "currentStreak")
        totalDaysLogged = defaults.integer(forKey: "totalDaysLogged")
        longestStreak = defaults.integer(forKey: "longestStreak")
        
        if let savedDate = defaults.object(forKey: "lastLoginDate") as? Date {
            lastLoginDate = savedDate
        }
    }
    
    private func saveStreakData() {
        let defaults = UserDefaults.standard
        defaults.set(currentStreak, forKey: "currentStreak")
        defaults.set(totalDaysLogged, forKey: "totalDaysLogged")
        defaults.set(longestStreak, forKey: "longestStreak")
        defaults.set(lastLoginDate, forKey: "lastLoginDate")
    }
    
    func checkDailyLogin() {
        let now = Date()
        let calendar = Calendar.current
        
        // If first time user
        // First-time login
        guard let lastDate = lastLoginDate else {
            currentStreak = 1
            totalDaysLogged = 1
            longestStreak = 1
            lastLoginDate = now
            saveStreakData()
            shouldShowPopup = true
            return
        }
        
        // Check if already logged in today
        if calendar.isDateInToday(lastDate) {
            shouldShowPopup = false
            return
        }
        
        // Check if logged in yesterday (maintain streak)
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
           calendar.isDate(lastDate, inSameDayAs: yesterday) {
            currentStreak += 1
        } else {
            // Reset streak if missed a day
            currentStreak = 1
        }
        
        // Update longest streak if needed
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
        
        // Update day counters
        lastLoginDate = now
        totalDaysLogged += 1
        saveStreakData()
        shouldShowPopup = true
    }
    
//    private func resetForNewDay(_ date: Date) {
//        lastLoginDate = date
//        currentStreak = 1
//        totalDaysLogged += 1
//        saveStreakData()
//    }
    
    func markPopupShown() {
        shouldShowPopup = false
    }
}
