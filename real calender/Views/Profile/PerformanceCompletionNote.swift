//
//  PerformanceCompletionNote.swift
//  real calender
//
//  Created by Mac on 08/10/25.
//

import SwiftUI

// MARK: - Performance Completion Note
struct PerformanceCompletionNote: View {
    let userProfile: UserProfile
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("🚀 Unlock Performance Analytics")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    Text("Complete your profile to see detailed performance comparisons")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Progress indicators
            VStack(spacing: 8) {
                HStack {
                    Text("Profile Completion")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("\(completionPercentage)%")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                
                ProgressView(value: Double(completionPercentage) / 100.0)
                    .tint(.orange)
                    .scaleEffect(y: 2)
            }
            
            // Missing items
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(getMissingItems(), id: \.self) { item in
                    HStack(spacing: 8) {
                        Image(systemName: "circle")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Text(item)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
            }
            
            // Call to action
            Text("💡 Complete these to unlock age group comparisons and detailed analytics!")
                .font(.caption)
                .foregroundColor(.orange)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: .orange.opacity(0.2), radius: 8, x: 0, y: 4)
    }
    
    private var completionPercentage: Int {
        var completed = 0
        let total = 5
        
        // Basic measurements
        if userProfile.hasBasicMeasurements {
            completed += 1
        }
        
        // Education
        if userProfile.educationLevel != .notSet {
            completed += 1
        }
        
        // Fitness - Swimming
        if userProfile.swimming50MLaps > 0 {
            completed += 1
        }
        
        // Fitness - Running
        if userProfile.running5KTimeSec > 0 {
            completed += 1
        }
        
        // Income
        if userProfile.annualIncomeThousands > 0 {
            completed += 1
        }
        
        return (completed * 100) / total
    }
    
    private func getMissingItems() -> [String] {
        var missing: [String] = []
        
        if !userProfile.hasBasicMeasurements {
            missing.append("Body measurements")
        }
        
        if userProfile.educationLevel == .notSet {
            missing.append("Education level")
        }
        
        if userProfile.swimming50MLaps == 0 {
            missing.append("Swimming endurance")
        }
        
        if userProfile.running5KTimeSec == 0 {
            missing.append("Running time")
        }
        
        if userProfile.annualIncomeThousands == 0 {
            missing.append("Annual income")
        }
        
        return missing
    }
}
