import Foundation

// MARK: - Age Group Data Generator
class AgeGroupDataGenerator {
    static func getStatsForAge(_ age: Int, gender: Gender, includeCustomStats: [CustomStat] = []) -> [PerformanceMetric] {
        var metrics: [PerformanceMetric] = []
        let coreStats = getCoreStatsForAge(age, gender: gender)
        metrics.append(contentsOf: coreStats)
        
        for customStat in includeCustomStats {
            if let predefinedStat = PredefinedCustomStat.availableStats.first(where: { $0.name == customStat.name }) {
                let ageGroupStats = predefinedStat.ageGroupStats(age)
                let metric = PerformanceMetric(
                    name: customStat.name,
                    userValue: customStat.value,
                    ageGroupStats: ageGroupStats,
                    unit: customStat.unit,
                    isHigherBetter: customStat.isHigherBetter
                )
                metrics.append(metric)
            }
        }
        
        return metrics
    }
    
    static func getSwimmingStats(age: Int, gender: Gender) -> AgeGroupStats {
        let baseMean: Double
        let baseStdDev: Double
        
        switch age {
        case 13...15:
            baseMean = gender == .male ? 6.0 : 4.0
            baseStdDev = gender == .male ? 4.0 : 2.5
        case 16...18:
            baseMean = gender == .male ? 10.0 : 7.0
            baseStdDev = gender == .male ? 5.0 : 3.5
        case 19...22:
            baseMean = gender == .male ? 14.0 : 10.0
            baseStdDev = gender == .male ? 7.0 : 5.0
        case 23...26:
            baseMean = gender == .male ? 15.0 : 11.0
            baseStdDev = gender == .male ? 7.5 : 5.5
        case 27...30:
            baseMean = gender == .male ? 12.0 : 8.0
            baseStdDev = gender == .male ? 6.0 : 4.0
        case 31...35:
            baseMean = gender == .male ? 10.0 : 6.0
            baseStdDev = gender == .male ? 5.0 : 3.0
        case 36...40:
            baseMean = gender == .male ? 9.0 : 5.5
            baseStdDev = gender == .male ? 4.5 : 2.8
        case 41...50:
            baseMean = gender == .male ? 8.0 : 5.0
            baseStdDev = gender == .male ? 4.0 : 2.5
        case 51...60:
            baseMean = gender == .male ? 6.0 : 3.5
            baseStdDev = gender == .male ? 3.0 : 2.0
        default: // 60+
            baseMean = gender == .male ? 4.0 : 2.5
            baseStdDev = gender == .male ? 2.5 : 1.5
        }
        
        return AgeGroupStats(
            mean: baseMean,
            standardDeviation: baseStdDev,
            min: 0,
            max: baseMean + 3 * baseStdDev
        )
    }
    
    static func getRunningStats(age: Int, gender: Gender) -> AgeGroupStats {
        let baseMean: Double
        let baseStdDev: Double
        
        switch age {
        case 13...15:
            baseMean = gender == .male ? 24.0 : 29.0
            baseStdDev = gender == .male ? 5.0 : 6.0
        case 16...18:
            baseMean = gender == .male ? 22.0 : 27.0
            baseStdDev = gender == .male ? 4.0 : 5.0
        case 19...22:
            baseMean = gender == .male ? 20.0 : 25.0
            baseStdDev = gender == .male ? 3.5 : 4.5
        case 23...26:
            baseMean = gender == .male ? 21.0 : 26.0
            baseStdDev = gender == .male ? 4.0 : 5.0
        case 27...30:
            baseMean = gender == .male ? 23.0 : 28.0
            baseStdDev = gender == .male ? 5.0 : 6.0
        case 31...35:
            baseMean = gender == .male ? 25.0 : 30.0
            baseStdDev = gender == .male ? 6.0 : 7.0
        case 36...40:
            baseMean = gender == .male ? 27.0 : 32.0
            baseStdDev = gender == .male ? 6.5 : 7.5
        case 41...50:
            baseMean = gender == .male ? 28.0 : 35.0
            baseStdDev = gender == .male ? 7.0 : 8.0
        case 51...60:
            baseMean = gender == .male ? 32.0 : 38.0
            baseStdDev = gender == .male ? 8.0 : 9.0
        default: // 60+
            baseMean = gender == .male ? 38.0 : 45.0
            baseStdDev = gender == .male ? 10.0 : 12.0
        }
        
        return AgeGroupStats(
            mean: baseMean,
            standardDeviation: baseStdDev,
            min: 12.0,
            max: 70.0
        )
    }
    
