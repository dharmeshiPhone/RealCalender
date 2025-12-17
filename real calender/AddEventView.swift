// AddEventView.swift
import SwiftUI
import CoreLocation

struct AddEventView: View {
    @EnvironmentObject var questManager: QuestManager
    let selectedDate: Date
    @Binding var events: [CalendarEvent]
    @Binding var isPresented: Bool
    
    @State private var title = ""
    @State private var date = Date()
    @State private var notes = ""
    @State private var location = ""
    @State private var selectedColor = Color.blue
    @State private var isValidatingLocation = false
    @State private var locationError: String?
    @State private var isLocationValid = false
    @State private var locationSuggestions: [String] = []
    @State private var showingLocationSuggestions = false
    
    @State private var scheduleNotification = false

    
    private let colors: [Color] = [.blue, .green, .red, .orange, .purple, .pink, .yellow]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Event Details")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            TextField("Event Title", text: $title)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date & Time")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            DatePicker("Date & Time", selection: $date, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(CompactDatePickerStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Location (Required)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                TextField("Enter a valid address", text: $location)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .onChange(of: location) { newValue in
                                        if !newValue.isEmpty {
                                            searchLocationSuggestions(for: newValue)
                                            validateLocation(newValue)
                                        } else {
                                            isLocationValid = false
                                            locationError = nil
                                            showingLocationSuggestions = false
                                            locationSuggestions = []
                                        }
                                    }
                                    .onSubmit {
                                        // Hide suggestions when user presses Enter
                                        showingLocationSuggestions = false
                                    }
                                
                                if isValidatingLocation {
                                    HStack {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                        Text("Validating address...")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                } else if let error = locationError {
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                } else if isLocationValid {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text("Valid address")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    }
                                }
                                
                                // Location suggestions
                                if showingLocationSuggestions && !locationSuggestions.isEmpty {
                                    ScrollView {
                                        LazyVStack(alignment: .leading, spacing: 4) {
                                            ForEach(locationSuggestions, id: \.self) { suggestion in
                                                Button(action: {
                                                    location = suggestion
                                                    showingLocationSuggestions = false
                                                    validateLocation(suggestion)
                                                }) {
                                                    HStack {
                                                        Image(systemName: getLocationIcon(for: suggestion))
                                                            .font(.caption)
                                                            .foregroundColor(.blue)
                                                        
                                                        Text(suggestion)
                                                            .font(.caption)
                                                            .foregroundColor(.primary)
                                                            .multilineTextAlignment(.leading)
                                                        
                                                        Spacer()
                                                    }
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                    }
                                    .frame(maxHeight: 120)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes (Optional)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            TextField("Add any additional details...", text: $notes, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(3...6)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 1)
                    
                    if questManager.currentBatch > 9 { // unlock this feature
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle(isOn: $scheduleNotification) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Schedule Notification")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text("Notify me 30 minutes before the event")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .disabled(date < Date())
                        }
                        .padding(.horizontal)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Color")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 16) {
                            ForEach(colors, id: \.self) { color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                                    )
                                    .scaleEffect(selectedColor == color ? 1.2 : 1.0)
                                    .animation(.spring(), value: selectedColor)
                                    .onTapGesture {
                                        selectedColor = color
                                    }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 1)
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .onTapGesture {
                // Hide suggestions when user taps outside
                showingLocationSuggestions = false
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEvent()
                    }
                    .disabled(!canSaveEvent())
                }
            }
        }
        .onAppear {
            date = selectedDate
        }
    }
    
    private func searchLocationSuggestions(for query: String) {
        guard !query.isEmpty && query.count > 2 else {
            showingLocationSuggestions = false
            locationSuggestions = []
            return
        }
        
        // Get mixed suggestions from all location types for events
        let universitySuggestions = LocationDatabase.shared.searchLocations(query: query, type: .university).prefix(2)
        let highSchoolSuggestions = LocationDatabase.shared.searchLocations(query: query, type: .highSchool).prefix(2)
        let workplaceSuggestions = LocationDatabase.shared.searchLocations(query: query, type: .workplace).prefix(2)
        let homeAddressSuggestions = LocationDatabase.shared.searchLocations(query: query, type: .homeAddress).prefix(2)
        
        var combinedSuggestions: [String] = []
        combinedSuggestions.append(contentsOf: universitySuggestions)
        combinedSuggestions.append(contentsOf: highSchoolSuggestions)
        combinedSuggestions.append(contentsOf: workplaceSuggestions)
        combinedSuggestions.append(contentsOf: homeAddressSuggestions)
        
        locationSuggestions = Array(Set(combinedSuggestions)).sorted().prefix(8).map { String($0) }
        showingLocationSuggestions = !locationSuggestions.isEmpty
    }
    
    private func getLocationIcon(for suggestion: String) -> String {
        let suggestionLower = suggestion.lowercased()
        
        if suggestionLower.contains("university") || suggestionLower.contains("college") || 
           suggestionLower.contains("ucla") || suggestionLower.contains("mit") || suggestionLower.contains("harvard") {
            return "graduationcap"
        } else if suggestionLower.contains("high school") || suggestionLower.contains("academy") || 
                  suggestionLower.contains("grammar") || suggestionLower.contains("preparatory") {
            return "building.columns"
        } else if suggestionLower.contains("street") || suggestionLower.contains("avenue") || 
                  suggestionLower.contains("road") || suggestionLower.contains("drive") {
            return "house"
        } else {
            return "building.2"
        }
    }
    
    private func canSaveEvent() -> Bool {
        return !title.isEmpty && !location.isEmpty && isLocationValid && !isValidatingLocation
    }
    
    private func validateLocation(_ address: String) {
        guard !address.isEmpty else {
            isLocationValid = false
            locationError = nil
            return
        }
        
        // Don't validate if it's too short or obviously invalid
        if address.count < 5 {
            isLocationValid = false
            locationError = "Address too short"
            return
        }
        
        // Check for basic address components
        let words = address.components(separatedBy: .whitespaces)
        if words.count < 2 {
            isLocationValid = false
            locationError = "Please enter a complete address"
            return
        }
        
        isValidatingLocation = true
        locationError = nil
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            DispatchQueue.main.async {
                self.isValidatingLocation = false
                
                if let error = error {
                    self.isLocationValid = false
                    self.locationError = "Invalid address. Please enter a real address."
                    return
                }
                
                if let placemarks = placemarks, !placemarks.isEmpty {
                    self.isLocationValid = true
                    self.locationError = nil
                } else {
                    self.isLocationValid = false
                    self.locationError = "Address not found. Please check and try again."
                }
            }
        }
    }
    
    private func saveEvent() {
        // Check if this is the FIRST scheduled event
          let isFirstScheduledEvent = !events.contains { $0.scheduleEvent == true }
        
        let newEvent = CalendarEvent(
            title: title,
            date: date,
            notes: notes,
            color: selectedColor,
            location: location,
            isRespond: isFirstScheduledEvent ? true : false,
            isCompleted: isFirstScheduledEvent ? true : false,
            scheduleEvent: true
        )
        
        // Add to local array for immediate UI update
        events.append(newEvent)
        
        // Notify ContentView through unified event system
        NotificationCenter.default.post(
            name: Notification.Name("EventAdded"),
            object: newEvent
        )
        
        print("📅 AddEventView: Created manual event '\(newEvent.title)' and posted unified notification")
      
        if scheduleNotification {
            print("⏰ Notification scheduled 30 minutes before: \(newEvent.title)")
            Task {
                await LocalNotificationManager.shared.scheduleEventReminder(
                    eventId: newEvent.id.uuidString,
                    title: newEvent.title,
                    eventDate: newEvent.date,
                    location: newEvent.location
                )
            }
        }

        
        if isFirstScheduledEvent{
            questManager.completeQuest(named: "Complete 1 scheduled event")
        }
        
        isPresented = false
    }
}
