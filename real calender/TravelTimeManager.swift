import Foundation
import SwiftUI

class TravelTimeManager {
    static let shared = TravelTimeManager()
    
    private init() {}
    
    /// Generates travel events for university/school classes and work events automatically
    func generateTravelEvents(for events: [CalendarEvent]) -> [CalendarEvent] {
        guard let homeLocation = UserDefaults.standard.string(forKey: "homeLocation"),
              let workLocation = UserDefaults.standard.string(forKey: "workLocation"),
              !homeLocation.isEmpty && !workLocation.isEmpty else {
            print("🚗 TravelTimeManager: No home/work locations saved - skipping travel events")
            return []
        }
        
        let travelTimeMinutes = UserDefaults.standard.integer(forKey: "travelTimeMinutes")
        let transportMethod = UserDefaults.standard.string(forKey: "transportMethod") ?? "car"
        
        print("🚗 TravelTimeManager: Generating travel events with \(travelTimeMinutes) min travel time via \(transportMethod)")
        
        var travelEvents: [CalendarEvent] = []
        
        for event in events {
            if shouldAddTravelEvent(for: event) {
                // Create travel event before the class/meeting
                let travelEvent = createTravelEvent(
                    for: event,
                    travelTimeMinutes: travelTimeMinutes,
                    homeLocation: homeLocation,
                    workLocation: workLocation,
                    transportMethod: transportMethod
                )
                
                travelEvents.append(travelEvent)
                print("🚗 Added travel event: \(travelEvent.title) at \(travelEvent.date)")
                
                // Also create return journey for events longer than 1 hour
                if isLongEvent(event) {
                    let returnEvent = createReturnEvent(
                        for: event,
                        travelTimeMinutes: travelTimeMinutes,
                        homeLocation: homeLocation,
                        workLocation: workLocation,
                        transportMethod: transportMethod
                    )
                    
                    travelEvents.append(returnEvent)
                    print("🏠 Added return travel event: \(returnEvent.title) at \(returnEvent.date)")
                }
            }
        }
        
        print("🚗 Generated \(travelEvents.count) travel events total")
        return travelEvents
    }
    
    /// Determines if an event needs a travel time added
    private func shouldAddTravelEvent(for event: CalendarEvent) -> Bool {
        let title = event.title.lowercased()
        
        // Check for university/school related keywords
        let schoolKeywords = [
            "class", "tutorial", "lecture", "seminar", "lab", "workshop",
            "course", "lesson", "study", "exam", "test", "quiz",
            "assignment", "project", "presentation", "meeting",
            "office hours", "discussion", "review", "practice"
        ]
        
        // Check for work-related keywords
        let workKeywords = [
            "meeting", "conference", "call", "interview", "training",
            "workshop", "seminar", "presentation", "review", "standup",
            "huddle", "sync", "session", "briefing", "demo",
            "kickoff", "planning", "retrospective", "sprint", "scrum",
            "onboarding", "orientation", "shift", "schedule", "duty",
            "appointment", "consultation", "client", "customer", "vendor",
            "team", "department", "board", "committee", "town hall"
        ]
        
        let containsSchoolKeyword = schoolKeywords.contains { keyword in
            title.contains(keyword)
        }
        
        let containsWorkKeyword = workKeywords.contains { keyword in
            title.contains(keyword)
        }
        
        // Also check if location is empty (assume it's at school/work)
        let hasNoSpecificLocation = event.location.isEmpty || 
                                   event.location.lowercased().contains("classroom") ||
                                   event.location.lowercased().contains("room") ||
                                   event.location.lowercased().contains("hall") ||
                                   event.location.lowercased().contains("office") ||
                                   event.location.lowercased().contains("conference") ||
                                   event.location.lowercased().contains("building")
        
        let needsTravel = (containsSchoolKeyword || containsWorkKeyword) && hasNoSpecificLocation
        
        if needsTravel {
            let eventType = containsSchoolKeyword ? "school" : "work"
            print("🎓 Event '\(event.title)' needs travel time (\(eventType) keyword match, location: '\(event.location)')")
        }
        
        return needsTravel
    }
    
    /// Extracts a clean event name from the full event title
    private func extractEventName(from title: String, eventType: EventType) -> String {
        // Remove common prefixes and clean up the title
        var cleanTitle = title
        
        let prefixesToRemove = ["📚", "🎓", "📖", "🔬", "💻", "📊", "🎨", "💼", "🏢", "📞", "👥"]
        for prefix in prefixesToRemove {
            cleanTitle = cleanTitle.replacingOccurrences(of: prefix, with: "").trimmingCharacters(in: .whitespaces)
        }
        
        // Take first part if there's a dash or comma
        if let dashRange = cleanTitle.range(of: " - ") {
            cleanTitle = String(cleanTitle[..<dashRange.lowerBound])
        }
        
        if let commaRange = cleanTitle.range(of: ", ") {
            cleanTitle = String(cleanTitle[..<commaRange.lowerBound])
        }
        
        return cleanTitle.trimmingCharacters(in: .whitespaces)
    }
    