    static func getIncomeStats(age: Int, gender: Gender) -> AgeGroupStats {
        let baseMean: Double
        let baseStdDev: Double
        let genderMultiplier = gender == .male ? 1.1 : 0.9
        
        switch age {
        case 13...15:
            baseMean = 5.0 * genderMultiplier  // Part-time/summer jobs
            baseStdDev = 3.0
        case 16...18:
            baseMean = 12.0 * genderMultiplier  // Part-time jobs
            baseStdDev = 8.0
        case 19...22:
            baseMean = 25.0 * genderMultiplier  // College jobs/internships
            baseStdDev = 15.0
        case 23...26:
            baseMean = 45.0 * genderMultiplier  // Entry level full-time
            baseStdDev = 20.0
        case 27...30:
            baseMean = 65.0 * genderMultiplier  // Mid-career
            baseStdDev = 30.0
        case 31...35:
            baseMean = 80.0 * genderMultiplier  // Established career
            baseStdDev = 35.0
        case 36...40:
            baseMean = 95.0 * genderMultiplier  // Senior positions
            baseStdDev = 40.0
        case 41...50:
            baseMean = 110.0 * genderMultiplier  // Peak earning years
            baseStdDev = 50.0
        case 51...60:
            baseMean = 105.0 * genderMultiplier  // Late career
            baseStdDev = 45.0
        default: // 60+
            baseMean = 85.0 * genderMultiplier  // Retirement/part-time
            baseStdDev = 40.0
        }
        
        return AgeGroupStats(
            mean: baseMean,
            standardDeviation: baseStdDev,
            min: 0,
            max: max(baseMean + 3 * baseStdDev, 200.0)
        )
    }
    
    static func getEducationStats(age: Int, educationLevel: EducationLevel, gender: Gender) -> AgeGroupStats {
        switch educationLevel {
        case .highSchool:
            // Age affects performance expectations in high school
            let baseMean: Double
            let baseStdDev: Double = 12.0
            
            switch age {
            case 13...15: // Younger high school students
                baseMean = gender == .female ? 78.0 : 74.0
            case 16...18: // Older high school students
                baseMean = gender == .female ? 82.0 : 78.0
            default: // Adult learners
                baseMean = gender == .female ? 85.0 : 80.0
            }
            
            return AgeGroupStats(
                mean: baseMean,
                standardDeviation: baseStdDev,
                min: 50.0,
                max: 100.0
            )
        case .university:
            // Age affects university performance
            let baseMean: Double
            let baseStdDev: Double = 1.2
            
            switch age {
            case 18...22: // Traditional university age
                baseMean = gender == .female ? 5.4 : 5.0
            case 23...30: // Graduate students/older undergrads
                baseMean = gender == .female ? 5.6 : 5.2
            default: // Mature students
                baseMean = gender == .female ? 5.8 : 5.4
            }
            
            return AgeGroupStats(
                mean: baseMean,
                standardDeviation: baseStdDev,
                min: 0.0,
                max: 7.0
            )
        default:
            return AgeGroupStats(
                mean: 78.0,
                standardDeviation: 12.0,
                min: 50.0,
                max: 100.0
            )
        }
    }
    
