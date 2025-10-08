import SwiftUI

// MARK: - Name Editor
struct NameEditor: View {
    @Binding var userProfile: UserProfile
    @Environment(\.dismiss) private var dismiss
    @State private var tempName: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    Text("✏️ Edit Your Name")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    TextField("Enter your name", text: $tempName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.title2)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Name")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        userProfile.name = tempName
                        userProfile.save()
                        //saveProfileSafely()
                        dismiss()
                    }
                    .disabled(tempName.isEmpty)
                }
            }
        }
        .onAppear {
            tempName = userProfile.name
        }
    }
    
//    private func saveProfileSafely() {
//        // Ensure we don't accidentally clear the onboarding flag
//        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
//        let hasCompletedCalendarSetup = UserDefaults.standard.bool(forKey: "hasCompletedCalendarSetup")
//        
//        userProfile.save()
//       
//        // Restore the onboarding flags if they somehow got lost
//        UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
//        UserDefaults.standard.set(hasCompletedCalendarSetup, forKey: "hasCompletedCalendarSetup")
//    }
}

// MARK: - Physical Stats Editor
struct PhysicalStatsEditor: View {
    @Binding var userProfile: UserProfile
    @Environment(\.dismiss) private var dismiss
    @State private var tempHeight: Double = 170
    @State private var tempWeight: Double = 70
    @State private var tempWaist: Double = 80
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    VStack(spacing: 20) {
                        Text("📏 Physical Stats")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Update your measurements")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 16) {
                        Text("Height: \(Int(tempHeight)) cm")
                            .font(.title2)
                        Slider(value: $tempHeight, in: 120...220, step: 1)
                        
                        Text("Weight: \(Int(tempWeight)) kg")
                            .font(.title2)
                        Slider(value: $tempWeight, in: 40...150, step: 1)
                        
                        Text("Waist: \(Int(tempWaist)) cm")
                            .font(.title2)
                        Slider(value: $tempWaist, in: 50...120, step: 1)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Physical Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        userProfile.heightCM = tempHeight
                        userProfile.weightKG = tempWeight
                        userProfile.waistCM = tempWaist
                        userProfile.save()
                        //saveProfileSafely()
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            tempHeight = userProfile.heightCM
            tempWeight = userProfile.weightKG
            tempWaist = userProfile.waistCM
        }
    }
    
//    private func saveProfileSafely() {
//        // Ensure we don't accidentally clear the onboarding flag
//        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
//        let hasCompletedCalendarSetup = UserDefaults.standard.bool(forKey: "hasCompletedCalendarSetup")
//        
//        if let encoded = try? JSONEncoder().encode(userProfile) {
//            UserDefaults.standard.set(encoded, forKey: "userProfile")
//        }
//        
//        // Restore the onboarding flags if they somehow got lost
//        UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
//        UserDefaults.standard.set(hasCompletedCalendarSetup, forKey: "hasCompletedCalendarSetup")
//    }
}

