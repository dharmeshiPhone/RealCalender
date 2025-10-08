import SwiftUI

struct EventDetailView: View {
    @Binding var event: CalendarEvent
    @Binding var isPresented: Bool
    let onSave: (CalendarEvent) -> Void
    let onDelete: () -> Void
    
    @State private var editedTitle: String = ""
    @State private var editedDate: Date = Date()
    @State private var editedLocation: String = ""
    @State private var editedTeacher: String = ""
    @State private var editedNotes: String = ""
    @State private var editedColor: Color = .blue
    @State private var editedExtraInformation: String = ""
    @State private var editedEquipment: String = ""
    @State private var showingDeleteAlert = false
    
    // Check if this is a travel event
    private var isTravelEvent: Bool {
        let title = event.title.lowercased()
        return title.contains("getting to") || 
               title.contains("heading to") || 
               title.contains("heading home") || 
               title.contains("leaving") ||
               title.contains("travel") ||
               title.contains("🎓") ||
               title.contains("💼") ||
               title.contains("🏠")
    }
    
    // Color options for the picker
    private let colorOptions: [Color] = [
        .blue, .green, .purple, .orange, .pink, .cyan, .red, .yellow,
        .mint, .indigo, .brown, .teal,
        Color(red: 0.8, green: 0.4, blue: 0.9),   // Light Purple
        Color(red: 0.9, green: 0.6, blue: 0.2),   // Light Orange
        Color(red: 0.6, green: 0.8, blue: 0.4),   // Light Green
        Color(red: 0.8, green: 0.2, blue: 0.6),   // Magenta
        Color(red: 0.4, green: 0.6, blue: 0.9),   // Sky Blue
        Color(red: 0.9, green: 0.4, blue: 0.4),   // Light Red
    ]
    
    var body: some View {
        NavigationView {
            Form {
                // Travel Event Warning (if applicable)
                if isTravelEvent {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Travel Time Notice")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.orange)
                            }
                            
                            Text("This travel time is not 100% accurate - we don't have enough money to use Google's API yet, but once we do it will be a lot more accurate. Thanks! - The Developer")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(Color.orange.opacity(0.05))
                }
                
                // MARK: - Notes Section (contains all the event information)
                Section("Notes") {
                    // Event Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Event Title")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter event title", text: $editedTitle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                    }
                    .padding(.vertical, 4)
                    
                    // Date and Time
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date & Time")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        DatePicker("Select date and time", selection: $editedDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(CompactDatePickerStyle())
                    }
                    .padding(.vertical, 4)
                    
                    // Location
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter location", text: $editedLocation)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                    }
                    .padding(.vertical, 4)
                    
                    // Teacher/Instructor
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Teacher/Instructor")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter teacher name", text: $editedTeacher)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                    }
                    .padding(.vertical, 4)
                    
                    // Color Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Event Color")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
                            ForEach(colorOptions, id: \.self) { color in
                                Button(action: {
                                    editedColor = color
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(color)
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.primary, lineWidth: editedColor == color ? 3 : 0)
                                            )
                                        
                                        if editedColor == color {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                    .padding(.vertical, 8)
                    
                    // Notes Text Area
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Additional Notes")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextEditor(text: $editedNotes)
                            .frame(minHeight: 100)
                            .font(.body)
                            .scrollContentBackground(.hidden)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .padding(.vertical, 4)
                }
                
                // MARK: - Extra Information Section (empty)
                Section("Extra Information") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Extra Information")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextEditor(text: $editedExtraInformation)
                            .frame(minHeight: 80)
                            .font(.body)
                            .scrollContentBackground(.hidden)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .padding(.vertical, 4)
                }
                
                // MARK: - Equipment Section
                Section("Equipment") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Equipment Needed")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextEditor(text: $editedEquipment)
                            .frame(minHeight: 80)
                            .font(.body)
                            .scrollContentBackground(.hidden)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .padding(.vertical, 4)
                }
                
                // MARK: - Delete Section
                Section {
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            
                            Text("Delete Event")
                                .foregroundColor(.red)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Event Details")
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
                    .fontWeight(.semibold)
                    .disabled(editedTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert("Delete Event", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    onDelete()
                    isPresented = false
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this event? This action cannot be undone.")
            }
        }
        .onAppear {
            loadEventData()
        }
    }
    
    private func loadEventData() {
        editedTitle = event.title
        editedDate = event.date
        editedLocation = event.location
        editedTeacher = event.teacher ?? ""
        editedNotes = event.notes
        editedColor = event.color
        editedExtraInformation = event.extraInformation
        editedEquipment = event.equipment
    }
    
    private func saveEvent() {
        // Update the binding with all the new data
        event.title = editedTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        event.date = editedDate
        event.notes = editedNotes
        event.color = editedColor
        event.location = editedLocation.trimmingCharacters(in: .whitespacesAndNewlines)
        event.teacher = editedTeacher.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : editedTeacher.trimmingCharacters(in: .whitespacesAndNewlines)
        event.extraInformation = editedExtraInformation
        event.equipment = editedEquipment
        
        onSave(event)
        isPresented = false
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

#Preview {
    @State var sampleEvent = CalendarEvent(
        title: "Sample Class",
        date: Date(),
        notes: "This is a sample event for preview",
        color: .blue,
        location: "Room 101",
        teacher: "Dr. Smith",
        extraInformation: "",
        equipment: ""
    )
    @State var isPresented = true
    
    EventDetailView(
        event: $sampleEvent,
        isPresented: $isPresented,
        onSave: { _ in },
        onDelete: { }
    )
}