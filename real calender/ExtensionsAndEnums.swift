import Foundation
import SwiftUI

// MARK: - Extensions and Enums
extension Notification.Name {
    static let swimmingUnlocked = Notification.Name("swimmingUnlocked")
    static let runningUnlocked = Notification.Name("runningUnlocked")
    static let pullUpsUnlocked = Notification.Name("pullUpsUnlocked")
    static let incomeUnlocked = Notification.Name("incomeUnlocked")
    static let bmiUnlocked = Notification.Name("bmiUnlocked")
    static let acedemicUnlocked = Notification.Name("acedemicUnlocked")
    static let bmiLockPositionUpdated = Notification.Name("bmiLockPositionUpdated")
    static let profileUpdated = Notification.Name("profileUpdated")
    static let appDataReset = Notification.Name("appDataReset")
}

// MARK: - Normal Distribution Helper Function
func normalCDF(_ x: Double) -> Double {
    return 0.5 * erfc(-x / sqrt(2.0))
}

// MARK: - Graph Types for Analytics
public enum GraphType {
    case swimming
    case running
    case pullUps
    case income
    case bmi
    case acedemic
}
