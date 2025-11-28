import SwiftUI
import PhotosUI

struct FirstTimeCalendarSetup: View {
    @AppStorage("basicCalenderSetupStepsCompleted") private var completedSteps = 0
    @Binding var isPresented: Bool
    @Binding var userProfile: UserProfile
    @State private var currentStep = 0
    @State private var selectedScheduleType: ScheduleType = .highSchool
    @State private var morningRoutineMinutes = 30
    @State private var selectedEvents: [ScheduleEvent] = []
    @State private var userName = "Champion"
    @State private var inputMethod: InputMethod = .template
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var showingImagePicker = false
    @State private var isRecording = false
    @State private var recordingTime: TimeInterval = 0
    @State private var showingCalendarPopup = false
    @State private var calendarEvents: [CalendarEvent] = []
    @State private var homeLocation = ""
    @State private var workLocation = ""
    @State private var travelTimeMinutes = 15
    @State private var transportMethod: TransportMethod = .car
    @State private var showingFingerprintButton = false
    @State private var isProcessingImage = false
    @State private var needsRetakePhoto = false
    @State private var processedImagesCount = 0
    @State private var currentProcessingStep = 0
    @State private var isProcessingComplete = false
    @State private var processedImageHashes: Set<String> = []
    @State private var duplicateImagesDetected = 0
    
    // NEW: Track whether we're adding to existing events or starting fresh
    @State private var isAddingMorePhotos = false
    @State private var previousEventsCount = 0
    
    @StateObject private var locationManager = LocationManager()

    let onEventsCreated: ([CalendarEvent]) -> Void

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                VStack(spacing: 30) {
                    progressIndicators
                    
                    ScrollView {
                        VStack(spacing: 30) {
                            currentStepContent
                        }
                        .padding()
                    }

                    navigationButtons
                }

                overlayViews
                
