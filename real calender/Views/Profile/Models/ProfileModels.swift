//
//  ProfileModels.swift
//  real calender
//
//  Created by Mac on 08/10/25.
//

import SwiftUI

// MARK: - Gold Mist Particle for Profile
struct ProfileGoldMistParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: CGFloat
    var opacity: Double
    let blur: CGFloat
    let fallSpeed: CGFloat
    let sway: CGFloat
}

class RemoteConfigManager: ObservableObject {
    @Published var config: RemoteConfig? = nil
    
    init() {
        self.fetch()
        // Run a timer that runs every 60 seconds
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            self.fetch()
        }
    }
    
    func fetch() {
    }
}

struct RemoteConfig {
    // Add properties as needed
}