// MARK: - Education Editor
struct EducationEditor: View {
    @Binding var userProfile: UserProfile
    @Environment(\.dismiss) private var dismiss
    @State private var tempEducationLevel: EducationLevel = .highSchool
    @State private var tempUniversityGPA: Double = 0.0
    @State private var tempHighSchoolGrades: [HighSchoolGrade] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Text("🎓 Education Details")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Picker("Education Level", selection: $tempEducationLevel) {
                        ForEach(EducationLevel.allCases, id: \.self) { level in
                            Text(level.displayName).tag(level)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    if tempEducationLevel == .university {
                        VStack(spacing: 16) {
                            Text("GPA: \(String(format: "%.1f", tempUniversityGPA))/7.0")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Slider(value: $tempUniversityGPA, in: 0...7, step: 0.1)
                                .tint(.blue)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Education")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        userProfile.educationLevel = tempEducationLevel
                        userProfile.universityGPA = tempUniversityGPA
                        userProfile.highSchoolGrades = tempHighSchoolGrades
                        userProfile.save()
                       //saveProfileSafely()
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            tempEducationLevel = userProfile.educationLevel
            tempUniversityGPA = userProfile.universityGPA
            tempHighSchoolGrades = userProfile.highSchoolGrades
        }
    }
    
//    private func saveProfileSafely() {
//        // Ensure we don't accidentally clear the onboarding flag
//        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
//        let hasCompletedCalendarSetup = UserDefaults.standard.bool(forKey: "hasCompletedCalendarSetup")
//        
//        if let encoded = try? JSONEncoder().encode(userProfile) {
//            UserDefaults.standard.set(encoded, forKey: "userProfile")
//        }
//        
//        // Restore the onboarding flags if they somehow got lost
//        UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
//        UserDefaults.standard.set(hasCompletedCalendarSetup, forKey: "hasCompletedCalendarSetup")
//    }
}

// MARK: - Income Editor
struct IncomeEditor: View {
    @Binding var userProfile: UserProfile
    @Environment(\.dismiss) private var dismiss
    @State private var tempIncome: Double = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("💰 Annual Income")
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(spacing: 16) {
                    Text("$\(Int(tempIncome))k")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.green)
                    
                    Slider(value: $tempIncome, in: 0...200, step: 1)
                        .tint(.green)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Income")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        print("💰 IncomeEditor: === SAVE START ===")
                        print("💰 IncomeEditor: Old value: \(userProfile.annualIncomeThousands), New value: \(Int(tempIncome))")
                        
                        // Update the binding
                        userProfile.annualIncomeThousands = Int(tempIncome)
                        print("💰 IncomeEditor: Updated binding - income: \(userProfile.annualIncomeThousands)")
                        
                        // Save to UserDefaults
                        userProfile.save()
                        
                        // Post notification
                        NotificationCenter.default.post(name: .profileUpdated, object: userProfile)
                        print("💰 IncomeEditor: Posted profileUpdated notification with income: \(userProfile.annualIncomeThousands)")
                        
                        print("💰 IncomeEditor: === SAVE END ===")
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            tempIncome = Double(userProfile.annualIncomeThousands)
            print("💰 IncomeEditor: Editor appeared with income: \(userProfile.annualIncomeThousands)")
        }
    }
}

// MARK: - Swimming Editor (DEBUG Version)
struct SwimmingEditor: View {
    @Binding var userProfile: UserProfile
    @Environment(\.dismiss) private var dismiss
    @State private var tempLaps: Double = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("🏊‍♂️ Swimming Endurance")
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(spacing: 16) {
                    Text("\(Int(tempLaps)) laps")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Slider(value: $tempLaps, in: 0...50, step: 1)
                        .tint(.blue)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Text("How many 50m laps can you swim consecutively?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Swimming")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        print("🏊‍♂️ SwimmingEditor: Cancel tapped")
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        print("🏊‍♂️ SwimmingEditor: === SAVE START ===")
                        print("🏊‍♂️ SwimmingEditor: Old value: \(userProfile.swimming50MLaps), New value: \(Int(tempLaps))")
                        
                        // Update the binding
                        userProfile.swimming50MLaps = Int(tempLaps)
                        print("🏊‍♂️ SwimmingEditor: Updated binding - swimming: \(userProfile.swimming50MLaps)")
                        
                        // Save to UserDefaults with extra safety
                        userProfile.save()
                       // saveProfileSafely()
                        
                        // Post notification to trigger unlock animation
                        NotificationCenter.default.post(name: .profileUpdated, object: userProfile)
                        print("🏊‍♂️ SwimmingEditor: Posted profileUpdated notification with swimming: \(userProfile.swimming50MLaps)")
                        
                        print("🏊‍♂️ SwimmingEditor: === SAVE END ===")
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            print("🏊‍♂️ SwimmingEditor: Editor appeared")
            print("🏊‍♂️ SwimmingEditor: Profile gender: \(userProfile.gender)")
            print("🏊‍♂️ SwimmingEditor: Profile hasBasicSetup: \(userProfile.hasBasicProfileSetup)")
            tempLaps = Double(userProfile.swimming50MLaps)
        }
        .onDisappear {
            print("🏊‍♂️ SwimmingEditor: Editor disappeared")
            print("🏊‍♂️ SwimmingEditor: Final profile gender: \(userProfile.gender)")
            print("🏊‍♂️ SwimmingEditor: Final profile hasBasicSetup: \(userProfile.hasBasicProfileSetup)")
        }
    }
    
