import Foundation

// MARK: - Academic Subject Model
struct AcademicSubject: Identifiable, Codable {
    let id = UUID()
    var name: String
    var percentage: Double
    
    init(name: String, percentage: Double) {
        self.name = name
        self.percentage = percentage
    }
}

// MARK: - High School Grade Model
struct HighSchoolGrade: Identifiable, Codable {
    let id = UUID()
    var subject: String
    var grade: String
    
    var gradePoint: Double {
        switch grade {
        case "A+", "A": return 4.0
        case "A-": return 3.7
        case "B+": return 3.3
        case "B": return 3.0
        case "B-": return 2.7
        case "C+": return 2.3
        case "C": return 2.0
        case "C-": return 1.7
        case "D+": return 1.3
        case "D": return 1.0
        case "D-": return 0.7
        case "F": return 0.0
        default: return 0.0
        }
    }
    
    var letterGrade: String {
        switch gradePoint {
        case 4.0: return "A"
        case 3.7: return "A-"
        case 3.3: return "B+"
        case 3.0: return "B"
        case 2.7: return "B-"
        case 2.3: return "C+"
        case 2.0: return "C"
        case 1.7: return "C-"
        case 1.3: return "D+"
        case 1.0: return "D"
        case 0.7: return "D-"
        case 0.0: return "F"
        default: return "N/A"
        }
    }
}

// MARK: - Education Level Enum
enum EducationLevel: String, CaseIterable, Codable {
    case notSet = "Not Set"
    case highSchool = "High School"
    case university = "University"
    case neither = "Neither"
    
    var displayName: String {
        switch self {
        case .neither:
            return "Neither (Working/Other)"
        default:
            return rawValue
        }
    }
}