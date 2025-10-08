import SwiftUI

struct CustomStatsView: View {
    @Binding var userProfile: UserProfile
    @State private var showingAddStat = false
    @State private var showingUnlockMessage = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 12) {
                Text("Custom Stats")
                    .font(.title2)
                    .fontWeight(.bold)
                
                if !userProfile.unlockedCustomStats {
                    UnlockMessageView(coreStatsComplete: userProfile.coreStatsComplete) {
                        showingUnlockMessage = true
                    }
                } else {
                    Text("Add your own achievements and skills!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            if userProfile.unlockedCustomStats {
                // Add new stat button
                Button(action: {
                    showingAddStat = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        Text("Add Custom Stat")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                // Existing custom stats
                if !userProfile.customStats.isEmpty {
                    VStack(spacing: 12) {
                        ForEach(userProfile.customStats) { stat in
                            CustomStatsCardView(
                                customStat: stat,
                                userProfile: userProfile,
                                onDelete: {
                                    deleteCustomStat(stat)
                                }
                            )
                        }
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.yellow)
                        
                        Text("No custom stats yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Add your achievements, skills, and talents to get a complete performance profile!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Popular suggestions
                if userProfile.customStats.count < 3 {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Popular Stats to Add:")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 8) {
                            ForEach(PredefinedCustomStat.availableStats.prefix(4), id: \.name) { stat in
                                if !userProfile.customStats.contains(where: { $0.name == stat.name }) {
                                    SuggestionCard(stat: stat) {
                                        addPredefinedStat(stat)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddStat) {
            CustomStatsAddView(userProfile: $userProfile)
        }
        .sheet(isPresented: $showingUnlockMessage) {
            UnlockCustomStatsView(userProfile: userProfile)
        }
    }
    
    private func deleteCustomStat(_ stat: CustomStat) {
        userProfile.customStats.removeAll { $0.id == stat.id }
        userProfile.save()
    }
    
    private func addPredefinedStat(_ predefinedStat: PredefinedCustomStat) {
        showingAddStat = true
    }
}

// MARK: - Unlock Message View
struct UnlockMessageView: View {
    let coreStatsComplete: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            Text("🔒 Custom Stats Locked")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.orange)
            
            if coreStatsComplete {
                VStack(spacing: 8) {
                    Text("Congratulations! You've completed all core stats!")
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                    
                    Button("🎉 Unlock Custom Stats") {
                        action()
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                VStack(spacing: 8) {
                    Text("Complete your core stats first to unlock custom achievements!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text("You need: Physical measurements, Swimming, Running, Income, Education grades/GPA, and Pull-ups")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("See What's Missing") {
                        action()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Custom Stats Card View (unique name to avoid conflict)
struct CustomStatsCardView: View {
    let customStat: CustomStat
    let userProfile: UserProfile
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: customStat.category.icon)
                        .foregroundColor(customStat.category.color)
                    
                    Text(customStat.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("\(formatValue(customStat.value)) \(customStat.unit)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if let metric = getPerformanceMetric(for: customStat) {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(metric.rank)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(metric.color)
                            
                            Text("\(Int(metric.percentile * 100))th percentile")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Text(customStat.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash.circle.fill")
                    .foregroundColor(.red)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
    
    private func formatValue(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }
    
    private func getPerformanceMetric(for customStat: CustomStat) -> PerformanceMetric? {
        guard let predefinedStat = PredefinedCustomStat.availableStats.first(where: { $0.name == customStat.name }) else {
            return nil
        }
        
        let ageGroupStats = predefinedStat.ageGroupStats(userProfile.age)
        return PerformanceMetric(
            name: customStat.name,
            userValue: customStat.value,
            ageGroupStats: ageGroupStats,
            unit: customStat.unit,
            isHigherBetter: customStat.isHigherBetter
        )
    }
}

// MARK: - Suggestion Card
struct SuggestionCard: View {
    let stat: PredefinedCustomStat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: stat.category.icon)
                    .font(.title2)
                    .foregroundColor(stat.category.color)
                
                Text(stat.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Add Custom Stat View (renamed to avoid conflict)
struct CustomStatsAddView: View {
    @Binding var userProfile: UserProfile
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPredefined: PredefinedCustomStat?
    @State private var customName = ""
    @State private var customValue = 0.0
    @State private var customUnit = ""
    @State private var selectedCategory = CustomStatCategory.other
    @State private var isHigherBetter = true
    @State private var showingPredefined = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Toggle between predefined and custom
                Picker("Type", selection: $showingPredefined) {
                    Text("Popular Stats").tag(true)
                    Text("Custom Stat").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 20) {
                        if showingPredefined {
                            PredefinedStatsSection(
                                selectedPredefined: $selectedPredefined,
                                customValue: $customValue,
                                userProfile: userProfile
                            )
                        } else {
                            CustomStatSection(
                                customName: $customName,
                                customValue: $customValue,
                                customUnit: $customUnit,
                                selectedCategory: $selectedCategory,
                                isHigherBetter: $isHigherBetter
                            )
                        }
                    }
                    .padding()
                }
                
                // Add button
                Button(showingPredefined ? "Add Stat" : "Add Custom Stat") {
                    addStat()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .disabled(!canAddStat)
            }
            .navigationTitle("Add Stat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var canAddStat: Bool {
        if showingPredefined {
            return selectedPredefined != nil && customValue > 0
        } else {
            return !customName.isEmpty && customValue > 0 && !customUnit.isEmpty
        }
    }
    
    private func addStat() {
        let newStat: CustomStat
        
        if showingPredefined, let predefined = selectedPredefined {
            newStat = CustomStat(
                name: predefined.name,
                value: customValue,
                unit: predefined.unit,
                category: predefined.category,
                isHigherBetter: predefined.isHigherBetter
            )
        } else {
            newStat = CustomStat(
                name: customName,
                value: customValue,
                unit: customUnit,
                category: selectedCategory,
                isHigherBetter: isHigherBetter
            )
        }
        
        userProfile.customStats.append(newStat)
        userProfile.save()
        dismiss()
    }
}

// MARK: - Predefined Stats Section
struct PredefinedStatsSection: View {
    @Binding var selectedPredefined: PredefinedCustomStat?
    @Binding var customValue: Double
    let userProfile: UserProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose a Popular Stat")
                .font(.headline)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(PredefinedCustomStat.availableStats.filter { stat in
                    !userProfile.customStats.contains { $0.name == stat.name }
                }, id: \.name) { stat in
                    PredefinedStatCard(
                        stat: stat,
                        isSelected: selectedPredefined?.name == stat.name
                    ) {
                        selectedPredefined = stat
                        customValue = 0.0
                    }
                }
            }
            
            if let selected = selectedPredefined {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Enter Your \(selected.name)")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(selected.placeholder)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        TextField("Value", value: $customValue, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Text(selected.unit)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Age group comparison preview
                    if customValue > 0 {
                        let ageGroupStats = selected.ageGroupStats(userProfile.age)
                        let metric = PerformanceMetric(
                            name: selected.name,
                            userValue: customValue,
                            ageGroupStats: ageGroupStats,
                            unit: selected.unit,
                            isHigherBetter: selected.isHigherBetter
                        )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Performance:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            HStack {
                                Text(metric.rank)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(metric.color)
                                
                                Spacer()
                                
                                Text("\(Int(metric.percentile * 100))th percentile")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(metric.color.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Custom Stat Section
struct CustomStatSection: View {
    @Binding var customName: String
    @Binding var customValue: Double
    @Binding var customUnit: String
    @Binding var selectedCategory: CustomStatCategory
    @Binding var isHigherBetter: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Create Your Own Stat")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Stat Name")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                TextField("e.g., Cooking Recipes Known", text: $customName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Category")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Picker("Category", selection: $selectedCategory) {
                    ForEach(CustomStatCategory.allCases, id: \.self) { category in
                        HStack {
                            Image(systemName: category.icon)
                                .foregroundColor(category.color)
                            Text(category.rawValue)
                        }
                        .tag(category)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Value")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    TextField("0", value: $customValue, format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Unit")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    TextField("e.g., recipes", text: $customUnit)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            
            Toggle("Higher is Better", isOn: $isHigherBetter)
                .font(.subheadline)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Predefined Stat Card
struct PredefinedStatCard: View {
    let stat: PredefinedCustomStat
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: stat.category.icon)
                    .font(.title2)
                    .foregroundColor(stat.category.color)
                
                Text(stat.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(stat.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? stat.category.color.opacity(0.2) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? stat.category.color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Unlock Custom Stats View
struct UnlockCustomStatsView: View {
    let userProfile: UserProfile
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                if userProfile.coreStatsComplete {
                    VStack(spacing: 16) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                        
                        Text("🎉 Congratulations!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("You've completed all core stats!")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 12) {
                        Text("Custom stats are now unlocked! Add your unique achievements, skills, and talents to get a complete performance profile.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Start Adding Custom Stats") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("Complete Core Stats First")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Fill out these essential stats to unlock custom achievements:")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        CoreStatItem(
                            title: "Physical Stats (Height, Weight, Waist)",
                            isComplete: userProfile.hasBasicMeasurements
                        )
                        
                        CoreStatItem(
                            title: "Swimming Endurance (50m laps)",
                            isComplete: userProfile.swimming50MLaps > 0
                        )
                        
                        CoreStatItem(
                            title: "5K Running Time",
                            isComplete: userProfile.running5KTimeSec > 0
                        )
                        
                        CoreStatItem(
                            title: "Annual Income",
                            isComplete: userProfile.annualIncomeThousands > 0
                        )
                        
                        CoreStatItem(
                            title: "Education (Grades/GPA)",
                            isComplete: userProfile.hasEducationData
                        )
                        
                        CoreStatItem(
                            title: "Pull-ups Performance",
                            isComplete: userProfile.hasPullUpsData
                        )
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            .padding()
            .navigationTitle("Custom Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Core Stat Item
struct CoreStatItem: View {
    let title: String
    let isComplete: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isComplete ? .green : .gray)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(isComplete ? .primary : .secondary)
            
            Spacer()
        }
    }
}

#Preview {
    CustomStatsView(userProfile: .constant(UserProfile(
        name: "Alex",
        age: 22,
        heightCM: 175,
        weightKG: 70,
        measurements: [:],
        level: 5,
        xp: 1200,
        stats: []
    )))
}
