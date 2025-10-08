import SwiftUI

struct NormalDistributionGraph: View {
    let metric: PerformanceMetric
    let userValue: Double
    let width: CGFloat
    let height: CGFloat
    @State private var showingEditSheet = false
    @State private var userProfile: UserProfile

    init(metric: PerformanceMetric, userValue: Double, width: CGFloat, height: CGFloat, userProfile: UserProfile) {
        self.metric = metric
        self.userValue = userValue
        self.width = width
        self.height = height
        self._userProfile = State(initialValue: userProfile)
    }

    var body: some View {
        VStack(spacing: 12) {
            // Title and user position
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(metric.name)
                            .font(.headline)
                            .fontWeight(.bold)

                        Spacer()

                        Button("Edit") {
                            showingEditSheet = true
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                    }

                    HStack {
                        if userValue > 0 {
                            Text("\(formatValue(userValue)) \(metric.unit)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(metric.color)
                        } else {
                            Text("Not Set")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            if userValue > 0 {
                                Text(metric.rank)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(metric.color)

                                Text("\(Int(metric.percentile * 100))th percentile")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("No Data")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)

                                Text("At baseline")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }

            // Distribution curve
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
                    .frame(width: width, height: height)

                // Normal distribution curve
                DistributionCurve(
                    ageGroupStats: metric.ageGroupStats,
                    width: width,
                    height: height
                )
                .foregroundColor(.blue.opacity(0.3))

                // User position marker - show at actual position or at 0
                let displayValue = userValue > 0 ? userValue : 0.0
                UserPositionMarker(
                    userValue: displayValue,
                    ageGroupStats: metric.ageGroupStats,
                    width: width,
                    height: height,
                    color: userValue > 0 ? metric.color : .gray
                )
            }

            // Statistics
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Age Group Average")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(formatValue(metric.ageGroupStats.mean)) \(metric.unit)")
                        .font(.caption)
                        .fontWeight(.semibold)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Your Position")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if userValue > 0 {
                        Text(metric.percentile > 0.5 ? "Above Average" : "Below Average")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(metric.percentile > 0.5 ? .green : .orange)
                    } else {
                        Text("At Baseline")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .sheet(isPresented: $showingEditSheet) {
            MetricEditView(metric: metric, userValue: userValue, userProfile: $userProfile, onSave: { updatedProfile in
                userProfile = updatedProfile
            })
        }
    }

    private func formatValue(_ value: Double) -> String {
        if metric.unit == "min" {
            let minutes = Int(value)
            let seconds = Int((value - Double(minutes)) * 60)
            return "\(minutes):\(String(format: "%02d", seconds))"
        } else {
            return String(format: "%.1f", value)
        }
    }
}

struct DistributionCurve: Shape {
    let ageGroupStats: AgeGroupStats
    let width: CGFloat
    let height: CGFloat

    func path(in rect: CGRect) -> Path {
        let distribution = ageGroupStats.generateNormalDistribution(points: 100)

        var path = Path()

        guard !distribution.isEmpty else { return path }

        // Find max Y value for scaling
        let maxY = distribution.map { $0.1 }.max() ?? 1.0

        // Convert first point
        let firstPoint = distribution[0]
        let firstX = CGFloat((firstPoint.0 - ageGroupStats.min) / (ageGroupStats.max - ageGroupStats.min)) * width
        let firstY = height - CGFloat(firstPoint.1 / maxY) * height

        path.move(to: CGPoint(x: firstX, y: firstY))

        // Add curve points
        for point in distribution.dropFirst() {
            let x = CGFloat((point.0 - ageGroupStats.min) / (ageGroupStats.max - ageGroupStats.min)) * width
            let y = height - CGFloat(point.1 / maxY) * height
            path.addLine(to: CGPoint(x: x, y: y))
        }

        // Close the path to the bottom
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()

        return path
    }
}

struct UserPositionMarker: View {
    let userValue: Double
    let ageGroupStats: AgeGroupStats
    let width: CGFloat
    let height: CGFloat
    let color: Color

