import SwiftUI
import PhotosUI

struct SimpleInputStep: View {
    @Binding var inputMethod: InputMethod
    @Binding var selectedPhotos: [PhotosPickerItem]
    @Binding var showingImagePicker: Bool
    @Binding var calendarEvents: [CalendarEvent]
    @Binding var showingCalendarPopup: Bool
    
    // Add voice recording state
    @State private var isRecording = false
    @State private var recordingTime: TimeInterval = 0
    @State private var recordingTimer: Timer?

    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Text("How would you like to add your schedule?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                // Show current events count if we have some
                if !calendarEvents.isEmpty {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Current Schedule")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                            
                            Text("\(calendarEvents.count) events already added")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    )
                }
            }

            VStack(spacing: 16) {
                Button(action: {
                    inputMethod = .screenshot
                    showingImagePicker = true
                }) {
                    HStack(spacing: 16) {
                        Image(systemName: "camera.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                            .frame(width: 40)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(calendarEvents.isEmpty ? "Upload Screenshots" : "Add More Screenshots")
                                .font(.headline)
                                .fontWeight(.semibold)

                            Text(calendarEvents.isEmpty ? "Select up to 15 photos of your timetables" : "Add more photos to expand your schedule")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if inputMethod == .screenshot {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                        }
                    }
                    .padding()
                    .background(
                        inputMethod == .screenshot ?
                        Color.green.opacity(0.1) :
                        Color(.systemGray6)
                    )
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
                
                // Add Voice Recording Option
                Button(action: {
                    inputMethod = .audio
                    if !isRecording {
                        startRecording()
                    } else {
                        stopRecording()
                    }
                }) {
                    HStack(spacing: 16) {
                        Image(systemName: isRecording ? "stop.circle.fill" : "mic.fill")
                            .font(.title2)
                            .foregroundColor(isRecording ? .red : .orange)
                            .frame(width: 40)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(isRecording ? "Stop Recording" : "Voice Recording")
                                .font(.headline)
                                .fontWeight(.semibold)

                            Text(isRecording ? 
                                 "Recording: \(formatTime(recordingTime))" : 
                                 "Tell AI about your schedule")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if inputMethod == .audio && !isRecording {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                        }
                    }
                    .padding()
                    .background(
                        inputMethod == .audio ?
                        Color.orange.opacity(0.1) :
                        Color(.systemGray6)
                    )
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)

                Button(action: {
                    inputMethod = .createOwn
                }) {
                    HStack(spacing: 16) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .frame(width: 40)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Create Own Schedule")
                                .font(.headline)
                                .fontWeight(.semibold)

                            Text("Build from scratch")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if inputMethod == .createOwn {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                        }
                    }
                    .padding()
                    .background(
                        inputMethod == .createOwn ?
                        Color.blue.opacity(0.1) :
                        Color(.systemGray6)
                    )
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }

            // Show selected photos preview
            if !selectedPhotos.isEmpty {
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "photo.stack.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                        
                        Text("\(selectedPhotos.count) photo\(selectedPhotos.count == 1 ? "" : "s") selected")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Spacer()
                        
                        Button("Change Photos") {
                            showingImagePicker = true
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Photo count indicators
                    HStack(spacing: 8) {
                        ForEach(0..<min(selectedPhotos.count, 10), id: \.self) { index in
                            Circle()
                                .fill(Color.green)
                                .frame(width: 12, height: 12)
                        }
                        if selectedPhotos.count > 10 {
                            Text("+\(selectedPhotos.count - 10)")
                                .font(.caption)
                                .foregroundColor(.green)
                                .fontWeight(.bold)
                        }
                        Text("(\(selectedPhotos.count)/15 selected)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if calendarEvents.isEmpty {
                        Text("✅ Ready to process your timetables!")
                            .font(.subheadline)
                            .foregroundColor(.green)
                            .fontWeight(.medium)
                    } else {
                        Text("✅ Ready to add more events to your \(calendarEvents.count) existing events!")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                    }
                }
                .padding()
                .background(calendarEvents.isEmpty ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Voice Recording Functions
    private func startRecording() {
        isRecording = true
        recordingTime = 0
        
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            recordingTime += 0.1
        }
        
        print("🎤 Started voice recording...")
    }
    
    private func stopRecording() {
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        print("🎤 Stopped voice recording after \(recordingTime) seconds")
        
        // Process the recording with AI
        processVoiceRecording()
    }
    
    private func processVoiceRecording() {
        Task {
            do {
                print("🤖 Processing voice recording with AI...")
                let events = try await GeminiAIService.shared.processAudioRecording(duration: recordingTime)
                
                await MainActor.run {
                    calendarEvents = events
                    showingCalendarPopup = true
                }
                
            } catch {
                print("❌ Voice recording processing failed: \(error)")
                
                await MainActor.run {
                    // Create fallback events
                    let fallbackEvent = CalendarEvent(
                        title: "📝 Voice Recording Event",
                        date: Date(),
                        notes: "Created from \(formatTime(recordingTime)) voice recording",
                        color: .orange
                    )
                    calendarEvents = [fallbackEvent]
                    showingCalendarPopup = true
                }
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}