    /// Checks if an event is long enough to warrant a return journey
    private func isLongEvent(_ event: CalendarEvent) -> Bool {
        let title = event.title.lowercased()
        
        // School events that typically need return journey
        let longSchoolEvents = ["lecture", "lab", "seminar", "workshop", "exam", "class"]
        
        // Work events that typically need return journey
        let longWorkEvents = ["meeting", "conference", "training", "workshop", "shift", "interview", "presentation"]
        
        let isLongSchoolEvent = longSchoolEvents.contains { keyword in
            title.contains(keyword)
        }
        
        let isLongWorkEvent = longWorkEvents.contains { keyword in
            title.contains(keyword)
        }
        
        return isLongSchoolEvent || isLongWorkEvent
    }
    
    /// Gets appropriate color for travel events based on transport method
    private func getTravelColor(for method: String) -> Color {
        switch method.lowercased() {
        case "walking":
            return .green
        case "cycling":
            return .orange
        case "car":
            return .blue
        case "publictransport":
            return .purple
        default:
            return .gray
        }
    }
    
    /// Generates detailed notes for travel events
    private func generateTravelNotes(
        from origin: String,
        to destination: String,
        method: String,
        duration: Int,
        destination eventTitle: String,
        eventType: EventType
    ) -> String {
        let transportEmoji = getTransportEmoji(for: method)
        let methodName = getTransportMethodName(for: method)
        let eventEmoji = eventType == .school ? "🎓" : "💼"
        let eventTypeName = eventType == .school ? "School/University" : "Work"
        
        var notes = """
        \(eventEmoji) Travel to \(eventTypeName):
        📍 From: \(origin)
        📍 To: \(destination)
        \(transportEmoji) Method: \(methodName)
        ⏱️ Duration: \(duration) minutes
        🎯 Destination: \(eventTitle)
        
        ⚠️ ACCURACY NOTICE:
        This travel time is not 100% accurate - we don't have enough money to use Google's API yet, but once we do it will be a lot more accurate. Thanks! - The Developer
        
        💡 Tips:
        """
        
        // Add method-specific tips
        switch method.lowercased() {
        case "walking":
            notes += """
            • Check weather conditions
            • Wear comfortable shoes
            • Allow extra time for traffic lights
            • Stay hydrated on hot days
            """
        case "cycling":
            notes += """
            • Check bike tire pressure
            • Wear helmet and safety gear
            • Check bike lanes and traffic
            • Bring lock for bike parking
            """
        case "car":
            notes += """
            • Check traffic conditions
            • Allow extra time for parking
            • Ensure enough fuel/charge
            • Consider rush hour delays
            """
        case "publictransport":
            notes += """
            • Check service updates/delays
            • Have backup transport ready
            • Allow time for connections
            • Keep transport card/ticket ready
            """
        default:
            notes += "• Plan your journey ahead of time"
        }
        
        // Add event-type specific reminders
        if eventType == .school {
            notes += "\n\n🎒 Don't forget:\n• Books and materials\n• Student ID\n• Assignments due\n• Laptop/charger if needed"
        } else {
            notes += "\n\n💼 Don't forget:\n• Work materials\n• Laptop/charger\n• Meeting notes\n• Business cards if needed"
        }
        
        return notes
    }
    
    /// Generates notes for return journey
    private func generateReturnNotes(
        from origin: String,
        to destination: String,
        method: String,
        duration: Int,
        eventType: EventType
    ) -> String {
        let transportEmoji = getTransportEmoji(for: method)
        let methodName = getTransportMethodName(for: method)
        let eventTypeName = eventType == .school ? "School/University" : "Work"
        
        var notes = """
        🏠 Return Journey from \(eventTypeName):
        📍 From: \(origin)
        📍 To: \(destination)
        \(transportEmoji) Method: \(methodName)
        ⏱️ Duration: \(duration) minutes
        
        ⚠️ ACCURACY NOTICE:
        This travel time is not 100% accurate - we don't have enough money to use Google's API yet, but once we do it will be a lot more accurate. Thanks! - The Developer
        
        💡 Don't forget:
        • Collect any items you brought
        • Plan for potential delays
        """
        
        if eventType == .school {
            notes += "\n• Check for any materials to take home\n• Review notes from class\n• Plan homework/study time"
        } else {
            notes += "\n• Check for any work materials to take home\n• Review meeting outcomes\n• Plan follow-up tasks"
        }
        
        return notes
    }
    
    private func getTransportEmoji(for method: String) -> String {
        switch method.lowercased() {
        case "walking": return "🚶‍♂️"
        case "cycling": return "🚴‍♂️"
        case "car": return "🚗"
        case "publictransport": return "🚌"
        default: return "🚶‍♂️"
        }
    }
    
