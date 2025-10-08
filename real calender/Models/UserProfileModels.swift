import Foundation
import SwiftUI

// MARK: - Enhanced User Profile Model
struct UserProfile: Identifiable, Codable {
    let id = UUID()
    var name: String
    var age: Int
    var heightCM: Double
    var weightKG: Double
    var measurements: [String: Double]
    var level: Int
    var xp: Double
    var stats: [CustomStat]
    var location: String = ""
    var morningPrepTimeMinutes: Int = 30
    var waistCM: Double = 0
    var gender: Gender = .notSet
    var educationLevel: EducationLevel = .notSet
    var highSchoolGPA: Double = 0.0
    var universityGPA: Double = 0.0
    var highSchoolSubjects: [AcademicSubject] = []
    var universitySubjects: [AcademicSubject] = []
    var annualIncomeThousands: Int = 0
    var swimming50MLaps: Int = 0
    var running5KTimeSec: Int = 0
    var customStats: [CustomStat] = []
    var currency: String = "USD"
    var totalEvents: Int = 0
    var onTimeEvents: Int = 0
    var punctualityStreak: Int = 0
    var runningHistory: [RunRecord] = []
    var lastRunDate: Date? = nil
    var runningStreak: Int = 0
    var unlockedCustomStats: Bool = false
    var highSchoolGrades: [HighSchoolGrade] = []
    
    var workLocation: String { "" }
    var universityLocation: String { "" }
    var primaryLocation: String { "" }
    
    var coins:Int = 0
    
    // Computed properties to fix compilation errors
    var hasBasicMeasurements: Bool {
        return heightCM > 0 && weightKG > 0
    }
    
    var bmi: Double {
        guard heightCM > 0 && weightKG > 0 else { return 0 }
        let heightInMeters = heightCM / 100
        return weightKG / (heightInMeters * heightInMeters)
    }
    
    var hasBasicProfileSetup: Bool {
        return !name.isEmpty && age > 0 && heightCM > 0 && weightKG > 0
    }
    
    var coreStatsComplete: Bool {
        // Check if basic measurements are set and other core stats are present
        return hasBasicMeasurements &&
        running5KTimeSec > 0 &&
        swimming50MLaps >= 0 &&
        annualIncomeThousands >= 0
    }
    
    var running5KTimeFormatted: String {
        guard running5KTimeSec > 0 else { return "N/A" }
        
        let minutes = running5KTimeSec / 60
        let seconds = running5KTimeSec % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var recentRuns: [RunRecord] {
        // Return the most recent runs, sorted by date (most recent first)
        return runningHistory.sorted { $0.date > $1.date }
    }
    
    var hasProgressGraph: Bool {
        // Need at least 3 runs to show a meaningful progress graph
        return runningHistory.count >= 3
    }
    
    var hasEducationData: Bool {
        // Check if either high school GPA is set or university GPA is set or we have high school grades
        return highSchoolGPA > 0.0 || universityGPA > 0.0 || !highSchoolGrades.isEmpty
    }
    
    var hasPullUpsData: Bool {
        // Check if we have pull-ups data in custom stats
        return customStats.contains { $0.name.lowercased().contains("pull") && $0.name.lowercased().contains("up") }
    }
    
    // MARK: - Running Methods
    mutating func addRun(_ runRecord: RunRecord) {
        runningHistory.append(runRecord)
        
        // Update best 5K time if this is better
        if runRecord.distance >= 5000 { // Only for 5K+ runs
            if running5KTimeSec == 0 || runRecord.timeSec < running5KTimeSec {
                running5KTimeSec = runRecord.timeSec
            }
        }
        
        // Update running streak
        updateRunningStreak(with: runRecord.date)
        
        lastRunDate = runRecord.date
    }
    
    func createRunRecord(timeSec: Int, distance: Double) -> RunRecord {
        // Calculate average pace (seconds per km)
        let averagePace = distance > 0 ? Double(timeSec) / (distance / 1000) : 0
        
        // Check if this is a personal best
        let isPersonalBest = distance >= 5000 && (running5KTimeSec == 0 || timeSec < running5KTimeSec)
        
        // Calculate improvement from previous run
        var improvementFromPrevious: Int?
        if let lastRun = runningHistory.last(where: { $0.distance >= 5000 }) {
            improvementFromPrevious = timeSec - lastRun.timeSec
        }
        
        return RunRecord(
            date: Date(),
            timeSec: timeSec,
            distance: distance,
            averagePace: averagePace,
            isPersonalBest: isPersonalBest,
            improvementFromPrevious: improvementFromPrevious
        )
    }
    
    private mutating func updateRunningStreak(with runDate: Date) {
        let calendar = Calendar.current
        
        guard let lastRunDate = lastRunDate else {
            // First run
            runningStreak = 1
            return
        }
        
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        
        if calendar.isDate(runDate, inSameDayAs: Date()) {
            // Running today
            if calendar.isDateInYesterday(lastRunDate) {
                // Ran yesterday too, increase streak
                runningStreak += 1
            } else if !calendar.isDate(lastRunDate, inSameDayAs: Date()) {
                // Didn't run yesterday, reset streak (but still ran today)
                runningStreak = 1
            }
            // If ran today already, streak doesn't change
        }
    }
    
    init(name: String, age: Int, heightCM: Double, weightKG: Double, measurements: [String: Double], level: Int, xp: Double, stats: [CustomStat]) {
        self.name = name
        self.age = age
        self.gender = .notSet
        self.heightCM = heightCM
        self.weightKG = weightKG
        self.waistCM = 0.0
        self.measurements = measurements
        self.level = level
        self.xp = xp
        self.stats = stats
        self.location = ""
        self.morningPrepTimeMinutes = 30
        self.educationLevel = .notSet
        self.highSchoolGPA = 0.0
        self.universityGPA = 0.0
        self.swimming50MLaps = 0
        self.running5KTimeSec = 0
        self.runningHistory = []
        self.lastRunDate = nil
        self.runningStreak = 0
        self.annualIncomeThousands = 0
        self.currency = "USD"
        self.totalEvents = 0
        self.onTimeEvents = 0
        self.punctualityStreak = 0
        self.customStats = []
        self.highSchoolGrades = []
        self.highSchoolSubjects = []
        self.universitySubjects = []
    }
    
    
    
    // MARK: - XP Helpers
    static func xpRequiredForLevel(_ level: Int) -> Double {
        // Define XP required for each level
        let xpTable: [Double] = [50, 50, 50, 100]
        if level > 0 && level <= xpTable.count {
            return xpTable.prefix(level).reduce(0, +)
        } else {
            return 0
        }
    }
    
    
    var progressToNextLevel: Double {
        let currentLevelXP = UserProfile.xpRequiredForLevel(level)
        let nextLevelXP = UserProfile.xpRequiredForLevel(level + 1)
        let progress = (xp - currentLevelXP) / (nextLevelXP - currentLevelXP)
        return max(0, min(1, progress))
    }
    
}

// MARK: - Persistence Helpers
extension UserProfile {
    private static let userProfileKey = "userProfile"
    
