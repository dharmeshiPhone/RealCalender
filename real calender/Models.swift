import Foundation
import SwiftUI

// MARK: - Universal App Type/Model Stubs

// App-wide: Only one version of each type/struct/enum below should exist in your entire repo!
class AchievementManager: ObservableObject {
    
    @Published var showLevelUp: Bool = false
    
    @Published var achievements: [Achievement] = []
    @Published var unlockedAchievements: Set<UUID> = []
    
    init() {
        loadAchievements()
    }
    
    func unlockAchievement(_ achievement: Achievement) {
        unlockedAchievements.insert(achievement.id)
    }
    
    func isUnlocked(_ achievement: Achievement) -> Bool {
        return unlockedAchievements.contains(achievement.id)
    }
    
    func completeCalendarSetup() {
        print(" AchievementManager: completeCalendarSetup() called")
        
        // Initialize calendar achievement if it doesn't exist
        if achievements.isEmpty {
            let calendarAchievement = Achievement(
                title: "Calendar Beginner",
                description: "Start organizing your schedule",
                icon: "calendar.badge.plus",
                category: .calendar,
                level: 1,
                currentProgress: 0,
                maxProgress: 3
            )
            achievements.append(calendarAchievement)
        }
        
        // Complete the calendar setup achievement
        if let index = achievements.firstIndex(where: { $0.category == .calendar }) {
            achievements[index].currentProgress = achievements[index].maxProgress
            achievements[index].isUnlocked = true
            achievements[index].unlockedDate = Date()
            
            print(" Calendar setup achievement completed!")
        }
        
        saveAchievements()
    }
    
    func updateCalendarProgress() {
        print(" AchievementManager: updateCalendarProgress() called")
        
        // Initialize calendar achievement if it doesn't exist
        if achievements.isEmpty {
            let calendarAchievement = Achievement(
                title: "Calendar Beginner", 
                description: "Start organizing your schedule",
                icon: "calendar.badge.plus",
                category: .calendar,
                level: 1,
                currentProgress: 0,
                maxProgress: 3
            )
            achievements.append(calendarAchievement)
        }
        
        if let index = achievements.firstIndex(where: { $0.category == .calendar }) {
            let currentProgress = achievements[index].currentProgress
            let maxProgress = achievements[index].maxProgress
            
            if currentProgress < maxProgress {
                achievements[index].currentProgress += 1
                print(" Calendar progress updated: \(achievements[index].currentProgress)/\(maxProgress)")
                
                // Check for level up
                if achievements[index].currentProgress >= maxProgress {
                    levelUpAchievement(at: index)
                }
            }
        }
        
        saveAchievements()
    }
    
    func resetAllAchievements() {
        print(" AchievementManager: resetAllAchievements() called")
        achievements.removeAll()
        unlockedAchievements.removeAll()
        
        // Clear saved achievements
        UserDefaults.standard.removeObject(forKey: "userAchievements")
        
        print(" All achievements have been reset")
    }
    
    func getCalendarAchievement() -> Achievement? {
        return achievements.first { $0.category == .calendar }
    }
    
    private func levelUpAchievement(at index: Int) {
        let achievement = achievements[index]
        achievements[index].level += 1
        achievements[index].currentProgress = 0
        achievements[index].isUnlocked = true
        achievements[index].unlockedDate = Date()
        
        // Increase max progress for next level
        achievements[index].maxProgress = min(achievements[index].maxProgress + 2, 10)
        
        print(" Achievement leveled up to level \(achievements[index].level)!")
        
        // Post notification for level up
        NotificationCenter.default.post(
            name: NSNotification.Name("AchievementLevelUp"),
            object: achievements[index]
        )
    }
    
    private func loadAchievements() {
        if let data = UserDefaults.standard.data(forKey: "userAchievements"),
           let loadedAchievements = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = loadedAchievements
        }
    }
    
    private func saveAchievements() {
        if let data = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(data, forKey: "userAchievements")
        }
    }
}

struct Achievement: Identifiable, Equatable, Codable {
    let id = UUID()
    var title: String = ""
    var description: String = ""
    var icon: String = "star.fill"
    var isUnlocked: Bool = false
    var unlockedDate: Date?
    var category: AchievementCategory = .general
    var level: Int = 1
    var currentProgress: Int = 0
    var maxProgress: Int = 3
    
