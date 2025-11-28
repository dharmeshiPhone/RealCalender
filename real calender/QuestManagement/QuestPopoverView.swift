//
//  QuestPopoverView.swift
//  real calender
//
//  Created by Mac on 07/10/25.
//

import SwiftUI

// MARK: - Main Popover View

struct QuestPopoverView: View {
    @AppStorage("showGlowIcon") private var showGlowQuestIcon: Bool = false
    @ObservedObject var questManager : QuestManager
    @Environment(\.dismiss) private var dismiss
  
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Text("Quests")
                .font(.custom("ArialRoundedMTBold", size: 22))
                .foregroundColor(.white)
                .padding(.leading, 8)
                .padding(.top, 10)
            
            // Quest Items List
            VStack(spacing: 8) {
                ForEach(questManager.getCurrentBatchQuests()) { quest in
                    QuestItemView(quest: quest,isUnassignedCoin:questManager.pendingRewardQuestIds.contains(quest.id))
                        .onTapGesture {
                            handle(quest: quest)
                        }
                }
            }
            .padding(.horizontal, 8)
            
            Spacer()
        }
        .frame(width: 300, height: 280)
        .background(
            Color(red: 0/255, green: 100/255, blue: 150/255)
                .ignoresSafeArea()
        )
    }
    
    private func handle(quest: QuestItem) {
        guard quest.isCompleted else { return }
        
        // Check if this quest has a pending reward
        guard questManager.pendingRewardQuestIds.contains(quest.id) else { return }
        
        var user = UserProfile.shared
        user.xp += Double(quest.xP)
        user.coins += quest.coins
        
        var showLevelUp: Bool = false
        
        let xpRequired = UserProfile.xpRequiredForLevel(user.level)
        if user.xp >= xpRequired {
            user.level += 1
            showLevelUp = true
        }
        
        user.save()
        NotificationCenter.default.post(name: .profileUpdated, object: user)
        
        // Remove this quest from pending list
        questManager.removePendingReward(for: quest.id)
        
        // Hide glow if no rewards left
        // 🔥 ONLY check batch completion when NO pending rewards left
        let pendingInCurrentBatch = questManager.pendingRewardQuestIds.filter { pendingId in
            questManager.getCurrentBatchQuests().contains { $0.id == pendingId }
        }
        
        if pendingInCurrentBatch.isEmpty {
            showGlowQuestIcon = false
            questManager.checkBatchCompletion()
        }
       
        dismiss()
        
        // Level-up animation
        if showLevelUp {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.easeOut(duration: 0.3)) {
                    questManager.showLevelUp = true
                }
            }
        }
    }

    
    private func resetCurrentBatch() {
        let currentBatchQuests = questManager.getCurrentBatchQuests()
        for quest in currentBatchQuests {
            questManager.resetQuest(quest.id)
        }
    }
    
    private func completeAllQuests() {
        let currentBatchQuests = questManager.getCurrentBatchQuests()
        for quest in currentBatchQuests {
            if !quest.isCompleted {
                questManager.completeQuest(quest.id)
            }
        }
    }
}


