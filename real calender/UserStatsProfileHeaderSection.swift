import SwiftUI

struct UserStatsProfileHeaderSection: View {
    let profile: UserProfile
    let anim: Namespace.ID
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.orange.opacity(0.16))
                    .frame(width: 150, height: 150)
                    .matchedGeometryEffect(id: "avatarbg", in: anim)
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .shadow(radius: 14)
                    .matchedGeometryEffect(id: "avatarimg", in: anim)
            }
            Text(profile.name)
                .font(.title)
                .bold()
            Text("Age \(profile.age), Level \(profile.level)")
                .font(.headline)
                .foregroundColor(.orange)
            let XprequriedToComplteLevel = UserProfile.xpRequiredForLevel(profile.level)
            let progress = Double(profile.xp) / Double(XprequriedToComplteLevel)
            ProgressView(value: progress)
                .accentColor(.orange)
                .frame(width: 180)
                .scaleEffect(x: 1.2, y: 1.2)
          //  let nextLevelXP = UserProfile.xpRequiredForLevel(profile.level + 1)
            
            Text("XP: \(Int(profile.xp)) / \(Int(XprequriedToComplteLevel))")
        }
    }
}


