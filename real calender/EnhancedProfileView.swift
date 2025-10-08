import SwiftUI
import Combine

// MARK: - Gold Mist Particle for Profile
struct ProfileGoldMistParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: CGFloat
    var opacity: Double
    let blur: CGFloat
    let fallSpeed: CGFloat
    let sway: CGFloat
}

class RemoteConfigManager: ObservableObject {
    @Published var config: RemoteConfig? = nil
    
    init() {
        self.fetch()
        // Run a timer that runs every 60 seconds
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            self.fetch()
        }
    }
    
    func fetch() {
    }
}

struct RemoteConfig {
    // Add properties as needed
}

struct EnhancedProfileView: View {
    @Binding var userProfile: UserProfile
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditProfile = false
    @State private var showingInitialSetup = false
    @State private var hasCompletedCalendarSetup = false
    @State private var goldMistParticles: [ProfileGoldMistParticle] = []
    @State private var mistTimer: Timer?
    @State private var profileGlow: Double = 0.3
    @State private var glowPulse: CGFloat = 1.0
    
    var body: some View {
        NavigationView {
            // Check if calendar setup is completed first
            if !hasCompletedCalendarSetup {
                LockedProfileSetupView()
            } else if !userProfile.hasBasicProfileSetup {
                InitialProfileSetupView(userProfile: $userProfile)
            } else {
                profileContent
            }
        }
        .onAppear {
            print("📱 EnhancedProfileView: onAppear called")
            checkCalendarSetup()
            print("📱 EnhancedProfileView: hasCompletedCalendarSetup = \(hasCompletedCalendarSetup)")
            print("📱 EnhancedProfileView: userProfile.hasBasicProfileSetup = \(userProfile.hasBasicProfileSetup)")
            print("📱 EnhancedProfileView: userProfile.gender = \(userProfile.gender)")
            
            if !userProfile.hasBasicProfileSetup && hasCompletedCalendarSetup {
                showingInitialSetup = true
            }
            startProfileGoldEffect() // Start the gold mist effect
        }
        .onDisappear {
            stopProfileGoldEffect() // Stop the gold mist effect when view disappears
        }
    }
    
    
    private func checkCalendarSetup() {
        let newCalendarSetup = UserDefaults.hasCompletedCalendarSetup
        print("📱 EnhancedProfileView: checkCalendarSetup() - value: \(newCalendarSetup)")
        
        if hasCompletedCalendarSetup != newCalendarSetup {
            print("📱 EnhancedProfileView: ⚠️  Calendar setup status CHANGED from \(hasCompletedCalendarSetup) to \(newCalendarSetup)")
        }
        
        hasCompletedCalendarSetup = newCalendarSetup
    }
    
    
    var profileContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with avatar and basic info
                VStack(spacing: 16) {
                    // Profile Avatar
                    ZStack {
                        // Gold glow effect behind avatar
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        .yellow.opacity(profileGlow * 0.4),
                                        .orange.opacity(profileGlow * 0.3),
                                        .yellow.opacity(profileGlow * 0.2),
                                        .clear
                                    ]),
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 180, height: 180)
                            .scaleEffect(glowPulse)
                            .blur(radius: 8)
                        
                        // Main profile circle
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .shadow(color: .yellow.opacity(0.5), radius: 10)
                        
                        Image(systemName: userProfile.gender == .male ? "figure.stand" : "figure.stand.dress")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                        
                        // Gold mist particles flowing down from profile
                        ForEach(goldMistParticles, id: \.id) { particle in
                            ZStack {
                                // Outer glow
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            gradient: Gradient(colors: [
                                                Color.yellow.opacity(particle.opacity * 0.3),
                                                Color.orange.opacity(particle.opacity * 0.2),
                                                .clear
                                            ]),
                                            center: .center,
                                            startRadius: 0,
                                            endRadius: particle.size * 1.2
                                        )
                                    )
                                    .frame(width: particle.size * 1.5, height: particle.size * 1.5)
                                    .blur(radius: particle.blur + 1)
                                
                                // Main particle
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            gradient: Gradient(colors: [
                                                Color.yellow.opacity(particle.opacity * 0.8),
                                                Color.orange.opacity(particle.opacity * 0.6),
                                                Color.yellow.opacity(particle.opacity * 0.4),
                                                .clear
                                            ]),
                                            center: .center,
                                            startRadius: 0,
                                            endRadius: particle.size * 0.6
                                        )
                                    )
                                    .frame(width: particle.size, height: particle.size)
                                    .blur(radius: particle.blur)
                                
                                // Bright core
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            gradient: Gradient(colors: [
                                                Color.white.opacity(particle.opacity * 0.7),
                                                Color.yellow.opacity(particle.opacity * 0.8),
                                                .clear
                                            ]),
                                            center: .center,
                                            startRadius: 0,
                                            endRadius: particle.size * 0.3
                                        )
                                    )
                                    .frame(width: particle.size * 0.3, height: particle.size * 0.3)
                                    .blur(radius: max(0.3, particle.blur - 0.5))
                            }
                            .position(particle.position)
                            .opacity(particle.opacity)
                        }
                    }
                    .frame(height: 200) // Extra height for mist particles
                    
                    // Basic Info
                    VStack(spacing: 8) {
                        Text(userProfile.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 16) {
                            Text("Age \(userProfile.age)")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            if userProfile.gender != .notSet {
                                Text(userProfile.gender.displayName)
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack(spacing: 16) {
                            Text("Level \(userProfile.level)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                            
                            Text("XP: \(Int(userProfile.xp))")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.purple)
                        }
                    }
                    
                    // XP Progress Bar
                    VStack(spacing: 8) {
                        let XprequriedToComplteLevel = UserProfile.xpRequiredForLevel(userProfile.level)
                        let progress = Double(userProfile.xp) / Double(XprequriedToComplteLevel)
                        ProgressView(value: progress)
                            .tint(.blue)
                            .scaleEffect(y: 2)
                        let remainingXP = Int(XprequriedToComplteLevel - userProfile.xp)
                        Text("Next Level: \(remainingXP) XP")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: 200)
                }
                
                // Performance Note (only show if profile is incomplete)
                if !userProfile.coreStatsComplete {
                    PerformanceCompletionNote(userProfile: userProfile)
                }
                
                // Quick Stats
                VStack(alignment: .leading, spacing: 16) {
                    Text("Quick Stats")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ProfileStatCard(
                            icon: "ruler",
                            title: "Height",
                            value: "\(Int(userProfile.heightCM)) cm",
                            color: .blue
                        )
                        
                        ProfileStatCard(
                            icon: "scalemass",
                            title: "Weight",
                            value: "\(Int(userProfile.weightKG)) kg",
                            color: .green
                        )
                        
                        ProfileStatCard(
                            icon: "heart.fill",
                            title: "BMI",
                            value: String(format: "%.1f", userProfile.bmi),
                            color: getBMIColor()
                        )
                        
                        ProfileStatCard(
                            icon: "circle.dashed",
                            title: "Waist",
                            value: "\(Int(userProfile.waistCM)) cm",
                            color: .orange
                        )
                    }
                }
                
                // Fitness Stats
                if userProfile.swimming50MLaps > 0 || userProfile.running5KTimeSec > 0 {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Fitness Performance")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 12) {
                            if userProfile.swimming50MLaps > 0 {
                                HStack {
                                    Image(systemName: "figure.pool.swim")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Swimming Endurance")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                        
                                        Text("\(userProfile.swimming50MLaps) laps (50m)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("💪")
                                        .font(.title2)
                                }
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                            }
                            
                            if userProfile.running5KTimeSec > 0 {
                                HStack {
                                    Image(systemName: "figure.run")
                                        .font(.title2)
                                        .foregroundColor(.green)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("5K Running Time")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                        
                                        Text(userProfile.running5KTimeFormatted)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("🏃‍♂️")
                                        .font(.title2)
                                }
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                
                // Academic & Career
                if userProfile.educationLevel != .notSet || userProfile.annualIncomeThousands > 0 {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Academic & Career")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 12) {
                            if userProfile.educationLevel != .notSet {
                                HStack {
                                    Image(systemName: "graduationcap.fill")
                                        .font(.title2)
                                        .foregroundColor(.purple)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Education Level")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                        
                                        Text(userProfile.educationLevel.displayName)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    let gpa = userProfile.educationLevel == .highSchool ? userProfile.highSchoolGPA : userProfile.universityGPA
                                    if gpa > 0 {
                                        Text("GPA: \(String(format: "%.1f", gpa))")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.purple)
                                    }
                                }
                                .padding()
                                .background(Color.purple.opacity(0.1))
                                .cornerRadius(12)
                            }
                            
                            if userProfile.annualIncomeThousands > 0 {
                                HStack {
                                    Image(systemName: "dollarsign.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.green)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Annual Income")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                        
                                        Text("$\(userProfile.annualIncomeThousands)k")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("💰")
                                        .font(.title2)
                                }
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                
                // Custom Measurements
                if !userProfile.measurements.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Body Measurements")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(userProfile.measurements.sorted(by: { $0.key < $1.key }), id: \.key) { measurement in
                                VStack(spacing: 8) {
                                    Text(measurement.key)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    Text("\(String(format: "%.1f", measurement.value))\"")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                
                // Action Buttons
                VStack(spacing: 12) {
                    
                    let showEditProfile = userProfile.hasBasicMeasurements  && userProfile.swimming50MLaps > 0 && userProfile.running5KTimeSec > 0 && userProfile.annualIncomeThousands > 0
                    
                    if showEditProfile{
                        Button("Edit Profile") {
                            showingEditProfile = true
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Quick restore button if missing performance data
                    if !hasCompletePerformanceData {
                        Button("📊 Restore Performance Data") {
                            restorePerformanceData()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.blue)
                    }
                    
                    NavigationLink(destination: UserStatsView(profile: userProfile)) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("View Detailed Analytics")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text("See your performance vs others")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            ProfileEditView(userProfile: $userProfile)
        }
    }
    
    private func getBMIColor() -> Color {
        let bmi = userProfile.bmi
        switch bmi {
        case ..<18.5: return .blue
        case 18.5..<25: return .green
        case 25..<30: return .orange
        default: return .red
        }
    }
    
    private func restartAllAppData() {
        // Clear ALL UserDefaults data - more comprehensive approach
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
        // Explicitly clear critical keys (backup approach)
        UserDefaults.standard.removeObject(forKey: "userProfile")
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: "measurements")
        UserDefaults.standard.removeObject(forKey: "stats")
        UserDefaults.standard.removeObject(forKey: "achievements")
        UserDefaults.standard.removeObject(forKey: "customStats")
        UserDefaults.standard.removeObject(forKey: "runningHistory")
        UserDefaults.standard.removeObject(forKey: "lastRunDate")
        UserDefaults.standard.removeObject(forKey: "calendarEvents")
        UserDefaults.standard.removeObject(forKey: "discountTimerStartTime")
        UserDefaults.standard.removeObject(forKey: "trialStartDate")
        UserDefaults.standard.removeObject(forKey: "isOnFreeTrial")
        UserDefaults.standard.removeObject(forKey: "subscriptionType")
        UserDefaults.standard.removeObject(forKey: "subscriptionStartDate")
        
        // Reset onboarding status to force app restart from beginning
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        
        // Force synchronize to ensure changes are persisted
        UserDefaults.standard.synchronize()
        
        // Post notification to ContentView to reset app state
        NotificationCenter.default.post(name: .appDataReset, object: nil)
        QuestStorageManager().clearAllData()
        // Dismiss the current view immediately
        dismiss()
    }
    
    private var hasCompletePerformanceData: Bool {
        let hasSwimming = userProfile.swimming50MLaps > 0
        let hasRunning = userProfile.running5KTimeSec > 0
        let hasIncome = userProfile.annualIncomeThousands > 0
        let hasPullUps = userProfile.customStats.contains { stat in
            stat.name.lowercased().contains("pull")
        }
        
        return hasSwimming && hasRunning && hasIncome && hasPullUps
    }
    
    private func restorePerformanceData() {
        // Add realistic performance data
        userProfile.swimming50MLaps = 12  // 12 laps
        userProfile.running5KTimeSec = 1470 // 24.5 minutes = 1470 seconds
        userProfile.annualIncomeThousands = 65 // $65,000
        
        // Add pull-ups to custom stats
        let pullUpsStat = CustomStat(
            name: "Pull-ups",
            value: 15.0,
            unit: "reps",
            category: .sports,
            isHigherBetter: true
        )
        
        // Remove existing pull-ups stat if it exists
        userProfile.customStats.removeAll { stat in
            stat.name.lowercased().contains("pull")
        }
        userProfile.customStats.append(pullUpsStat)
        
        if userProfile.level == 2{
            userProfile.xp =  Double(400 + earnedXP)
            if userProfile.xp == 1400{
                userProfile.level = 3
            }
        }
        
        userProfile.save()
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
    
    // MARK: - Profile Gold Mist Effects
    private func startProfileGoldEffect() {
        // Start golden glow pulsing
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            profileGlow = 0.7
            glowPulse = 1.1
        }
        
        // Start gold mist particle generation
        mistTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            createProfileMistParticle()
        }
        
        print("🌟 Started profile gold mist effect")
    }
    
    private func stopProfileGoldEffect() {
        mistTimer?.invalidate()
        mistTimer = nil
        goldMistParticles.removeAll()
        print("✨ Stopped profile gold mist effect")
    }
    
    private func createProfileMistParticle() {
        // Create particle at the bottom of the profile circle
        let centerX: CGFloat = UIScreen.main.bounds.width / 2
        let startY: CGFloat = 200 // Just below the profile avatar
        
        let particle = ProfileGoldMistParticle(
            position: CGPoint(
                x: centerX + CGFloat.random(in: -60...60), // Spread around profile
                y: startY + CGFloat.random(in: -10...10)
            ),
            size: CGFloat.random(in: 8...25),
            opacity: Double.random(in: 0.3...0.8),
            blur: CGFloat.random(in: 0.5...2.0),
            fallSpeed: CGFloat.random(in: 1.5...3.0),
            sway: CGFloat.random(in: -20...20)
        )
        
        goldMistParticles.append(particle)
        
        // Animate the particle falling down
        animateProfileMistParticle(particle)
        
        // Remove old particles to prevent memory issues
        if goldMistParticles.count > 20 {
            goldMistParticles.removeFirst()
        }
    }
    
    private func animateProfileMistParticle(_ particle: ProfileGoldMistParticle) {
        let particleIndex = goldMistParticles.firstIndex(where: { $0.id == particle.id })
        guard let index = particleIndex else { return }
        
        let duration: Double = Double.random(in: 4.0...8.0)
        let fallDistance: CGFloat = UIScreen.main.bounds.height + 200
        
        withAnimation(.linear(duration: duration)) {
            // Fall down with gentle sway
            goldMistParticles[index].position.y += fallDistance
            goldMistParticles[index].position.x += particle.sway
            
            // Fade out as it falls
            goldMistParticles[index].opacity *= 0.3
        }
        
        // Remove particle after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            goldMistParticles.removeAll { $0.id == particle.id }
        }
    }
}

// MARK: - Profile Stat Card
struct ProfileStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

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
        var total = 5
        
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

// MARK: - Profile Update Notification
extension Notification.Name {
    static let appDataReset = Notification.Name("appDataReset")
}

// MARK: - Preview
struct Preview: PreviewProvider {
    static var previews: some View {
        EnhancedProfileView(userProfile: .constant(UserProfile(
            name: "Alex",
            age: 25,
            heightCM: 175,
            weightKG: 70,
            measurements: ["Biceps": 12, "Chest": 38],
            level: 5,
            xp: 1200,
            stats: []
        )))
    }
}