//    private func saveProfileSafely() {
//        print("🏊‍♂️ SwimmingEditor: saveProfileSafely() called")
//        
//        // Preserve critical flags before saving
//        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
//        let hasCompletedCalendarSetup = UserDefaults.standard.bool(forKey: "hasCompletedCalendarSetup")
//        
//        print("🏊‍♂️ SwimmingEditor: Preserving flags - onboarding: \(hasCompletedOnboarding), calendar: \(hasCompletedCalendarSetup)")
//        
//        // Save the profile
//        do {
//            let encoded = try JSONEncoder().encode(userProfile)
//            UserDefaults.standard.set(encoded, forKey: "userProfile")
//            UserDefaults.standard.synchronize()
//            print("🏊‍♂️ SwimmingEditor: Profile saved successfully")
//        } catch {
//            print("❌ SwimmingEditor: Failed to save profile: \(error)")
//        }
//        
//        // Restore the critical flags
//        UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
//        UserDefaults.standard.set(hasCompletedCalendarSetup, forKey: "hasCompletedCalendarSetup")
//        UserDefaults.standard.synchronize()
//        
//        print("🏊‍♂️ SwimmingEditor: Flags restored and synchronized")
//    }
}

// MARK: - Running Editor
struct RunningEditor: View {
    @Binding var userProfile: UserProfile
    @Environment(\.dismiss) private var dismiss
    @State private var tempMinutes: Double = 25
    @State private var tempSeconds: Double = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("🏃‍♂️ Running")
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(spacing: 24) {
                    HStack(spacing: 16) {
                        VStack {
                            Text("\(Int(tempMinutes))")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.orange)
                            Text("minutes")
                                .font(.caption)
                        }
                        
                        Text(":")
                            .font(.system(size: 48, weight: .bold))
                        
                        VStack {
                            Text(String(format: "%02d", Int(tempSeconds)))
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.orange)
                            Text("seconds")
                                .font(.caption)
                        }
                    }
                    
                    VStack(spacing: 8) {
                        Text("Minutes: \(Int(tempMinutes))")
                            .font(.headline)
                        Slider(value: $tempMinutes, in: 15...60, step: 1)
                            .tint(.orange)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Seconds: \(Int(tempSeconds))")
                            .font(.headline)
                        Slider(value: $tempSeconds, in: 0...59, step: 1)
                            .tint(.orange)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Running")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        print("🏃‍♂️ RunningEditor: === SAVE START ===")
                        let totalSeconds = Int(tempMinutes * 60 + tempSeconds)
                        print("🏃‍♂️ RunningEditor: Old value: \(userProfile.running5KTimeSec), New value: \(totalSeconds)")
                        
                        userProfile.running5KTimeSec = totalSeconds
                        print("🏃‍♂️ RunningEditor: Updated binding - running: \(userProfile.running5KTimeSec)")
                        userProfile.save()
                        //saveProfileSafely()
                        
                        NotificationCenter.default.post(name: .profileUpdated, object: userProfile)
                        print("🏃‍♂️ RunningEditor: Posted profileUpdated notification with running: \(userProfile.running5KTimeSec)")
                        
                        print("🏃‍♂️ RunningEditor: === SAVE END ===")
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            let totalSeconds = userProfile.running5KTimeSec
            tempMinutes = Double(totalSeconds / 60)
            tempSeconds = Double(totalSeconds % 60)
            print("🏃‍♂️ RunningEditor: Editor appeared with running: \(userProfile.running5KTimeSec) seconds")
        }
    }
    
