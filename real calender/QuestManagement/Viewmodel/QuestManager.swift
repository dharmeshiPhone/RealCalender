//
//  QuestManager.swift
//  real calender
//
//  Created by Mac on 07/10/25.
//

import SwiftUI

// MARK: - Quest Storage Manager
class QuestStorageManager {
    private let currentBatchKey = "questCurrentBatch"
    private let allQuestsKey = "questAllQuests"
    
    func saveCurrentBatch(_ batch: Int) {
        UserDefaults.standard.set(batch, forKey: currentBatchKey)
    }
    
    func loadCurrentBatch() -> Int {
        let savedBatch = UserDefaults.standard.integer(forKey: currentBatchKey)
        return savedBatch > 0 ? savedBatch : 1
    }
    
    func saveAllQuests(_ quests: [QuestItem]) {
        do {
            let encodedQuests = try JSONEncoder().encode(quests)
            UserDefaults.standard.set(encodedQuests, forKey: allQuestsKey)
        } catch {
            print("Error saving quests: \(error)")
        }
    }
    
    func loadAllQuests() -> [QuestItem]? {
        guard let questsData = UserDefaults.standard.data(forKey: allQuestsKey) else {
            return nil
        }
        
        do {
            let decodedQuests = try JSONDecoder().decode([QuestItem].self, from: questsData)
            return decodedQuests
        } catch {
            print("Error loading quests: \(error)")
            return nil
        }
    }
    
    func clearAllData() {
        UserDefaults.standard.removeObject(forKey: currentBatchKey)
        UserDefaults.standard.removeObject(forKey: allQuestsKey)
    }
}

// MARK: - Quest Manager
class QuestManager: ObservableObject {
    @AppStorage("showGlowIcon") private var showGlowQuestIcon: Bool = false
    @AppStorage("pendingRewardQuestIds") private var storedPendingRewardQuestIdsData: Data?

    
    var pendingRewardQuestIds: [UUID] {
        get {
            guard let data = storedPendingRewardQuestIdsData,
                  let ids = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return ids.compactMap { UUID(uuidString: $0) }
        }
        set {
            let strings = newValue.map { $0.uuidString }
            storedPendingRewardQuestIdsData = try? JSONEncoder().encode(strings)
        }
    }

    
    @Published var showNotificationPopup : Bool = false
   

    @Published var currentBatch: Int = 1
    @Published var allQuests: [QuestItem] = []
    
    @Published var showLevelUp: Bool = false// for level up
    
    private let storageManager = QuestStorageManager()
    private let predefinedQuests: [QuestItem]
    
    init() {
        // Define all quests here
        self.predefinedQuests = [
            // Batch 1 - Basic Quests
            QuestItem(title: "Set up the basics of your calendar", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 1),
            QuestItem(title: "Complete two graphs in your profile", completedCount: 0, totalCount: 2, xP: 50, coins: 25, batch: 1),
            QuestItem(title: "Get your first egg from the pet store", completedCount: 0, totalCount: 1, xP: 50, coins: 50, batch: 1),
            
            // temps
            // Batch 2 - Intermediate Quests
            QuestItem(title: "Log 3 calendar event", completedCount: 0, totalCount: 3, xP: 75, coins: 50, batch: 2),
            QuestItem(title: "Turn on notifications", completedCount: 0, totalCount: 1, xP: 75, coins: 50, batch: 2),
            QuestItem(title: "Complete 1 scheduled event", completedCount: 0, totalCount: 1, xP: 100, coins: 75, batch: 2),
            
            // Batch 3 - Advanced Quests
            QuestItem(title: "Complete 2 scheduled event", completedCount: 0, totalCount: 2, xP: 75, coins: 75, batch: 3),
            QuestItem(title: "Add 5 new event", completedCount: 0, totalCount: 5, xP: 100, coins: 50, batch: 3),
            QuestItem(title: "Use Task Prioritisation", completedCount: 0, totalCount: 1, xP: 75, coins: 75, batch: 3),
            
            // Batch 4 - Expert Quests
            QuestItem(title: "Complete 3 scheduled event", completedCount: 0, totalCount: 3, xP: 100, coins: 75, batch: 4),
            QuestItem(title: "Check pet happiness (just open pet page)", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 4),
            QuestItem(title: "Use Sick or Holiday prompt", completedCount: 0, totalCount: 1, xP: 100, coins: 50, batch: 4)
        ]
        
        loadQuests()
    }
    
