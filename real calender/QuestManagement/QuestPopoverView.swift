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
                    QuestItemView(quest: quest,isUnassignedCoin:quest.id == questManager.pendingRewardQuestId)
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
    
    private func handle(quest:QuestItem){
        guard quest.isCompleted else { return }
        
        if questManager.pendingRewardQuestId == quest.id {
            // Add XP & coins when user taps
            var user = UserProfile.shared
            user.xp += Double(quest.xP)
            user.coins += quest.coins
            
            // Handle level-up
            let xpRequired = UserProfile.xpRequiredForLevel(user.level)
            if user.xp >= xpRequired {
                user.level += 1
            }
            
            user.save()
            NotificationCenter.default.post(name: .profileUpdated, object: user)
            
            // Clear glow & pending reward
            showGlowQuestIcon = false
            questManager.pendingRewardQuestId = nil
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.easeOut(duration: 0.3)){
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


