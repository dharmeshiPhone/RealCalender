// MessageAnalysisView.swift
import SwiftUI
import UserNotifications

struct MessageAnalysisView: View {
    @EnvironmentObject var messageAnalyzer: MessageAnalyzer
    @EnvironmentObject var aiChatManager: AIChatManager
    
    var body: some View {
        NavigationView {
           ScrollView {
                VStack(spacing: 20) {
                    // Hero Section - Shortcuts Integration
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Smart Message Analysis")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Text("Analyze text from Messages, Mail, and more using iOS Shortcuts")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "square.grid.3x3.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                        }
                        
                        // Shortcuts Status
                        HStack {
                            Image(systemName: messageAnalyzer.shortcutInstalled ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                .foregroundColor(messageAnalyzer.shortcutInstalled ? .green : .orange)
                            
                            Text(messageAnalyzer.shortcutInstalled ? "Shortcuts Ready!" : "Setup Required")
                                .font(.headline)
                                .foregroundColor(messageAnalyzer.shortcutInstalled ? .green : .orange)
                        }
                        
                        // Setup Button
                        if !messageAnalyzer.shortcutInstalled {
                            VStack(alignment: .leading, spacing: 12) {
                                Button("🚀 Setup Shortcuts Integration") {
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                    impactFeedback.impactOccurred()
                                    messageAnalyzer.createAdvancedShortcut()
                                }
                                .buttonStyle(.plain)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.blue, .purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                                .scaleEffect(1.0)
                                .animation(.easeInOut(duration: 0.08), value: messageAnalyzer.shortcutInstalled)
                                .simultaneousGesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { _ in
                                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                            impactFeedback.impactOccurred()
                                        }
                                )
                                
                                Text("This will open the Shortcuts app. Create a shortcut that sends text to: realcalendar://analyze?text=")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 4)
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("✅ Ready to use!")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                
                                Text("Share any text to your 'Analyze Message' shortcut to create calendar events automatically.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(radius: 2)
                    
                    // Quick Usage Guide
                    VStack(alignment: .leading, spacing: 16) {
                        Text("How to Use")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("📱 Setup Instructions")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            Text("1. Tap 'Setup Shortcuts Integration' above")
                            Text("2. In Shortcuts app, create a new shortcut")
                            Text("3. Add these actions:")
                            Text("   • Get Text from Input")
                            Text("   • Open URL: realcalendar://analyze?text=[Previous Result]")
                            Text("4. Name it 'Analyze Message'")
                            Text("5. Enable 'Use with Share Sheet'")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("🎯 Usage")
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            Text("• In Messages: Select text → Share → Analyze Message")
                            Text("• In Mail: Select text → Share → Analyze Message")
                            Text("• In Safari: Select text → Share → Analyze Message")
                            Text("• Or say 'Hey Siri, Analyze Message'")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(radius: 1)
                    
                    // Alternative Methods
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Alternative Methods")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        // Siri Integration
                        HStack {
                            Image(systemName: "mic.fill")
                                .foregroundColor(.purple)
                                .font(.title2)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Siri Integration")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                Text("Say 'Hey Siri, Analyze Message' and speak the text")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if messageAnalyzer.hasSiriPermission {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title2)
                            } else {
                                Button("Enable") {
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                    messageAnalyzer.setupSiriIntegration()
                                }
                                .buttonStyle(.plain)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.purple)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.purple.opacity(0.1))
                                .cornerRadius(6)
                                .scaleEffect(1.0)
                                .animation(.easeInOut(duration: 0.08), value: messageAnalyzer.hasSiriPermission)
                            }
                        }
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(12)
                        
                        // Email Integration
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.orange)
                                .font(.title2)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Email Analysis")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                Text("Analyze existing email content for events and tasks")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button("Analyze") {
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                                Task {
                                    await messageAnalyzer.analyzeEmailContent()
                                }
                            }
                            .buttonStyle(.plain)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(messageAnalyzer.isAnalyzing ? .gray : .orange)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(messageAnalyzer.isAnalyzing ? Color.gray.opacity(0.1) : Color.orange.opacity(0.1))
                            .cornerRadius(6)
                            .disabled(messageAnalyzer.isAnalyzing)
                            .scaleEffect(messageAnalyzer.isAnalyzing ? 0.95 : 1.0)
                            .animation(.easeInOut(duration: 0.08), value: messageAnalyzer.isAnalyzing)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(radius: 2)
                    
                    // Permission Status
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Permissions")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        PermissionRow(
                            title: "Calendar",
                            description: "Create events automatically",
                            isGranted: messageAnalyzer.hasCalendarPermission,
                            icon: "calendar"
                        )
                        
                        PermissionRow(
                            title: "Contacts",
                            description: "Identify people in messages",
                            isGranted: messageAnalyzer.hasContactsPermission,
                            icon: "person.2.fill"
                        )
                        
                        PermissionRow(
                            title: "Siri",
                            description: "Voice commands",
                            isGranted: messageAnalyzer.hasSiriPermission,
                            icon: "mic.fill"
                        )
                        
