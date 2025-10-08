import Foundation

// MARK: - Predefined Custom Stats
struct PredefinedCustomStat {
    let name: String
    let unit: String
    let category: CustomStatCategory
    let isHigherBetter: Bool
    let placeholder: String
    let ageGroupStats: (Int) -> AgeGroupStats
    
    static let availableStats: [PredefinedCustomStat] = [
        PredefinedCustomStat(
            name: "Languages Fluent",
            unit: "languages",
            category: .languages,
            isHigherBetter: true,
            placeholder: "How many languages are you fluent in?",
            ageGroupStats: { age in
                let mean: Double
                switch age {
                case 13...18: mean = 1.6  // High school students
                case 19...25: mean = 1.9  // University age - more exposure
                case 26...35: mean = 2.3  // Working age - travel/business
                case 36...50: mean = 2.1  // Mid-career
                default: mean = 1.8      // Older adults
                }
                return AgeGroupStats(mean: mean, standardDeviation: 1.2, min: 1, max: 8)
            }
        ),
        PredefinedCustomStat(
            name: "Chess.com ELO",
            unit: "rating",
            category: .gaming,
            isHigherBetter: true,
            placeholder: "Your Chess.com rating",
            ageGroupStats: { age in
                let mean: Double
                switch age {
                case 13...18: mean = 1000  // Learning phase
                case 19...25: mean = 1150  // Peak learning age
                case 26...35: mean = 1100  // Experienced but less time
                case 36...50: mean = 1050  // Strategic thinking peak
                default: mean = 950       // More casual play
                }
                return AgeGroupStats(mean: mean, standardDeviation: 300, min: 400, max: 2800)
            }
        ),
        PredefinedCustomStat(
            name: "Musical Instruments",
            unit: "instruments",
            category: .music,
            isHigherBetter: true,
            placeholder: "Instruments you can play",
            ageGroupStats: { age in
                let mean: Double
                switch age {
                case 13...18: mean = 1.5  // School music programs
                case 19...25: mean = 1.4  // Less time in university
                case 26...35: mean = 1.2  // Career focus
                case 36...50: mean = 1.6  // More time and money
                default: mean = 1.8      // Retirement hobby
                }
                return AgeGroupStats(mean: mean, standardDeviation: 1.0, min: 0, max: 6)
            }
        ),
        PredefinedCustomStat(
            name: "Programming Languages",
            unit: "languages",
            category: .skills,
            isHigherBetter: true,
            placeholder: "Programming languages you know",
            ageGroupStats: { age in
                let mean: Double
                switch age {
                case 13...18: mean = 1.8  // Learning phase
                case 19...25: mean = 3.2  // University/bootcamp age
                case 26...35: mean = 4.1  // Career building
                case 36...50: mean = 3.5  // Established career
                default: mean = 2.0      // Less current with new languages
                }
                return AgeGroupStats(mean: mean, standardDeviation: 1.5, min: 0, max: 15)
            }
        ),
        PredefinedCustomStat(
            name: "WPM Typing Speed",
            unit: "WPM",
            category: .skills,
            isHigherBetter: true,
            placeholder: "Words per minute typing speed",
            ageGroupStats: { age in
                let mean: Double
                switch age {
                case 13...18: mean = 70   // Digital natives
                case 19...25: mean = 75   // Peak dexterity
                case 26...35: mean = 68   // Professional use
                case 36...50: mean = 55   // Different learning era
                default: mean = 45       // Older generation
                }
                return AgeGroupStats(mean: mean, standardDeviation: 20, min: 20, max: 150)
            }
        ),
        PredefinedCustomStat(
            name: "Books Read This Year",
            unit: "books",
            category: .academics,
            isHigherBetter: true,
            placeholder: "Books you've read this year",
            ageGroupStats: { age in
                let mean: Double
                switch age {
                case 13...18: mean = 6.0  // School requirements
                case 19...25: mean = 4.0  // Less free time in university
                case 26...35: mean = 8.0  // Career development reading
                case 36...50: mean = 12.0 // More established, leisure time
                default: mean = 15.0     // Retirement reading
                }
                return AgeGroupStats(mean: mean, standardDeviation: 6.0, min: 0, max: 50)
            }
        ),
        PredefinedCustomStat(
            name: "Bench Press (kg)",
            unit: "kg",
            category: .sports,
            isHigherBetter: true,
            placeholder: "Maximum bench press weight",
            ageGroupStats: { age in
                let mean: Double
                switch age {
                case 13...18: mean = 55   // Building strength
                case 19...25: mean = 75   // Peak strength building age
                case 26...35: mean = 80   // Peak strength
                case 36...50: mean = 70   // Maintaining strength
                default: mean = 55       // Age-related decline
                }
                return AgeGroupStats(mean: mean, standardDeviation: 25, min: 20, max: 200)
            }
        ),
        PredefinedCustomStat(
            name: "Volunteer Hours/Month",
            unit: "hours",
            category: .other,
            isHigherBetter: true,
            placeholder: "Hours volunteered per month",
            ageGroupStats: { age in
                let mean: Double
                switch age {
                case 13...18: mean = 6.0  // School service requirements
                case 19...25: mean = 3.0  // Less time during university
                case 26...35: mean = 2.0  // Career building phase
                case 36...50: mean = 5.0  // More established, giving back
                default: mean = 8.0      // Retirement volunteering
                }
                return AgeGroupStats(mean: mean, standardDeviation: 4.0, min: 0, max: 25)
            }
        )
    ]
}