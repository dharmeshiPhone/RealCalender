//
//  QuestItemView.swift
//  real calender
//
//  Created by Mac on 07/10/25.
//

import SwiftUI


struct QuestItemView: View {
    let quest: QuestItem
    let onComplete: (() -> Void)?
    
    let questBoxColor = Color(red: 32/255, green: 32/255, blue: 32/255) // Dark gray/black box
    let rewardIconColor = Color(red: 255/255, green: 200/255, blue: 70/255) // Gold/Yellow reward background
    let grayRewardIconColor = Color(red: 100/255, green: 100/255, blue: 100/255) // Gray for upcoming quests
    let progressBackgroundColor = Color(red: 80/255, green: 80/255, blue: 80/255) // Dark gray progress background
    let completedProgressColor = Color(red: 60/255, green: 200/255, blue: 60/255) // Bright green for 1/1
    let partialProgressColor = Color(red: 160/255, green: 160/255, blue: 160/255).opacity(0.5) // Gray for 1/2
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(quest.title)
                    .font(.custom("ArialRoundedMTBold", size: 14))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Progress Bar and Counter
                VStack(alignment: .leading, spacing: 0) {
                    
                    // Progress Bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background bar (Gray)
                            RoundedRectangle(cornerRadius: 8)
                                .fill(progressBackgroundColor)
                            
                            // Progress filled (Green or Partial Gray)
                            RoundedRectangle(cornerRadius: 8)
                                .fill(quest.isCompleted ? completedProgressColor : partialProgressColor)
                                .frame(width: geometry.size.width * CGFloat(quest.progress))
                        }
                    }
                    .frame(height: 14)
                    .overlay(alignment: .center) {
                        Text("\(quest.completedCount)/\(quest.totalCount)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(quest.isCompleted ? .white : .white.opacity(0.8))
                    }
                }
            }
            .padding(.vertical, 8)
            .padding(.leading, 12)
            
            Spacer()
            
            // Right Side: Reward Icon with Tap Action
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(rewardIconFillColor)
                    .frame(width: 54, height: 54)
                
                VStack(spacing: 0) {
                    Text("$")
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                    
                    // XP and Coin Rewards
                    Text("+\(quest.xP) exp")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundColor(.black)
                    Text("+\(quest.coins) coins")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
            .padding(.vertical, 4)
            .padding(.trailing, 10)
            .onTapGesture {
                if !quest.isCompleted {
                    onComplete?()
                }
            }
        }
        .frame(height: 70)
        .background(questBoxColor)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(quest.isCompleted ? completedProgressColor : Color.clear, lineWidth: 2)
        )
    }
    
    private var rewardIconFillColor: Color {
        if quest.isCompleted {
            return rewardIconColor // completed quest → yellow
        } else if quest.completedCount > 0 {
            return rewardIconColor // running quest → yellow
        } else {
            return grayRewardIconColor // upcoming quest → gray
        }
    }
}
