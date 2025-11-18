//
//  PetModel.swift
//  real calender
//
//  Created by Mac on 07/10/25.
//

import SwiftUI

// MARK: - Data Models
struct Pet: Codable, Identifiable,Hashable {
    let id: UUID
    let name: String
    var isUnlocked: Bool
    var unlockTimestamp: Date?
    let cost: Int
    let icon: String
    let color: CustomColor
    
    init(id: UUID = UUID(), name: String, isUnlocked: Bool, cost: Int, icon: String, color: Color, unlockTimestamp: Date? = nil) {
        self.id = id
        self.name = name
        self.isUnlocked = isUnlocked
        self.cost = cost
        self.icon = icon
        self.color = CustomColor(color: color)
        self.unlockTimestamp = unlockTimestamp
    }
    
    var swiftUIColor: Color { color.color }
    
    private static let hatchDuration: TimeInterval = 30//24 * 60 * 60
    
    
    func timeRemaining(currentTime: Date) -> TimeInterval? {
        guard let start = unlockTimestamp else { return nil }
        let remaining = Pet.hatchDuration - currentTime.timeIntervalSince(start)
        return remaining > 0 ? remaining : 0
    }
    
    var isHatching: Bool {
        guard let start = unlockTimestamp else { return false }
        return Pet.hatchDuration - Date().timeIntervalSince(start) > 0 && !isUnlocked
    }
    
    var isReadyToReveal: Bool {
        if let unlockTimestamp = unlockTimestamp {
            return !isUnlocked && Date().timeIntervalSince(unlockTimestamp) >= Pet.hatchDuration
        }
        return false
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(isUnlocked)
        hasher.combine(unlockTimestamp)
        hasher.combine(cost)
        hasher.combine(icon)
    }
    
    static func == (lhs: Pet, rhs: Pet) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.isUnlocked == rhs.isUnlocked &&
        lhs.unlockTimestamp == rhs.unlockTimestamp &&
        lhs.cost == rhs.cost &&
        lhs.icon == rhs.icon
    }
}



// MARK: - Custom Color Wrapper
struct CustomColor: Codable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
    
    init(color: Color) {
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        self.red = Double(red)
        self.green = Double(green)
        self.blue = Double(blue)
        self.alpha = Double(alpha)
    }
    
    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }
}



// MARK: - Custom Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}


