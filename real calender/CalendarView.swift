// CalendarView.swift
import SwiftUI
import PhotosUI

struct CalendarView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @EnvironmentObject var aiChatManager: AIChatManager
    @Binding var events: [CalendarEvent]
    @State private var selectedDate = Date()
    @State private var showingAddEvent = false
    @State private var showingAddMethodSheet = false
    @State private var showingImagePicker = false
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var showingTimetableProcessing = false
    @State private var isProcessingImage = false
    @State private var newEventTitle = ""
    @State private var newEventTime = Date()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Interactive Calendar - Fixed sizing
                VStack {
                    InteractiveCalendarView(selectedDate: $selectedDate, events: events)
                        .frame(maxHeight: 420) // Adequate height for interactive calendar
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                
                // Events for selected date - Flexible space
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Events for \(selectedDate, formatter: dateFormatter)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: {
                            showingAddMethodSheet = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    if eventsForSelectedDate.isEmpty {
                        ScrollView {
                            VStack(spacing: 16) {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 48))
                                    .foregroundColor(.gray)
                                
                                Text("No events scheduled")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                
                                // Quick action buttons for adding events
                                VStack(spacing: 12) {
                                    HStack(spacing: 16) {
                                        QuickAddButton(
                                            title: "Manual Entry",
                                            icon: "square.and.pencil",
                                            color: .blue
                                        ) {
                                            showingAddEvent = true
                                        }
                                        
                                        QuickAddButton(
                                            title: "Voice Input",
                                            icon: "mic.fill",
                                            color: .green
                                        ) {
                                            startVoiceEventCreation()
                                        }
                                    }
                                    
                                    QuickAddButton(
                                        title: "Image Timetable",
                                        icon: "camera.viewfinder",
                                        color: .purple
                                    ) {
                                        showingImagePicker = true
                                    }
                                }
                                
                                Divider()
                                    .padding(.vertical, 8)
                                
                                Button("Ask AI to help plan your day") {
                                    aiChatManager.sendMessage("Help me plan my day for \(dateFormatter.string(from: selectedDate))")
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .padding()
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(eventsForSelectedDate) { event in
                                    EventRow(event: event)
                                        .onTapGesture {
                                            aiChatManager.sendMessage("Tell me about my \(event.title) event")
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Use remaining space
                .background(Color(.systemGroupedBackground))
                
                // Screen Time Summary for selected date - Fixed size
                if screenTimeManager.isAuthorized {
                    ScreenTimeSummaryCard(date: selectedDate)
                        .environmentObject(screenTimeManager)
                        .padding()
                }
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAddEvent) {
                AddEventView(
                    selectedDate: selectedDate,
                    events: $events,
                    isPresented: $showingAddEvent
                )
            }
            .actionSheet(isPresented: $showingAddMethodSheet) {
                ActionSheet(
                    title: Text("Add Event"),
                    message: Text("How would you like to create your event?"),
                    buttons: [
                        .default(Text("📝 Manual Entry")) {
                            showingAddEvent = true
                        },
                        .default(Text("🎤 Voice Input")) {
                            startVoiceEventCreation()
                        },
                        .default(Text("📸 Image Timetable")) {
                            showingImagePicker = true
                        },
                        .cancel()
                    ]
                )
            }
            .photosPicker(isPresented: $showingImagePicker, selection: $photoPickerItem, matching: .images)
            .fullScreenCover(isPresented: $showingTimetableProcessing) {
                TimetableProcessingView(
                    totalPhotos: 1,
                    processedPhotos: isProcessingImage ? 1 : 0,
                    currentStep: 2,
                    isComplete: !isProcessingImage
                )
            }
            .onChange(of: photoPickerItem) { oldValue, newValue in
                Task {
                    if let newItem = newValue {
                        await processSelectedImage(newItem)
                    }
                }
            }
        }
    }
    
    private var eventsForSelectedDate: [CalendarEvent] {
        let calendar = Calendar.current
        return events.filter { event in
            calendar.isDate(event.date, inSameDayAs: selectedDate)
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    private func startVoiceEventCreation() {
        // Create a specific prompt for voice event creation
        let dateString = dateFormatter.string(from: selectedDate)
        let prompt = "I want to create a new event using voice input for \(dateString). Please listen to what I say and create a calendar event from it."
        
        aiChatManager.sendMessage(prompt)
        
        // Start listening immediately after sending the message
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            aiChatManager.startListening()
        }
        
        // Show a toast or feedback to user
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func processSelectedImage(_ item: PhotosPickerItem) async {
        do {
            isProcessingImage = true
            showingTimetableProcessing = true
            
            if let data = try await item.loadTransferable(type: Data.self) {
                // Use the TimetableAnalysisService to process the image
                let extractedEvents = try await TimetableAnalysisService.shared.analyzeImage(data)
                
                // Add all the extracted events to the calendar
                for event in extractedEvents {
                    // Adjust the date to be relative to the selected date if needed
                    var adjustedEvent = event
                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.hour, .minute], from: event.date)
                    if let newDate = calendar.date(bySettingHour: components.hour ?? 9, 
                                                  minute: components.minute ?? 0, 
                                                  second: 0, 
                                                  of: selectedDate) {
                        adjustedEvent.date = newDate
                    }
                    
                    events.append(adjustedEvent)
                    
                    // Notify other parts of the app
                    NotificationCenter.default.post(
                        name: Notification.Name("EventAdded"),
                        object: adjustedEvent
                    )
                }
                
                print("📸 CalendarView: Processed image and created \(extractedEvents.count) events")
                
                // Show success feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                impactFeedback.impactOccurred()
            }
        } catch {
            print("❌ Image processing error: \(error)")
            
            // Show error feedback to user through AI chat
            let errorMessage = "❌ I couldn't process that timetable image. Please try again with a clearer image or use manual entry."
            aiChatManager.sendMessage("Error processing timetable: \(error.localizedDescription)")
        }
        
        isProcessingImage = false
        
        // Dismiss processing view after a short delay to show completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showingTimetableProcessing = false
        }
        
        // Reset the picker item
        photoPickerItem = nil
    }
}

// MARK: - Quick Add Button Component
struct QuickAddButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct EventRow: View {
    let event: CalendarEvent
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(event.date, formatter: timeFormatter)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if !event.location.isEmpty {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text(event.location)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                if !event.notes.isEmpty {
                    Text(event.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            Circle()
                .fill(event.color)
                .frame(width: 12, height: 12)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

struct ScreenTimeSummaryCard: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    let date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.blue)
                Text("Screen Time Summary")
                    .font(.headline)
                Spacer()
            }
            
            let totalMinutes = screenTimeManager.getTotalUsageToday()
            let mostUsedApp = screenTimeManager.getMostUsedApp()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Today")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(totalMinutes) min")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                if let (appName, minutes) = mostUsedApp {
                    VStack(alignment: .trailing) {
                        Text("Most Used")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(appName)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("\(minutes) min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}