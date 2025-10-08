import SwiftUI

struct UserStatsProfileMetricsSection: View {
    let profile: UserProfile
    
    var body: some View {
        GroupBox {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Height: \(Int(profile.heightCM)) cm")
                    Text("Weight: \(Int(profile.weightKG)) kg")
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 5) {
                    ForEach(profile.measurements.sorted(by:{$0.key < $1.key}), id: \.key) { key, value in
                        Text("\(key): \(value, specifier: "%.1f")\"")
                    }
                }
            }
        }
    }
}