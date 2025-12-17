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
        self.predefinedQuests = questItems
        
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
        if currentBatch > 27{ // unlock after day 27
            Task{
                await sendLowProgressNotificationIfNeeded()
            }
        }
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
    
    func completeQuestWithIncremnetForce(named questTitle: String,num:Int, Quebatch: Int? = nil) { // icremental
        // 1) Find by title and batch (if batch provided)
        let questIndex: Int?
        
        if let batch = Quebatch {
            questIndex = allQuests.firstIndex(where: { $0.title == questTitle && $0.batch == batch })
        } else {
            questIndex = allQuests.firstIndex(where: { $0.title == questTitle })
        }
        
        // 2) Validate index
        guard let index = questIndex else {
            print("Quest not found for title: \(questTitle), batch: \(Quebatch ?? -1)")
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
    
    func completeQuestWithIncremnetStaticForce(named questTitle: String, num: Int, Quebatch: Int? = nil) {
        
        // 1) Find by title and batch (if batch provided)
        let questIndex: Int?
        
        if let batch = Quebatch {
            questIndex = allQuests.firstIndex(where: { $0.title == questTitle && $0.batch == batch })
        } else {
            questIndex = allQuests.firstIndex(where: { $0.title == questTitle })
        }
        
        // 2) Validate index
        guard let index = questIndex else {
            print("Quest not found for title: \(questTitle), batch: \(Quebatch ?? -1)")
            return
        }
        
        // 3) Access quest safely
        let quest = allQuests[index]
        if !quest.isCompleted {
            allQuests[index].staticIncrementforceProgress(num: num)
            
            let latestQuest = allQuests[index]
            if latestQuest.isCompleted {
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

        currentBatch = nextBatch <= maxBatch ? nextBatch : 1

        resetCurrentBatchQuests()
        saveAllData()

        handleAutoCompleteForCurrentBatch()
    }
    
    private func handleAutoCompleteForCurrentBatch() {
        let currentStreak = UserDefaults.standard.integer(forKey: "currentStreak")

        // Streak-based quest rules
        let streakRules: [Int: String] = [
            7:  "Maintain 7-day streak",
            14: "Maintain 14-day streak",
            20: "Maintain 20-day streak",
            21: "Maintain 21-day streak",
            28: "Maintain 28-day streak",
            30: "Maintain 30-day streak",
            35: "Maintain 35-day streak",
            40: "Maintain 40-day streak"
        ]

        // Notification-only batches
        if currentBatch == 2 {
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
            return
        }

        // Handle streak quests
        if let questName = streakRules[currentBatch],
           currentStreak >= currentBatch {
            completeQuest(named: questName)
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
    
    
    // MARK: - Daily Summary Task
    
    @Published var dailySummaryStreak: Int = 0
    @Published var lastDailySummaryDate: Date? = nil
    
    func updateDailySummaryStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastDate = lastDailySummaryDate {
            let last = Calendar.current.startOfDay(for: lastDate)
            
            if let diff = Calendar.current.dateComponents([.day], from: last, to: today).day {
                if diff == 1 {
                    dailySummaryStreak += 1
                } else if diff > 1 {
                    dailySummaryStreak = 1
                }
            }
        } else {
            dailySummaryStreak = 1
        }
        
        lastDailySummaryDate = today
        // MARK: Complete the quest after 7 days in a row
        if dailySummaryStreak >= 7 {
            completeQuest(named: "Check Daily Summary 7 days in a row")
        }
    }
}



extension QuestManager {
    func sendLowProgressNotificationIfNeeded() async {
        let progress = getBatchCompletionPercentage()
        if let savedPetsData = UserDefaults.standard.data(forKey: "userPets"),
           let decodedPets = try? JSONDecoder().decode([Pet].self, from: savedPetsData) {
            
            // Fire notification only when progress < 33%
            if progress < 0.33 {
                await LocalNotificationManager.shared.schedulePetHappinessNotifications(petName: decodedPets.first?.name ?? "Fluffy")
            }
        }else{
            // Fire notification only when progress < 33%
            if progress < 0.33 {
                await LocalNotificationManager.shared.schedulePetHappinessNotifications(petName:  "Fluffy")
            }
        }
    }
}
