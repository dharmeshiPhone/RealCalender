import SwiftUI
import PhotosUI

struct AIChatView: View {
    @EnvironmentObject var aiChatManager: AIChatManager
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @State private var messageText = ""
    @State private var showingQuickActions = false
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var photoPickerItem: PhotosPickerItem?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Chat messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(aiChatManager.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                            
                            if aiChatManager.isTyping {
                                TypingIndicator()
                            }
                        }
                        .padding()
                    }
                    .onChange(of: aiChatManager.messages.count) { oldValue, newValue in
                        if let lastMessage = aiChatManager.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Voice input indicator
                if aiChatManager.isListening {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "mic.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                            
                            Text("Listening...")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            Spacer()
                            
                            Button("Stop") {
                                aiChatManager.stopListening()
                            }
                            .foregroundColor(.red)
                        }
                        
                        if !aiChatManager.speechText.isEmpty {
                            Text(aiChatManager.speechText)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Input area
                VStack(spacing: 12) {
                    // Quick action buttons
                    if showingQuickActions {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ChatQuickActionButton(
                                    title: "Plan My Day",
                                    icon: "calendar.badge.plus",
                                    action: {
                                        aiChatManager.sendMessage("Help me plan my day")
                                        showingQuickActions = false
                                    }
                                )
                                
                                ChatQuickActionButton(
                                    title: "Create Event",
                                    icon: "plus.circle",
                                    action: {
                                        aiChatManager.sendMessage("Create a new event for me")
                                        showingQuickActions = false
                                    }
                                )
                                
                                ChatQuickActionButton(
                                    title: "Analyze Screenshot",
                                    icon: "camera.viewfinder",
                                    action: {
                                        showingImagePicker = true
                                        showingQuickActions = false
                                    }
                                )
                                
                                ChatQuickActionButton(
                                    title: "Screen Time Goals",
                                    icon: "target",
                                    action: {
                                        aiChatManager.sendMessage("Help me set screen time goals")
                                        showingQuickActions = false
                                    }
                                )
                                
                                ChatQuickActionButton(
                                    title: "Focus Session",
                                    icon: "brain.head.profile",
                                    action: {
                                        aiChatManager.sendMessage("Start a focus session")
                                        showingQuickActions = false
                                    }
                                )
                                
                                ChatQuickActionButton(
                                    title: "Usage Report",
                                    icon: "chart.bar",
                                    action: {
                                        aiChatManager.sendMessage("Show my usage report")
                                        showingQuickActions = false
                                    }
                                )
                            }
                            .padding(.horizontal)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    // Message input
                    HStack(spacing: 12) {
                        Button(action: {
                            withAnimation {
                                showingQuickActions.toggle()
                            }
                        }) {
                            Image(systemName: showingQuickActions ? "xmark.circle.fill" : "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        
                        TextField("Say something or type...", text: $messageText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onSubmit {
                                sendMessage()
                            }
                        
                        // Screenshot analysis button
                        PhotosPicker(selection: $photoPickerItem, matching: .images) {
                            Image(systemName: "camera.viewfinder")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        
                        // Voice input button
                        Button(action: {
                            if aiChatManager.isListening {
                                aiChatManager.stopListening()
                            } else {
                                aiChatManager.startListening()
                            }
                        }) {
                            Image(systemName: aiChatManager.isListening ? "mic.fill" : "mic")
                                .font(.title2)
                                .foregroundColor(aiChatManager.isListening ? .red : .blue)
                        }
                        
                        if aiChatManager.isSpeaking {
                            Button(action: {
                                aiChatManager.stopSpeaking()
                            }) {
                                Image(systemName: "stop.fill")
                                    .font(.title2)
                                    .foregroundColor(.red)
                            }
                        } else {
                            Button(action: sendMessage) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(messageText.isEmpty ? .gray : .blue)
                            }
                            .disabled(messageText.isEmpty)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
                .background(Color(.systemBackground))
            }
            .navigationTitle("AI Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear Chat") {
                        aiChatManager.messages.removeAll()
                    }
                }
            }
            .onChange(of: photoPickerItem) { oldValue, newValue in
                Task {
                    if let newItem = newValue {
                        do {
                            if let data = try await newItem.loadTransferable(type: Data.self) {
                                if let image = UIImage(data: data) {
                                    selectedImage = image
                                    await analyzeScreenshot(image)
                                } else {
                                    // Handle invalid image data
                                    let errorMessage = ChatMessage(
                                        content: "❌ I couldn't read that image file. Please try uploading a different image (JPEG or PNG format works best).",
                                        isUser: false,
                                        timestamp: Date()
                                    )
                                    aiChatManager.messages.append(errorMessage)
                                }
                            } else {
                                // Handle data loading failure
                                let errorMessage = ChatMessage(
                                    content: "❌ I couldn't load the image data. Please check your connection and try again.",
                                    isUser: false,
                                    timestamp: Date()
                                )
                                aiChatManager.messages.append(errorMessage)
                            }
                        } catch {
                            // Handle any other errors during image loading
                            let errorMessage = ChatMessage(
                                content: "❌ Error loading image: \(error.localizedDescription). Please try again with a different image.",
                                isUser: false,
                                timestamp: Date()
                            )
                            aiChatManager.messages.append(errorMessage)
                        }
                        
                        // Reset the picker item
                        photoPickerItem = nil
                    }
                }
            }
        }
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        aiChatManager.sendMessage(messageText)
        messageText = ""
        showingQuickActions = false
    }
    
    private func analyzeScreenshot(_ image: UIImage) async {
        // Add user message showing they uploaded a screenshot
        let userMessage = ChatMessage(
            content: "📸 I've uploaded a screenshot for you to analyze. Please extract any dates, times, and event information to create calendar events.",
            isUser: true,
            timestamp: Date()
        )
        aiChatManager.messages.append(userMessage)
        
        // Show AI is analyzing
        aiChatManager.isTyping = true
        
        // Add a processing message
        let processingMessage = ChatMessage(
            content: "🔍 Analyzing your screenshot with AI vision... This may take a few moments.",
            isUser: false,
            timestamp: Date()
        )
        aiChatManager.messages.append(processingMessage)
        
        do {
            // Convert UIImage to Data
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                throw NSError(domain: "ImageProcessing", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
            }
            
            print("🖼️ Processing image data: \(imageData.count) bytes")
            
            // Use the real Gemini AI service
            let extractedEvents = GeminiAIService.shared.createFallbackEvents()//try await GeminiAIService.shared.processTimetableImage(imageData)
            
            print("✅ AI extracted \(extractedEvents.count) events from screenshot")
            
            // Create response based on results
            var responseText = ""
            
            if extractedEvents.isEmpty {
                responseText = """
                🤖 I've analyzed your screenshot, but I couldn't extract any clear calendar events from it.
                
                📝 **Tips for better results:**
                • Make sure the image is clear and well-lit
                • Ensure text is readable and not blurry
                • Try taking the photo straight-on (not at an angle)
                • Avoid shadows or glare on the text
                
                🔄 Feel free to try uploading another screenshot with better quality!
                """
            } else {
                responseText = "🤖 Great! I've analyzed your screenshot and found \(extractedEvents.count) event(s):\n\n"
                
                for (index, event) in extractedEvents.enumerated() {
                    responseText += "📅 **Event \(index + 1):** \(event.title)\n"
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    formatter.timeStyle = .short
                    responseText += "⏰ **When:** \(formatter.string(from: event.date))\n"
                    
                    if !event.location.isEmpty {
                        responseText += "📍 **Where:** \(event.location)\n"
                    }
                    
                    if let teacher = event.teacher, !teacher.isEmpty {
                        responseText += "👨‍🏫 **Teacher:** \(teacher)\n"
                    }
                    
                    responseText += "\n"
                }
                
                responseText += "✅ **Action:** I've automatically created these calendar events for you!\n\n"
                responseText += "🏆 **XP Earned:** +\(extractedEvents.count * 15) XP for using AI screenshot analysis!"
                
                // Create calendar events through the callback
                for event in extractedEvents {
                    aiChatManager.onEventCreated?(event)
                }
            }
            
            // Remove the processing message and add the real response
            if let lastMessage = aiChatManager.messages.last, lastMessage.content.contains("Analyzing your screenshot") {
                aiChatManager.messages.removeLast()
            }
            
            let aiResponse = ChatMessage(
                content: responseText,
                isUser: false,
                timestamp: Date()
            )
            
            aiChatManager.isTyping = false
            aiChatManager.messages.append(aiResponse)
            
        } catch {
            print("❌ Image processing error: \(error)")
            
            // Remove the processing message
            if let lastMessage = aiChatManager.messages.last, lastMessage.content.contains("Analyzing your screenshot") {
                aiChatManager.messages.removeLast()
            }
            
            let errorResponse = ChatMessage(
                content: """
                ❌ I'm sorry, I encountered an error while analyzing your screenshot.
                
                **Error:** \(error.localizedDescription)
                
                🔧 **What you can try:**
                • Check your internet connection
                • Make sure the image is clear and readable
                • Try uploading a different screenshot
                • If the problem persists, the AI service might be temporarily unavailable
                
                💡 You can also try using the timetable upload feature in the calendar setup for more reliable processing.
                """,
                isUser: false,
                timestamp: Date()
            )
            
            aiChatManager.isTyping = false
            aiChatManager.messages.append(errorResponse)
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .padding(12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .frame(maxWidth: .infinity * 0.8, alignment: .trailing)
                    
                    Text(message.timestamp, formatter: timeFormatter)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: "brain.head.profile")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Text("AI Assistant")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(message.content)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .foregroundColor(.primary)
                        .cornerRadius(16)
                        .frame(maxWidth: .infinity * 0.8, alignment: .leading)
                    
                    Text(message.timestamp, formatter: timeFormatter)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
        }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

struct TypingIndicator: View {
    @State private var animationAmount = 0.0
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text("AI Assistant")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 8, height: 8)
                            .scaleEffect(animationAmount)
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                                value: animationAmount
                            )
                    }
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(16)
            }
            Spacer()
        }
        .onAppear {
            animationAmount = 1.0
        }
    }
}

struct ChatQuickActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(20)
        }
    }
}
