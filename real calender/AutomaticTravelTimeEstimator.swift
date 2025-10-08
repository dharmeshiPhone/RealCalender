import Foundation
import SwiftUI
import CoreLocation

class AutomaticTravelTimeEstimator {
    static let shared = AutomaticTravelTimeEstimator()
    
    private init() {}
    
    /// Automatically estimates travel time based on multiple factors
    func estimateTravelTime(
        from origin: String,
        to destination: String,
        transportMethod: TransportMethod,
        eventDate: Date,
        userProfile: UserProfile? = nil
    ) -> Int {
        
        print("🤖 AUTO ESTIMATION: Calculating travel time")
        print("   From: \(origin)")
        print("   To: \(destination)")
        print("   Method: \(transportMethod.rawValue)")
        print("   Date: \(eventDate)")
        
        // Base time calculation based on transport method and distance estimation
        let baseTime = calculateBaseTime(
            from: origin,
            to: destination,
            method: transportMethod,
            userProfile: userProfile
        )
        
        // Time of day adjustments (rush hour, etc.)
        let timeAdjustedTime = adjustForTimeOfDay(baseTime: baseTime, eventDate: eventDate, method: transportMethod)
        
        // Day of week adjustments (weekend vs weekday)
        let dayAdjustedTime = adjustForDayOfWeek(baseTime: timeAdjustedTime, eventDate: eventDate, method: transportMethod)
        
        // Weather and seasonal adjustments
        let weatherAdjustedTime = adjustForWeatherAndSeason(baseTime: dayAdjustedTime, eventDate: eventDate, method: transportMethod)
        
        // Final validation and reasonable bounds
        let finalTime = validateAndBoundTravelTime(estimatedTime: weatherAdjustedTime, method: transportMethod)
        
        print("🤖 AUTO ESTIMATION RESULT:")
        print("   Base time: \(baseTime) min")
        print("   After time adjustment: \(timeAdjustedTime) min")
        print("   After day adjustment: \(dayAdjustedTime) min")
        print("   After weather adjustment: \(weatherAdjustedTime) min")
        print("   Final time: \(finalTime) min")
        
        return finalTime
    }
    
    /// Calculates base travel time based on distance and transport method
    private func calculateBaseTime(
        from origin: String,
        to destination: String,
        method: TransportMethod,
        userProfile: UserProfile?
    ) -> Int {
        
        // Check if it's the same location first
        if isSameLocation(origin: origin, destination: destination, userProfile: userProfile) {
            print("🤖 Same location detected - using minimal prep time")
            return 8 // Just prep/movement time
        }
        
        // Estimate distance category
        let distanceCategory = estimateDistanceCategory(from: origin, to: destination, userProfile: userProfile)
        
        // Base times by transport method and distance
        let baseTimes: [TransportMethod: [DistanceCategory: Int]] = [
            .walking: [
                .sameBuilding: 5,
                .nearby: 15,
                .sameCityClose: 25,
                .sameCityFar: 45,
                .differentCity: 90
            ],
            .cycling: [
                .sameBuilding: 3,
                .nearby: 8,
                .sameCityClose: 15,
                .sameCityFar: 25,
                .differentCity: 60
            ],
            .car: [
                .sameBuilding: 5,
                .nearby: 8,
                .sameCityClose: 12,
                .sameCityFar: 20,
                .differentCity: 45
            ],
            .publicTransport: [
                .sameBuilding: 10,
                .nearby: 18,
                .sameCityClose: 25,
                .sameCityFar: 40,
                .differentCity: 75
            ]
        ]
        
        let baseTime = baseTimes[method]?[distanceCategory] ?? 20
        
        print("🤖 Base calculation: \(distanceCategory.rawValue) distance = \(baseTime) min for \(method.rawValue)")
        
        return baseTime
    }
    
    /// Adjusts travel time based on time of day (rush hour, etc.)
    private func adjustForTimeOfDay(baseTime: Int, eventDate: Date, method: TransportMethod) -> Int {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: eventDate)
        let minute = calendar.component(.minute, from: eventDate)
        let totalMinutes = hour * 60 + minute
        
        // Define rush hour periods (in minutes from midnight)
        let morningRushStart = 7 * 60      // 7:00 AM
        let morningRushEnd = 9 * 60 + 30   // 9:30 AM
        let eveningRushStart = 16 * 60 + 30 // 4:30 PM
        let eveningRushEnd = 18 * 60 + 30   // 6:30 PM
        
        var multiplier: Double = 1.0
        var adjustmentReason = "Normal time"
        
