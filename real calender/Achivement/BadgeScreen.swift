//
//  BadgesView.swift
//  real calender
//
//  Created by Mac on 15/12/25.
//

import SwiftUI

// MARK: - Badge Screen
struct BadgeScreen: View {
    @State private var selectedCategory: BadgeCategory = .activity
    @State private var showingUnlockAnimation = false
    @State private var recentlyUnlockedBadge: Badge?
    var userProfile = UserProfile.shared
    @State private var allBadges: [BadgeCategory: [Badge]] = allintialBadges
    
    var body: some View {
        NavigationStack{
            ScrollView {
                VStack(spacing: 0) {
                    Text("Unlock rewards by tracking your progress")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth:.infinity,alignment: .leading)
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                    
                    NavigationLink {
                        AchievementView(userProfile:userProfile)
                    } label: {
                        AnimatedProgress()
                    }
                    
                    
                    // Achievement Progress View
                    if let achievements = allBadges[.achievement] {
                        AchievementProgressView(level: userProfile.level, achievements: achievements)
                            .padding(.bottom, 30)
                    }
                    
                    
                    // Category Picker
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(BadgeCategory.allCases, id: \.self) { category in
                                CategoryButton(
                                    category: category,
                                    isSelected: selectedCategory == category,
                                    unlockedCount: allBadges[category]?.filter { $0.isUnlocked }.count ?? 0,
                                    totalCount: allBadges[category]?.count ?? 0
                                )
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        selectedCategory = category
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                    
                    // Badges for Selected Category
                    if let badges = allBadges[selectedCategory] {
                        BadgeCategoryView(category: selectedCategory, badges: badges)
                            .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 50)
                }
            }
            .background(
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6).opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .overlay {
                if showingUnlockAnimation, let badge = recentlyUnlockedBadge {
                    BadgeUnlockAnimation(badge: badge, isShowing: $showingUnlockAnimation)
                }
            }
            .navigationTitle("Achievements")//& Badges
            .onAppear {
                let storeage = BadgeStorage.shared
                if let storedBadges = storeage.loadBadgesFromStorage() {
                    let updated = storeage.checkedUserBadgesComplitions(storedBadges,level:userProfile.level)
                    storeage.saveBadgesToStorage(updated)
                } else {
                    let updated = storeage.checkedUserBadgesComplitions(allintialBadges, level:userProfile.level)
                    storeage.saveBadgesToStorage(updated)
                }
            }
            
        }
    }
}

// MARK: - Supporting Views
struct CategoryButton: View {
    let category: BadgeCategory
    let isSelected: Bool
    let unlockedCount: Int
    let totalCount: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: category.icon)
                .font(.title2)
                .foregroundColor(isSelected ? .white : .blue)
            
            Text(category.rawValue)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
            
            //            Text("\(unlockedCount)/\(totalCount)")
            //                .font(.caption2)
            //                .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
        }
        .frame(width: 80, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    isSelected ?
                    LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom) :
                        LinearGradient(colors: [Color(.systemBackground), Color(.systemGray6)], startPoint: .top, endPoint: .bottom)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: isSelected ? .blue.opacity(0.2) : .clear, radius: 10)
    }
}



// MARK: - Achievement Progress View
struct AchievementProgressView: View {
    var level:Int
    let achievements: [Badge]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("66-Day Journey")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            // Progress Circle
            ZStack {
                // Background Circle
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .frame(width: 200)
                
                // Progress Circle
                Circle()
                    .trim(from: 0, to: CGFloat(3/66))
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 200)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: .purple.opacity(0.3), radius: 10)
                // Progress Text
                VStack {
                    Text("Day \(level)/66")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("The Beginning Part")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(66 - level) days remaining")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
            
            // Upcoming Milestones
            VStack(alignment: .leading, spacing: 12) {
                Text("Upcoming Milestones")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                ForEach(achievements) { achievement in
                    HStack {
                        Image(systemName: achievement.iconName)
                            .foregroundColor(achievement.isUnlocked ? .green : .gray)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(achievement.title)
                                .font(.subheadline)
                                .foregroundColor(achievement.isUnlocked ? .primary : .gray)
                            
                            Text(achievement.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if achievement.isUnlocked {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 2)
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10)
        )
        .padding(.horizontal)
    }
}

struct AnimatedProgress: View {
    @State private var arrowOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 8) {
            Text("See Level Progress")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
            
            Image(systemName: "arrow.forward")
                .offset(x: arrowOffset)
        }
        .foregroundColor(.white)
        .padding(.vertical, 14)
        .padding(.horizontal, 30)
        .background(
            LinearGradient(gradient: Gradient(colors: [
                Color(red: 0.1, green: 0.7, blue: 0.95),
                Color(red: 0.1, green: 0.4, blue: 0.8)
            ]), startPoint: .leading, endPoint: .trailing)
        )
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        .onAppear {
            startArrowAnimation()
        }
    }
    
    func startArrowAnimation() {
        withAnimation(
            .easeInOut(duration: 0.8)
            .repeatForever(autoreverses: true)
        ) {
            arrowOffset = 3
        }
    }
}


// MARK: - Preview
#Preview {
    BadgeScreen()
}



