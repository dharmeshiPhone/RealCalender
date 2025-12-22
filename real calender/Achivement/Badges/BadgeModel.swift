//
//  Badge.swift
//  real calender
//
//  Created by Mac on 15/12/25.
//

import Foundation
import SwiftUI


// MARK: - Data Models
struct Badge: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let iconName: String
    let gradientColors: [Color]
    let requirement: String
    let progress: Double
    let isUnlocked: Bool
    let unlockDate: Date?
    let reward: String?
    let category: BadgeCategory

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case iconName
        case gradientColorData
        case requirement
        case progress
        case isUnlocked
        case unlockDate
        case reward
        case category
    }

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        iconName: String,
        gradientColors: [Color],
        requirement: String,
        progress: Double,
        isUnlocked: Bool,
        unlockDate: Date?,
        reward: String?,
        category: BadgeCategory
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
        self.gradientColors = gradientColors
        self.requirement = requirement
        self.progress = progress
        self.isUnlocked = isUnlocked
        self.unlockDate = unlockDate
        self.reward = reward
        self.category = category
    }

    // MARK: - Decode
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        iconName = try container.decode(String.self, forKey: .iconName)
        requirement = try container.decode(String.self, forKey: .requirement)
        progress = try container.decode(Double.self, forKey: .progress)
        isUnlocked = try container.decode(Bool.self, forKey: .isUnlocked)
        unlockDate = try container.decodeIfPresent(Date.self, forKey: .unlockDate)
        reward = try container.decodeIfPresent(String.self, forKey: .reward)
        category = try container.decode(BadgeCategory.self, forKey: .category)

        // Decode gradient colors
        if let dataArray = try container.decodeIfPresent([Data].self, forKey: .gradientColorData) {
            gradientColors = dataArray.compactMap {
                guard let uiColor = try? NSKeyedUnarchiver
                    .unarchivedObject(ofClass: UIColor.self, from: $0)
                else { return nil }
                return Color(uiColor)
            }
        } else {
            gradientColors = [.blue]
        }
    }

    // MARK: - Encode
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(iconName, forKey: .iconName)
        try container.encode(requirement, forKey: .requirement)
        try container.encode(progress, forKey: .progress)
        try container.encode(isUnlocked, forKey: .isUnlocked)
        try container.encodeIfPresent(unlockDate, forKey: .unlockDate)
        try container.encodeIfPresent(reward, forKey: .reward)
        try container.encode(category, forKey: .category)

        // Encode gradient colors
        let colorDataArray: [Data] = try gradientColors.map {
            let uiColor = UIColor($0)
            return try NSKeyedArchiver.archivedData(
                withRootObject: uiColor,
                requiringSecureCoding: false
            )
        }
        try container.encode(colorDataArray, forKey: .gradientColorData)
    }
}


enum BadgeCategory: String, CaseIterable, Codable {
    case activity = "Activity"
    case health = "Health"
    case special = "Nerd"
    case achievement = "Achievement"
   
    
    var icon: String {
        switch self {
        case .activity: return "figure.run"
        case .health: return "heart.fill"
        case .special: return "sparkles"
        case .achievement: return "trophy.fill"
        }
    }
}

