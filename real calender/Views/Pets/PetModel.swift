//
//  PetModel.swift
//  real calender
//
//  Created by Mac on 07/10/25.
//

import SwiftUI

// MARK: - Data Models
struct Pet {
    let name: String
    let isUnlocked: Bool
    let cost: Int
    let icon: String
    let color: Color
}

// MARK: - Custom Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