    var body: some View {
        // Clamp the user value to be within the valid range
        let clampedValue = max(ageGroupStats.min, min(userValue, ageGroupStats.max))
        let xPosition = CGFloat((clampedValue - ageGroupStats.min) / (ageGroupStats.max - ageGroupStats.min)) * width

        VStack(spacing: 2) {
            Rectangle()
                .fill(color)
                .frame(width: 1.5, height: height * 0.8)

            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 1)
                )
        }
        .position(x: xPosition, y: height / 2)
    }
}

// MARK: - Metric Edit View
struct MetricEditView: View {
    let metric: PerformanceMetric
    let userValue: Double
    @Binding var userProfile: UserProfile
    let onSave: (UserProfile) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var inputValue: String = ""
    
    // Education specific states
    @State private var educationLevel: EducationLevel = .notSet
    @State private var universityGPA: String = ""
    @State private var highSchoolGrades: [HighSchoolGradeInput] = []
    @State private var showingAddSubject = false
    
    init(metric: PerformanceMetric, userValue: Double, userProfile: Binding<UserProfile>, onSave: @escaping (UserProfile) -> Void) {
        self.metric = metric
        self.userValue = userValue
        self._userProfile = userProfile
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Text("Edit \(metric.name)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Enter your current \(metric.name.lowercased()) value")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                ScrollView {
                    VStack(spacing: 20) {
                        if isEducationMetric() {
                            // Education-specific UI
                            educationEditSection
                        } else {
                            // Standard metric input
                            standardMetricSection
                        }
                        
                        // Current vs Population (for both types)
                        if let currentValue = getCurrentValue(), currentValue > 0 {
                            comparisonSection(currentValue: currentValue)
                        }
                    }
                }
                
                Spacer()
                
                // Save button
                Button("Save \(metric.name)") {
                    saveMetric()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .disabled(!canSave())
            }
            .padding()
            .navigationTitle("Edit Metric")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddSubject) {
            AddSubjectView { subject, percentage in
                highSchoolGrades.append(HighSchoolGradeInput(subject: subject, percentage: percentage))
            }
        }
    }
    
    private func saveMetric() {
        guard let value = getCurrentValue() else { return }
        
        // Update the user profile based on the metric type
        switch metric.name {
        case "50M Swimming Endurance":
            userProfile.swimming50MLaps = Int(value)
            
        case "5K Running Time":
            userProfile.running5KTimeSec = Int(value * 60) // Convert minutes to seconds
            
        case "Annual Income":
            userProfile.annualIncomeThousands = Int(value)
            
        case "Pull-ups":
            // Add or update pull-ups custom stat
            if let index = userProfile.customStats.firstIndex(where: { $0.name.lowercased().contains("pull") }) {
                userProfile.customStats[index].value = value
            } else {
                let pullUpsStat = CustomStat(
                    name: "Pull-ups",
                    value: value,
                    unit: "reps",
                    category: .sports,
                    isHigherBetter: true
                )
                userProfile.customStats.append(pullUpsStat)
            }
            
        case "High School Grades":
            userProfile.educationLevel = .highSchool
            userProfile.highSchoolGrades = highSchoolGrades.map { input in
                HighSchoolGrade(subject: input.subject, grade: percentageToGrade(input.percentage))
            }
            
        case "University GPA":
            userProfile.educationLevel = .university
            userProfile.universityGPA = value
            
        default:
            break
        }
        
        // Save to UserDefaults
        userProfile.save()
        
        // Call the callback to update the parent view
        onSave(userProfile)
        
        // Dismiss the sheet
        dismiss()
    }
   
    
    private func percentageToGrade(_ percentage: Double) -> String {
        switch percentage {
        case 97...: return "A+"
        case 93..<97: return "A"
        case 90..<93: return "A-"
        case 87..<90: return "B+"
        case 83..<87: return "B"
        case 80..<83: return "B-"
        case 77..<80: return "C+"
        case 73..<77: return "C"
        case 70..<73: return "C-"
        case 67..<70: return "D+"
        case 63..<67: return "D"
        default: return "F"
        }
    }
    
    private var educationEditSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Education level picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Education Level")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Picker("Education Level", selection: $educationLevel) {
                    Text("High School").tag(EducationLevel.highSchool)
                    Text("University").tag(EducationLevel.university)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            if educationLevel == .highSchool {
                // High school grades section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("High School Subjects")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button("Add Subject") {
                            showingAddSubject = true
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                    }
                    
                    if highSchoolGrades.isEmpty {
                        VStack(spacing: 8) {
                            Text("No subjects added yet")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Add your subjects and current grades to see your average")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(highSchoolGrades.indices, id: \.self) { index in
                                HStack {
                                    Text(highSchoolGrades[index].subject)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                    
                                    Text("\(Int(highSchoolGrades[index].percentage))%")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                    
                                    Button("Remove") {
                                        highSchoolGrades.remove(at: index)
                                    }
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(4)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                            
                            // Average display
                            if !highSchoolGrades.isEmpty {
                                HStack {
                                    Text("Average:")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                    
                                    Text("\(Int(calculateHighSchoolAverage()))%")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                }
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                    }
                }
            } else if educationLevel == .university {
                // University GPA section
                VStack(alignment: .leading, spacing: 12) {
                    Text("University GPA")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack {
                        TextField("e.g., 5.5", text: $universityGPA)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.title2)
                        
                        Text("/ 7.0")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("University GPA Scale:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text("7.0 = HD (High Distinction), 6.0 = D (Distinction), 5.0 = C (Credit), 4.0 = P (Pass)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    private var standardMetricSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your \(metric.name)")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                TextField(getPlaceholder(), text: $inputValue)
                    .keyboardType(getKeyboardType())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.title2)
                
                if !metric.unit.isEmpty {
                    Text(metric.unit)
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Helpful hints
            VStack(alignment: .leading, spacing: 8) {
                Text("Helpful Info:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(getHelpfulHint())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private func comparisonSection(currentValue: Double) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How You Compare:")
                .font(.headline)
                .fontWeight(.semibold)
            
            let tempMetric = PerformanceMetric(
                name: metric.name,
                userValue: currentValue,
                ageGroupStats: metric.ageGroupStats,
                unit: metric.unit,
                isHigherBetter: metric.isHigherBetter
            )
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Rank")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(tempMetric.rank)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(tempMetric.color)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Percentile")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(tempMetric.percentile * 100))th")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(tempMetric.color)
                }
            }
            
            HStack {
                Text("Population Average: \(formatValue(metric.ageGroupStats.mean))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                let diff = currentValue - metric.ageGroupStats.mean
                let isAbove = diff > 0
                Text("\(isAbove ? "+" : "")\(formatValue(diff)) vs avg")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isAbove ? .green : .red)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func calculateHighSchoolAverage() -> Double {
        guard !highSchoolGrades.isEmpty else { return 0.0 }
        let total = highSchoolGrades.reduce(0.0) { $0 + $1.percentage }
        return total / Double(highSchoolGrades.count)
    }
    
    private func getCurrentValue() -> Double? {
        if isEducationMetric() {
            if educationLevel == .highSchool {
                return calculateHighSchoolAverage()
            } else if educationLevel == .university {
                return Double(universityGPA)
            }
            return nil
        } else {
            return Double(inputValue)
        }
    }
    
    private func canSave() -> Bool {
        if isEducationMetric() {
            if educationLevel == .highSchool {
                return !highSchoolGrades.isEmpty
            } else if educationLevel == .university {
                return !universityGPA.isEmpty && Double(universityGPA) != nil
            }
            return false
        } else {
            return !inputValue.isEmpty && Double(inputValue) != nil
        }
    }
    
    private func isEducationMetric() -> Bool {
        return metric.name.contains("School") || metric.name.contains("University") || metric.name.contains("Academic")
    }
    
    private func setupInitialValues() {
        if isEducationMetric() {
            educationLevel = userProfile.educationLevel
            if educationLevel == .highSchool {
                highSchoolGrades = userProfile.highSchoolGrades.map { grade in
                    HighSchoolGradeInput(subject: grade.subject, percentage: gradeToPercentage(grade.grade))
                }
            } else if educationLevel == .university {
                universityGPA = userProfile.universityGPA > 0 ? String(format: "%.1f", userProfile.universityGPA) : ""
            }
        } else {
            if userValue > 0 {
                inputValue = formatInputValue(userValue)
            }
        }
    }
    
    private func gradeToPercentage(_ grade: String) -> Double {
        switch grade {
        case "A+": return 97.0
        case "A": return 93.0
        case "A-": return 90.0
        case "B+": return 87.0
        case "B": return 83.0
        case "B-": return 80.0
        case "C+": return 77.0
        case "C": return 73.0
        case "C-": return 70.0
        case "D+": return 67.0
        case "D": return 63.0
        case "F": return 50.0
        default: return 0.0
        }
    }
    
    private func getPlaceholder() -> String {
        switch metric.name {
        case "50M Swimming Endurance":
            return "e.g., 10"
        case "5K Running Time":
            return "e.g., 25.5"
        case "Pull-ups":
            return "e.g., 15"
        case "Annual Income":
            return "e.g., 65"
        default:
            return "Enter value"
        }
    }
    
    private func getKeyboardType() -> UIKeyboardType {
        return .decimalPad
    }
    
    private func getHelpfulHint() -> String {
        switch metric.name {
        case "50M Swimming Endurance":
            return "How many 50-meter laps can you swim continuously without stopping?"
        case "5K Running Time":
            return "Your best 5K (5000m) running time in minutes. For example, 22:30 would be 22.5 minutes."
        case "Pull-ups":
            return "Maximum number of pull-ups you can do in a row with proper form."
        case "Annual Income":
            return "Your annual income in thousands. For example, $65,000 would be 65."
        default:
            return "Enter your current value for this metric."
        }
    }
    
    private func formatValue(_ value: Double) -> String {
        if metric.unit == "min" {
            let minutes = Int(value)
            let seconds = Int((value - Double(minutes)) * 60)
            return "\(minutes):\(String(format: "%02d", seconds))"
        } else {
            return String(format: "%.1f", value)
        }
    }
    
    private func formatInputValue(_ value: Double) -> String {
        if metric.unit == "min" {
            return String(format: "%.1f", value)
        } else {
            return String(format: "%.0f", value)
        }
    }
}

// MARK: - High School Grade Input Helper
struct HighSchoolGradeInput: Identifiable {
    let id = UUID()
    var subject: String
    var percentage: Double
}

// MARK: - Add Subject View
struct AddSubjectView: View {
    let onAdd: (String, Double) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var subject = ""
    @State private var percentage = 0.0

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Subject Name")
                        .font(.headline)
                        .fontWeight(.semibold)

                    TextField("e.g., Mathematics", text: $subject)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Current Grade")
                        .font(.headline)
                        .fontWeight(.semibold)

                    HStack {
                        TextField("0", value: $percentage, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Text("%")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Button("Add Subject") {
                    onAdd(subject, percentage)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .disabled(subject.isEmpty || percentage <= 0)
            }
            .padding()
            .navigationTitle("Add Subject")
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
}

#Preview {
    let mockMetric = PerformanceMetric(
        name: "5K Running Time",
        userValue: 22.5,
        ageGroupStats: AgeGroupStats(
            mean: 25.0,
            standardDeviation: 5.0,
            min: 15.0,
            max: 45.0
        ),
        unit: "min",
        isHigherBetter: false
    )
    
    NormalDistributionGraph(
        metric: mockMetric,
        userValue: 22.5,
        width: 300,
        height: 120,
        userProfile: UserProfile(
            name: "Test User",
            age: 20,
            heightCM: 175,
            weightKG: 70,
            measurements: [:],
            level: 1,
            xp: 0,
            stats: []
        )
    )
    .padding()
}