                // DEV: Skip button overlay
                devSkipButton
            }
            .navigationTitle("Calendar Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        isPresented = false
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
        .onAppear {
            loadUserName()
        }
        .photosPicker(isPresented: $showingImagePicker, selection: $selectedPhotos, maxSelectionCount: 15, matching: .images)
        .onChange(of: selectedPhotos) { oldValue, newValue in
            print("  DEBUG: selectedPhotos onChange triggered!")
            print("   Old count: \(oldValue.count)")
            print("   New count: \(newValue.count)")
            
            if !newValue.isEmpty && newValue != oldValue {
                print("  DEBUG: New photos selected, calling processMultipleScreenshots()...")
                processMultipleScreenshots()
            } else {
                print("  DEBUG: Photos were cleared or unchanged")
            }
        }
        .onChange(of: needsRetakePhoto) { _, needsRetake in
            if needsRetake {
                print("  DEBUG: needsRetakePhoto triggered - showing image picker")
                showingImagePicker = true
                needsRetakePhoto = false
            }
        }
    }
    
    // MARK: - View Components
    
    private var progressIndicators: some View {
        HStack {
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .fill(index <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 12, height: 12)
                    .scaleEffect(index == currentStep ? 1.2 : 1.0)
                    .animation(.spring(), value: currentStep)
            }
        }
        .padding(.top, 20)
    }
    
    @ViewBuilder
    private var currentStepContent: some View {
        switch currentStep {
        case 0:
            WelcomeStep(userName: userName)
        case 1:
            ScheduleTypeStep(selectedScheduleType: $selectedScheduleType)
        case 2:
            SimpleLocationStep(
                homeLocation: $homeLocation,
                workLocation: $workLocation,
                travelTimeMinutes: $travelTimeMinutes,
                transportMethod: $transportMethod
            )
        case 3:
            inputStepContent
        default:
            EmptyView()
        }
    }
    
    private var inputStepContent: some View {
        VStack(spacing: 30) {
            SimpleInputStep(
                inputMethod: $inputMethod,
                selectedPhotos: $selectedPhotos,
                showingImagePicker: $showingImagePicker,
                calendarEvents: $calendarEvents,
                showingCalendarPopup: $showingCalendarPopup
            )
            
            debugButtons
        }
    }
    
    @ViewBuilder
    private var debugButtons: some View {
        // TEMPORARY: Add test button for API debugging
        VStack(spacing: 10) {
            Button(" Test API Connection") {
               // testAPIDirectly()
            }
            .buttonStyle(.bordered)
            .foregroundColor(.blue)
            
            Button(" Test with Sample Image") {
                //testWithSampleImage()
            }
            .buttonStyle(.bordered)
            .foregroundColor(.green)
        }
        .padding()
    }
    
    private var navigationButtons: some View {
        HStack {
            if currentStep > 0 {
                Button("Back") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep -= 1
                    }
                }
                .foregroundColor(.secondary)
            }

            Spacer()

            if currentStep < 3 {
                Button("Continue") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep += 1
                        completedSteps = currentStep
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!canContinue())
            } else {
                Button("Complete Setup! ") {
                    createSchedule()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 30)
    }
    
   
    @ViewBuilder
    private var overlayViews: some View {
        if showingCalendarPopup {
            calendarPopupView
        }
        
        if isProcessingImage {
            TimetableProcessingView(
                totalPhotos: selectedPhotos.count,
                processedPhotos: processedImagesCount,
                currentStep: currentProcessingStep,
                isComplete: isProcessingComplete
            )
        }
    }
    
    private var calendarPopupView: some View {
        SimpleCalendarPopup(
            isShowing: $showingCalendarPopup,
            events: calendarEvents,
            onConfirm: { createSchedule() },
            onRetakePhoto: {
                // Clear everything and start over
                calendarEvents = []
                selectedPhotos = []
                processedImagesCount = 0
                isAddingMorePhotos = false
                previousEventsCount = 0
                processedImageHashes = []
                duplicateImagesDetected = 0
                needsRetakePhoto = true
            },
            onAddMorePhotos: {
                // Keep existing events and add more
                selectedPhotos = []  // Clear photo selection for new photos
                processedImagesCount = 0
                duplicateImagesDetected = 0
                isAddingMorePhotos = true
                showingCalendarPopup = false  // Close popup to show photo picker
                showingImagePicker = true     // Open photo picker for additional photos
            },
            onEventDeleted: { deletedEvent in
                // Remove the deleted event from our local array
                calendarEvents.removeAll { $0.id == deletedEvent.id }
            }
        )
    }

    // MARK: - Dev Skip Button
    @ViewBuilder
    private var devSkipButton: some View {
        #if DEBUG
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: devSkipSetup) {
                    VStack(spacing: 4) {
                        Image(systemName: "forward.fill")
                            .font(.title2)
                        Text("DEV SKIP")
                            .font(.caption2)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red)
                            .shadow(radius: 4)
                    )
                }
                .padding(.trailing, 20)
                .padding(.bottom, 100)
            }
        }
        #endif
    }
    
    // MARK: - Functions (rest remain the same)
    
    private func canContinue() -> Bool {
        switch currentStep {
        case 2:
            return !homeLocation.isEmpty && !workLocation.isEmpty
        case 3:
            switch inputMethod {
            case .screenshot:
                return !selectedPhotos.isEmpty
            case .audio:
                return !calendarEvents.isEmpty  // Can continue if audio events were created
            default:
                return true
            }
        default:
            return true
        }
    }

    private func processMultipleScreenshots() {
        print("📸 DEBUG: processMultipleScreenshots() called!")
        print("📸 DEBUG: selectedPhotos count: \(selectedPhotos.count)")
        print("📸 DEBUG: isAddingMorePhotos: \(isAddingMorePhotos)")
        print("📸 DEBUG: existing calendarEvents count: \(calendarEvents.count)")
        
        guard !selectedPhotos.isEmpty else { 
            print("📸 DEBUG: No selectedPhotos available - this should not happen!")
            return 
        }
        
        // Store existing events if we're adding more photos
        let existingEvents = isAddingMorePhotos ? calendarEvents : []
        previousEventsCount = existingEvents.count
        
        print("📸 DEBUG: Processing \(selectedPhotos.count) new photos...")
        print("📸 DEBUG: Will preserve \(existingEvents.count) existing events")
        
        isProcessingImage = true
        processedImagesCount = 0
        duplicateImagesDetected = 0
        currentProcessingStep = 0
        isProcessingComplete = false
        
        Task {
            var newEvents: [CalendarEvent] = []
            var processedCount = 0
            
            for (index, photoItem) in selectedPhotos.enumerated() {
                do {
                    print("📸 DEBUG: [TASK] Processing NEW image \(index + 1)/\(selectedPhotos.count)...")
                    
                    await MainActor.run {
                        self.currentProcessingStep = 0
                    }
                    
                    guard let imageData = try await photoItem.loadTransferable(type: Data.self) else {
                        print("📸 DEBUG: [TASK] Failed to load image data for photo \(index + 1)")
                        continue
                    }
                    
                    print("📸 DEBUG: [TASK] Image \(index + 1) data loaded: \(imageData.count) bytes")
                    
                    // Check for duplicate image
                    let imageHash = generateSimpleHash(from: imageData)
                    print("📸 DEBUG: [TASK] Image \(index + 1) hash: \(imageHash)")
                    
                    if processedImageHashes.contains(imageHash) {
                        print("📸 DEBUG: [TASK] ⚠️ DUPLICATE IMAGE DETECTED - skipping image \(index + 1)")
                        await MainActor.run {
                            self.duplicateImagesDetected += 1
                        }
                        processedCount += 1
                        await MainActor.run {
                            self.processedImagesCount = processedCount
                        }
                        continue
                    }
                    
                    // Add hash to processed set
                    processedImageHashes.insert(imageHash)
                    
                    for step in 0..<7 {
                        await MainActor.run {
                            self.currentProcessingStep = step
                        }
                        
                        try await Task.sleep(nanoseconds: 300_000_000)
                    }
                    
                    let analyzedEvents = GeminiAIService.shared.createFallbackEvents()//try await GeminiAIService.shared.processTimetableImage(imageData)
                    
                    print("📸 DEBUG: [TASK] Image \(index + 1) returned \(analyzedEvents.count) events")
                    
                    newEvents.append(contentsOf: analyzedEvents)
                    processedCount += 1
                    
                    await MainActor.run {
                        self.processedImagesCount = processedCount
                        print("📸 DEBUG: [UI] Updated progress: \(processedCount)/\(self.selectedPhotos.count)")
                    }
                    
                } catch {
                    print("📸 DEBUG: [ERROR] Failed to process image \(index + 1): \(error)")
                    processedCount += 1
                    
                    await MainActor.run {
                        self.processedImagesCount = processedCount
                    }
                }
            }
            
            await MainActor.run {
                print("📸 DEBUG: [UI] All NEW images processed. New events: \(newEvents.count)")
                print("📸 DEBUG: [UI] Existing events: \(existingEvents.count)")
                print("📸 DEBUG: [UI] Duplicate images detected: \(self.duplicateImagesDetected)")
                
                self.isProcessingComplete = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.isProcessingImage = false
                    
                    var combinedEvents = existingEvents
                    
                    if newEvents.isEmpty && self.duplicateImagesDetected == 0 {
                        print("📸 DEBUG: [FALLBACK] No new events extracted")
                        if existingEvents.isEmpty {
                            print("📸 DEBUG: [FALLBACK] Creating fallback events...")
                            combinedEvents = self.createFallbackEvents()
                        }
                    } else {
                        print("📸 DEBUG: [UI] Adding \(newEvents.count) new events to \(existingEvents.count) existing events")
                        
                        for newEvent in newEvents {
                            if !self.isDuplicateEvent(newEvent, in: combinedEvents) {
                                combinedEvents.append(newEvent)
                            } else {
                                print("📸 DEBUG: [UI] Skipping duplicate event: \(newEvent.title)")
                            }
                        }
                    }
                    
                    self.calendarEvents = combinedEvents
                    
                    print("📸 DEBUG: [UI] Final combined events count: \(combinedEvents.count)")
                    print("📸 DEBUG: [UI] Showing calendar popup...")
                    
                    // Show duplicate warning if applicable
                    if self.duplicateImagesDetected > 0 {
                        print("📸 DEBUG: [UI] ⚠️ Warning: \(self.duplicateImagesDetected) duplicate images were skipped")
                    }
                    
                    self.showingCalendarPopup = true
                    
                    self.isAddingMorePhotos = false
                    
                    print("📸 DEBUG: [UI] Multi-photo processing completed successfully")
                }
            }
        }
    }
    
    private func isDuplicateEvent(_ newEvent: CalendarEvent, in existingEvents: [CalendarEvent]) -> Bool {
        return existingEvents.contains { existingEvent in
            if existingEvent.id == newEvent.id {
                return true
            }
            
            let titleMatch = existingEvent.title.lowercased() == newEvent.title.lowercased()
            let timeMatch = abs(existingEvent.date.timeIntervalSince(newEvent.date)) < 300
            let locationMatch = existingEvent.location.lowercased() == newEvent.location.lowercased()
            
            return titleMatch && timeMatch && locationMatch
        }
    }
    
    private func createFallbackEvents() -> [CalendarEvent] {
        print(" CALENDAR SETUP: Creating fallback events - no real events were extracted")
        
        return [
            CalendarEvent(
                title: " No Events Found",
                date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                notes: "Couldn't extract events from your images. Please try:\nUsing clearer, higher-resolution photos\nBetter lighting (avoid shadows/glare)\nMaking sure text is sharp and readable",
                color: .red,
                location: "Image Quality Issue",
                teacher: "Setup Helper",
                isRespond: false,
                isCompleted: false
            ),
            CalendarEvent(
                title: " Try Again with Better Photos",
                date: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
                notes: "Use the 'Add More Photos' option in the review screen to upload clearer images of your timetable.",
                color: .orange,
                location: "Setup Helper",
                teacher: "AI Assistant",
                isRespond: false,
                isCompleted: false
            )
        ]
    }
    
    private func loadUserName() {
        if let profile = UserProfile.load(){
            userName = profile.name
        }
    }
   

    
    private func createSchedule() {
        var finalEvents: [CalendarEvent] = []
        
        switch inputMethod {
        case .screenshot:
            finalEvents = calendarEvents
            
            print(" SETUP: Using screenshot events - Count: \(finalEvents.count)")
            
            for (index, event) in finalEvents.enumerated() {
                let isRealEvent = !event.title.contains(" No Events Found") && !event.title.contains(" Try Again with Better Photos")
                let eventType = isRealEvent ? "REAL" : "FALLBACK"
                
                print("   [\(eventType)] Event \(index + 1): '\(event.title)'")
                print("      Date: \(event.date)")
                print("      Location: '\(event.location)'")
                print("      Teacher: '\(event.teacher ?? "None")'")
                print("      Notes preview: \(event.notes.prefix(50))...")
                print("")
            }
            
            let realEventsCount = finalEvents.filter { !$0.title.contains(" No Events Found") && !$0.title.contains(" Try Again with Better Photos") }.count
            if realEventsCount == 0 {
                print(" WARNING: All \(finalEvents.count) events appear to be fallback events - no real schedule data was extracted!")
            } else {
                print(" SUCCESS: Found \(realEventsCount) real events out of \(finalEvents.count) total events")
            }
            
        case .audio:
            finalEvents = calendarEvents
            print(" SETUP: Using audio recording events - Count: \(finalEvents.count)")
            for (index, event) in finalEvents.enumerated() {
                print("   Audio Event \(index + 1): '\(event.title)'")
                print("      Date: \(event.date)")
                print("      Notes: \(event.notes)")
            }
        default:
            finalEvents = [
                CalendarEvent(
                    title: " Template Event",
                    date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                    notes: "Sample event created during setup - you can add real events later",
                    color: .blue,
                    location: "Setup Template",
                    teacher: "Template",
                    isRespond: false,
                    isCompleted: false
                )
            ]
            print(" SETUP: Using default template events - Count: \(finalEvents.count)")
        }
        
        print(" SETUP: About to call onEventsCreated with \(finalEvents.count) events")
        UserDefaults.hasCompletedCalendarSetup = true
        UserDefaults.standard.set(morningRoutineMinutes, forKey: "morningRoutineMinutes")
        UserDefaults.standard.set(selectedScheduleType.rawValue, forKey: "scheduleType")
        UserDefaults.standard.set(homeLocation, forKey: "homeLocation")
        UserDefaults.standard.set(workLocation, forKey: "workLocation")
        UserDefaults.standard.set(travelTimeMinutes, forKey: "travelTimeMinutes")
        UserDefaults.standard.set(transportMethod.rawValue, forKey: "transportMethod")
        
        onEventsCreated(finalEvents)
        print(" SETUP: onEventsCreated callback completed")
        
        isPresented = false
        print(" SETUP: Setup dismissed")
    }
    
    private func testAPIDirectly() {
        print(" DIRECT API TEST: Starting...")
        
        Task {
            do {
                let response = try await GeminiAIService.shared.testAPIConnection()
                print(" DIRECT API TEST SUCCESS: \(response)")
                
                await MainActor.run {
                    let testEvent = CalendarEvent(
                        title: " API Test Successful",
                        date: Date(),
                        notes: "API Response: \(response)",
                        color: .green,
                        isRespond: false,
                        isCompleted: false
                    )
                    self.calendarEvents = [testEvent]
                    self.showingCalendarPopup = true
                }
                
            } catch {
                print(" DIRECT API TEST FAILED: \(error)")
                
                await MainActor.run {
                    let errorEvent = CalendarEvent(
                        title: " API Test Failed",
                        date: Date(),
                        notes: "Error: \(error.localizedDescription)",
                        color: .red,
                        isRespond: false,
                        isCompleted: false
                    )
                    self.calendarEvents = [errorEvent]
                    self.showingCalendarPopup = true
                }
            }
        }
    }
    
    private func testWithSampleImage() {
        print(" SAMPLE IMAGE TEST: Starting...")
        
        let sampleImageData = Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChAI9aGL9ZQAAAABJRU5ErkJggg==") ?? Data()
        
        print(" SAMPLE IMAGE TEST: Created \(sampleImageData.count) bytes of test image data")
        
        Task {
            do {
                let events = try await GeminiAIService.shared.processTimetableImage(sampleImageData)
                print(" SAMPLE IMAGE TEST SUCCESS: Got \(events.count) events")
                
                await MainActor.run {
                    self.calendarEvents = events
                    self.showingCalendarPopup = true
                }
                
            } catch {
                print(" SAMPLE IMAGE TEST FAILED: \(error)")
                
                await MainActor.run {
                    let errorEvent = CalendarEvent(
                        title: " Image Test Failed",
                        date: Date(),
                        notes: "Error: \(error.localizedDescription)",
                        color: .red,
                        isRespond: false,
                        isCompleted: false
                    )
                    self.calendarEvents = [errorEvent]
                    self.showingCalendarPopup = true
                }
            }
        }
    }
    
    // Generate a simple hash from image data to detect duplicates
    private func generateSimpleHash(from data: Data) -> String {
        // Use first and last 1KB + file size as a simple hash
        let prefix = data.prefix(1024)
        let suffix = data.suffix(1024)
        let size = data.count
        
        let combined = prefix + suffix + Data([UInt8(size & 0xFF), UInt8((size >> 8) & 0xFF)])
        
        return combined.map { String(format: "%02x", $0) }.joined().prefix(32).description
    }
    
    // MARK: - Dev Functions
    #if DEBUG
    private func devSkipSetup() {
        print("🚀 DEV SKIP: Bypassing calendar setup with fallback events")
        
        // Set reasonable defaults
        selectedScheduleType = .highSchool
        homeLocation = "Home"
        workLocation = "School"
        travelTimeMinutes = 20
        transportMethod = .car
        morningRoutineMinutes = 30
        
        // Create comprehensive fallback events
//        let fallbackEvents = createComprehensiveFallbackEvents() // har
        
        // Save settings
        UserDefaults.hasCompletedCalendarSetup = true
        UserDefaults.standard.set(morningRoutineMinutes, forKey: "morningRoutineMinutes")
        UserDefaults.standard.set(selectedScheduleType.rawValue, forKey: "scheduleType")
        UserDefaults.standard.set(homeLocation, forKey: "homeLocation")
        UserDefaults.standard.set(workLocation, forKey: "workLocation")
        UserDefaults.standard.set(travelTimeMinutes, forKey: "travelTimeMinutes")
        UserDefaults.standard.set(transportMethod.rawValue, forKey: "transportMethod")
        //har
//        print("🚀 DEV SKIP: Created \(fallbackEvents.count) fallback events")
//        for (index, event) in fallbackEvents.enumerated() {
//            print("   [\(index + 1)] \(event.title) on \(event.date.formatted(date: .abbreviated, time: .shortened))")
//        }
//        
//        // Call completion handlers
        onEventsCreated([])//fallbackEvents
        isPresented = false
        
        print("🚀 DEV SKIP: Setup completed successfully")
    }
    
    private func createComprehensiveFallbackEvents() -> [CalendarEvent] {
        let calendar = Calendar.current
        let today = Date()
        
        // Create events for the next 7 days
        var events: [CalendarEvent] = []
        
        // School schedule (Mon-Fri)
        let schoolSubjects = [
            ("Mathematics", Color.blue, "Room 101", "Ms. Johnson"),
            ("English Literature", Color.green, "Room 205", "Mr. Smith"),
            ("Physics", Color.red, "Lab 3", "Dr. Wilson"),
            ("Chemistry", Color.orange, "Lab 2", "Prof. Davis"),
            ("History", Color.purple, "Room 150", "Ms. Brown"),
            ("Art", Color.pink, "Art Studio", "Mr. Garcia"),
            ("Physical Education", Color.cyan, "Gymnasium", "Coach Miller")
        ]
        
        for dayOffset in 0...6 {
            guard let currentDay = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
            let weekday = calendar.component(.weekday, from: currentDay)
            
            // School days (Monday = 2, Friday = 6)
            if weekday >= 2 && weekday <= 6 {
                // Morning routine
                if let morningTime = calendar.date(bySettingHour: 7, minute: 30, second: 0, of: currentDay) {
                    events.append(CalendarEvent(
                        title: "Morning Routine",
                        date: morningTime,
                        notes: "Get ready for school - shower, breakfast, pack bag",
                        color: .yellow,
                        location: "Home",
                        teacher: nil,
                        isRespond: false,
                        isCompleted: false
                    ))
                }
                
                // School classes
                for (index, (subject, color, location, teacher)) in schoolSubjects.prefix(4).enumerated() {
                    let startHour = 9 + index
                    if let classTime = calendar.date(bySettingHour: startHour, minute: 0, second: 0, of: currentDay) {
                        events.append(CalendarEvent(
                            title: subject,
                            date: classTime,
                            notes: "Regular class session",
                            color: color,
                            location: location,
                            teacher: teacher,
                            isRespond: false,
                            isCompleted: false
                        ))
                    }
                }
                
                // Lunch break
                if let lunchTime = calendar.date(bySettingHour: 13, minute: 0, second: 0, of: currentDay) {
                    events.append(CalendarEvent(
                        title: "Lunch Break",
                        date: lunchTime,
                        notes: "Cafeteria lunch with friends",
                        color: .brown,
                        location: "School Cafeteria",
                        teacher: nil,
                        isRespond: false,
                        isCompleted: false
                    ))
                }
                
                // Afternoon classes
                for (index, (subject, color, location, teacher)) in schoolSubjects.suffix(2).enumerated() {
                    let startHour = 14 + index
                    if let classTime = calendar.date(bySettingHour: startHour, minute: 0, second: 0, of: currentDay) {
                        events.append(CalendarEvent(
                            title: subject,
                            date: classTime,
                            notes: "Afternoon session",
                            color: color,
                            location: location,
                            teacher: teacher,
                            isRespond: false,
                            isCompleted: false
                        ))
                    }
                }
                
                // Study time
                if let studyTime = calendar.date(bySettingHour: 16, minute: 30, second: 0, of: currentDay) {
                    events.append(CalendarEvent(
                        title: "Study Session",
                        date: studyTime,
                        notes: "Review today's lessons and prepare for tomorrow",
                        color: .indigo,
                        location: "Library",
                        teacher: nil,
                        isRespond: false,
                        isCompleted: false
                    ))
                }
            }
            
            // Weekend events
            if weekday == 1 || weekday == 7 { // Sunday or Saturday
                // Weekend activities
                if let weekendActivity = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: currentDay) {
                    let activities = [
                        ("Family Time", Color.green, "Home", "Spend time with family"),
                        ("Sports Practice", Color.red, "Sports Center", "Soccer training session"),
                        ("Shopping", Color.purple, "Mall", "Weekly grocery shopping"),
                        ("Movie Night", Color.blue, "Home", "Watch a movie with friends")
                    ]
                    
                    let activity = activities[dayOffset % activities.count]
                    events.append(CalendarEvent(
                        title: activity.0,
                        date: weekendActivity,
                        notes: activity.3,
                        color: activity.1,
                        location: activity.2,
                        teacher: nil,
                        isRespond: false,
                        isCompleted: false
                    ))
                }
            }
            
            // Daily evening routine
            if let eveningTime = calendar.date(bySettingHour: 19, minute: 0, second: 0, of: currentDay) {
                events.append(CalendarEvent(
                    title: "Dinner & Family Time",
                    date: eveningTime,
                    notes: "Dinner with family and relaxation",
                    color: .orange,
                    location: "Home",
                    teacher: nil,
                    isRespond: false,
                    isCompleted: false
                ))
            }
        }
        
        // Add some upcoming special events
        if let specialEvent1 = calendar.date(byAdding: .day, value: 3, to: today),
           let eventTime1 = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: specialEvent1) {
            events.append(CalendarEvent(
                title: "Science Project Due",
                date: eventTime1,
                notes: "Submit the chemistry research project on renewable energy",
                color: .red,
                location: "Chemistry Lab",
                teacher: "Prof. Davis",
                isRespond: false,
                isCompleted: false
            ))
        }
        
        if let specialEvent2 = calendar.date(byAdding: .day, value: 5, to: today),
           let eventTime2 = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: specialEvent2) {
            events.append(CalendarEvent(
                title: "Math Test",
                date: eventTime2,
                notes: "Chapter 7-9: Algebra and Trigonometry",
                color: .blue,
                location: "Room 101",
                teacher: "Ms. Johnson",
                isRespond: false,
                isCompleted: false
            ))
        }
        
        if let specialEvent3 = calendar.date(byAdding: .day, value: 8, to: today),
           let eventTime3 = calendar.date(bySettingHour: 15, minute: 30, second: 0, of: specialEvent3) {
            events.append(CalendarEvent(
                title: "Parent-Teacher Conference",
                date: eventTime3,
                notes: "Meeting with teachers to discuss academic progress",
                color: .purple,
                location: "Main Office",
                teacher: "Various Teachers",
                isRespond: false,
                isCompleted: false
            ))
        }
        
        return events.sorted { $0.date < $1.date }
    }
    #endif
}
