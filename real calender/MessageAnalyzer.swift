import Foundation
import EventKit
import Contacts
import Intents
import UIKit

@MainActor
class MessageAnalyzer: NSObject, ObservableObject {
    @Published var hasContactsPermission = false
    @Published var hasCalendarPermission = false
    @Published var hasSiriPermission = false
    @Published var isAnalyzing = false
    @Published var recentEvents: [ExtractedEvent] = []
    @Published var todaysSummary: String = ""
    @Published var pendingTasks: [PendingTask] = []
    @Published var pastedText: String = ""
    @Published var shortcutSetupInstructions: [String] = []
    @Published var shortcutInstalled = false
    
    private let eventStore = EKEventStore()
    private let contactStore = CNContactStore()
    
    // Event creation callback
    var onEventCreated: ((CalendarEvent) -> Void)?
    
    override init() {
        super.init()
        checkPermissions()
        loadPendingTasks()
        setupShortcutInstructions()
        checkShortcutInstallation()
    }
    
    private func checkShortcutInstallation() {
        // Check if our URL scheme has been registered by a shortcut
        shortcutInstalled = UserDefaults.standard.bool(forKey: "shortcutInstalled")
    }
    
    private func setupShortcutInstructions() {
        shortcutSetupInstructions = [
            "📱 Quick Setup Guide:",
            "1. Tap 'Create Shortcut' below",
            "2. This opens the Shortcuts app with a pre-built shortcut",
            "3. Tap 'Add Shortcut' to save it",
            "4. Now you can share any text from Messages, Mail, or Safari to analyze it!",
            "",
            "🎯 How to Use:",
            "• In Messages: Long press a message → Share → Analyze Message",
            "• In Mail: Select text → Share → Analyze Message", 
            "• In Safari: Select text → Share → Analyze Message",
            "• Or say 'Hey Siri, Analyze Message' and speak the text"
        ]
    }
    
    func createShortcutURL() -> URL? {
        // Create a more robust shortcut URL
        let shortcutName = "Analyze Message"
        let encodedName = shortcutName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Analyze%20Message"
        
        // Create the shortcut URL that will be opened when user taps the setup button
        let shortcutURLString = "shortcuts://x-callback-url/import-shortcut?name=\(encodedName)&silent=false"
        
        return URL(string: shortcutURLString)
    }
    
    func createAdvancedShortcut() {
        // Create a more user-friendly shortcut installation process
        let shortcutInstructions = """
        1. This will open the Shortcuts app
        2. Create a new shortcut with these actions:
           - Get Text from Input
           - Open URL: realcalendar://analyze?text=[Text from previous action]
        3. Name it "Analyze Message"
        4. Set it to accept text input
        5. Add it to your Share Sheet
        """
        
        print("Shortcut setup instructions: \(shortcutInstructions)")
        
        // Open Shortcuts app
        if let url = URL(string: "shortcuts://") {
            UIApplication.shared.open(url)
        }
    }
    
    // Enhanced URL handling with better error handling
    func handleURLScheme(_ url: URL) {
        guard url.scheme == "realcalendar" else { 
            print("⚠️ Invalid URL scheme: \(url.scheme ?? "none")")
            return 
        }
        
        print("📱 Handling URL scheme: \(url.absoluteString)")
        
        if url.host == "analyze" {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if let textQuery = components?.queryItems?.first(where: { $0.name == "text" })?.value {
                let decodedText = textQuery.removingPercentEncoding ?? textQuery
                print("📝 Analyzing text from shortcut: \(decodedText)")
                
                Task {
                    await handleSharedText(decodedText)
                }
                
                // Mark shortcut as installed and working
                UserDefaults.standard.set(true, forKey: "shortcutInstalled")
                shortcutInstalled = true
                
                // Show success feedback
                showSuccessNotification()
            } else {
                print("⚠️ No text parameter found in URL")
            }
        } else {
            print("⚠️ Unknown URL host: \(url.host ?? "none")")
        }
    }
    
