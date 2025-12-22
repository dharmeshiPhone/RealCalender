//
//  BadgeStorage.swift
//  real calender
//
//  Created by Mac on 16/12/25.
//

import SwiftUI
import Foundation


final class BadgeStorage {
    static let shared = BadgeStorage()
    private let key = "user_badges"
    
    func loadBadgesFromStorage() -> [BadgeCategory: [Badge]]? {
        guard let data = UserDefaults.standard.data(forKey: "userBadges") else {
            return nil
        }
        return try? JSONDecoder().decode([BadgeCategory: [Badge]].self, from: data)
    }
    
    func saveBadgesToStorage(_ badges: [BadgeCategory: [Badge]]) {
        if let data = try? JSONEncoder().encode(badges) {
            UserDefaults.standard.set(data, forKey: "userBadges")
        }
    }
    
 
    
    func checkedUserBadgesComplitions(_ badges: [BadgeCategory: [Badge]], level:Int) -> [BadgeCategory: [Badge]] {

        var updatedBadges = badges
        let user = UserProfile.shared
        let now = Date()

        // MARK: - Activity → Runner
        if var activityBadges = updatedBadges[.activity] {
            for index in activityBadges.indices {
                if activityBadges[index].title == "Runner" {
                    let progress = min(Double(user.numRunningGraphUpdated) / 5.0, 1.0)
                    let shouldUnlock = progress >= 1.0

                    activityBadges[index] = Badge(
                        id: activityBadges[index].id,
                        title: activityBadges[index].title,
                        description: activityBadges[index].description,
                        iconName: activityBadges[index].iconName,
                        gradientColors: activityBadges[index].gradientColors,
                        requirement: activityBadges[index].requirement,
                        progress: progress,
                        isUnlocked: shouldUnlock || activityBadges[index].isUnlocked,
                        unlockDate: shouldUnlock && activityBadges[index].unlockDate == nil ? now : activityBadges[index].unlockDate,
                        reward: activityBadges[index].reward,
                        category: .activity
                    )
                }
            }
            updatedBadges[.activity] = activityBadges
        }

        // MARK: - Health → Health Tracker
        if var healthBadges = updatedBadges[.health] {
            for index in healthBadges.indices {
                if healthBadges[index].title == "Health Tracker" {
                    let progress = min(Double(user.numBMIGraphUpdated) / 10.0, 1.0)
                    let shouldUnlock = progress >= 1.0

                    healthBadges[index] = Badge(
                        id: healthBadges[index].id,
                        title: healthBadges[index].title,
                        description: healthBadges[index].description,
                        iconName: healthBadges[index].iconName,
                        gradientColors: healthBadges[index].gradientColors,
                        requirement: healthBadges[index].requirement,
                        progress: progress,
                        isUnlocked: shouldUnlock || healthBadges[index].isUnlocked,
                        unlockDate: shouldUnlock && healthBadges[index].unlockDate == nil ? now : healthBadges[index].unlockDate,
                        reward: healthBadges[index].reward,
                        category: .health
                    )
                }
            }
            updatedBadges[.health] = healthBadges
        }

        // MARK: - Special → Data Nerd
        if var specialBadges = updatedBadges[.special] {
            for index in specialBadges.indices {
                if specialBadges[index].title == "Data Nerd" {

                    // MARK: - Count completed graphs
                    var completedGraphs = 0

                    if user.numBMIGraphUpdated > 0 { completedGraphs += 1 }
                    if user.numIncomeGraphUpdated > 0 { completedGraphs += 1 }
                    if user.numPullupsGraphUpdated > 0 { completedGraphs += 1 }
                    if user.numRunningGraphUpdated > 0 { completedGraphs += 1 }
                    if user.swimming50MLaps > 0 { completedGraphs += 1 }

                    // Student-only graph
                    let totalGraphs = user.isStudent ? 6 : 5
                    if user.isStudent, user.numAcedemicGraphUpdated > 0 {
                        completedGraphs += 1
                    }

                    let progress = min(Double(completedGraphs) / Double(totalGraphs), 1.0)
                    let shouldUnlock = progress >= 1.0

                    specialBadges[index] = Badge(
                        id: specialBadges[index].id,
                        title: specialBadges[index].title,
                        description: specialBadges[index].description,
                        iconName: specialBadges[index].iconName,
                        gradientColors: specialBadges[index].gradientColors,
                        requirement: specialBadges[index].requirement,
                        progress: progress,
                        isUnlocked: shouldUnlock || specialBadges[index].isUnlocked,
                        unlockDate: shouldUnlock && specialBadges[index].unlockDate == nil ? now : specialBadges[index].unlockDate,
                        reward: specialBadges[index].reward,
                        category: .special
                    )
                }
            }
            updatedBadges[.special] = specialBadges
        }
        
        // MARK: - Achievement → Streak Badges
        if var achievementBadges = updatedBadges[.achievement] {

            for index in achievementBadges.indices {

                let badge = achievementBadges[index]

                // Determine target days based on badge title
                let targetDays: Int
                switch badge.title {
                case "30-Day Champion":
                    targetDays = 30
                case "50-Day Legend":
                    targetDays = 50
                case "60-Day Master":
                    targetDays = 60
                case "Ultimate Achiever":
                    targetDays = 62
                case "66-Day Champion":
                    targetDays = 66
                default:
                    continue
                }
              

                let progress = min(Double(level) / Double(targetDays), 1.0)
                let shouldUnlock = progress >= 1.0

                achievementBadges[index] = Badge(
                    id: badge.id,
                    title: badge.title,
                    description: badge.description,
                    iconName: badge.iconName,
                    gradientColors: badge.gradientColors,
                    requirement: badge.requirement,
                    progress: progress,
                    isUnlocked: shouldUnlock || badge.isUnlocked,
                    unlockDate: shouldUnlock && badge.unlockDate == nil ? now : badge.unlockDate,
                    reward: badge.reward,
                    category: .achievement
                )
                
                
            }

            updatedBadges[.achievement] = achievementBadges
        }



        // MARK: - Save
        saveBadgesToStorage(updatedBadges)
        return updatedBadges
    }

    
    
}