    private func getTransportMethodName(for method: String) -> String {
        switch method.lowercased() {
        case "walking": return "Walking"
        case "cycling": return "Cycling"
        case "car": return "Driving"
        case "publictransport": return "Public Transport"
        default: return "Walking"
        }
    }
    
    /// Creates travel event with appropriate title based on event type
    private func createTravelEvent(for event: CalendarEvent, travelTimeMinutes: Int, homeLocation: String, workLocation: String, transportMethod: String) -> CalendarEvent {
        let travelStartTime = Calendar.current.date(
            byAdding: .minute, 
            value: -travelTimeMinutes, 
            to: event.date
        ) ?? event.date
        
        let eventType = getEventType(for: event)
        let destination = extractEventName(from: event.title, eventType: eventType)
        
        let title: String
        switch eventType {
        case .school:
            title = "🎓 Getting to \(destination)"
        case .work:
            title = "💼 Heading to \(destination)"
        }
        
        let travelEvent = CalendarEvent(
            title: title,
            date: travelStartTime,
            notes: generateTravelNotes(
                from: homeLocation,
                to: workLocation,
                method: transportMethod,
                duration: travelTimeMinutes,
                destination: event.title,
                eventType: eventType
            ),
            color: getTravelColor(for: transportMethod),
            location: "From \(homeLocation) to \(workLocation)",
            teacher: nil,
            isRespond: false,
            isCompleted: false
        )
        
        return travelEvent
    }
    
    /// Creates return journey event with appropriate title
    private func createReturnEvent(for event: CalendarEvent, travelTimeMinutes: Int, homeLocation: String, workLocation: String, transportMethod: String) -> CalendarEvent {
        let returnTime = Calendar.current.date(
            byAdding: .hour,
            value: 1,
            to: event.date
        ) ?? event.date
        
        let eventType = getEventType(for: event)
        let destination = extractEventName(from: event.title, eventType: eventType)
        
        let title: String
        switch eventType {
        case .school:
            title = "🏠 Heading Home from \(destination)"
        case .work:
            title = "🏠 Leaving \(destination)"
        }
        
        let returnEvent = CalendarEvent(
            title: title,
            date: returnTime,
            notes: generateReturnNotes(
                from: workLocation,
                to: homeLocation,
                method: transportMethod,
                duration: travelTimeMinutes,
                eventType: eventType
            ),
            color: getTravelColor(for: transportMethod).opacity(0.7),
            location: "From \(workLocation) to \(homeLocation)",
            teacher: nil,
            isRespond: false,
            isCompleted: false
        )
        
        return returnEvent
    }
    
    /// Determines if an event is school or work related
    private func getEventType(for event: CalendarEvent) -> EventType {
        let title = event.title.lowercased()
        
        let schoolKeywords = [
            "class", "tutorial", "lecture", "seminar", "lab", "workshop",
            "course", "lesson", "study", "exam", "test", "quiz",
            "assignment", "project", "office hours", "discussion", "review", "practice"
        ]
        
        let containsSchoolKeyword = schoolKeywords.contains { keyword in
            title.contains(keyword)
        }
        
        return containsSchoolKeyword ? .school : .work
    }
    
    /// Adjusts travel time based on time of day (rush hour consideration)
    func adjustForTraffic(baseTime: Int, eventDate: Date) -> Int {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: eventDate)
        let weekday = calendar.component(.weekday, from: eventDate)
        
        // Weekend - no traffic adjustment
        if weekday == 1 || weekday == 7 {
            return baseTime
        }
        
        // Rush hour adjustments (7-9 AM, 4-6 PM)
        if (hour >= 7 && hour <= 9) || (hour >= 16 && hour <= 18) {
            let trafficMultiplier = 1.5 // 50% longer during rush hour
            let adjustedTime = Int(Double(baseTime) * trafficMultiplier)
            print("🚦 Rush hour detected - adjusting travel time from \(baseTime) to \(adjustedTime) minutes")
            return adjustedTime
        }
        
        return baseTime
    }
    
    enum EventType {
        case school, work
    }
}

// MARK: - Extensions for Calendar Integration

extension Array where Element == CalendarEvent {
    /// Adds travel events to existing calendar events
    mutating func addTravelEvents() {
        let travelEvents = TravelTimeManager.shared.generateTravelEvents(for: self)
        self.append(contentsOf: travelEvents)
        
        // Sort by date to maintain chronological order
        self.sort { $0.date < $1.date }
        
        print("📅 Added \(travelEvents.count) travel events to calendar. Total events: \(self.count)")
    }
    
    /// Gets events with travel time automatically generated
    func withTravelEvents() -> [CalendarEvent] {
        var eventsWithTravel = self
        eventsWithTravel.addTravelEvents()
        return eventsWithTravel
    }
}