    private func loadQuests() {
        // Load current batch
        currentBatch = storageManager.loadCurrentBatch()
        
        // Load quests or use predefined ones
        if let savedQuests = storageManager.loadAllQuests() {
            allQuests = savedQuests
        } else {
            allQuests = predefinedQuests
            saveAllData()
        }
    }
    
    func resetAllQuests() {
        currentBatch = 1
        for index in allQuests.indices {
            allQuests[index].resetProgress()
        }
        saveAllData()
    }
    
    
    private func saveAllData() {
        storageManager.saveCurrentBatch(currentBatch)
        storageManager.saveAllQuests(allQuests)
    }
    
    // MARK: - Public Methods
    
    func completeQuest(_ questId: UUID) {
        guard let index = allQuests.firstIndex(where: { $0.id == questId }) else { return }
        
        if !allQuests[index].isCompleted {
            allQuests[index].incrementProgress()
            saveAllData()
            checkBatchCompletion()
        }
    }
    
    // MARK: - Complete Quest normally
    func completeQuest(named questTitle: String) {
        guard let index = allQuests.firstIndex(where: { $0.title == questTitle }) else {
            print("Quest not found: \(questTitle)")
            return
        }
        
        let quest = allQuests[index]
        if !quest.isCompleted {
            allQuests[index].incrementProgress()
            
            let latestQuest = allQuests[index]
            if latestQuest.isCompleted{
                // Add XP to current user
//                var user = UserProfile.shared
//                user.xp += Double(quest.xP)
//                user.coins += quest.coins
//                
//                let XprequriedToComplteLevel = UserProfile.xpRequiredForLevel(user.level)
//                
//                if user.xp >= XprequriedToComplteLevel{
//                    user.level += 1
//                    showGlowQuestIcon = true
//                }
//                
//                user.save()
//                NotificationCenter.default.post(name: .profileUpdated, object: user)
                var list = pendingRewardQuestIds
                list.append(quest.id)
                pendingRewardQuestIds = list

                showGlowQuestIcon = true
            }
            // Save quests and check batch
            saveAllData()
          //  checkBatchCompletion()
            
            print("Quest progress updated: \(questTitle), XP added: \(quest.xP)")
        } else {
            print("Quest already completed: \(questTitle)")
        }
    }
    
    // MARK: - Complete Quest force
    
    func completeQuestWithIncremnetForce(named questTitle: String,num:Int) { // icremental
        guard let index = allQuests.firstIndex(where: { $0.title == questTitle }) else {
            print("Quest not found: \(questTitle)")
            return
        }
        
        let quest = allQuests[index]
        if !quest.isCompleted {
            allQuests[index].incrementforceProgress(num: num)
            
            let latestQuest = allQuests[index]
            if latestQuest.isCompleted{
                var list = pendingRewardQuestIds
                list.append(quest.id)
                pendingRewardQuestIds = list
                showGlowQuestIcon = true
            }
            // Save quests and check batch
            saveAllData()
            
            print("Quest progress updated: \(questTitle), XP added: \(quest.xP)")
        } else {
            print("Quest already completed: \(questTitle)")
        }
    }
    
    func completeQuestWithIncremnetStaticForce(named questTitle: String,num:Int) { // static
        guard let index = allQuests.firstIndex(where: { $0.title == questTitle }) else {
            print("Quest not found: \(questTitle)")
            return
        }
        
        let quest = allQuests[index]
        if !quest.isCompleted {
            allQuests[index].staticIncrementforceProgress(num: num)
            
            let latestQuest = allQuests[index]
            if latestQuest.isCompleted{
                var list = pendingRewardQuestIds
                list.append(quest.id)
                pendingRewardQuestIds = list
                showGlowQuestIcon = true
            }
            // Save quests and check batch
            saveAllData()
            
            print("Quest progress updated: \(questTitle), XP added: \(quest.xP)")
        } else {
            print("Quest already completed: \(questTitle)")
        }
    }
    
