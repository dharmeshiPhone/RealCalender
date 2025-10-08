import Foundation
import SwiftUI

// MARK: - Custom Stat Model
struct CustomStat: Identifiable, Codable {
    let id = UUID()
    var name: String
    var value: Double
    var unit: String
    var category: CustomStatCategory
    var isHigherBetter: Bool
    var dateAdded: Date
    
    init(name: String, value: Double, unit: String, category: CustomStatCategory, isHigherBetter: Bool = true) {
        self.name = name
        self.value = value
        self.unit = unit
        self.category = category
        self.isHigherBetter = isHigherBetter
        self.dateAdded = Date()
    }
}

// MARK: - Custom Stat Categories
enum CustomStatCategory: String, CaseIterable, Codable {
    case languages = "Languages"
    case gaming = "Gaming"
    case music = "Music"
    case sports = "Sports"
    case academics = "Academics"
    case skills = "Skills"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .languages: return "globe"
        case .gaming: return "gamecontroller.fill"
        case .music: return "music.note"
        case .sports: return "sportscourt.fill"
        case .academics: return "book.fill"
        case .skills: return "wrench.and.screwdriver.fill"
        case .other: return "star.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .languages: return .blue
        case .gaming: return .purple
        case .music: return .pink
        case .sports: return .green
        case .academics: return .orange
        case .skills: return .cyan
        case .other: return .gray
        }
    }
}