//
//  AchievementView.swift
//  real calender
//
//  Created by Mac on 15/12/25.
//

import SwiftUI

struct AchievementView: View {
    var userProfile = UserProfile.shared
    // Determine the max required XP for the *next* level
    var nextLevelExp: Int {
        allLevels.first(where: { $0.number == userCurrentLevel + 1 })?.requiredExp ?? 0
    }
    
    var userCurrentLevel: Int{
        return userProfile.level
    }
    
    var userCurrentExp: Double{
        return userProfile.xp
    }
    
    var currentLevelStartExp: Int {
        allLevels.first(where: { $0.number == userCurrentLevel })?.requiredExp ?? 0
    }
    
    // Calculate progress fraction for the top bar
    var progressFraction: Double {
        if nextLevelExp == 0 { return 1.0 }
        let expRange = Double(nextLevelExp - currentLevelStartExp)
        let currentProgress = Double(userCurrentExp - Double(currentLevelStartExp))
        return currentProgress / expRange
    }
    
    var body: some View {
        ZStack {
            // Background color
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // MARK: - Top Header (Level and Progress Bar)
                HStack {
                    Text("Level \(userProfile.level)")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        let XprequriedToComplteLevel = UserProfile.xpRequiredForLevel(userProfile.level)// + 1
                        Text("XP: \(Int(userProfile.xp)) / \(Int(XprequriedToComplteLevel))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        let progress = Double(userProfile.xp) / Double(XprequriedToComplteLevel)
                        ProgressView(value: progress)//userProfile.progressToNextLevel
                            .frame(width: 100)
                            .tint(.blue)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                
                // MARK: - Level Tracker with Horizontal Connector Line
                VStack {
                    
                    // Level markers
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(allLevels) { level in
                                LevelMarker(level: level, isCompleted: level.number <= userCurrentLevel)
                                    .frame(width: 120)
                            }
                        }
                        .padding(.horizontal, 20)
                        .background(alignment: .top) {
                            GeometryReader { geometry in
                                let totalWidth = geometry.size.width - 60 // Account for padding
                                let segmentWidth = totalWidth / CGFloat(allLevels.count - 1)
                                
                                // Background line (full length)
                                Path { path in
                                    path.move(to: CGPoint(x: 70, y: 20))//30
                                    path.addLine(to: CGPoint(x: totalWidth , y: 20))
                                }
                                .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                                
                                // Completed portion of the line
                                let completedWidth = segmentWidth * CGFloat(userCurrentLevel - 1)
                                Path { path in
                                    path.move(to: CGPoint(x: 70, y: 20))
                                    path.addLine(to: CGPoint(x: completedWidth + 70, y: 20))
                                }
                                .stroke(Color.green, lineWidth: 2)
                            }
                            .frame(height: 40)
                            .offset(y:34)
                        }
                    }
                }
                .frame(height: 180)
            }
        }
    }
}


// MARK: - LevelMarker View
struct LevelMarker: View {
    let level: Level
    let isCompleted: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            // 1. Required Exp Label (Top)
            Text("\(level.requiredExp) Exp")
                .font(.caption)
                .foregroundColor(.gray)
                .frame(height: 20)
            
            // 2. The Level Icon with connecting line
            ZStack {
                // Connecting line from previous marker
                //                Rectangle()
                //                    .fill(isCompleted ? Color.green : Color.gray.opacity(0.5))
                //                    .frame(width: 60, height: 2)
                //                    .offset(x: -30)
                
                // Icon background circle
                Circle()
                    .fill(Color.black)
                    .frame(width: 44, height: 44)
                
                // Icon
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 36, height: 36)
                    .foregroundColor(isCompleted ? .green : .gray)
            }
            .frame(height: 50)
            
            // 3. Level Number (Bottom)
            Text("\(level.number)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(isCompleted ? .green : .gray)
                .frame(height: 20)
            
            // 4. Reward Text
            Text(level.reward)
                .font(.caption2)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(isCompleted ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                .cornerRadius(8)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: 100, height: 40)
        }
        .frame(width: 120)
    }
}

// MARK: - Alternative: Continuous Line Version
struct AchievementViewWithContinuousLine: View {
    let userCurrentLevel = 3
    let userCurrentExp = 175
    
    var nextLevelExp: Int {
        allLevels.first(where: { $0.number == userCurrentLevel + 1 })?.requiredExp ?? 0
    }
    
    var currentLevelStartExp: Int {
        allLevels.first(where: { $0.number == userCurrentLevel })?.requiredExp ?? 0
    }
    
    var progressFraction: Double {
        if nextLevelExp == 0 { return 1.0 }
        let expRange = Double(nextLevelExp - currentLevelStartExp)
        let currentProgress = Double(userCurrentExp - currentLevelStartExp)
        return currentProgress / expRange
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 5) {
                    Text("Level \(userCurrentLevel)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack {
                        Rectangle()
                            .frame(height: 4)
                            .foregroundColor(Color.blue)
                            .overlay(alignment: .leading) {
                                Rectangle()
                                    .frame(width: max(0, 150 * progressFraction))
                                    .foregroundColor(.white)
                            }
                        
                        Text("XP: \(userCurrentExp)/\(nextLevelExp)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .frame(width: 250)
                }
                .padding(.top, 20)
                
                // Level Tracker with Horizontal Connector
                VStack(spacing: 0) {
                    // Horizontal connector line that spans all markers
                    GeometryReader { geo in
                        ZStack {
                            // Full background line
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: geo.size.height / 2))
                                path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height / 2))
                            }
                            .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                            
                            // Completed portion
                            let completedWidth = geo.size.width * CGFloat(userCurrentLevel) / CGFloat(allLevels.count)
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: geo.size.height / 2))
                                path.addLine(to: CGPoint(x: completedWidth, y: geo.size.height / 2))
                            }
                            .stroke(Color.green, lineWidth: 2)
                        }
                    }
                    .frame(height: 40)
                    
                    // Level markers
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(allLevels) { level in
                                VStack(spacing: 5) {
                                    // Level icon
                                    ZStack {
                                        Circle()
                                            .fill(Color.black)
                                            .frame(width: 44, height: 44)
                                        
                                        Image(systemName: level.number <= userCurrentLevel ? "checkmark.circle.fill" : "circle")
                                            .resizable()
                                            .frame(width: 36, height: 36)
                                            .foregroundColor(level.number <= userCurrentLevel ? .green : .gray)
                                    }
                                    
                                    // Level number
                                    Text("\(level.number)")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(level.number <= userCurrentLevel ? .green : .gray)
                                    
                                    // Reward
                                    Text(level.reward)
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .frame(width: 100)
                                }
                                .frame(width: 120)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .frame(height: 180)
                
                Spacer()
            }
        }
    }
}


