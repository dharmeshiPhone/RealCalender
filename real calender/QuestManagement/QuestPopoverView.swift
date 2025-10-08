//
//  QuestPopoverView.swift
//  real calender
//
//  Created by Mac on 07/10/25.
//

import SwiftUI

// MARK: - Main Popover View

struct QuestPopoverView: View {
    @ObservedObject var questManager : QuestManager
  
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
                    QuestItemView(quest: quest) {
                        //questManager.completeQuest(quest.id)
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


