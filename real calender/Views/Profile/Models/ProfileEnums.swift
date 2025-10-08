import Foundation

// MARK: - Gender Enum
enum Gender: String, CaseIterable, Codable {
    case male = "Male"
    case female = "Female"
    case notSet = "Not Set"
    
    var displayName: String {
        return rawValue
    }
}