    func checkQuestWasCompleted(_ questTitle: String) -> Bool{
        guard let index = allQuests.firstIndex(where: { $0.title == questTitle }) else {
            print("Quest not found: \(questTitle)")
            return false
        }
        return allQuests[index].isCompleted
    }
    
    func removePendingReward(for questId: UUID) {
        var list = pendingRewardQuestIds
        list.removeAll { $0 == questId }
        pendingRewardQuestIds = list
    }

    func resetQuest(_ questId: UUID) {
        guard let index = allQuests.firstIndex(where: { $0.id == questId }) else { return }
        
        allQuests[index].resetProgress()
        saveAllData()
    }
    
    func resetCurrentBatch() {
        for index in allQuests.indices where allQuests[index].batch == currentBatch {
            allQuests[index].resetProgress()
        }
        saveAllData()
    }
    
    func completeAllQuestsInCurrentBatch() {
        for index in allQuests.indices where allQuests[index].batch == currentBatch {
            allQuests[index].completedCount = allQuests[index].totalCount
        }
        saveAllData()
        checkBatchCompletion()
    }
    
    func checkBatchCompletion() {
        let currentBatchQuests = getCurrentBatchQuests()
        let allCompleted = currentBatchQuests.allSatisfy { $0.isCompleted }
        
        if allCompleted {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.advanceToNextBatch()
            }
        }
    }
    
    private func advanceToNextBatch() {
        let nextBatch = currentBatch + 1
        let maxBatch = allQuests.map { $0.batch }.max() ?? 1
        
        if nextBatch <= maxBatch {
            currentBatch = nextBatch
        } else {
            // Loop back to first batch
            currentBatch = 1
        }
        
        resetCurrentBatchQuests()
        saveAllData()
        
        // MARK: -  Auto complete questions
        
        switch currentBatch{
        case 2:
//            if let data = UserDefaults.standard.data(forKey: "calendarEvents"),
//               let events = try? JSONDecoder().decode([CalendarEvent].self, from: data) {
//                if events.count == 1{
//                    completeQuest(named: "Log 3 calendar event")
//                }else if events.count == 2{
//                    completeQuestWithIncremnetForce(named: "Log 3 calendar event", num: 2)
//                }else if events.count > 2{
//                    completeQuestWithIncremnetForce(named: "Log 3 calendar event", num: 3)
//                }
//            }
            showNotificationPopup = true
        default:
            break
        }
       
    }
    
    private func resetCurrentBatchQuests() {
        for index in allQuests.indices where allQuests[index].batch == currentBatch {
            allQuests[index].resetProgress()
        }
    }
    
    func getCurrentBatchQuests() -> [QuestItem] {
        allQuests.filter { $0.batch == currentBatch }
    }
    
    func getBatchCompletionPercentage() -> Double {
        let currentBatchQuests = getCurrentBatchQuests()
        guard !currentBatchQuests.isEmpty else { return 0 }
        
        let completedCount = currentBatchQuests.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(currentBatchQuests.count)
    }
    
    func getCompletedQuestsCount() -> Int {
        getCurrentBatchQuests().filter { $0.isCompleted }.count
    }
    
    func getTotalQuestsCount() -> Int {
        getCurrentBatchQuests().count
    }
    
    // MARK: - Debug Methods
    
    func clearAllData() {
        storageManager.clearAllData()
        currentBatch = 1
        allQuests = predefinedQuests
        saveAllData()
    }
    
    func printDebugInfo() {
        print("=== Quest Manager Debug ===")
        print("Current Batch: \(currentBatch)")
        print("Total Quests: \(allQuests.count)")
        
        let batches = Set(allQuests.map { $0.batch }).sorted()
        for batch in batches {
            let batchQuests = allQuests.filter { $0.batch == batch }
            let completed = batchQuests.filter { $0.isCompleted }.count
            print("Batch \(batch): \(completed)/\(batchQuests.count) completed")
        }
        print("===========================")
    }
}



