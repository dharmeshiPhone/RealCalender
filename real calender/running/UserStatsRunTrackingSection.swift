import SwiftUI

struct UserStatsRunTrackingSection: View {
    @Binding var profile: UserProfile
    @Binding var showingRunTracker: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🏃 5K Run Tracking")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                if profile.running5KTimeSec > 0 {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Best 5K Time")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text(profile.running5KTimeFormatted)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.green)
                            
                            Text("Pace: \(profile.running5KTimeFormatted)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showingRunTracker = true
                        }) {
                            VStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                Text("New Run")
                                    .font(.caption)
                            }
                            .foregroundColor(.green)
                        }
                    }
                } else {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "figure.run")
                                .font(.title2)
                                .foregroundColor(.green)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("No 5K time recorded")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text("Track your first 5K run!")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        Button(action: {
                            showingRunTracker = true
                        }) {
                            HStack {
                                Image(systemName: "location.fill")
                                    .font(.title2)
                                
                                Text("Start GPS 5K Run")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.title2)
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .foregroundColor(.green)
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                }
            }
        }
    }
}