    /// Save to UserDefaults
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: Self.userProfileKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    /// Load from UserDefaults
    static func load() -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: Self.userProfileKey),
              let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) else {
            return nil
        }
        return decoded
    }
    
    /// Delete stored profile
    static func clear() {
        UserDefaults.standard.removeObject(forKey: Self.userProfileKey)
    }
    
    /// Shared profile for global access
    static var shared: UserProfile {
        get {
            if let saved = load() {
                return saved
            } else {
                return UserProfile(name: "Champion", age: 0, heightCM: 0, weightKG: 0, measurements: [:], level: 1, xp: 0, stats: [])
            }
        }
        set {
            newValue.save()
        }
    }
    
    static func createTempuser(){
        let user = UserProfile(
            name: "Champion",
            age: 20,
            heightCM: 170.0,// har
            weightKG: 70.0,
            measurements: [:],
            level: 1,
            xp: 0.0,
            stats: []
        )
        user.save()
    }
}

// Supporting types that UserProfile depends on
// These should be defined elsewhere in the project, but including them here for completeness

// If these aren't defined elsewhere, you'll need to create separate files for them or define them here:
/*
 enum Gender: String, CaseIterable, Codable {
 case notSet = "Not Set"
 case male = "Male"
 case female = "Female"
 case other = "Other"
 }
 
 enum EducationLevel: String, CaseIterable, Codable {
 case notSet = "Not Set"
 case highSchool = "High School"
 case university = "University"
 case postGraduate = "Post Graduate"
 }
 
 struct CustomStat: Identifiable, Codable {
 let id = UUID()
 var name: String
 var value: Double
 var unit: String
 var category: String
 var isUnlocked: Bool = false
 }
 
 struct RunRecord: Identifiable, Codable {
 let id = UUID()
 var date: Date
 var timeSec: Int
 var distance: Double // in meters
 var averagePace: Double // seconds per km
 var isPersonalBest: Bool
 var improvementFromPrevious: Int? // seconds improvement from previous run
 }
 
 struct AcademicSubject: Identifiable, Codable {
 let id = UUID()
 var name: String
 var grade: String
 }
 
 struct HighSchoolGrade: Identifiable, Codable {
 let id = UUID()
 var subject: String
 var grade: String
 var credits: Int
 }
 */