    init(title: String = "", description: String = "", icon: String = "star.fill", isUnlocked: Bool = false, unlockedDate: Date? = nil, category: AchievementCategory = .general, level: Int = 1, currentProgress: Int = 0, maxProgress: Int = 3) {
        self.title = title
        self.description = description
        self.icon = icon
        self.isUnlocked = isUnlocked
        self.unlockedDate = unlockedDate
        self.category = category
        self.level = level
        self.currentProgress = currentProgress
        self.maxProgress = maxProgress
    }
    
    var levelTitle: String {
        switch level {
        case 1: return "Beginner"
        case 2: return "Intermediate"
        case 3: return "Advanced"
        case 4: return "Expert"
        default: return "Master"
        }
    }
    
    var progressPercentage: Double {
        guard maxProgress > 0 else { return 0.0 }
        return Double(currentProgress) / Double(maxProgress)
    }
}

enum AchievementCategory: String, Codable, CaseIterable {
    case general = "General"
    case calendar = "Calendar"
    case productivity = "Productivity"
    case fitness = "Fitness"
    case social = "Social"
    
    var color: Color {
        switch self {
        case .general: return .gray
        case .calendar: return .blue
        case .productivity: return .green
        case .fitness: return .red
        case .social: return .purple
        }
    }
}

// ChatMessage model matching AIChatManager requirements
struct ChatMessage: Identifiable, Equatable, Codable {
    let id = UUID()
    var content: String
    var isUser: Bool
    var timestamp: Date
    
    init(content: String, isUser: Bool, timestamp: Date) {
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
    }
}

// MARK: - Analytics Support Models

struct AnalyticsCategoryData: Equatable, Codable {
    var name: String = ""
    var count: Int = 0
    var percentage: Double = 0.0
}

struct AnalyticsChartDataPoint: Equatable, Codable {
    var date: Date = Date()
    var value: Double = 0.0
}

// MARK: - Calendar Insight Models

struct CalendarInsight: Identifiable, Equatable, Codable {
    let id = UUID()
    var title: String = ""
    var description: String = ""
    var category: CalendarInsightCategory = .productivity
    var priority: Int = 0
}

enum CalendarInsightCategory: String, Equatable, Codable, CaseIterable {
    case productivity = "Productivity"
    case timeManagement = "Time Management"
    case workLifeBalance = "Work-Life Balance"
    case scheduling = "Scheduling"
    case optimization = "Optimization"
    case patterns = "Patterns"
    case wellness = "Wellness"
}

struct ScheduleEvent: Identifiable, Equatable, Codable {
    let id = UUID()
    var title: String = ""
    var startDate: Date = Date()
    var endDate: Date = Date()
    var location: String = ""
}

// MARK: - Calendar Models

struct CalendarFolder: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var color: Color

    enum CodingKeys: String, CodingKey {
        case id, name, colorData
    }

    init(name: String, color: Color = .blue) {
        self.id = UUID()
        self.name = name
        self.color = color
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        if let colorData = try container.decodeIfPresent(Data.self, forKey: .colorData),
           let uiColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            color = Color(uiColor)
        } else {
            color = .blue
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        let uiColor = UIColor(color)
        let colorData = try NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false)
        try container.encode(colorData, forKey: .colorData)
    }
}

struct CalendarEvent: Identifiable, Codable {
    let id: UUID
    var title: String
    var date: Date
    var notes: String
    var color: Color
    var location: String
    var teacher: String?
    var folderId: UUID?
    var extraInformation: String
    var equipment: String

    enum CodingKeys: String, CodingKey {
        case id, title, date, notes, colorData, location, teacher, folderId, extraInformation, equipment
    }