                        if !messageAnalyzer.hasContactsPermission || !messageAnalyzer.hasCalendarPermission {
                            Button("Grant Permissions") {
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                                Task {
                                    await messageAnalyzer.requestAllPermissions()
                                }
                            }
                            .buttonStyle(.plain)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(12)
                            .scaleEffect(1.0)
                            .animation(.easeInOut(duration: 0.08), value: messageAnalyzer.hasContactsPermission && messageAnalyzer.hasCalendarPermission)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(radius: 2)
                    
                    // Manual Input (as fallback - de-emphasized)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Manual Input (Fallback)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        
                        Text("Use only if Shortcuts integration isn't working:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $messageAnalyzer.pastedText)
                            .frame(minHeight: 60)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                        
                        HStack(spacing: 12) {
                            Button("Analyze Text") {
                                Task {
                                    await messageAnalyzer.analyzeText(messageAnalyzer.pastedText)
                                    messageAnalyzer.pastedText = ""
                                }
                            }
                            .buttonStyle(.plain)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(messageAnalyzer.pastedText.isEmpty || messageAnalyzer.isAnalyzing ? Color.gray : Color.blue)
                            .cornerRadius(8)
                            .disabled(messageAnalyzer.pastedText.isEmpty || messageAnalyzer.isAnalyzing)
                            .scaleEffect(messageAnalyzer.pastedText.isEmpty || messageAnalyzer.isAnalyzing ? 0.95 : 1.0)
                            .animation(.easeInOut(duration: 0.1), value: messageAnalyzer.pastedText.isEmpty || messageAnalyzer.isAnalyzing)
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { _ in
                                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                        impactFeedback.impactOccurred()
                                    }
                            )
                            
                            Button("Try Sample") {
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                                messageAnalyzer.pastedText = "Meeting tomorrow at 3 PM with John. Don't forget doctor appointment Thursday 2 PM."
                            }
                            .buttonStyle(.plain)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                            .scaleEffect(1.0)
                            .animation(.easeInOut(duration: 0.1), value: messageAnalyzer.pastedText.isEmpty)
                            
                            if messageAnalyzer.isAnalyzing {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    
                    // Results sections 
                    // Today's Summary
                    if !messageAnalyzer.todaysSummary.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Daily Summary")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(messageAnalyzer.todaysSummary)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(radius: 2)
                    }
                    
                    // Extracted Events
                    if !messageAnalyzer.recentEvents.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Events Found")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            ForEach(messageAnalyzer.recentEvents) { event in
                                EventCard(event: event)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(radius: 2)
                    }
                    
                    // Pending Tasks
                    if !messageAnalyzer.pendingTasks.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Tasks Found")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            ForEach(messageAnalyzer.pendingTasks) { task in
                                TaskCard(
                                    task: task,
                                    onComplete: { messageAnalyzer.completeTask(task) },
                                    onDelete: { messageAnalyzer.deleteTask(task) }
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(radius: 2)
                    }
                    
                    // Clear data button
                    if !messageAnalyzer.recentEvents.isEmpty || !messageAnalyzer.pendingTasks.isEmpty {
                        Button("Clear All Data") {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            messageAnalyzer.clearAllData()
                        }
                        .buttonStyle(.plain)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.red)
                        .cornerRadius(8)
                        .scaleEffect(1.0)
                        .animation(.easeInOut(duration: 0.08), value: messageAnalyzer.recentEvents.isEmpty && messageAnalyzer.pendingTasks.isEmpty)
                    }
                    
                    // Privacy Notice
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Privacy & Security")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("🔒 All analysis happens locally on your device. No data is sent to servers. You control what gets analyzed through Shortcuts.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Message Analysis")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                messageAnalyzer.onEventCreated = { event in
                    print("📸 MessageAnalysisView: Event created from analysis: '\(event.title)'")
                    
                    // Send through unified event system instead of direct callback
                    NotificationCenter.default.post(
                        name: Notification.Name("PhotoEventsCreated"),
                        object: event
                    )
                }
                setupURLHandling()
            }
        }
    }
    
    private func setupURLHandling() {
        // Listen for URL scheme notifications
        NotificationCenter.default.addObserver(
            forName: Notification.Name("shortcutURLReceived"),
            object: nil,
            queue: .main
        ) { notification in
            if let url = notification.userInfo?["url"] as? URL {
                messageAnalyzer.handleURLScheme(url)
            }
        }
    }
}

// Supporting Views
struct PermissionRow: View {
    let title: String
    let description: String
    let isGranted: Bool
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: isGranted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isGranted ? .green : .red)
        }
        .padding(.vertical, 4)
    }
}

struct TaskCard: View {
    let task: PendingTask
    let onComplete: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(task.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .strikethrough(task.isCompleted)
                
                Spacer()
                
                let priorityColor: Color = task.priority == .high ? .red : task.priority == .medium ? .orange : .green
                Text(task.priority.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(priorityColor.opacity(0.2))
                    .foregroundColor(priorityColor)
                    .cornerRadius(4)
            }
            
            if let dueDate = task.dueDate {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                    Text("Due: \(dueDate, style: .date)")
                        .font(.subheadline)
                }
            }
            
            Text(task.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
            
            HStack(spacing: 12) {
                if !task.isCompleted {
                    Button("Complete") {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        onComplete()
                    }
                    .buttonStyle(.plain)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green)
                    .cornerRadius(6)
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 0.08), value: task.isCompleted)
                }
                
                Button("Delete") {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    onDelete()
                }
                .buttonStyle(.plain)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.red)
                .cornerRadius(6)
                .scaleEffect(1.0)
                .animation(.easeInOut(duration: 0.08), value: task.isCompleted)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .opacity(task.isCompleted ? 0.6 : 1.0)
    }
}

private struct EventCard: View {
    let event: ExtractedEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(event.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(Int(event.confidence * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.blue)
                Text(event.date, style: .date)
                    .font(.subheadline)
                Text(event.date, style: .time)
                    .font(.subheadline)
            }
            
            if let location = event.location {
                HStack {
                    Image(systemName: "location")
                        .foregroundColor(.green)
                    Text(location)
                        .font(.subheadline)
                }
            }
            
            Text(event.originalMessage)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// Preview
struct MessageAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        MessageAnalysisView()
    }
}