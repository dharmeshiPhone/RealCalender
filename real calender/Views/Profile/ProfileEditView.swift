//
//  ProfileEditView.swift
//  real calender
//
//  Created by Mac on 08/10/25.
//

import SwiftUI

// MARK: - Profile Edit View
struct ProfileEditView: View {
    @EnvironmentObject var questManager: QuestManager
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
                        .disabled(questManager.currentBatch <= 17)

                    
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
        if questManager.currentBatch > 17 {
            if name != userProfile.name {
                guard userProfile.coins >= 50 else {
                    presentAlert(message: "Coins are not enough to change name", primaryAction: .OK)
                    return
                }
                userProfile.name = name
                userProfile.coins -= 50
            }
        }
        
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
        
        userProfile.incrementGraphUpdate(for: .bmi)
        
        // Save fitness data
        if let swimmingVal = Int(swimming), swimmingVal > 0 {
            userProfile.swimming50MLaps = swimmingVal
            userProfile.incrementGraphUpdate(for: .swimming)
        }
        
       
        
        if let runningVal = Double(running), runningVal > 0 {
            userProfile.running5KTimeSec = Int(runningVal * 60) // Convert minutes to seconds
            userProfile.incrementGraphUpdate(for: .running)
        }
        
        if let incomeVal = Int(income), incomeVal > 0 {
            userProfile.annualIncomeThousands = incomeVal
            userProfile.incrementGraphUpdate(for: .income)
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
            userProfile.incrementGraphUpdate(for: .pullUps)
        }
        
        if questManager.currentBatch == 7{
            questManager.completeQuestWithIncremnetStaticForce(named: "Update 2 different graphs", num: 2, Quebatch: 7)
        }
        
        if questManager.currentBatch == 12{
            questManager.completeQuestWithIncremnetStaticForce(named: "Update 2 different graphs", num: 2, Quebatch: 12)
        }
        
        if questManager.currentBatch == 13{
            questManager.completeQuestWithIncremnetForce(named: "Update one graph", num: 1, Quebatch: 13)
        }
        
        if questManager.currentBatch == 14{
            questManager.completeQuestWithIncremnetForce(named: "Update BMI or Running graph", num: 1, Quebatch: 14)
        }
        
        if questManager.currentBatch == 16{
            questManager.completeQuestWithIncremnetForce(named: "Update Swimming or Gym graph", num: 1, Quebatch: 16)
        }
        
        if questManager.currentBatch == 18{
            questManager.completeQuestWithIncremnetStaticForce(named: "Update 3 different graphs", num: 3, Quebatch: 18)
            questManager.completeQuestWithIncremnetForce(named: "Update one graph", num: 1, Quebatch: 18)
        }
        
        if questManager.currentBatch == 20{
            questManager.completeQuestWithIncremnetForce(named: "Update 2 graphs", num: 2, Quebatch: 20)
        }
        
        if questManager.currentBatch == 21{
            questManager.completeQuestWithIncremnetForce(named: "Update all unlocked graphs", num: 1, Quebatch: 21)
        }
        
        if questManager.currentBatch == 23{
            questManager.completeQuestWithIncremnetForce(named: "BMI or running graph", num: 1, Quebatch: 23)
        }
        
        if questManager.currentBatch == 25{
            questManager.completeQuestWithIncremnetForce(named: "Update 2 graphs", num: 2, Quebatch: 25)
            questManager.completeQuestWithIncremnetForce(named: "Update gym graph and Running graphs", num: 1, Quebatch: 25)
        }
        
        if questManager.currentBatch == 30{
            questManager.completeQuestWithIncremnetStaticForce(named: "Update all graphs", num: 5, Quebatch: 30)
        }
        
        if questManager.currentBatch == 31{
            questManager.completeQuestWithIncremnetForce(named: "Update one graph", num: 1, Quebatch: 31)
        }
        
        if questManager.currentBatch == 33{
            questManager.completeQuestWithIncremnetForce(named: "Update BMI and Running graphs", num: 1, Quebatch: 33)
        }
        if questManager.currentBatch == 36{
            questManager.completeQuestWithIncremnetForce(named: "Update 3 graphs", num: 3, Quebatch: 36)
        }
        if questManager.currentBatch == 39{
            questManager.completeQuestWithIncremnetForce(named: "Update all unlocked graphs", num: 5, Quebatch: 39)
        }
        if questManager.currentBatch == 42{
            questManager.completeQuestWithIncremnetForce(named: "Update 4 graphs", num: 4, Quebatch: 42)
        }
        if questManager.currentBatch == 45{
            questManager.completeQuestWithIncremnetForce(named: "Update 3 graphs", num: 3, Quebatch: 45)
        }
        
        if questManager.currentBatch == 46{
            questManager.completeQuestWithIncremnetForce(named: "Update 4 different graphs", num: 4, Quebatch: 46)
        }
        
        if questManager.currentBatch == 50{
            questManager.completeQuestWithIncremnetForce(named: "Update all graphs", num: 5, Quebatch: 50)
        }
        
        if questManager.currentBatch == 52{
            questManager.completeQuestWithIncremnetForce(named: "Update 2 graphs", num: 2, Quebatch: 52)
        }
        
        if questManager.currentBatch == 53{
            questManager.completeQuestWithIncremnetForce(named: "Update 4 graphs", num: 4, Quebatch: 53)
        }
        
        if questManager.currentBatch == 54{
            questManager.completeQuestWithIncremnetForce(named: "Update one graph", num: 1, Quebatch: 54)
        }
        
        if questManager.currentBatch == 56{
            questManager.completeQuestWithIncremnetForce(named: "Update all graphs", num: 5, Quebatch: 56)
        }
        
        if questManager.currentBatch == 57{
            questManager.completeQuestWithIncremnetForce(named: "Update 2 graphs", num: 2, Quebatch: 57)
        }
        
        if questManager.currentBatch == 58{
            questManager.completeQuestWithIncremnetForce(named: "Update 1 graph", num: 1, Quebatch: 58)
        }
        
        if questManager.currentBatch == 59{
            questManager.completeQuestWithIncremnetForce(named: "Update 5 different graphs", num: 5, Quebatch: 59)
        }
        
        if questManager.currentBatch == 61{
            questManager.completeQuestWithIncremnetForce(named: "Update all graphs", num: 5, Quebatch: 61)
        }
        
        if questManager.currentBatch == 63{
            questManager.completeQuestWithIncremnetForce(named: "Update all graphs", num: 5, Quebatch: 63)
        }
//        if userProfile.level == 2{
//            userProfile.xp =  Double(400 + earnedXP) // 400 for level 1 xp
//            if userProfile.xp == 1400{
//                userProfile.level = 3
//            }
//        }
        
        if questManager.currentBatch == 57{
            questManager.completeQuestWithIncremnetForce(named: "Update 2 graphs", num: 2, Quebatch: 57)
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