    init(title: String, date: Date, notes: String = "", color: Color = .blue, location: String = "", teacher: String? = nil, folderId: UUID? = nil, extraInformation: String = "", equipment: String = "") {
        self.id = UUID()
        self.title = title
        self.date = date
        self.notes = notes
        self.color = color
        self.location = location
        self.teacher = teacher
        self.folderId = folderId
        self.extraInformation = extraInformation
        self.equipment = equipment
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        date = try container.decode(Date.self, forKey: .date)
        notes = try container.decode(String.self, forKey: .notes)
        location = try container.decodeIfPresent(String.self, forKey: .location) ?? ""
        teacher = try container.decodeIfPresent(String.self, forKey: .teacher)
        folderId = try container.decodeIfPresent(UUID.self, forKey: .folderId)
        extraInformation = try container.decodeIfPresent(String.self, forKey: .extraInformation) ?? ""
        equipment = try container.decodeIfPresent(String.self, forKey: .equipment) ?? ""
        if let colorData = try container.decodeIfPresent(Data.self, forKey: .colorData),
           let uiColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            color = Color(uiColor)
        } else {
            color = .blue
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(date, forKey: .date)
        try container.encode(notes, forKey: .notes)
        try container.encode(location, forKey: .location)
        try container.encodeIfPresent(teacher, forKey: .teacher)
        try container.encodeIfPresent(folderId, forKey: .folderId)
        try container.encode(extraInformation, forKey: .extraInformation)
        try container.encode(equipment, forKey: .equipment)
        let uiColor = UIColor(color)
        let colorData = try NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false)
        try container.encode(colorData, forKey: .colorData)
    }
}

// MARK: - Conflict and Insight Models (Centralized here to avoid duplicates)

struct ConflictScheduleConflict: Identifiable {
    let id: UUID
    let type: ConflictType
    let severity: ConflictSeverity
    let title: String
    let description: String
    let affectedEvents: [CalendarEvent]
    let suggestedSolutions: [String]
}

enum ConflictType {
    case timeOverlap
    case locationConflict
    case travelTime
    case resourceConflict
}

enum ConflictSeverity {
    case low, medium, high
    
    var color: Color {
        switch self {
        case .low: return .yellow
        case .medium: return .orange
        case .high: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "exclamationmark.circle"
        case .medium: return "exclamationmark.triangle"
        case .high: return "exclamationmark.octagon.fill"
        }
    }
    
    var displayName: String {
        switch self {
        case .low: return "Low Priority"
        case .medium: return "Medium Priority" 
        case .high: return "High Priority"
        }
    }
}

struct ScheduleInsight: Identifiable {
    let id: UUID
    let type: InsightType
    let priority: InsightPriority
    let title: String
    let description: String
    let impact: String
    let actionItems: [String]
}

enum InsightType {
    case recommendation
    case optimization
    case warning
    
    var icon: String {
        switch self {
        case .recommendation: return "lightbulb.fill"
        case .optimization: return "speedometer"
        case .warning: return "exclamationmark.triangle.fill"
        }
    }
    
    var displayName: String {
        switch self {
        case .recommendation: return "Recommendation"
        case .optimization: return "Optimization"
        case .warning: return "Warning"
        }
    }
}

enum InsightPriority {
    case low, medium, high
    
    var color: Color {
        switch self {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
}

// MARK: - UI Helper Models for Analytics Views

struct CalendarRecommendation {
    let id = UUID()
    let title: String
    let description: String
    let priority: String
    let actionType: String
}

// MARK: - Extended CalendarInsight Helper

extension CalendarInsight {
    enum Impact {
        case positive, negative, neutral
    }
    
    enum Priority {
        case low, medium, high
    }
    
    // Initialize with extended properties for better insights
    init(category: CalendarInsightCategory, title: String, description: String, impact: Impact, priority: Priority, suggestion: String, metricValue: String) {
        self.title = title
        self.description = description
        self.category = category
        self.priority = priority == .high ? 3 : (priority == .medium ? 2 : 1)
    }
}
// MARK: - Cosmic Visualization Models

struct CosmicStar: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var color: Color
    var opacity: Double
    var speed: Double
    var twinkle: Double
}

struct NebulaPatch: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var color: Color
    var drift: Double
    var rotation: Double
}

struct GalaxySpiral: Identifiable {
    let id = UUID()
    var center: CGPoint
    var innerRadius: Double
    var outerRadius: Double
    var arms: Int
    var color: Color
    var rotationSpeed: Double
}

struct CosmicParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var color: Color
    var opacity: Double
    var frequency: Double
    var amplitude: CGFloat
}
