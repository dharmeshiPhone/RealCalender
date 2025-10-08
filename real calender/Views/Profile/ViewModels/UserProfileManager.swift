//
//  UserProfileManager.swift
//  real calender
//
//  Created by Mac on 08/10/25.
//

import SwiftUI
import Combine

@MainActor
final class UserProfileManager: ObservableObject {
    static let shared = UserProfileManager()
    
    @Published var profile: UserProfile?
    
    private init() {
        if let saved = UserProfile.load() {
            self.profile = saved
        }
    }
    
    func saveProfile() {
        profile?.save()
    }
    
    func reloadProfile() {
        if let saved = UserProfile.load() {
            self.profile = saved
        }
    }
    
    func resetProfile() {
        UserProfile.clear()
        self.profile = UserProfile(
            name: "Champion",
            age: 20,
            heightCM: 170,
            weightKG: 70,
            measurements: [:],
            level: 1,
            xp: 0,
            stats: []
        )
    }
}
