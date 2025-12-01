import SwiftUI

struct InitialProfileSetupView: View {
    @Binding var userProfile: UserProfile
    @State private var selectedGender: Gender = .notSet
    @State private var userAgeInt: Int = 18  // Changed to Int with default value
    @State private var heightCM: String = ""
    @State private var weightKG: String = ""
    @State private var currentGPA: String = ""
    @State private var subjects: [SubjectGrade] = []
    @State private var showingAddSubject = false
    @State private var isTransitioning = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var questManager: QuestManager
    
    var body: some View {
        //        NavigationView {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Text("👋 Welcome!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Let's set up your profile with some basic information to provide accurate comparisons.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Gender Selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("What's your gender?")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("This helps us provide accurate fitness and health comparisons for your age group.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    VStack(spacing: 12) {
                        GenderSelectionCard(
                            gender: .male,
                            isSelected: selectedGender == .male
                        ) {
                            selectedGender = .male
                        }
                        
                        GenderSelectionCard(
                            gender: .female,
                            isSelected: selectedGender == .female
                        ) {
                            selectedGender = .female
                        }
                    }
                }
                
                // Age Question (show after gender is selected)
                if selectedGender != .notSet {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("How old are you?")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Your age helps us provide accurate comparisons with your peer group and adjust all statistics accordingly.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Picker("Age", selection: $userAgeInt) {
                                ForEach(10...100, id: \.self) { age in
                                    Text("\(age)")
                                        .tag(age)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 120)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            
                            Text("💡 This adjusts all normal distributions and comparisons to be age-appropriate")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .italic()
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(radius: 2)
                }
                
                // Height and Weight Section (only show after gender and age are selected)
                if selectedGender != .notSet && userAgeInt >= 10 {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Physical Information")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("This helps us calculate your BMI and provide personalized health insights.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            // Honesty note
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                    .font(.title3)
                                
                                Text("Please be honest and don't lie to yourself - this app is here to help you!")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        VStack(spacing: 16) {
                            // Height Input
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Height (cm)")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                TextField("e.g. 175", text: $heightCM)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.numberPad)
                                    .frame(maxWidth: 150)
                            }
                            
                            // Weight Input
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Weight (kg)")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                TextField("e.g. 70", text: $weightKG)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.numberPad)
                                    .frame(maxWidth: 150)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(radius: 2)
                }
                
                if selectedGender != .notSet && userAgeInt >= 10 {
                    
                    // Student status
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Are you a student?")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 16) {
                            Button(action: {
                                userProfile.isStudent = true
                                userProfile.educationLevel = .notSet
                            }) {
                                Text("Yes")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(userProfile.isStudent ? Color.blue : Color(.systemGray6))
                                    .foregroundColor(userProfile.isStudent ? .white : .primary)
                                    .cornerRadius(12)
                            }
                            
                            Button(action: {
                                userProfile.isStudent = false
                                userProfile.educationLevel = .neither
                            }) {
                                Text("No")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(!userProfile.isStudent ? Color.blue : Color(.systemGray6))
                                    .foregroundColor(!userProfile.isStudent ? .white : .primary)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                }
                
                // Education Level Info (read-only display)
                // Show only if user is a student
                if userProfile.isStudent {
                    
                    // CASE 1: Student has already selected education level → Show “detected” UI
                    if userProfile.educationLevel != .notSet {
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Education Status")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            HStack {
                                Image(systemName: getEducationIcon())
                                    .foregroundColor(.blue)
                                    .font(.title2)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(userProfile.educationLevel.displayName)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    Text("Detected from your calendar setup")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title2)
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                            
                            Text("💡 You can change this later in your profile settings if needed.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                        
                    } else {
                        
                        // CASE 2: Student but educationLevel == .notSet → let user choose
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Select Your Education Level")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            HStack(spacing: 16) {
                                
                                // High School Button
                                Button(action: {
                                    userProfile.educationLevel = .highSchool
                                }) {
                                    Text("High School")
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            userProfile.educationLevel == .highSchool ?
                                            Color.blue : Color(.systemGray6)
                                        )
                                        .foregroundColor(
                                            userProfile.educationLevel == .highSchool ?
                                                .white : .primary
                                        )
                                        .cornerRadius(12)
                                }
                                
                                // University Button
                                Button(action: {
                                    userProfile.educationLevel = .university
                                }) {
                                    Text("University")
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            userProfile.educationLevel == .university ?
                                            Color.blue : Color(.systemGray6)
                                        )
                                        .foregroundColor(
                                            userProfile.educationLevel == .university ?
                                                .white : .primary
                                        )
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                }
                
                // if userProfile.educationLevel != .notSet{//educationLevel
                //                    if userProfile.isStudent && userProfile.educationLevel != .notSet {
                //
                //                        VStack(alignment: .leading, spacing: 16) {
                //                            Text("Education Status")
                //                                .font(.title2)
                //                                .fontWeight(.bold)
                //
                //                            HStack {
                //                                Image(systemName: getEducationIcon())
                //                                    .foregroundColor(.blue)
                //                                    .font(.title2)
                //
                //                                VStack(alignment: .leading, spacing: 4) {
                //                                    Text(userProfile.educationLevel.displayName)
                //                                        .font(.headline)
                //                                        .fontWeight(.semibold)
                //
                //                                    Text("Detected from your calendar setup")
                //                                        .font(.caption)
                //                                        .foregroundColor(.secondary)
                //                                }
                //
                //                                Spacer()
                //
                //                                Image(systemName: "checkmark.circle.fill")
                //                                    .foregroundColor(.green)
                //                                    .font(.title2)
                //                            }
                //                            .padding()
                //                            .background(Color.blue.opacity(0.1))
                //                            .cornerRadius(12)
                //
                //                            Text("💡 You can change this later in your profile settings if needed.")
                //                                .font(.caption)
                //                                .foregroundColor(.secondary)
                //                                .italic()
                //                        }
                //                    }else{
                //                        VStack(alignment: .leading, spacing: 16) {
                //                            Text("Education Information")
                //                                .font(.title2)
                //                                .fontWeight(.bold)
                //
                //                            HStack {
                //                                Image(systemName: getEducationIcon())
                //                                    .foregroundColor(.blue)
                //                                    .font(.title2)
                //
                //                                VStack(alignment: .leading, spacing: 4) {
                //                                    Text(userProfile.educationLevel.displayName)
                //                                        .font(.headline)
                //                                        .fontWeight(.semibold)
                //
                //                                    Text("Detected from your calendar setup")
                //                                        .font(.caption)
                //                                        .foregroundColor(.secondary)
                //                                }
                //
                //                                Spacer()
                //
                //                                Image(systemName: "checkmark.circle.fill")
                //                                    .foregroundColor(.green)
                //                                    .font(.title2)
                //                            }
                //                            .padding()
                //                            .background(Color.blue.opacity(0.1))
                //                            .cornerRadius(12)
                //
                //                            Text("💡 You can change this later in your profile settings if needed.")
                //                                .font(.caption)
                //                                .foregroundColor(.secondary)
                //                                .italic()
                //                        }
                //                    }
                
                // Academic Questions (only for high school and university students)
                if userProfile.isStudent &&
                    (userProfile.educationLevel == .highSchool || userProfile.educationLevel == .university) &&
                    hasPhysicalInfo &&
                    userAgeInt >= 10{
                    
                    
                    //  if (userProfile.educationLevel == .highSchool || userProfile.educationLevel == .university) && hasPhysicalInfo && userAgeInt >= 10 {
                    VStack(alignment: .leading, spacing: 20) {
                        // GPA Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("What's your current GPA?")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Enter your GPA out of 7.0 (or convert from 4.0 scale)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("e.g. 6.2", text: $currentGPA)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                                .frame(maxWidth: 150)
                        }
                        .frame(maxWidth:.infinity,alignment: .leading)
                        
                        // Subjects Section // har just commented for rmove
                        //                            VStack(alignment: .leading, spacing: 16) {
                        //                                HStack {
                        //                                    Text("Current Subjects & Grades")
                        //                                        .font(.title2)
                        //                                        .fontWeight(.bold)
                        //
                        //                                    Spacer()
                        //
                        //                                    Button("+ Add Subject") {
                        //                                        showingAddSubject = true
                        //                                    }
                        //                                    .buttonStyle(.borderedProminent)
                        //                                    .controlSize(.small)
                        //                                }
                        //
                        //                                Text("Add your current subjects and their percentages")
                        //                                    .font(.subheadline)
                        //                                    .foregroundColor(.secondary)
                        //
                        //                                if subjects.isEmpty {
                        //                                    VStack(spacing: 12) {
                        //                                        Image(systemName: "book.closed")
                        //                                            .font(.system(size: 40))
                        //                                            .foregroundColor(.gray)
                        //
                        //                                        Text("No subjects added yet")
                        //                                            .font(.subheadline)
                        //                                            .foregroundColor(.secondary)
                        //
                        //                                        Text("Tap 'Add Subject' to get started")
                        //                                            .font(.caption)
                        //                                            .foregroundColor(.secondary)
                        //                                    }
                        //                                    .frame(maxWidth: .infinity)
                        //                                    .padding()
                        //                                    .background(Color(.systemGray6))
                        //                                    .cornerRadius(12)
                        //                                } else {
                        //                                    LazyVStack(spacing: 8) {
                        //                                        ForEach(subjects.indices, id: \.self) { index in
                        //                                            SubjectRow(
                        //                                                subject: subjects[index],
                        //                                                onDelete: {
                        //                                                    subjects.remove(at: index)
                        //                                                }
                        //                                            )
                        //                                        }
                        //                                    }
                        //                                }
                        //                            }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(radius: 2)
                }
                
                // Continue Button - moved inside ScrollView content
                VStack(spacing: 16) {
                    // Show selection status
                    if canProceed {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Ready to continue!")
                                .font(.subheadline)
                                .foregroundColor(.green)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Button(isTransitioning ? "Continuing..." : "Continue to Profile") {
                        saveAndContinue()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
                    .disabled(!canProceed || isTransitioning)
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .navigationTitle("Profile Setup")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showingAddSubject) {
            // Removed AddSubjectView implementation, use the one from NormalDistributionGraph.swift
        }
        .onAppear {
            // Pre-populate if values are already set
            selectedGender = userProfile.gender
            userAgeInt = userProfile.age > 0 ? userProfile.age : 18  // Use Int picker with default 18
            heightCM = userProfile.heightCM > 0 ? String(Int(userProfile.heightCM)) : ""
            weightKG = userProfile.weightKG > 0 ? String(Int(userProfile.weightKG)) : ""
            currentGPA = userProfile.educationLevel == .highSchool ?
            String(userProfile.highSchoolGPA) : String(userProfile.universityGPA)
            loadExistingSubjects()
        }
        //        }
        
    }
    
    private var hasPhysicalInfo: Bool {
        return !heightCM.isEmpty && !weightKG.isEmpty &&
        Double(heightCM) != nil && Double(weightKG) != nil
    }
    
    private var hasValidAge: Bool {
        return userAgeInt >= 10 && userAgeInt <= 100
    }
    
    private var canProceed: Bool {
        guard selectedGender != .notSet else { return false }
        guard hasValidAge else { return false }
        guard hasPhysicalInfo else { return false }
        
        // For work education level, only gender, age and physical info required
        if userProfile.educationLevel == .neither {
            return true
        }
        
        // For high school and university, require GPA and at least one subject
        if userProfile.isStudent &&
            (userProfile.educationLevel == .highSchool || userProfile.educationLevel == .university) {
            
            //if userProfile.educationLevel == .highSchool || userProfile.educationLevel == .university {
            let hasValidGPA = !currentGPA.isEmpty && Double(currentGPA) != nil && Double(currentGPA) != 0.0 && Double(currentGPA) ?? 0.0 <= 7.0
           // let hasSubjects = !subjects.isEmpty // har subjects remove for current
            return hasValidGPA //&& hasSubjects
        }
        
        return true
    }
    
    private func loadExistingSubjects() {
        // Only load subjects if they exist in the profile
        if userProfile.educationLevel == .highSchool && !userProfile.highSchoolSubjects.isEmpty {
            subjects = userProfile.highSchoolSubjects.map { subject in
                SubjectGrade(name: subject.name, percentage: String(subject.percentage))
            }
        } else if userProfile.educationLevel == .university && !userProfile.universitySubjects.isEmpty {
            subjects = userProfile.universitySubjects.map { subject in
                SubjectGrade(name: subject.name, percentage: String(subject.percentage))
            }
        }
    }
    
    private func getEducationIcon() -> String {
        switch userProfile.educationLevel {
        case .highSchool:
            return "graduationcap"
        case .university:
            return "building.columns"
        case .neither:
            return "briefcase"
        default:
            return "questionmark.circle"
        }
    }
    
    private func saveAndContinue() {
        print("🔧 InitialProfileSetup: === SAVE AND CONTINUE START ===")
        print("🔧 InitialProfileSetup: User selected - Gender: \(selectedGender), Age: \(userAgeInt)")
        print("🔧 InitialProfileSetup: Physical data - Height: \(heightCM), Weight: \(weightKG)")
        
        isTransitioning = true
        
        // Update the profile with all collected data
        userProfile.gender = selectedGender
        userProfile.age = userAgeInt
        userProfile.heightCM = Double(heightCM) ?? 0.0
        userProfile.weightKG = Double(weightKG) ?? 0.0
        userProfile.isStudent = userProfile.isStudent
        
        
        // Ensure name is set if empty
        if userProfile.name.isEmpty {
            userProfile.name = "User"
        }
        
        print("🔧 InitialProfileSetup: Updated profile data:")
        print("🔧 InitialProfileSetup:   Name: '\(userProfile.name)'")
        print("🔧 InitialProfileSetup:   Gender: \(userProfile.gender)")
        print("🔧 InitialProfileSetup:   Age: \(userProfile.age)")
        print("🔧 InitialProfileSetup:   Height: \(userProfile.heightCM)")
        print("🔧 InitialProfileSetup:   Weight: \(userProfile.weightKG)")
        print("🔧 InitialProfileSetup:   hasBasicProfileSetup: \(userProfile.hasBasicProfileSetup)")
        
        // Save GPA and subjects for academic students
        if userProfile.educationLevel == .highSchool || userProfile.educationLevel == .university {
            let gpa = Double(currentGPA) ?? 0.0
            
            if userProfile.educationLevel == .highSchool {
                userProfile.highSchoolGPA = gpa
                userProfile.highSchoolSubjects = subjects.map { subject in
                    AcademicSubject(name: subject.name, percentage: Double(subject.percentage) ?? 0.0)
                }
            } else {
                userProfile.universityGPA = gpa
                userProfile.universitySubjects = subjects.map { subject in
                    AcademicSubject(name: subject.name, percentage: Double(subject.percentage) ?? 0.0)
                }
            }
            print("🔧 InitialProfileSetup: Added academic data - GPA: \(gpa)")
            questManager.completeQuest(named: "Complete two graphs in your profile")
        }
        
        // Save to UserDefaults with proper error handling
        do {
            userProfile.save()
            print("🔧 InitialProfileSetup: ✅ Profile saved successfully to UserDefaults")
            
#if DEBUG
            if let verifyProfile = UserProfile.load() {
                print("🔧 InitialProfileSetup: ✅ Verification - Saved profile name: '\(verifyProfile.name)'")
                print("🔧 InitialProfileSetup: ✅ Verification - Saved profile gender: \(verifyProfile.gender)")
                print("🔧 InitialProfileSetup: ✅ Verification - hasBasicProfileSetup: \(verifyProfile.hasBasicProfileSetup)")
            }
#endif
            
            
            // save Quest pass
            questManager.completeQuest(named: "Complete two graphs in your profile")
          
            
            // CRITICAL: Also post a notification so other views update
            print("🔧 InitialProfileSetup: Posting profileUpdated notification...")
            NotificationCenter.default.post(name: .profileUpdated, object: userProfile)
            
        } catch {
            print("🔧 InitialProfileSetup: ❌ CRITICAL ERROR - Failed to encode/save profile: \(error)")
            // Even if save fails, continue with transition
        }
        
        print("🔧 InitialProfileSetup: === SAVE AND CONTINUE END ===")
        
        // Add a small delay for better UX, then the binding will automatically update
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isTransitioning = false
        }
    }
    
    private func getAgeGroupName(for age: Int) -> String {
        switch age {
        case 13...15: return "Early High School (13-15)"
        case 16...18: return "Late High School (16-18)"
        case 19...22: return "University Age (19-22)"
        case 23...26: return "Early Career (23-26)"
        case 27...30: return "Young Professional (27-30)"
        case 31...35: return "Early Mid-Career (31-35)"
        case 36...40: return "Mid-Career (36-40)"
        case 41...50: return "Experienced Professional (41-50)"
        case 51...60: return "Senior Professional (51-60)"
        default: return age > 60 ? "Senior Adult (60+)" : "Young Teen (Under 13)"
        }
    }
}

// MARK: - Supporting Models
struct SubjectGrade: Identifiable {
    let id = UUID()
    var name: String
    var percentage: String
}

// MARK: - Subject Row
struct SubjectRow: View {
    let subject: SubjectGrade
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(subject.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("\(subject.percentage)%")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Remove") {
                onDelete()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .foregroundColor(.red)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Gender Selection Card
struct GenderSelectionCard: View {
    let gender: Gender
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: gender == .male ? "figure.stand" : "figure.stand.dress")
                            .font(.title2)
                            .foregroundColor(isSelected ? .white : .primary)
                        
                        Text(gender.displayName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(isSelected ? .white : .primary)
                    }
                    
                    Text(gender == .male ? "Male fitness and health comparisons" : "Female fitness and health comparisons")
                        .font(.subheadline)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    InitialProfileSetupView(userProfile: .constant(UserProfile(
        name: "Test User",
        age: 25,
        heightCM: 0,
        weightKG: 0,
        measurements: [:],
        level: 1,
        xp: 0,
        stats: []
    )))
}