    static func getPullUpStats(age: Int, gender: Gender) -> AgeGroupStats {
        let baseMean: Double
        let baseStdDev: Double
        
        switch age {
        case 13...15:
            baseMean = gender == .male ? 8.0 : 3.0
            baseStdDev = gender == .male ? 6.0 : 2.5
        case 16...18:
            baseMean = gender == .male ? 12.0 : 6.0
            baseStdDev = gender == .male ? 8.0 : 4.0
        case 19...22:
            baseMean = gender == .male ? 15.0 : 8.0
            baseStdDev = gender == .male ? 10.0 : 5.0
        case 23...26:
            baseMean = gender == .male ? 16.0 : 9.0
            baseStdDev = gender == .male ? 10.0 : 5.0
        case 27...30:
            baseMean = gender == .male ? 14.0 : 7.0
            baseStdDev = gender == .male ? 9.0 : 4.5
        case 31...35:
            baseMean = gender == .male ? 12.0 : 6.0
            baseStdDev = gender == .male ? 8.0 : 4.0
        case 36...40:
            baseMean = gender == .male ? 10.0 : 4.0
            baseStdDev = gender == .male ? 6.0 : 3.0
        case 41...50:
            baseMean = gender == .male ? 8.0 : 3.0
            baseStdDev = gender == .male ? 5.0 : 2.0
        case 51...60:
            baseMean = gender == .male ? 6.0 : 2.0
            baseStdDev = gender == .male ? 4.0 : 1.5
        default: // 60+
            baseMean = gender == .male ? 4.0 : 1.0
            baseStdDev = gender == .male ? 3.0 : 1.0
        }
        
        return AgeGroupStats(
            mean: baseMean,
            standardDeviation: baseStdDev,
            min: 0.0,
            max: 50.0
        )
    }
    
    static func getBMIStats(age: Int, gender: Gender) -> AgeGroupStats {
        let baseMean: Double
        let baseStdDev: Double = 4.0
        
        switch age {
        case 13...18:
            baseMean = gender == .male ? 21.5 : 21.0  // Teens typically lower BMI
        case 19...30:
            baseMean = gender == .male ? 24.0 : 23.0  // Young adults
        case 31...50:
            baseMean = gender == .male ? 26.0 : 25.0  // Middle age - slight increase
        default: // 50+
            baseMean = gender == .male ? 27.0 : 26.0  // Older adults
        }
        
        return AgeGroupStats(
            mean: baseMean,
            standardDeviation: baseStdDev,
            min: 15.0,
            max: 40.0
        )
    }
    
    private static func getCoreStatsForAge(_ age: Int, gender: Gender) -> [PerformanceMetric] {
        var metrics: [PerformanceMetric] = []
        
        let swimmingStats = getSwimmingStats(age: age, gender: gender)
        metrics.append(PerformanceMetric(
            name: "Swimming Endurance",
            userValue: 0,
            ageGroupStats: swimmingStats,
            unit: "laps",
            isHigherBetter: true
        ))
        
        let runningStats = getRunningStats(age: age, gender: gender)
        metrics.append(PerformanceMetric(
            name: "5K Running Time",
            userValue: 0,
            ageGroupStats: runningStats,
            unit: "min",
            isHigherBetter: false
        ))
        
        let incomeStats = getIncomeStats(age: age, gender: gender)
        metrics.append(PerformanceMetric(
            name: "Annual Income",
            userValue: 0,
            ageGroupStats: incomeStats,
            unit: "k",
            isHigherBetter: true
        ))
        
        let gpaStats = getEducationStats(age: age, educationLevel: .highSchool, gender: gender)
        metrics.append(PerformanceMetric(
            name: "Academic Performance",
            userValue: 0,
            ageGroupStats: gpaStats,
            unit: "GPA",
            isHigherBetter: true
        ))
        
        let educationStats = getEducationStats(age: age, educationLevel: .highSchool, gender: gender)
        metrics.append(PerformanceMetric(
            name: "Education Level",
            userValue: 0,
            ageGroupStats: educationStats,
            unit: "percentage",
            isHigherBetter: true
        ))
        
        let bmiStats = getBMIStats(age: age, gender: gender)
        metrics.append(PerformanceMetric(
            name: "BMI",
            userValue: 0,
            ageGroupStats: bmiStats,
            unit: "",
            isHigherBetter: false
        ))
        
        return metrics
    }
}