// Sample data
var allintialBadges = [
    BadgeCategory.activity: [
        Badge(title: "Runner", description: "Consistent running tracker", iconName: "figure.run", gradientColors: [.blue, .purple], requirement: "Update Running graph 5 times", progress: 0.0, isUnlocked: false, unlockDate: nil, reward: nil, category: .activity)
    ],
    BadgeCategory.health: [
        Badge(title: "Health Tracker", description: "BMI monitoring expert", iconName: "heart.text.square.fill", gradientColors: [.green, .teal], requirement: "Update BMI graph 10 times", progress: 0.0, isUnlocked: false, unlockDate: nil, reward: nil, category: .health)
    ],
    BadgeCategory.achievement: [
        Badge(title: "30-Day Champion", description: "Almost halfway there!", iconName: "flag.fill", gradientColors: [.purple, .pink], requirement: "30 consecutive days", progress: 0.0, isUnlocked: false, unlockDate: nil, reward: "500 coins", category: .achievement),
        Badge(title: "50-Day Legend", description: "Pretty much there", iconName: "crown.fill", gradientColors: [.orange, .red], requirement: "50 consecutive days", progress: 0, isUnlocked: false, unlockDate: nil, reward: "750 coins", category: .achievement),
        Badge(title: "60-Day Master", description: "6 more days to go", iconName: "star.fill", gradientColors: [.yellow, .green], requirement: "60 consecutive days", progress: 0, isUnlocked: false, unlockDate: nil, reward: "900 coins", category: .achievement),
        Badge(title: "Ultimate Achiever", description: "A special custom milestone", iconName: "sparkles", gradientColors: [.blue, .purple], requirement: "Complete 62-day journey", progress: 0.0, isUnlocked: false, unlockDate: nil, reward: "2000 coins", category: .achievement),
        Badge(title: "66-Day Champion", description: "End or start of a new beginning", iconName: "trophy.fill", gradientColors: [.yellow, .orange], requirement: "Complete 66-day journey", progress: 0.0, isUnlocked: false, unlockDate: nil, reward: "1000 coins", category: .achievement)
    ],
    BadgeCategory.special: [
        Badge(title: "Data Nerd", description: "Complete all graph types", iconName: "chart.bar.fill", gradientColors: [.indigo, .blue], requirement: "Update all graphs at least once", progress: 0.0, isUnlocked: false, unlockDate: nil, reward: nil, category: .special)
    ]
]




// MARK: - Badge Card View
struct BadgeCardView: View {
    let badge: Badge
    
    var body: some View {
        VStack(spacing: 0) {
            // Badge Icon
            ZStack {
                // Background Gradient
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: badge.isUnlocked ?
                                badge.gradientColors :
                                [.gray.opacity(0.3), .gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 140)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                badge.isUnlocked ?
                                    LinearGradient(
                                        colors: [.white.opacity(0.3), .clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ) :
                                    LinearGradient(
                                        colors: [.gray.opacity(0.3), .gray.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                lineWidth: 1
                            )
                    )
                
                VStack(spacing: 8) {
                    // Badge Icon
                    Image(systemName: badge.iconName)
                        .font(.system(size: 40))
                        .foregroundStyle(
                            badge.isUnlocked ?
                                LinearGradient(
                                    colors: [.white, .yellow],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ) :
                                LinearGradient(
                                    colors: [.gray.opacity(0.5), .gray.opacity(0.3)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                        )
                        .shadow(color: badge.isUnlocked ? .yellow.opacity(0.3) : .clear, radius: 10)
                        .overlay {
                            if !badge.isUnlocked {
                                Image(systemName: "lock.fill")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .offset(y: 20)
                            }
                        }
                    
                    // Badge Title
                    Text(badge.title)
                        .font(.headline)
                        .foregroundColor(badge.isUnlocked ? .white : .gray)
                        .shadow(color: badge.isUnlocked ? .black.opacity(0.2) : .clear, radius: 2)
                }
            }
            
            // Badge Info
            VStack(alignment: .leading, spacing: 12) {
                Text(badge.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Progress Bar
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Progress")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(badge.progress * 100))%")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(badge.isUnlocked ? .green : .gray)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 6)
                            
                            Capsule()
                                .fill(
                                    badge.isUnlocked ?
                                    LinearGradient(colors: [.green, .blue], startPoint: .leading, endPoint: .trailing) :
                                    LinearGradient(colors: [.gray.opacity(0.5), .gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing)
                                )
                                .frame(width: geometry.size.width * badge.progress, height: 6)
                        }
                    }
                    .frame(height: 6)
                    
                    Text(badge.requirement)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    // Unlock Status & Reward
                    HStack {
                        if let reward = badge.reward ,!badge.isUnlocked{
                            Label(reward, systemImage: "dollarsign.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                        
                        Spacer()
                        
                        if badge.isUnlocked, let unlockDate = badge.unlockDate {
                            Text("\(unlockDate, style: .relative)")
                                .font(.caption2)
                                .foregroundColor(.green)
                        } else {
                            Text("Locked")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding(12)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(color: badge.isUnlocked ?
                    Color.blue.opacity(0.1) :
                    Color.black.opacity(0.05),
                    radius: 10, x: 0, y: 4
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}