//    private func saveProfileSafely() {
//        print("🏃‍♂️ RunningEditor: saveProfileSafely() called")
//        
//        // Ensure we don't accidentally clear the onboarding flag
//        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
//        let hasCompletedCalendarSetup = UserDefaults.standard.bool(forKey: "hasCompletedCalendarSetup")
//        
//        print("🏃‍♂️ RunningEditor: Preserving flags - onboarding: \(hasCompletedOnboarding), calendar: \(hasCompletedCalendarSetup)")
//        
//        do {
//            let encoded = try JSONEncoder().encode(userProfile)
//            UserDefaults.standard.set(encoded, forKey: "userProfile")
//            UserDefaults.standard.synchronize()
//            print("🏃‍♂️ RunningEditor: Profile saved successfully")
//        } catch {
//            print("❌ RunningEditor: Failed to save profile: \(error)")
//        }
//        
//        // Restore the onboarding flags if they somehow got lost
//        UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
//        UserDefaults.standard.set(hasCompletedCalendarSetup, forKey: "hasCompletedCalendarSetup")
//        UserDefaults.standard.synchronize()
//        
//        print("🏃‍♂️ RunningEditor: Flags restored and synchronized")
//    }
}

// MARK: - Custom Stats Editor
struct CustomStatsEditor: View {
    @Binding var userProfile: UserProfile
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Custom Stats")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Feature coming soon!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Custom Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Pull-ups Editor
struct PullUpsEditor: View {
    @Binding var userProfile: UserProfile
    @Environment(\.dismiss) private var dismiss
    @State private var tempPullUps: Double = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("💪 Pull-ups")
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(spacing: 16) {
                    Text("\(Int(tempPullUps)) reps")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.red)
                    
                    Slider(value: $tempPullUps, in: 0...50, step: 1)
                        .tint(.red)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Pull-ups")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        print("💪 PullUpsEditor: === SAVE START ===")
                        print("💪 PullUpsEditor: Old pull-ups count: \(userProfile.customStats.filter { $0.name.lowercased().contains("pull") }.count), New value: \(Int(tempPullUps))")
                        
                        // Remove existing pull-up stat if it exists
                        userProfile.customStats.removeAll { stat in
                            stat.name.lowercased().contains("pull") || stat.name.lowercased().contains("pullup")
                        }
                        
                        // FIXED: Only add pull-up stat if value > 0
                        if tempPullUps > 0 {
                            let pullUpStat = CustomStat(
                                name: "Pull-ups",
                                value: tempPullUps,
                                unit: "reps",
                                category: .sports,
                                isHigherBetter: true
                            )
                            userProfile.customStats.append(pullUpStat)
                            print("💪 PullUpsEditor: Added pull-ups stat with value: \(pullUpStat.value)")
                        } else {
                            print("💪 PullUpsEditor: No pull-ups data added (value is 0)")
                        }
                        
                        // Save to UserDefaults
                        userProfile.save()
                       
                        
                        // Post notification to trigger unlock animation
                        NotificationCenter.default.post(name: .profileUpdated, object: userProfile)
                        print("💪 PullUpsEditor: Posted profileUpdated notification")
                        
                        print("💪 PullUpsEditor: === SAVE END ===")
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            // Load existing pull-up value if it exists
            if let existingPullUp = userProfile.customStats.first(where: { stat in
                stat.name.lowercased().contains("pull") || stat.name.lowercased().contains("pullup")
            }) {
                tempPullUps = existingPullUp.value
                print("💪 PullUpsEditor: Editor appeared with existing pull-ups: \(existingPullUp.value)")
            } else {
                print("💪 PullUpsEditor: Editor appeared with no existing pull-ups data")
            }
        }
    }
}
