//
//  QuestItemView.swift
//  real calender
//
//  Created by Mac on 07/10/25.
//

import SwiftUI


struct QuestItemView: View {
    let quest: QuestItem
    var isUnassignedCoin: Bool = false
    
    @State private var glowAnimation = false
    
    let questBoxColor = Color(red: 32/255, green: 32/255, blue: 32/255)
    let rewardIconColor = Color(red: 255/255, green: 200/255, blue: 70/255)
    let grayRewardIconColor = Color(red: 100/255, green: 100/255, blue: 100/255)
    let progressBackgroundColor = Color(red: 80/255, green: 80/255, blue: 80/255)
    let completedProgressColor = Color(red: 60/255, green: 200/255, blue: 60/255)
    let partialProgressColor = Color(red: 160/255, green: 160/255, blue: 160/255).opacity(0.5)
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(quest.title)
                    .font(.custom("ArialRoundedMTBold", size: 14))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                VStack(alignment: .leading, spacing: 0) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(progressBackgroundColor)
                            
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
            
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(rewardIconFillColor)
                    .frame(width: 54, height: 54)
                    .overlay(
                        // Glow border when coin is unassigned
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.yellow, lineWidth: 4)
                            .opacity(isUnassignedCoin ? (glowAnimation ? 1 : 0.3) : 0)
                            .scaleEffect(glowAnimation ? 1.2 : 1.0)
                            .animation(isUnassignedCoin ?
                                       Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true) :
                                       .default, value: glowAnimation)
                    )
                    .onAppear {
                        if isUnassignedCoin {
                            glowAnimation = true
                        }
                    }
                
                VStack(spacing: 0) {
                    Text("$")
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                    
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
        }
        .frame(height: 70)
        .background(questBoxColor)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(quest.isCompleted && !isUnassignedCoin ? completedProgressColor : Color.clear, lineWidth: 2)
        )
    }
    
    private var rewardIconFillColor: Color {
        if quest.isCompleted {
            return rewardIconColor
        } else if quest.completedCount > 0 {
            return rewardIconColor
        } else {
            return grayRewardIconColor
        }
    }
}
