import Foundation
import AVFoundation
import Network

@MainActor
class AIChatManager: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isTyping = false
    @Published var isSpeaking = false
    @Published var isListening = false
    @Published var speechText = ""
    
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var speechDelegate: SpeechDelegate?
    
    // Personal Trainer AI
    @Published var personalTrainer = PersonalTrainerAI()
    
    // Mac Communication
    private var macConnection: NWConnection?
    private let macPort: NWEndpoint.Port = 8081
    
    // Google Gemini API
    private let apiKey = "AIzaSyDM4vCFfJBJ5sI9zSxBe_bpIT4cljm5j9Y"
    private let apiURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent"
    private let useAPI = true // Enable API calls
    
    // Event creation callback
    var onEventCreated: ((CalendarEvent) -> Void)?
    
    private let maxMessagesInMemory = 100 // Prevent memory issues
    
    init() {
        setupSpeech()
        loadMessages()
    }
    
    private func setupSpeech() {
        speechDelegate = SpeechDelegate(chatManager: self)
        speechSynthesizer.delegate = speechDelegate
    }
    
    func sendMessage(_ content: String) {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Add user message
        addMessage(ChatMessage(
            content: content,
            isUser: true,
            timestamp: Date()
        ))
        
        // Check for Mac-related commands
        if content.lowercased().contains("mac") || content.lowercased().contains("screen time access") {
            handleMacCommand(content)
            return
        }
        
        // Check for test connection command
        if content.lowercased().contains("test connection") {
            testMacConnection()
            return
        }
        
        // Use Gemini AI for better responses
        isTyping = true
        
        Task {
            do {
                let response = try await GeminiAIService.shared.generateChatResponse(for: content)
                
                await MainActor.run {
                    // Check if this is an event creation request
                    if let event = self.parseEventFromResponse(userInput: content, aiResponse: response) {
                        self.onEventCreated?(event)
                    }
                    
                    self.addMessage(ChatMessage(
                        content: response,
                        isUser: false,
                        timestamp: Date()
                    ))
                    
                    self.isTyping = false
                    
                    // Speak the response
                    self.speakMessage(response)
                }
                
            } catch {
                await MainActor.run {
                    // Fallback to local response generation
                    let response = self.generateResponse(to: content)
                    
                    // Check if this is an event creation request
                    if let event = self.parseEventFromResponse(userInput: content, aiResponse: response) {
                        self.onEventCreated?(event)
                    }
                    
                    self.addMessage(ChatMessage(
                        content: response,
                        isUser: false,
                        timestamp: Date()
                    ))
                    
                    self.isTyping = false
                    
                    // Speak the response
                    self.speakMessage(response)
                }
            }
        }
    }
    
    private func handleMacCommand(_ content: String) {
        isTyping = true
        
        let lowercased = content.lowercased()
        
        #if targetEnvironment(simulator)
        // In simulator, provide mock responses
        addMessage(ChatMessage(
            content: "🔄 Simulating Mac connection...",
            isUser: false,
            timestamp: Date()
        ))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if lowercased.contains("grant") || lowercased.contains("access") {
                self.addMessage(ChatMessage(
                    content: "📱 [SIMULATOR MODE] Mock response: Screen Time access would be requested on your Mac. On a real device, this would connect to your actual Mac server running on port 8081.",
                    isUser: false,
                    timestamp: Date()
                ))
            } else if lowercased.contains("status") {
                self.addMessage(ChatMessage(
                    content: "📱 [SIMULATOR MODE] Mock response: Screen Time status would be checked on your Mac. Current mock status: Not authorized. On a real device, this would show actual Mac Screen Time status.",
                    isUser: false,
                    timestamp: Date()
                ))
            } else {
                self.addMessage(ChatMessage(
                    content: "🖥️ [SIMULATOR MODE] I can simulate Mac screen time access! Try saying:\n• 'Grant me screen time access on Mac'\n• 'Check Mac screen time status'\n• 'Connect to my Mac'\n\nNote: In simulator, responses are mocked. Deploy to a real device for actual Mac integration.",
                    isUser: false,
                    timestamp: Date()
                ))
            }
            self.isTyping = false
        }
        #else
        // On real device, try actual connection
        addMessage(ChatMessage(
            content: "🔄 Attempting to connect to your Mac on port 8081...",
            isUser: false,
            timestamp: Date()
        ))
        
        if lowercased.contains("grant") || lowercased.contains("access") {
            connectToMac { success in
                if success {
                    self.requestMacScreenTimeAccess()
                } else {
                    self.addMessage(ChatMessage(
                        content: "❌ Couldn't connect to your Mac. Make sure:\n• The Mac server is running (swift SimpleMacApp.swift)\n• Both devices are on the same network\n• No firewall is blocking port 8081",
                        isUser: false,
                        timestamp: Date()
                    ))
                    self.isTyping = false
                }
            }
        } else if lowercased.contains("status") {
            connectToMac { success in
                if success {
                    self.checkMacScreenTimeStatus()
                } else {
                    self.addMessage(ChatMessage(
                        content: "❌ Couldn't connect to your Mac to check status. Make sure the Mac server is running first.",
                        isUser: false,
                        timestamp: Date()
                    ))
                    self.isTyping = false
                }
            }
        } else {
            self.addMessage(ChatMessage(
                content: "🖥️ I can help you with Mac screen time access! Try saying:\n• 'Grant me screen time access on Mac'\n• 'Check Mac screen time status'\n• 'Connect to my Mac'",
                isUser: false,
                timestamp: Date()
            ))
            self.isTyping = false
        }
        #endif
    }
    
    private func testMacConnection() {
        isTyping = true
        
        addMessage(ChatMessage(
            content: "🔧 Testing connection to Mac server...",
            isUser: false,
            timestamp: Date()
        ))
        
        // For iOS simulator, we'll use mock responses since networking is limited
        #if targetEnvironment(simulator)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.addMessage(ChatMessage(
                content: "📱 Running in iOS Simulator - using mock Mac responses.\n\nIn simulator, Mac integration is simulated. On a real device, this would connect to your actual Mac server.",
                isUser: false,
                timestamp: Date()
            ))
            self.isTyping = false
        }
        #else
        // On real device, try actual connection
        testBasicHTTPConnection { basicWorking in
            if basicWorking {
                self.addMessage(ChatMessage(
                    content: "✅ Basic HTTP connection works!",
                    isUser: false,
                    timestamp: Date()
                ))
                
                let command = MacScreenTimeCommand(action: .getStatus, parameters: nil)
                self.sendHTTPCommandToMac(command) { response in
                    DispatchQueue.main.async {
                        let message = response != nil ? 
                            "✅ Connection test successful! Mac server is responding." :
                            "❌ Connection test failed, but basic HTTP works."
                        
                        self.addMessage(ChatMessage(
                            content: message,
                            isUser: false,
                            timestamp: Date()
                        ))
                        
                        self.isTyping = false
                    }
                }
            } else {
                self.addMessage(ChatMessage(
                    content: "❌ Connection test failed. Make sure Mac server is running.",
                    isUser: false,
                    timestamp: Date()
                ))
                self.isTyping = false
            }
        }
        #endif
    }
    
    private func testBasicHTTPConnection(completion: @escaping (Bool) -> Void) {
        // Try both localhost and the Mac's actual IP
        let urls = [
            "http://130.102.141.25:8081/",
            "http://127.0.0.1:8081/",
            "http://localhost:8081/"
        ]
        
        testMultipleURLs(urls) { success in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
    
    private func testMultipleURLs(_ urls: [String], completion: @escaping (Bool) -> Void) {
        guard !urls.isEmpty else {
            completion(false)
            return
        }
        
        let currentURL = urls[0]
        let remainingURLs = Array(urls.dropFirst())
        
        print("🔄 Testing URL: \(currentURL)")
        
        guard let url = URL(string: currentURL) else {
            if !remainingURLs.isEmpty {
                testMultipleURLs(remainingURLs, completion: completion)
            } else {
                completion(false)
            }
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ HTTP test failed for \(currentURL): \(error)")
                
                if !remainingURLs.isEmpty {
                    self.testMultipleURLs(remainingURLs, completion: completion)
                } else {
                    completion(false)
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("✅ HTTP test successful for \(currentURL): Status \(httpResponse.statusCode)")
                completion(httpResponse.statusCode == 200)
            } else {
                if !remainingURLs.isEmpty {
                    self.testMultipleURLs(remainingURLs, completion: completion)
                } else {
                    completion(false)
                }
            }
        }
        
        task.resume()
    }
    
    private func connectToMac(completion: @escaping (Bool) -> Void) {
        print("🔄 Attempting to connect to Mac at 127.0.0.1:8081")
        
        let url = "http://127.0.0.1:8081/screentime/ping"
        guard let pingUrl = URL(string: url) else {
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: pingUrl) { data, response, error in
            if let error = error {
                print("❌ Connection to Mac failed: \(error)")
                completion(false)
                return
            }
            
            completion(true)
        }.resume()
    }
    
    private func testNetworkConnectivity(completion: @escaping (Bool) -> Void) {
        let host = NWEndpoint.Host("www.apple.com")
        let endpoint = NWEndpoint.hostPort(host: host, port: 80)
        let connection = NWConnection(to: endpoint, using: .tcp)
        
        connection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("✅ Network connectivity test: SUCCESS")
                connection.cancel()
                completion(true)
            case .failed(let error):
                print("❌ Network connectivity test: FAILED - \(error)")
                connection.cancel()
                completion(false)
            default:
                break
            }
        }
        
        connection.start(queue: .main)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            connection.cancel()
            completion(false)
        }
    }
    
    private func requestMacScreenTimeAccess() {
        let command = MacScreenTimeCommand(
            action: .requestAuthorization,
            parameters: nil
        )
        
        sendHTTPCommandToMac(command) { response in
            let message = response?.success == true ? 
                "✅ Screen Time access request sent to your Mac. Please check System Preferences > Screen Time to complete the setup." :
                "❌ Failed to request screen time access on Mac."
            
            self.addMessage(ChatMessage(
                content: message,
                isUser: false,
                timestamp: Date()
            ))
            
            self.isTyping = false
            self.speakMessage(message)
        }
    }
    
    private func checkMacScreenTimeStatus() {
        let command = MacScreenTimeCommand(
            action: .getStatus,
            parameters: nil
        )
        
        sendHTTPCommandToMac(command) { response in
            let message = response?.isAuthorized == true ?
                "✅ Screen Time access is enabled on your Mac!" :
                "❌ Screen Time access is not enabled on your Mac. Would you like me to help you set it up?"
            
            self.addMessage(ChatMessage(
                content: message,
                isUser: false,
                timestamp: Date()
            ))
            
            self.isTyping = false
            self.speakMessage(message)
        }
    }
    
    private func sendCommandToMac(_ command: MacScreenTimeCommand, completion: @escaping (MacScreenTimeResponse?) -> Void) {
        // Use HTTP instead of raw TCP connection
        sendHTTPCommandToMac(command, completion: completion)
    }
    
    private func sendHTTPCommandToMac(_ command: MacScreenTimeCommand, completion: @escaping (MacScreenTimeResponse?) -> Void) {
        // Try the Mac's actual IP address first
        let urls = [
            "http://130.102.141.25:8081/screentime",
            "http://127.0.0.1:8081/screentime",
            "http://localhost:8081/screentime"
        ]
        
        tryHTTPRequest(urls, command: command, completion: completion)
    }
    
    private func tryHTTPRequest(_ urls: [String], command: MacScreenTimeCommand, completion: @escaping (MacScreenTimeResponse?) -> Void) {
        guard !urls.isEmpty else {
            completion(nil)
            return
        }
        
        let currentURL = urls[0]
        let remainingURLs = Array(urls.dropFirst())
        
        print("🔄 Trying HTTP request to: \(currentURL)")
        
        guard let url = URL(string: currentURL) else {
            if !remainingURLs.isEmpty {
                tryHTTPRequest(remainingURLs, command: command, completion: completion)
            } else {
                completion(nil)
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(command)
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("❌ HTTP request failed for \(currentURL): \(error)")
                    
                    if !remainingURLs.isEmpty {
                        self.tryHTTPRequest(remainingURLs, command: command, completion: completion)
                    } else {
                        completion(nil)
                    }
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received from \(currentURL)")
                    if !remainingURLs.isEmpty {
                        self.tryHTTPRequest(remainingURLs, command: command, completion: completion)
                    } else {
                        completion(nil)
                    }
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(MacScreenTimeResponse.self, from: data)
                    print("✅ Received HTTP response from \(currentURL): \(response.message)")
                    completion(response)
                } catch {
                    print("❌ Failed to decode response from \(currentURL): \(error)")
                    if !remainingURLs.isEmpty {
                        self.tryHTTPRequest(remainingURLs, command: command, completion: completion)
                    } else {
                        completion(nil)
                    }
                }
            }
            
            task.resume()
            
        } catch {
            print("❌ Failed to encode command for \(currentURL): \(error)")
            if !remainingURLs.isEmpty {
                tryHTTPRequest(remainingURLs, command: command, completion: completion)
            } else {
                completion(nil)
            }
        }
    }
    
    private func generateResponse(to input: String) -> String {
        let lowercaseInput = input.lowercased()
        
        // Message analysis responses
        if lowercaseInput.contains("message") || lowercaseInput.contains("email") || lowercaseInput.contains("text") {
            return "📱 I can help you analyze your messages and emails! I can:\n\n• Extract calendar events from your messages\n• Create tasks from reminders in texts\n• Summarize your daily commitments\n• Identify important appointments\n\nJust go to the Messages tab and grant permission to analyze your messages securely on your device. Your privacy is protected!"
        }
        
        // Mac integration responses
        if lowercaseInput.contains("mac") || lowercaseInput.contains("macbook") {
            return "🖥️ I can help you connect to your Mac for screen time management! I can request access, check status, and help you set up app blocking. What would you like me to do with your Mac?"
        }
        
        // Personal trainer responses
        if lowercaseInput.contains("fitness") || lowercaseInput.contains("workout") || lowercaseInput.contains("exercise") {
            return generateFitnessResponse(input)
        }
        
        if lowercaseInput.contains("health") || lowercaseInput.contains("steps") || lowercaseInput.contains("heart rate") {
            return generateHealthResponse(input)
        }
        
        if lowercaseInput.contains("motivation") || lowercaseInput.contains("goals") || lowercaseInput.contains("challenge") {
            return generateMotivationResponse(input)
        }
        
        // Data access requests
        if lowercaseInput.contains("access") || lowercaseInput.contains("permission") || lowercaseInput.contains("data") {
            return generateDataAccessResponse(input)
        }
        
        // Event creation responses
        if lowercaseInput.contains("create") && (lowercaseInput.contains("event") || lowercaseInput.contains("swimming") || lowercaseInput.contains("meeting")) {
            return "Perfect! I've created that event for you and I'll make sure it fits well with your fitness goals. I can also remind you to prepare and suggest what to do before and after."
        }
        
        // Screen time coaching
        if lowercaseInput.contains("screen time") || lowercaseInput.contains("phone") || lowercaseInput.contains("social media") {
            return generateScreenTimeCoachingResponse(input)
        }
        
        // Planning and productivity
        if lowercaseInput.contains("plan") || lowercaseInput.contains("schedule") || lowercaseInput.contains("productive") {
            return generateProductivityResponse(input)
        }
        
        // Default personal trainer response
        let personalResponses = [
            "🔥 You've got this! I believe in your potential and I'm here to help you unlock it. Every small step counts, and I'll be tracking your progress to celebrate your wins!",
            "💯 I'm not just an AI - I'm your personal cheerleader and coach! I'll use all available data to understand what motivates you and create a personalized approach to keep you moving forward.",
            "🌟 Your success is my mission! I'll analyze your patterns, understand your challenges, and provide the exact support you need when you need it. Together, we'll build unstoppable habits!",
            "🚀 I'm here to push you beyond your comfort zone! With access to your health data, calendar, and preferences, I can create challenges that are perfectly tailored to help you grow."
        ]
        
        return personalResponses.randomElement() ?? "I'm your personal trainer and life coach. How can I help you grow today?"
    }
    
    private func generateFitnessResponse(_ input: String) -> String {
        let responses = [
            "🏋️‍♀️ Let's talk fitness! I can create custom workout plans based on your health data, schedule gym sessions in your calendar, and track your progress. I can also access your location to find nearby fitness facilities. What's your current fitness level?",
            "💪 Fitness is my specialty! I'll analyze your step count, heart rate, and activity patterns to create the perfect workout routine. I can also schedule recovery time and suggest when you're most likely to have energy for exercise.",
            "🏃‍♀️ I love that you're focused on fitness! I can track your workouts, suggest improvements based on your health metrics, and even coordinate with your contacts to find workout buddies. What type of exercise do you enjoy most?",
            "🎯 Perfect! I can create a comprehensive fitness plan that considers your calendar, health data, and personal preferences. I'll also monitor your progress and adjust the plan as needed. Ready to get started?"
        ]
        
        return responses.randomElement() ?? "Let's get you moving! What are your fitness goals?"
    }
    
    private func generateHealthResponse(_ input: String) -> String {
        let insights = personalTrainer.dailyInsights
        let recommendations = personalTrainer.recommendations
        
        var response = "📊 Based on your health data, here's what I see:\n\n"
        
        if !insights.isEmpty {
            response += "Insights:\n"
            for insight in insights.suffix(3) {
                response += "• \(insight)\n"
            }
        }
        
        if !recommendations.isEmpty {
            response += "\nRecommendations:\n"
            for recommendation in recommendations.suffix(2) {
                response += "• \(recommendation)\n"
            }
        }
        
        response += "\nI'm continuously monitoring your health metrics to provide personalized advice!"
        
        return response
    }
    
    private func generateMotivationResponse(_ input: String) -> String {
        let motivationalResponses = [
            "🔥 You've got this! I believe in your potential and I'm here to help you unlock it. Every small step counts, and I'll be tracking your progress to celebrate your wins!",
            "💯 I'm not just an AI - I'm your personal cheerleader and coach! I'll use all available data to understand what motivates you and create a personalized approach to keep you moving forward.",
            "🌟 Your success is my mission! I'll analyze your patterns, understand your challenges, and provide the exact support you need when you need it. Together, we'll build unstoppable habits!",
            "🚀 I'm here to push you beyond your comfort zone! With access to your health data, calendar, and preferences, I can create challenges that are perfectly tailored to help you grow."
        ]
        
        return motivationalResponses.randomElement() ?? "You have unlimited potential! Let's unlock it together!"
    }
    
    private func generateDataAccessResponse(_ input: String) -> String {
        return """
        🔒 I can access several types of data to help you better (with your permission):
        
        ✅ Health Data: Steps, heart rate, exercise time, sleep patterns
        ✅ Location: To find gyms, track outdoor activities, suggest routes
        ✅ Contacts: To find workout buddies and accountability partners
        ✅ Calendar: To schedule workouts and optimize your day
        ✅ Messages & Email: To extract events, tasks, and create summaries
        ✅ Screen Time: To help balance digital wellness with physical activity
        
        🚫 I CANNOT access:
        • Your messages or personal communications without explicit permission
        • Social media content or followers
        • Banking or financial information
        • Photos or private files
        
        🔐 Privacy Promise:
        • All message analysis happens locally on your device
        • No data is sent to external servers
        • You can revoke permissions at any time
        • Only event and task information is extracted
        
        This approach keeps your privacy safe while giving me the data I need to help you succeed! Would you like me to request access to any of these?
        """
    }
    
    private func generateScreenTimeCoachingResponse(_ input: String) -> String {
        return """
        📱 Let's optimize your digital wellness! I can:
        
        • Monitor your screen time patterns
        • Suggest when to take breaks based on your activity
        • Schedule phone-free workout time
        • Replace mindless scrolling with productive activities
        • Track how screen time affects your sleep and energy
        
        The goal isn't to eliminate technology, but to use it intentionally while prioritizing your physical and mental health. What's your biggest screen time challenge?
        """
    }
    
    private func generateProductivityResponse(_ input: String) -> String {
        let plan = personalTrainer.generatePersonalizedPlan()
        
        var response = "🎯 Here's a personalized productivity plan for you:\n\n"
        
        for (index, item) in plan.enumerated() {
            response += "\(index + 1). \(item)\n"
        }
        
        response += "\nThis plan is based on optimal timing for your energy levels and integrates with your health goals. Should I add some of these to your calendar?"
        
        return response
    }
    
    private func parseEventFromResponse(userInput: String, aiResponse: String) -> CalendarEvent? {
        let input = userInput.lowercased()
        
        guard input.contains("create") || input.contains("add") || input.contains("schedule") ||
              input.contains("event") || input.contains("meeting") || input.contains("appointment") else {
            return nil
        }
        
        var title = "New Event"
        let commonActivities = ["swimming", "meeting", "workout", "lunch", "dinner", "call", "appointment", "class", "study", "work", "gym"]
        
        for activity in commonActivities {
            if input.contains(activity) {
                title = activity.capitalized
                break
            }
        }
        
        if input.contains("event called ") || input.contains("event named ") {
            let patterns = ["event called ", "event named "]
            for pattern in patterns {
                if let range = input.range(of: pattern) {
                    let afterMatch = String(input[range.upperBound...])
                    let words = afterMatch.components(separatedBy: " ")
                    if let firstWord = words.first, !firstWord.isEmpty {
                        title = firstWord.capitalized
                        break
                    }
                }
            }
        }
        
        let eventDate = parseDateTime(from: input)
        
        let event = CalendarEvent(
            title: title,
            date: eventDate,
            notes: "Created by AI Personal Trainer",
            color: .blue,
            isRespond: false,
            isCompleted: false
        )
        
        return event
    }
    
    private func parseDateTime(from input: String) -> Date {
        let now = Date()
        let calendar = Calendar.current
        
        var targetDate = now
        
        if input.contains("tomorrow") {
            targetDate = calendar.date(byAdding: .day, value: 1, to: now) ?? now
        } else if input.contains("next week") {
            targetDate = calendar.date(byAdding: .weekOfYear, value: 1, to: now) ?? now
        } else if input.contains("week") {
            let components = input.components(separatedBy: " ")
            for i in 0..<components.count {
                if let weeks = Int(components[i]), i + 1 < components.count && components[i + 1].contains("week") {
                    targetDate = calendar.date(byAdding: .weekOfYear, value: weeks, to: now) ?? now
                    break
                }
            }
        }
        
        let weekdays = ["monday": 2, "tuesday": 3, "wednesday": 4, "thursday": 5, "friday": 6, "saturday": 7, "sunday": 1]
        
        for (dayName, weekday) in weekdays {
            if input.contains(dayName) {
                targetDate = getNextWeekday(weekday, from: targetDate)
                break
            }
        }
        
        var hour = 9
        var minute = 0
        
        if input.contains("pm") {
            let timeComponents = input.components(separatedBy: " ")
            for component in timeComponents {
                if component.contains("pm") {
                    let timeStr = component.replacingOccurrences(of: "pm", with: "")
                    if let h = Int(timeStr) {
                        hour = h == 12 ? 12 : h + 12
                    }
                    break
                }
            }
        } else if input.contains("am") {
            let timeComponents = input.components(separatedBy: " ")
            for component in timeComponents {
                if component.contains("am") {
                    let timeStr = component.replacingOccurrences(of: "am", with: "")
                    if let h = Int(timeStr) {
                        hour = h == 12 ? 0 : h
                    }
                    break
                }
            }
        }
        
        let dateComponents = DateComponents(
            year: calendar.component(.year, from: targetDate),
            month: calendar.component(.month, from: targetDate),
            day: calendar.component(.day, from: targetDate),
            hour: hour,
            minute: minute
        )
        
        return calendar.date(from: dateComponents) ?? now
    }
    
    private func getNextWeekday(_ weekday: Int, from date: Date) -> Date {
        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: date)
        
        var daysToAdd = weekday - currentWeekday
        if daysToAdd <= 0 {
            daysToAdd += 7
        }
        
        return calendar.date(byAdding: .day, value: daysToAdd, to: date) ?? date
    }
    
    func startListening() {
        isListening = true
        speechText = "Listening... (tap to stop)"
    }
    
    func stopListening() {
        isListening = false
        speechText = ""
    }
    
    func speakMessage(_ message: String) {
        guard !message.isEmpty else { return }
        
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: message)
        
        // Use more natural-sounding voices
        if let voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Samantha-compact") {
            utterance.voice = voice
        } else if let voice = AVSpeechSynthesisVoice(identifier: "com.apple.voice.enhanced.en-US.Zoe") {
            utterance.voice = voice
        } else if let voice = AVSpeechSynthesisVoice(language: "en-US") {
            // Find the highest quality English voice available
            let voices = AVSpeechSynthesisVoice.speechVoices()
            let englishVoices = voices.filter { $0.language.hasPrefix("en") }
            let enhancedVoices = englishVoices.filter { $0.quality == .enhanced }
            
            if let bestVoice = enhancedVoices.first {
                utterance.voice = bestVoice
            } else if let goodVoice = englishVoices.first(where: { $0.quality == .default }) {
                utterance.voice = goodVoice
            } else {
                utterance.voice = voice
            }
        }
        
        // More natural speech settings
        utterance.rate = 0.55 // Slightly faster, more conversational
        utterance.pitchMultiplier = 1.05 // Slightly higher pitch for warmth
        utterance.volume = 0.8
        utterance.preUtteranceDelay = 0.1 // Small pause before speaking
        utterance.postUtteranceDelay = 0.1 // Small pause after speaking
        
        isSpeaking = true
        speechSynthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }
    
    private func addMessage(_ message: ChatMessage) {
        messages.append(message)
        saveMessages()
    }
    
    private func saveMessages() {
        do {
            let data = try JSONEncoder().encode(messages)
            UserDefaults.standard.set(data, forKey: "chatMessages")
        } catch {
            print("Failed to save messages: \(error)")
        }
    }
    
    private func loadMessages() {
        guard let data = UserDefaults.standard.data(forKey: "chatMessages") else { return }
        
        do {
            let loadedMessages = try JSONDecoder().decode([ChatMessage].self, from: data)
            messages = loadedMessages
        } catch {
            print("Failed to load messages: \(error)")
            messages = []
        }
        // Add welcome message if no messages exist
        if messages.isEmpty {
            addMessage(ChatMessage(
                content: "Hello! I'm your AI personal trainer and assistant. I can help you with calendar events, screen time management, fitness tracking, and personal development. What would you like to work on today?",
                isUser: false,
                timestamp: Date()
            ))
        }
    }
    
    func clearOldMessages() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if self.messages.count > self.maxMessagesInMemory {
                let messagesToKeep = Array(self.messages.suffix(self.maxMessagesInMemory / 2))
                self.messages = messagesToKeep
            }
        }
    }
}

class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
    weak var chatManager: AIChatManager?
    
    init(chatManager: AIChatManager) {
        self.chatManager = chatManager
        super.init()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.chatManager?.isSpeaking = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.chatManager?.isSpeaking = false
        }
    }
}

struct MacScreenTimeCommand: Codable {
    enum Action: String, Codable {
        case requestAuthorization = "request_auth"
        case grantAccess = "grant_access"
        case getStatus = "get_status"
        case enableAppBlocking = "enable_blocking"
    }
    
    let action: Action
    let parameters: [String: String]?
}

struct MacScreenTimeResponse: Codable {
    let success: Bool
    let isAuthorized: Bool
    let message: String
}