        // Morning rush hour
        if totalMinutes >= morningRushStart && totalMinutes <= morningRushEnd {
            switch method {
            case .car:
                multiplier = 1.6 // 60% longer for cars
                adjustmentReason = "Morning rush hour (car)"
            case .publicTransport:
                multiplier = 1.4 // 40% longer for public transport
                adjustmentReason = "Morning rush hour (public transport)"
            case .cycling:
                multiplier = 1.2 // 20% longer for cycling (more traffic)
                adjustmentReason = "Morning rush hour (cycling)"
            case .walking:
                multiplier = 1.0 // Walking unaffected by traffic
                adjustmentReason = "Morning rush hour (walking unaffected)"
            }
        }
        // Evening rush hour
        else if totalMinutes >= eveningRushStart && totalMinutes <= eveningRushEnd {
            switch method {
            case .car:
                multiplier = 1.7 // 70% longer for cars (evening typically worse)
                adjustmentReason = "Evening rush hour (car)"
            case .publicTransport:
                multiplier = 1.5 // 50% longer for public transport
                adjustmentReason = "Evening rush hour (public transport)"
            case .cycling:
                multiplier = 1.3 // 30% longer for cycling
                adjustmentReason = "Evening rush hour (cycling)"
            case .walking:
                multiplier = 1.0 // Walking unaffected
                adjustmentReason = "Evening rush hour (walking unaffected)"
            }
        }
        // Late night/early morning (reduced services for public transport)
        else if totalMinutes < 6 * 60 || totalMinutes > 23 * 60 {
            switch method {
            case .publicTransport:
                multiplier = 1.8 // Much longer due to reduced frequency
                adjustmentReason = "Late night/early morning (reduced public transport)"
            case .car:
                multiplier = 0.8 // Faster due to no traffic
                adjustmentReason = "Late night/early morning (no traffic)"
            default:
                multiplier = 1.0
                adjustmentReason = "Late night/early morning (normal)"
            }
        }
        // Peak hours but not rush hour (busy but manageable)
        else if (totalMinutes >= 10 * 60 && totalMinutes <= 12 * 60) || // 10 AM - 12 PM
                (totalMinutes >= 14 * 60 && totalMinutes <= 16 * 60) {   // 2 PM - 4 PM
            multiplier = 1.1 // Slightly longer
            adjustmentReason = "Peak hours"
        }
        
        let adjustedTime = Int(Double(baseTime) * multiplier)
        
        print("🤖 Time adjustment: \(adjustmentReason) - \(baseTime) → \(adjustedTime) min")
        
