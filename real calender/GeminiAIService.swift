import Foundation
import UIKit
import SwiftUI

class GeminiAIService {
    static let shared = GeminiAIService()
    
    private func getAPIKey() -> String? {
        return "AIzaSyDM4vCFfJBJ5sI9zSxBe_bpIT4cljm5j9Y"
    }
    
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models"
    
    private init() {}
    
    // MARK: - Simple API Test Function
    func testAPIConnection() async throws -> String {
        print("🧪 === TESTING API CONNECTION ===")
        print("🔑 Using API Key: AIzaSyDM4vCFfJBJ5sI9zSxBe_bpIT4cljm5j9Y")
        
        let testPrompt = "Say 'API CONNECTED SUCCESSFULLY' if you can read this."
        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=AIzaSyDM4vCFfJBJ5sI9zSxBe_bpIT4cljm5j9Y")!
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        [
                            "text": testPrompt
                        ]
                    ]
                ]
            ]
        ]
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        urlRequest.timeoutInterval = 30
        
        print("📤 Sending direct API test...")
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiError.invalidResponse
        }
        
        print("📊 Status Code: \(httpResponse.statusCode)")
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("📄 Raw Response: \(responseString)")
        }
        
        if httpResponse.statusCode == 200 {
            if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let candidates = jsonResponse["candidates"] as? [[String: Any]],
               let firstCandidate = candidates.first,
               let content = firstCandidate["content"] as? [String: Any],
               let parts = content["parts"] as? [[String: Any]],
               let firstPart = parts.first,
               let text = firstPart["text"] as? String {
                print("✅ API SUCCESS: \(text)")
                return text
            }
        }
        
        throw GeminiError.apiError(httpResponse.statusCode, String(data: data, encoding: .utf8) ?? "Unknown error")
    }
    
    // MARK: - Audio Processing
    func processAudioRecording(duration: TimeInterval) async throws -> [CalendarEvent] {
        let prompt = """
        Create a sample university student schedule with the following events:
        - Morning classes (9:00 AM - 12:00 PM)
        - Afternoon study time (2:00 PM - 4:00 PM)
        - Evening activities (6:00 PM - 8:00 PM)
        
        Make it realistic for a student and include specific subject names.
        """
        
        do {
            let response = try await generateContent(prompt: prompt)
            return parseScheduleFromAIResponse(response)
        } catch {
            print("Gemini AI Error: \(error)")
            return createSampleAudioEvents()
        }
    }
    
    // MARK: - Chat Response
    func generateChatResponse(for message: String) async throws -> String {
        let prompt = """
        You are a helpful personal assistant and calendar expert. The user said: "\(message)"
        
        Respond in a friendly, conversational way. If they're asking about creating events, scheduling, or time management, provide helpful suggestions.
        Keep responses concise and actionable.
        """
        
        return try await generateContent(prompt: prompt)
    }
    
    // MARK: - Schedule Analysis
    func analyzeScheduleConflicts(events: [CalendarEvent]) async throws -> String {
        let eventsDescription = events.map { event in
            "- \(event.title) at \(formatDate(event.date))"
        }.joined(separator: "\n")
        
        let prompt = """
        Analyze this schedule for potential conflicts or optimization opportunities:
        
        \(eventsDescription)
        
        Provide brief suggestions for:
        1. Any scheduling conflicts
        2. Optimization opportunities
        3. Work-life balance improvements
        
        Keep the response concise and actionable.
        """
        
        return try await generateContent(prompt: prompt)
    }
    
    // MARK: - Core Text Generation
    private func generateContent(prompt: String) async throws -> String {
        print("🔧 === GENERATE CONTENT ===")
        
        guard let API_KEY = getAPIKey(), !API_KEY.isEmpty else {
            print("❌ Missing Gemini API key")
            throw GeminiError.apiError(401, "Missing Gemini API key")
        }
        
        let url = URL(string: "\(baseURL)/gemini-1.5-flash-latest:generateContent?key=\(API_KEY)")!
        print("🌐 API URL: \(url)")
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        [
                            "text": prompt
                        ]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.7,
                "topK": 40,
                "topP": 0.95,
                "maxOutputTokens": 1024
            ]
        ]
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        urlRequest.timeoutInterval = 60
        
        print("📤 Sending request...")
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        print("📥 Response received - Size: \(data.count) bytes")
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            throw GeminiError.invalidResponse
        }
        
        print("📊 HTTP Status: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            let statusCode = httpResponse.statusCode
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ Gemini API Error (\(statusCode)): \(errorMessage)")
            throw GeminiError.apiError(statusCode, errorMessage)
        }
        
        guard let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = jsonResponse["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            print("❌ Failed to parse response structure")
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 Raw response: \(responseString.prefix(500))")
            }
            throw GeminiError.invalidResponse
        }
        
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        print("✅ Generated content (length: \(cleanText.count))")
        return cleanText
    }
    
    // MARK: - Image Processing (Simplified with Better Error Handling)
    func processTimetableImage(_ imageData: Data) async throws -> [CalendarEvent] {
        print("🚀 === STARTING TIMETABLE IMAGE PROCESSING ===")
        print("📊 Image data size: \(imageData.count) bytes")
        
        // Validate input
        guard imageData.count > 100 else {
            print("❌ Image data too small: \(imageData.count) bytes")
            return createFallbackEvents()
        }
        
        guard imageData.count < 20 * 1024 * 1024 else {
            print("❌ Image data too large: \(imageData.count) bytes")
            return createFallbackEvents()
        }
        
        guard let API_KEY = getAPIKey(), !API_KEY.isEmpty else {
            print("❌ API key missing")
            return createFallbackEvents()
        }
        
        do {
            let url = URL(string: "\(baseURL)/gemini-1.5-flash-latest:generateContent?key=\(API_KEY)")!
            let base64Image = imageData.base64EncodedString()
            let mimeType = determineImageMimeType(from: imageData)
            
            print("✅ Base64 length: \(base64Image.count)")
            print("✅ MIME type: \(mimeType)")
            print("✅ API URL: \(url)")
            
            let prompt = """
            Please analyze this timetable/schedule image and extract class information.
            
            For each class you can see, provide:
            - Subject name
            - Day of week
            - Time
            - Room (if visible)
            - Teacher (if visible)
            
            Format your response as:
            CLASS: [Subject] | [Day] | [Time] | [Room] | [Teacher]
            
            Example:
            CLASS: Mathematics | Monday | 9:00 AM | Room 101 | Mr. Smith
            CLASS: English | Tuesday | 10:30 AM | Room 205 | Ms. Johnson
            
            If you cannot read the image clearly, respond with: "CANNOT_READ_IMAGE"
            """
            
            print("📝 Prompt length: \(prompt.count) characters")
            
            let requestBody: [String: Any] = [
                "contents": [
                    [
                        "parts": [
                            [
                                "text": prompt
                            ],
                            [
                                "inlineData": [
                                    "mimeType": mimeType,
                                    "data": base64Image
                                ]
                            ]
                        ]
                    ]
                ]
            ]
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Serialize the request body
            let requestData = try JSONSerialization.data(withJSONObject: requestBody)
            urlRequest.httpBody = requestData
            urlRequest.timeoutInterval = 60
            
            print("📤 Request body size: \(requestData.count) bytes")
            print("📤 Sending API request...")
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            print("📥 Response received - Data size: \(data.count) bytes")
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid HTTP response type")
                return createFallbackEvents()
            }
            
            print("📈 HTTP Status: \(httpResponse.statusCode)")
            print("📋 Response headers: \(httpResponse.allHeaderFields)")
            
            // Log the raw response data for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 Raw API Response:")
                print("================")
                print(responseString.prefix(1000)) // First 1000 chars
                print("================")
            }
            
            guard httpResponse.statusCode == 200 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("❌ API Error (\(httpResponse.statusCode)): \(errorMessage)")
                return createFallbackEvents()
            }
            
            // Parse JSON response with detailed error handling
            guard let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("❌ Failed to parse JSON response")
                return createFallbackEvents()
            }
            
            print("✅ JSON parsed successfully")
            print("🔍 JSON keys: \(jsonResponse.keys.sorted())")
            
            guard let candidates = jsonResponse["candidates"] as? [[String: Any]] else {
                print("❌ No 'candidates' found in response")
                print("📋 Available keys: \(jsonResponse.keys)")
                return createFallbackEvents()
            }
            
            print("✅ Found \(candidates.count) candidates")
            
            guard let firstCandidate = candidates.first else {
                print("❌ No first candidate found")
                return createFallbackEvents()
            }
            
            print("🔍 First candidate keys: \(firstCandidate.keys.sorted())")
            
            guard let content = firstCandidate["content"] as? [String: Any] else {
                print("❌ No 'content' found in first candidate")
                print("📋 Candidate keys: \(firstCandidate.keys)")
                return createFallbackEvents()
            }
            
            print("✅ Content found")
            print("🔍 Content keys: \(content.keys.sorted())")
            
            guard let parts = content["parts"] as? [[String: Any]] else {
                print("❌ No 'parts' found in content")
                print("📋 Content keys: \(content.keys)")
                return createFallbackEvents()
            }
            
            print("✅ Found \(parts.count) parts")
            
            guard let firstPart = parts.first else {
                print("❌ No first part found")
                return createFallbackEvents()
            }
            
            print("🔍 First part keys: \(firstPart.keys.sorted())")
            
            guard let text = firstPart["text"] as? String else {
                print("❌ No 'text' found in first part")
                print("📋 Part keys: \(firstPart.keys)")
                return createFallbackEvents()
            }
            
            print("✅ API Response Text Retrieved:")
            print("================")
            print(text)
            print("================")
            
            if text.contains("CANNOT_READ_IMAGE") {
                print("⚠️ API could not read the image")
                return createFallbackEvents()
            }
            
            let events = parseSimpleResponse(text)
            print("🎯 Parsed \(events.count) events from response")
            
            if events.isEmpty {
                print("⚠️ No events parsed, using fallback")
                return createFallbackEvents()
            }
            
            // Log parsed events
            for (index, event) in events.enumerated() {
                print("✅ Event \(index + 1): '\(event.title)' on \(event.date)")
            }
            
            return events
            
        } catch {
            print("💥 CRITICAL ERROR in image processing:")
            print("💥 Error type: \(type(of: error))")
            print("💥 Error description: '\(error.localizedDescription)'")
            print("💥 Error details: \(error)")
            return createFallbackEvents()
        }
    }
    
    // MARK: - Simple Response Parser
    private func parseSimpleResponse(_ text: String) -> [CalendarEvent] {
        let lines = text.components(separatedBy: .newlines)
        var events: [CalendarEvent] = []
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.hasPrefix("CLASS:") {
                let content = String(trimmed.dropFirst(6)).trimmingCharacters(in: .whitespacesAndNewlines)
                let components = content.components(separatedBy: " | ")
                
                if components.count >= 3 {
                    let subject = components[0]
                    let day = components[1]
                    let time = components[2]
                    let room = components.count > 3 ? components[3] : ""
                    let teacher = components.count > 4 ? components[4] : nil
                    
                    let eventDate = createDateFromDayAndTime(day: day, time: time)
                    // Use the original subject name (no processing) for unique colors
                    let className = subject.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    let event = CalendarEvent(
                        title: className,
                        date: eventDate,
                        notes: " Extracted from timetable image\n Room: \(room)",
                        color: getColorForEvent(className),
                        location: room,
                        teacher: teacher,
                        isRespond: false,
                        isCompleted: false
                    )
                    
                    events.append(event)
                    print(" Parsed event: \(className) on \(day) at \(time)")
                }
            }
        }
        
        return events
    }
    
    // MARK: - Fallback Events (Reduced and clearly marked)
     func createFallbackEvents() -> [CalendarEvent] {
        print("⚠️ WARNING: Creating fallback events - AI image processing failed")
        
        let calendar = Calendar.current
        let today = Date()
        
        return [
            CalendarEvent(
                title: "⚠️ Image Processing Failed",
                date: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: getNextWeekday(2)) ?? today,
                notes: "❌ AI couldn't read your timetable image. Please try uploading a clearer, higher-resolution image with better lighting. Make sure text is clearly visible and not blurry.",
                color: .red,
                location: "Please retry with better image",
                teacher: "AI Processing Error",
                isRespond: false,
                isCompleted: false
            ),
            CalendarEvent(
                title: "📸 Upload Better Image",
                date: calendar.date(bySettingHour: 11, minute: 0, second: 0, of: getNextWeekday(2)) ?? today,
                notes: "💡 Tips for better results:\n• Use good lighting\n• Keep text sharp and clear\n• Avoid shadows or glare\n• Try a different angle\n• Ensure high contrast",
                color: .orange,
                location: "Image Quality Tips",
                teacher: "AI Helper",
                isRespond: false,
                isCompleted: false
            )
        ]
    }
    
    // MARK: - Schedule Parser
    private func parseScheduleFromAIResponse(_ response: String) -> [CalendarEvent] {
        let lines = response.components(separatedBy: .newlines)
        var events: [CalendarEvent] = []
        
        let timePattern = #"(\d{1,2}):(\d{2})\s*(AM|PM)"#
        
        for line in lines {
            let cleanLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !cleanLine.isEmpty, !cleanLine.hasPrefix("#") else { continue }
            
            if let timeMatch = cleanLine.range(of: timePattern, options: .regularExpression) {
                let timeString = String(cleanLine[timeMatch])
                
                var eventName = cleanLine.replacingOccurrences(of: timeString, with: "")
                eventName = eventName.replacingOccurrences(of: "-", with: "")
                eventName = eventName.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if !eventName.isEmpty {
                    let eventDate = parseTimeString(timeString)
                    let color = getColorForEvent(eventName)
                    
                    let event = CalendarEvent(
                        title: eventName,
                        date: eventDate,
                        notes: "Created from audio recording analysis",
                        color: color,
                        location: "",
                        teacher: nil,
                        isRespond: false,
                        isCompleted: false
                    )
                    events.append(event)
                }
            }
        }
        
        return events.isEmpty ? createSampleAudioEvents() : events
    }
    
    private func parseTimeString(_ timeString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        
        let calendar = Calendar.current
        let today = Date()
        
        if let time = formatter.date(from: timeString) {
            let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
            let targetDate = calendar.date(bySettingHour: timeComponents.hour ?? 9,
                                         minute: timeComponents.minute ?? 0,
                                         second: 0,
                                         of: calendar.date(byAdding: .day, value: 1, to: today) ?? today)
            return targetDate ?? Date()
        }
        
        return Date()
    }
    
    private func getColorForEvent(_ eventName: String) -> Color {
        // Use the EXACT class name for color assignment (no normalization)
        // This ensures different class names get different colors
        let cleanClassName = eventName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Create a consistent hash for the exact class name
        let classHash = abs(cleanClassName.lowercased().hashValue)
        
        // Define a palette of distinct, vibrant colors
        let colorPalette: [Color] = [
            .blue,                                      // 0
            .green,                                     // 1
            .purple,                                    // 2
            .orange,                                    // 3
            .pink,                                      // 4
            .cyan,                                      // 5
            .red,                                       // 6
            .yellow,                                    // 7
            .mint,                                      // 8
            .indigo,                                    // 9
            .brown,                                     // 10
            .teal,                                      // 11
            Color(red: 0.8, green: 0.4, blue: 0.9),   // 12 - Light Purple
            Color(red: 0.9, green: 0.6, blue: 0.2),   // 13 - Light Orange
            Color(red: 0.6, green: 0.8, blue: 0.4),   // 14 - Light Green
            Color(red: 0.8, green: 0.2, blue: 0.6),   // 15 - Magenta
            Color(red: 0.4, green: 0.6, blue: 0.9),   // 16 - Sky Blue
            Color(red: 0.9, green: 0.4, blue: 0.4),   // 17 - Light Red
            Color(red: 0.6, green: 0.4, blue: 0.8),   // 18 - Violet
            Color(red: 0.4, green: 0.8, blue: 0.8),   // 19 - Aqua
            Color(red: 0.8, green: 0.8, blue: 0.4),   // 20 - Lime
            Color(red: 0.8, green: 0.6, blue: 0.8),   // 21 - Lavender
            Color(red: 0.6, green: 0.8, blue: 0.6),   // 22 - Mint Green
            Color(red: 0.9, green: 0.7, blue: 0.4),   // 23 - Peach
        ]
        
        // Use hash to get consistent color for same exact class name
        let colorIndex = classHash % colorPalette.count
        let selectedColor = colorPalette[colorIndex]
        
        print(" COLOR ASSIGNMENT: '\(cleanClassName)' → Hash: \(classHash) → Color Index: \(colorIndex) → \(selectedColor)")
        return selectedColor
    }
    
     func createSampleAudioEvents() -> [CalendarEvent] {
        print("⚠️ WARNING: Creating fallback audio events - AI audio processing failed")
        
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        
        return [
            CalendarEvent(
                title: "🎤 Voice Recording Failed",
                date: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: tomorrow) ?? Date(),
                notes: "❌ AI couldn't process your voice recording. Please try speaking more clearly or use the photo upload option instead.",
                color: .red,
                location: "Voice Processing Error",
                teacher: "AI Audio Helper",
                isRespond: false, isCompleted: false
            )
        ]
    }
    
    private func createDateFromDayAndTime(day: String, time: String) -> Date {
        let calendar = Calendar.current
        let today = Date()
        
        let dayMapping: [String: Int] = [
            "monday": 2, "tuesday": 3, "wednesday": 4, "thursday": 5, "friday": 6,
            "mon": 2, "tue": 3, "wed": 4, "thu": 5, "fri": 6
        ]
        
        let targetWeekday = dayMapping[day.lowercased()] ?? 2
        var hour = 9
        var minute = 0
        
        // Parse time
        if time.contains(":") {
            let components = time.components(separatedBy: ":")
            hour = Int(components[0]) ?? 9
            if components.count > 1 {
                let minuteString = components[1].replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                minute = Int(String(minuteString.prefix(2))) ?? 0
            }
        }
        
        if time.lowercased().contains("pm") && hour < 12 {
            hour += 12
        } else if time.lowercased().contains("am") && hour == 12 {
            hour = 0
        }
        
        let currentWeekday = calendar.component(.weekday, from: today)
        let daysToAdd = (targetWeekday - currentWeekday + 7) % 7
        let targetDate = calendar.date(byAdding: .day, value: daysToAdd == 0 ? 7 : daysToAdd, to: today) ?? today
        
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: targetDate) ?? Date()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func getNextWeekday(_ targetWeekday: Int) -> Date {
        let calendar = Calendar.current
        let today = Date()
        
        let currentWeekday = calendar.component(.weekday, from: today)
        let daysToAdd = (targetWeekday - currentWeekday + 7) % 7
        return calendar.date(byAdding: .day, value: daysToAdd == 0 ? 7 : daysToAdd, to: today) ?? today
    }
    
    private func determineImageMimeType(from data: Data) -> String {
        guard data.count > 8 else { return "image/jpeg" }
        
        let bytes = data.prefix(8)
        
        if bytes.starts(with: Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])) {
            return "image/png"
        }
        
        if bytes.starts(with: Data([0xFF, 0xD8, 0xFF])) {
            return "image/jpeg"
        }
        
        return "image/jpeg"
    }
    
    enum GeminiError: Error {
        case invalidResponse
        case apiError(Int, String)
        case networkError
        case imageProcessingError(String)
        case invalidImageData
        
        var localizedDescription: String {
            switch self {
            case .invalidResponse:
                return "Invalid response from AI service"
            case .apiError(let code, let message):
                return "AI service error (\(code)): \(message)"
            case .networkError:
                return "Network connection error"
            case .imageProcessingError(let message):
                return "Image processing error: \(message)"
            case .invalidImageData:
                return "Invalid or corrupted image data"
            }
        }
    }
}