    private func showSuccessNotification() {
        // Show a brief success notification
        let content = UNMutableNotificationContent()
        content.title = "✅ Shortcut Working!"
        content.body = "Text analysis complete. Check the Message Analysis tab for results."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "shortcut-success-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to show success notification: \(error)")
            }
        }
    }
    
    func setupSiriIntegration() {
        #if targetEnvironment(simulator) || targetEnvironment(macCatalyst)
        self.hasSiriPermission = false // Siri not available on Simulator/Catalyst
        #else
        if let entitlements = Bundle.main.infoDictionary?["com.apple.developer.siri"] as? Bool, entitlements == true {
            INPreferences.requestSiriAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    self?.hasSiriPermission = status == .authorized
                }
            }
        } else {
            DispatchQueue.main.async {
                self.hasSiriPermission = false
            }
            print("❌ Siri capability is missing!")
        }
        #endif
    }
    
    private func checkPermissions() {
        hasContactsPermission = CNContactStore.authorizationStatus(for: .contacts) == .authorized
        hasCalendarPermission = EKEventStore.authorizationStatus(for: .event) == .authorized
        // Defensive: Avoid using INPreferences unless Siri entitlement is present
        if let entitlements = Bundle.main.infoDictionary?["com.apple.developer.siri"] as? Bool, entitlements == true {
            hasSiriPermission = INPreferences.siriAuthorizationStatus() == .authorized
        } else {
            hasSiriPermission = false
            print("⚠️ Siri capability not available; running in Personal Team mode or Siri not enabled. Siri features will be disabled, but app will not crash.")
        }
    }
    
    func handleSharedText(_ text: String) async {
        await analyzeText(text)
    }
    
    func handleSiriRequest(_ text: String) async {
        await analyzeText(text)
    }
    
    func analyzeEmailContent() async {
        isAnalyzing = true
        
        let mockEmails = [
            "Meeting scheduled for tomorrow at 3 PM in the main conference room",
            "Don't forget about the doctor's appointment on Thursday at 2 PM",
            "Your flight confirmation: Flight AA123 departing Friday at 6 AM",
            "Reminder: Project deadline is next Monday"
        ]
        
        for email in mockEmails {
            await analyzeText(email)
        }
        
        isAnalyzing = false
    }
    
    func requestAllPermissions() async {
        await requestContactsPermission()
        await requestCalendarPermission()
        setupSiriIntegration()
    }
    
    private func requestContactsPermission() async {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        
        switch status {
        case .authorized:
            hasContactsPermission = true
        case .notDetermined:
            do {
                try await contactStore.requestAccess(for: .contacts)
                hasContactsPermission = true
            } catch {
                print("❌ Contacts permission denied: \(error)")
                hasContactsPermission = false
            }
        default:
            hasContactsPermission = false
        }
    }
    
    private func requestCalendarPermission() async {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .authorized:
            hasCalendarPermission = true
        case .notDetermined:
            do {
                try await eventStore.requestAccess(to: .event)
                hasCalendarPermission = true
            } catch {
                print("❌ Calendar permission denied: \(error)")
                hasCalendarPermission = false
            }
        default:
            hasCalendarPermission = false
        }
    }
    
    func analyzeText(_ text: String) async {
        guard !text.isEmpty else { return }
        
        isAnalyzing = true
        
        let extractedEvents = await extractEventsFromText(text)
        let extractedTasks = await extractTasksFromText(text)
        
        recentEvents.append(contentsOf: extractedEvents)
        pendingTasks.append(contentsOf: extractedTasks)
        todaysSummary = await generateDailySummary(events: recentEvents, tasks: pendingTasks)
        
        isAnalyzing = false
        
        if hasCalendarPermission {
            await createCalendarEventsFromText(extractedEvents)
        }
        
        savePendingTasks()
    }
    
    func analyzeCalendarInvitations() async {
        isAnalyzing = true
        
        let calendarEvents = await readCalendarInvitations()
        
        let extractedEvents = calendarEvents.map { event in
            ExtractedEvent(
                id: UUID(),
                title: event.title,
                date: event.startDate,
                location: event.location,
                sender: event.organizer?.name ?? "Unknown",
                originalMessage: "Calendar invitation",
                confidence: 1.0,
                type: .appointment
            )
        }
        
        recentEvents.append(contentsOf: extractedEvents)
        todaysSummary = await generateDailySummary(events: recentEvents, tasks: pendingTasks)
        
        isAnalyzing = false
    }
    
    private func readCalendarInvitations() async -> [EKEvent] {
        guard hasCalendarPermission else { return [] }
        
        let calendar = Calendar.current
        let now = Date()
        let endDate = calendar.date(byAdding: .day, value: 7, to: now) ?? now
        
        let predicate = eventStore.predicateForEvents(withStart: now, end: endDate, calendars: nil)
        return eventStore.events(matching: predicate)
    }
    
    private func extractEventsFromText(_ text: String) async -> [ExtractedEvent] {
        var events: [ExtractedEvent] = []
        
        let sentences = text.components(separatedBy: .newlines)
        
        for sentence in sentences {
            if let event = await parseEventFromText(sentence) {
                events.append(event)
            }
        }
        
        return events
    }
    
    private func extractTasksFromText(_ text: String) async -> [PendingTask] {
        var tasks: [PendingTask] = []
        
        let sentences = text.components(separatedBy: .newlines)
        
        for sentence in sentences {
            if let task = await parseTaskFromText(sentence) {
                tasks.append(task)
            }
        }
        
        return tasks
    }
    
    private func parseEventFromText(_ text: String) async -> ExtractedEvent? {
        let content = text.lowercased()
        
        let eventKeywords = ["appointment", "meeting", "dinner", "coffee", "session", "lunch", "call", "interview", "flight", "conference"]
        let hasEventKeyword = eventKeywords.contains { content.contains($0) }
        
        guard hasEventKeyword else { return nil }
        
        var title = "Event"
        if content.contains("appointment") { title = "Appointment" }
        else if content.contains("meeting") { title = "Meeting" }
        else if content.contains("dinner") { title = "Dinner" }
        else if content.contains("coffee") { title = "Coffee Meeting" }
        else if content.contains("session") { title = "Session" }
        else if content.contains("interview") { title = "Interview" }
        else if content.contains("flight") { title = "Flight" }
        else if content.contains("conference") { title = "Conference" }
        
        let eventDate = extractDateFromText(text)
        
        return ExtractedEvent(
            id: UUID(),
            title: title,
            date: eventDate,
            location: extractLocationFromText(text),
            sender: "Analyzed Text",
            originalMessage: text,
            confidence: 0.85,
            type: .appointment
        )
    }
    
    private func parseTaskFromText(_ text: String) async -> PendingTask? {
        let content = text.lowercased()
        
        let taskKeywords = ["reminder", "don't forget", "please", "expires", "update", "bring", "need to", "remember", "deadline", "due"]
        let hasTaskKeyword = taskKeywords.contains { content.contains($0) }
        
        guard hasTaskKeyword else { return nil }
        
        var title = text
        var priority: TaskPriority = .medium
        
        if content.contains("urgent") || content.contains("asap") || content.contains("expires") || content.contains("deadline") {
            priority = .high
        } else if content.contains("when you can") || content.contains("no rush") {
            priority = .low
        }
        
        if title.count > 50 {
            title = String(title.prefix(50)) + "..."
        }
        
        return PendingTask(
            id: UUID(),
            title: title,
            description: text,
            priority: priority,
            sender: "Analyzed Text",
            dueDate: extractDateFromText(text),
            isCompleted: false
        )
    }
    
    private func extractDateFromText(_ content: String) -> Date {
        let content = content.lowercased()
        let calendar = Calendar.current
        let now = Date()
        
        if content.contains("tomorrow") {
            var date = calendar.date(byAdding: .day, value: 1, to: now) ?? now
            date = extractTimeFromText(content, baseDate: date)
            return date
        } else if content.contains("today") {
            var date = now
            date = extractTimeFromText(content, baseDate: date)
            return date
        } else if content.contains("next week") {
            var date = calendar.date(byAdding: .weekOfYear, value: 1, to: now) ?? now
            date = extractTimeFromText(content, baseDate: date)
            return date
        }
        
        let weekdays = ["monday": 2, "tuesday": 3, "wednesday": 4, "thursday": 5, "friday": 6, "saturday": 7, "sunday": 1]
        
        for (dayName, weekday) in weekdays {
            if content.contains(dayName) {
                let nextDate = calendar.nextDate(after: now, matching: DateComponents(weekday: weekday), matchingPolicy: .nextTime) ?? now
                let dateWithTime = extractTimeFromText(content, baseDate: nextDate)
                return dateWithTime
            }
        }
        
        return now
    }
    
    private func extractTimeFromText(_ content: String, baseDate: Date) -> Date {
        let calendar = Calendar.current
        let content = content.lowercased()
        
        let timePatterns = [
            ("1 pm", 13, 0), ("2 pm", 14, 0), ("3 pm", 15, 0), ("4 pm", 16, 0), ("5 pm", 17, 0), ("6 pm", 18, 0),
            ("7 pm", 19, 0), ("8 pm", 20, 0), ("9 pm", 21, 0), ("10 pm", 22, 0), ("11 pm", 23, 0),
            ("1 am", 1, 0), ("2 am", 2, 0), ("3 am", 3, 0), ("4 am", 4, 0), ("5 am", 5, 0), ("6 am", 6, 0),
            ("7 am", 7, 0), ("8 am", 8, 0), ("9 am", 9, 0), ("10 am", 10, 0), ("11 am", 11, 0), ("12 pm", 12, 0),
            ("1:00 pm", 13, 0), ("2:00 pm", 14, 0), ("3:00 pm", 15, 0), ("1:30 pm", 13, 30), ("2:30 pm", 14, 30)
        ]
        
        for (pattern, hour, minute) in timePatterns {
            if content.contains(pattern) {
                return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: baseDate) ?? baseDate
            }
        }
        
        return baseDate
    }
    
    private func extractLocationFromText(_ content: String) -> String? {
        let content = content.lowercased()
        
        let locationPatterns = [
            "conference room", "meeting room", "boardroom", "office", "starbucks", "coffee shop",
            "restaurant", "gym", "hospital", "clinic", "airport", "hotel", "home", "park"
        ]
        
        for pattern in locationPatterns {
            if content.contains(pattern) {
                if content.contains("conference room b") { return "Conference Room B" }
                if content.contains("main conference room") { return "Main Conference Room" }
                if content.contains("starbucks") { return "Starbucks" }
                return pattern.capitalized
            }
        }
        
        return nil
    }
    
    private func generateDailySummary(events: [ExtractedEvent], tasks: [PendingTask]) async -> String {
        let today = Date()
        let calendar = Calendar.current
        
        let todayEvents = events.filter { calendar.isDate($0.date, inSameDayAs: today) }
        let todayTasks = tasks.filter { 
            guard let dueDate = $0.dueDate else { return false }
            return calendar.isDate(dueDate, inSameDayAs: today)
        }
        
        var summary = "📅 Today's Summary:\n\n"
        
        if todayEvents.isEmpty && todayTasks.isEmpty {
            summary += "You have a light day ahead! 🌟"
        } else {
            if !todayEvents.isEmpty {
                summary += "🗓️ Events:\n"
                for event in todayEvents {
                    let timeFormatter = DateFormatter()
                    timeFormatter.timeStyle = .short
                    summary += "• \(event.title) at \(timeFormatter.string(from: event.date))\n"
                }
                summary += "\n"
            }
            
            if !todayTasks.isEmpty {
                summary += "✅ Tasks:\n"
                for task in todayTasks {
                    let priorityIcon = task.priority == .high ? "🔴" : task.priority == .medium ? "🟡" : "🟢"
                    summary += "• \(priorityIcon) \(task.title)\n"
                }
            }
        }
        
        return summary
    }
    
    private func createCalendarEventsFromText(_ events: [ExtractedEvent]) async {
        guard hasCalendarPermission else { return }
        
        for extractedEvent in events {
            let calendarEvent = CalendarEvent(
                title: extractedEvent.title,
                date: extractedEvent.date,
                notes: "Created from text analysis: \(extractedEvent.originalMessage)",
                color: .blue
            )
            
            onEventCreated?(calendarEvent)
        }
    }
    
    func completeTask(_ task: PendingTask) {
        if let index = pendingTasks.firstIndex(where: { $0.id == task.id }) {
            pendingTasks[index].isCompleted = true
            savePendingTasks()
        }
    }
    
    func deleteTask(_ task: PendingTask) {
        pendingTasks.removeAll { $0.id == task.id }
        savePendingTasks()
    }
    
    func clearAllData() {
        recentEvents.removeAll()
        pendingTasks.removeAll()
        todaysSummary = ""
        pastedText = ""
        savePendingTasks()
    }
    
    private func savePendingTasks() {
        do {
            let data = try JSONEncoder().encode(pendingTasks)
            UserDefaults.standard.set(data, forKey: "pendingTasks")
        } catch {
            print("Failed to save pending tasks: \(error)")
        }
    }
    
    private func loadPendingTasks() {
        guard let data = UserDefaults.standard.data(forKey: "pendingTasks") else { return }
        
        do {
            let tasks = try JSONDecoder().decode([PendingTask].self, from: data)
            pendingTasks = tasks
        } catch {
            print("Failed to load pending tasks: \(error)")
        }
    }
}

struct ExtractedEvent: Identifiable, Codable {
    let id: UUID
    let title: String
    let date: Date
    let location: String?
    let sender: String
    let originalMessage: String
    let confidence: Double
    let type: MessageType
}

struct PendingTask: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let priority: TaskPriority
    let sender: String
    let dueDate: Date?
    var isCompleted: Bool
}

enum TaskPriority: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

enum MessageType: Codable {
    case appointment, work, social, health, task
}