        return adjustedTime
    }
    
    /// Adjusts travel time based on day of week
    private func adjustForDayOfWeek(baseTime: Int, eventDate: Date, method: TransportMethod) -> Int {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: eventDate) // 1 = Sunday, 7 = Saturday
        
        var multiplier: Double = 1.0
        var adjustmentReason = "Weekday"
        
        // Weekend adjustments
        if weekday == 1 || weekday == 7 { // Sunday or Saturday
            switch method {
            case .car:
                multiplier = 0.8 // 20% faster on weekends (less traffic)
                adjustmentReason = "Weekend (less traffic)"
            case .publicTransport:
                multiplier = 1.3 // 30% longer on weekends (reduced frequency)
                adjustmentReason = "Weekend (reduced public transport)"
            case .cycling:
                multiplier = 0.9 // Slightly faster (less traffic)
                adjustmentReason = "Weekend (less traffic for cycling)"
            case .walking:
                multiplier = 1.0 // No change
                adjustmentReason = "Weekend (walking unchanged)"
            }
        }
        // Friday adjustments (people leaving early/going out)
        else if weekday == 6 { // Friday
            switch method {
            case .car:
                multiplier = 1.2 // 20% longer (people going out, leaving early)
                adjustmentReason = "Friday (increased activity)"
            case .publicTransport:
                multiplier = 1.1 // 10% longer
                adjustmentReason = "Friday (increased activity)"
            default:
                multiplier = 1.0
                adjustmentReason = "Friday (normal)"
            }
        }
        // Monday adjustments (everyone going back to work/school)
        else if weekday == 2 { // Monday
            switch method {
            case .car, .publicTransport:
                multiplier = 1.1 // 10% longer (back to work/school rush)
                adjustmentReason = "Monday (back to work/school)"
            default:
                multiplier = 1.0
                adjustmentReason = "Monday (normal)"
            }
        }
        
        let adjustedTime = Int(Double(baseTime) * multiplier)
        
        print("🤖 Day adjustment: \(adjustmentReason) - \(baseTime) → \(adjustedTime) min")
        
        return adjustedTime
    }
    
    /// Adjusts travel time based on weather and seasonal factors
    private func adjustForWeatherAndSeason(baseTime: Int, eventDate: Date, method: TransportMethod) -> Int {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: eventDate)
        
        var multiplier: Double = 1.0
        var adjustmentReason = "Normal weather"
        
        // Seasonal adjustments
        // Winter months (December, January, February) - assuming Northern Hemisphere
        if month == 12 || month == 1 || month == 2 {
            switch method {
            case .walking:
                multiplier = 1.2 // 20% longer (slower in cold/snow)
                adjustmentReason = "Winter (slower walking)"
            case .cycling:
                multiplier = 1.4 // 40% longer (dangerous/slow in winter)
                adjustmentReason = "Winter (difficult cycling)"
            case .car:
                multiplier = 1.1 // 10% longer (careful driving, warming up)
                adjustmentReason = "Winter (careful driving)"
            case .publicTransport:
                multiplier = 1.2 // 20% longer (delays due to weather)
                adjustmentReason = "Winter (weather delays)"
            }
        }
        // Summer months (June, July, August)
        else if month == 6 || month == 7 || month == 8 {
            switch method {
            case .walking:
                multiplier = 1.1 // 10% longer (slower in heat)
                adjustmentReason = "Summer (slower in heat)"
            case .cycling:
                multiplier = 1.1 // 10% longer (slower in heat)
                adjustmentReason = "Summer (slower in heat)"
            default:
                multiplier = 1.0
                adjustmentReason = "Summer (normal)"
            }
        }
        // Rainy season adjustments (Spring - March, April, May)
        else if month == 3 || month == 4 || month == 5 {
            switch method {
            case .walking:
                multiplier = 1.15 // 15% longer (slower in rain)
                adjustmentReason = "Spring (potential rain delays)"
            case .cycling:
                multiplier = 1.25 // 25% longer (dangerous in rain)
                adjustmentReason = "Spring (rain affects cycling)"
            case .car:
                multiplier = 1.05 // 5% longer (careful driving in rain)
                adjustmentReason = "Spring (rain affects driving)"
            default:
                multiplier = 1.0
                adjustmentReason = "Spring (normal)"
            }
        }
        
        let adjustedTime = Int(Double(baseTime) * multiplier)
        
        print("🤖 Weather adjustment: \(adjustmentReason) - \(baseTime) → \(adjustedTime) min")
        
        return adjustedTime
    }
    
    /// Validates and applies reasonable bounds to travel time estimates
    private func validateAndBoundTravelTime(estimatedTime: Int, method: TransportMethod) -> Int {
        // Define reasonable bounds for each transport method
        let bounds: [TransportMethod: (min: Int, max: Int)] = [
            .walking: (min: 5, max: 90),
            .cycling: (min: 3, max: 60),
            .car: (min: 5, max: 90),
            .publicTransport: (min: 10, max: 120)
        ]
        
        guard let bound = bounds[method] else {
            print("🤖 No bounds found for \(method.rawValue), using estimated time: \(estimatedTime)")
            return estimatedTime
        }
        
        let boundedTime = max(bound.min, min(bound.max, estimatedTime))
        
        if boundedTime != estimatedTime {
            print("🤖 Bounded travel time: \(estimatedTime) → \(boundedTime) min (bounds: \(bound.min)-\(bound.max))")
        }
        
        return boundedTime
    }
    
    /// Determines if two locations are essentially the same
    private func isSameLocation(origin: String, destination: String, userProfile: UserProfile?) -> Bool {
        let originLower = origin.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let destLower = destination.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Exact match
        if originLower == destLower {
            return true
        }
        
        // Empty destination often means same as primary location
        if destLower.isEmpty {
            return true
        }
        
        // Check if both refer to the same known location (university, work, home)
        if let profile = userProfile {
            let homeLocation = profile.location.lowercased()
            let workLocation = profile.workLocation.lowercased()
            let uniLocation = profile.universityLocation.lowercased()
            
            let originIsHome = originLower.contains(homeLocation) || homeLocation.contains(originLower)
            let destIsHome = destLower.contains(homeLocation) || homeLocation.contains(destLower)
            
            let originIsWork = originLower.contains(workLocation) || workLocation.contains(originLower)
            let destIsWork = destLower.contains(workLocation) || workLocation.contains(destLower)
            
            let originIsUni = originLower.contains(uniLocation) || uniLocation.contains(originLower)
            let destIsUni = destLower.contains(uniLocation) || uniLocation.contains(destLower)
            
            return (originIsHome && destIsHome) || (originIsWork && destIsWork) || (originIsUni && destIsUni)
        }
        
        // Check for building/room-level same location
        let sameLocationKeywords = [
            "room", "building", "hall", "center", "library", "gym", "cafeteria", "lab", "classroom"
        ]
        
        for keyword in sameLocationKeywords {
            if originLower.contains(keyword) && destLower.contains(keyword) {
                // Extract the building/location name before the keyword
                let originParts = originLower.components(separatedBy: keyword)
                let destParts = destLower.components(separatedBy: keyword)
                
                if let originBuilding = originParts.first?.trimmingCharacters(in: .whitespacesAndNewlines),
                   let destBuilding = destParts.first?.trimmingCharacters(in: .whitespacesAndNewlines),
                   !originBuilding.isEmpty && !destBuilding.isEmpty {
                    
                    // Check if building names are similar
                    if originBuilding == destBuilding || 
                       originBuilding.contains(destBuilding) || 
                       destBuilding.contains(originBuilding) {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    /// Estimates the distance category between two locations
    private func estimateDistanceCategory(from origin: String, to destination: String, userProfile: UserProfile?) -> DistanceCategory {
        let originLower = origin.lowercased()
        let destLower = destination.lowercased()
        
        // Same building indicators
        let sameBuildingKeywords = ["room", "floor", "suite", "wing", "section"]
        let originHasBuildingKeyword = sameBuildingKeywords.contains { originLower.contains($0) }
        let destHasBuildingKeyword = sameBuildingKeywords.contains { destLower.contains($0) }
        
        if originHasBuildingKeyword && destHasBuildingKeyword {
            // Check if they share the same building name
            for keyword in sameBuildingKeywords {
                if originLower.contains(keyword) && destLower.contains(keyword) {
                    let originBuilding = originLower.components(separatedBy: keyword)[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    let destBuilding = destLower.components(separatedBy: keyword)[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if originBuilding == destBuilding {
                        return .sameBuilding
                    }
                }
            }
        }
        
        // Nearby location indicators
        let nearbyKeywords = ["campus", "university", "college", "school grounds", "business park", "shopping center", "mall"]
        let originHasNearbyKeyword = nearbyKeywords.contains { originLower.contains($0) }
        let destHasNearbyKeyword = nearbyKeywords.contains { destLower.contains($0) }
        
        if originHasNearbyKeyword && destHasNearbyKeyword {
            return .nearby
        }
        
        // City-level analysis
        let originCity = extractCityFromLocation(originLower)
        let destCity = extractCityFromLocation(destLower)
        
        if !originCity.isEmpty && !destCity.isEmpty {
            if originCity == destCity {
                // Same city - determine if close or far
                let distanceIndicators = ["downtown", "city center", "cbd", "central", "near", "close"]
                let hasDistanceIndicator = distanceIndicators.contains { 
                    originLower.contains($0) || destLower.contains($0) 
                }
                
                return hasDistanceIndicator ? .sameCityClose : .sameCityFar
            } else {
                return .differentCity
            }
        }
        
        // Fallback analysis based on address structure
        let originComponents = originLower.components(separatedBy: ",").count
        let destComponents = destLower.components(separatedBy: ",").count
        
        // More components usually mean more specific/distant addresses
        if originComponents >= 3 && destComponents >= 3 {
            return .sameCityFar
        } else if originComponents >= 2 && destComponents >= 2 {
            return .sameCityClose
        } else {
            return .nearby
        }
    }
    
    /// Extracts city name from location string
    private func extractCityFromLocation(_ location: String) -> String {
        let components = location.components(separatedBy: ",")
        
        // Usually city is the second-to-last component in address format
        if components.count >= 2 {
            let cityComponent = components[components.count - 2].trimmingCharacters(in: .whitespacesAndNewlines)
            return cityComponent.lowercased()
        }
        
        // Known major cities - check if any are mentioned
        let majorCities = [
            "sydney", "melbourne", "brisbane", "perth", "adelaide", "canberra", "darwin", "hobart",
            "new york", "los angeles", "chicago", "houston", "philadelphia", "phoenix", "san antonio",
            "san diego", "dallas", "san jose", "austin", "jacksonville", "san francisco", "columbus",
            "london", "birmingham", "manchester", "leeds", "liverpool", "sheffield", "bristol",
            "glasgow", "leicester", "edinburgh", "nottingham", "coventry", "hull", "bradford",
            "toronto", "montreal", "vancouver", "calgary", "ottawa", "winnipeg", "quebec city"
        ]
        
        for city in majorCities {
            if location.contains(city) {
                return city
            }
        }
        
        return ""
    }
    
    fileprivate func getPrimaryLocationString(for profile: UserProfile) -> String { 
        return profile.location // or profile.homeLocation if defined
    }

}

// MARK: - Supporting Types

enum DistanceCategory: String, CaseIterable {
    case sameBuilding = "Same Building"
    case nearby = "Nearby"
    case sameCityClose = "Same City (Close)"
    case sameCityFar = "Same City (Far)"
    case differentCity = "Different City"
}

// Add this function just above the TravelTimeManager extension:
private func getPrimaryLocationString(from profile: UserProfile) -> String {
    return profile.location // or profile.homeLocation if defined
}