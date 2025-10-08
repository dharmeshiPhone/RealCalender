import SwiftUI

struct LockedProfileView: View {
    let userProfile: UserProfile
    
    private func calculateProgressValue() -> Double {
        let nextLevelXP = getNextLevelXP()
        if nextLevelXP <= 0 {
            return 0.0
        }
        let progress = Double(userProfile.xp) / Double(nextLevelXP)
        return min(progress, 1.0) // Ensure we don't exceed 1.0
    }
    
    private func getNextLevelXP() -> Double {
        // Using a simple calculation for level 2 requirement
        // Assuming 1000 XP is needed for level 2
        return 1000.0
    }
    
    private func getNeededXP() -> Double {
        let nextLevelXP = getNextLevelXP()
        let needed = nextLevelXP - userProfile.xp
        return max(needed, 0) // Ensure non-negative value
    }
    
    private func getXPText() -> String {
        let currentXP = Int(userProfile.xp)
        let nextLevelXP = Int(getNextLevelXP())
        return "\(currentXP) / \(nextLevelXP)"
    }
    
    private func getNeededXPText() -> String {
        return "\(Int(getNeededXP()))"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    Spacer().frame(height: 20)
                    
                    // Simplified lock icon
                    Image(systemName: "lock.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.gray)
                    
                    VStack(spacing: 10) {
                        Text("Profile Locked")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Complete your calendar setup to unlock your profile!")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    
                    // Progress Section
                    VStack(spacing: 16) {
                        Text("Your Progress")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("Level:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("Level \(userProfile.level)")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                            }
                            
                            HStack {
                                Text("XP:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(getXPText())
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                            }
                            
                            ProgressView(value: calculateProgressValue())
                                .scaleEffect(y: 1.5)
                            
                            Text("Need \(getNeededXPText()) more XP to unlock")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    
                    // Unlock Requirements
                    VStack(spacing: 16) {
                        Text("How to Unlock")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "calendar.badge.plus")
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading) {
                                    Text("Complete Calendar Setup")
                                        .font(.headline)
                                    Text("Add your schedule and events")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}