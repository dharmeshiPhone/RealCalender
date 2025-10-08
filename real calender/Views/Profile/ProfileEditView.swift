//
//  ProfileEditView.swift
//  real calender
//
//  Created by Mac on 08/10/25.
//

import SwiftUI

// MARK: - Profile Edit View
struct ProfileEditView: View {
    @Binding var userProfile: UserProfile
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var waist: String = ""
    @State private var swimming: String = ""
    @State private var running: String = ""
    @State private var income: String = ""
    @State private var pullups: String = ""
    @State private var selectedGender: Gender = .notSet
    @State private var selectedEducationLevel: EducationLevel = .notSet
    
    var body: some View {
        NavigationView {
            Form {
                Section("Personal Information") {
                    TextField("Name", text: $name)
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                    
                    // Gender selection
                    Picker("Gender", selection: $selectedGender) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.displayName).tag(gender)
                        }
                    }
                    
                    // Education level selection - manual override
                    Picker("Education Level", selection: $selectedEducationLevel) {
                        ForEach(EducationLevel.allCases, id: \.self) { level in
                            Text(level.displayName).tag(level)
                        }
                    }
                    
                    if selectedEducationLevel != .notSet && selectedEducationLevel != .neither {
                        Text("💡 This was automatically set from your calendar setup, but you can change it here if needed.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Physical Measurements") {
                    TextField("Height (cm)", text: $height)
                        .keyboardType(.decimalPad)
                    TextField("Weight (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                    TextField("Waist (cm)", text: $waist)
                        .keyboardType(.decimalPad)
                }
                
                Section("Fitness Performance") {
                    TextField("Swimming 50m laps", text: $swimming)
                        .keyboardType(.numberPad)
                    TextField("5K running time (minutes)", text: $running)
                        .keyboardType(.decimalPad)
                    TextField("Pull-ups (max reps)", text: $pullups)
                        .keyboardType(.numberPad)
                }
                
                Section("Financial") {
                    TextField("Annual income (thousands)", text: $income)
                        .keyboardType(.numberPad)
                }
                
                Section("Quick Fill Options") {
                    Button("📊 Restore Previous Analytics Data") {
                        loadSamplePerformanceData()
                    }
                    .foregroundColor(.blue)
                    
                    Button("🔥 Load High Performance Data") {
                        loadHighPerformanceData()
                    }
                    .foregroundColor(.green)
                    
                    Button("📈 Load Average Performance Data") {
                        loadAveragePerformanceData()
                    }
                    .foregroundColor(.orange)
                }
                
                Section("Calculated") {
                    if let heightVal = Double(height), let weightVal = Double(weight), heightVal > 0, weightVal > 0 {
                        let bmi = weightVal / pow(heightVal / 100, 2)
                        HStack {
                            Text("BMI")
                            Spacer()
                            Text(String(format: "%.1f", bmi))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadCurrentValues()
        }
    }
    
    private func loadCurrentValues() {
        name = userProfile.name
        age = "\(userProfile.age)"
        height = "\(userProfile.heightCM)"
        weight = "\(userProfile.weightKG)"
        waist = "\(userProfile.waistCM)"
        swimming = userProfile.swimming50MLaps > 0 ? "\(userProfile.swimming50MLaps)" : ""
        running = userProfile.running5KTimeSec > 0 ? String(format: "%.1f", Double(userProfile.running5KTimeSec) / 60.0) : ""
        income = userProfile.annualIncomeThousands > 0 ? "\(userProfile.annualIncomeThousands)" : ""
        selectedGender = userProfile.gender
        selectedEducationLevel = userProfile.educationLevel
        
        // Load pull-ups from custom stats
        if let pullUpsStat = userProfile.customStats.first(where: { stat in
            stat.name.lowercased().contains("pull")
        }) {
            pullups = String(format: "%.0f", pullUpsStat.value)
        } else {
            pullups = ""
        }
    }
    
    private func loadSamplePerformanceData() {
        // Typical performance data that will show all graphs
        swimming = "12"  // 12 laps
        running = "24.5" // 24.5 minutes for 5K
        income = "65"    // $65,000 annual income
        pullups = "15"   // 15 pull-ups max
        
        // Update the text fields
        loadCurrentValues()
    }
    
    private func loadHighPerformanceData() {
        // High performance data (top percentiles)
        swimming = "20"  // 20 laps
        running = "18.5" // 18.5 minutes for 5K
        income = "85"    // $85,000 annual income
        pullups = "25"   // 25 pull-ups max
        
        // Update the text fields
        loadCurrentValues()
    }
    
    private func loadAveragePerformanceData() {
        // Average performance data
        swimming = "8"   // 8 laps
        running = "27.0" // 27 minutes for 5K
        income = "45"    // $45,000 annual income
        pullups = "8"    // 8 pull-ups max
        
        // Update the text fields
        loadCurrentValues()
    }
    
    private func saveProfile() {
        userProfile.name = name
        userProfile.gender = selectedGender
        userProfile.educationLevel = selectedEducationLevel
        
        if let ageVal = Int(age) {
            userProfile.age = ageVal
        }
        if let heightVal = Double(height) {
            userProfile.heightCM = heightVal
        }
        if let weightVal = Double(weight) {
            userProfile.weightKG = weightVal
        }
        if let waistVal = Double(waist) {
            userProfile.waistCM = waistVal
        }
        
        // Save fitness data
        if let swimmingVal = Int(swimming), swimmingVal > 0 {
            userProfile.swimming50MLaps = swimmingVal
        }
        
        if let runningVal = Double(running), runningVal > 0 {
            userProfile.running5KTimeSec = Int(runningVal * 60) // Convert minutes to seconds
        }
        
        if let incomeVal = Int(income), incomeVal > 0 {
            userProfile.annualIncomeThousands = incomeVal
        }
        
        // Save pull-ups data to custom stats
        if let pullupsVal = Double(pullups), pullupsVal > 0 {
            // Remove existing pull-ups stat if it exists
            userProfile.customStats.removeAll { stat in
                stat.name.lowercased().contains("pull")
            }
            
            // Add new pull-ups stat
            let pullUpsStat = CustomStat(
                name: "Pull-ups",
                value: pullupsVal,
                unit: "reps",
                category: .sports,
                isHigherBetter: true
            )
            userProfile.customStats.append(pullUpsStat)
        }
        
        if userProfile.level == 2{
            userProfile.xp =  Double(400 + earnedXP) // 400 for level 1 xp
            if userProfile.xp == 1400{
                userProfile.level = 3
            }
        }
        
        
        userProfile.save()
        
        NotificationCenter.default.post(name: .profileUpdated, object: nil)
    }
    
    private var earnedXP: Int {
        var xp = 0
        
        if userProfile.hasBasicMeasurements {
            xp += 200
        }
        if userProfile.educationLevel != .notSet {
            xp += 200
        }
        if userProfile.swimming50MLaps > 0 {
            xp += 200
        }
        if userProfile.running5KTimeSec > 0 {
            xp += 200
        }
        if userProfile.annualIncomeThousands > 0 {
            xp += 200
        }
        
        return xp
    }
    
}
