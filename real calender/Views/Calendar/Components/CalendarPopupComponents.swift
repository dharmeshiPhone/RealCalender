import SwiftUI

struct DetailCard {
    let icon: String
    let color: Color
    let title: String
    let content: String
}

struct DetailInfoCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let content: String
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(iconColor)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            Text(content)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct EditableLocationCard: View {
    let event: CalendarEvent
    let onLocationChanged: (String) -> Void
    
    @State private var isEditing = false
    @State private var editedLocation: String = ""
    @State private var showingLocationSuggestions = false
    
    private var workLocation: String {
        UserDefaults.standard.string(forKey: "workLocation") ?? ""
    }
    
    private var homeLocation: String {
        UserDefaults.standard.string(forKey: "homeLocation") ?? ""
    }
    
    private var locationSuggestions: [String] {
        var suggestions: [String] = []
        
        if !workLocation.isEmpty && !event.location.contains(workLocation) {
            suggestions.append(workLocation)
        }
        
        if !homeLocation.isEmpty && event.location != homeLocation {
            suggestions.append(homeLocation)
        }
        
        // Add common campus locations
        let commonLocations = [
            "Library",
            "Student Center",
            "Cafeteria",
            "Gym",
            "Laboratory",
            "Auditorium",
            "Online/Remote"
        ]
        
        for location in commonLocations {
            if !event.location.lowercased().contains(location.lowercased()) {
                let fullLocation = workLocation.isEmpty ? location : "\(workLocation) - \(location)"
                suggestions.append(fullLocation)
            }
        }
        
        return Array(suggestions.prefix(5))
    }
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: "location.fill")
                    .font(.caption)
                    .foregroundColor(.green)
                
                Text("Location")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    if isEditing {
                        // Save changes
                        let newLocation = editedLocation.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !newLocation.isEmpty && newLocation != event.location {
                            onLocationChanged(newLocation)
                        }
                        isEditing = false
                    } else {
                        // Start editing
                        editedLocation = event.location
                        isEditing = true
                    }
                }) {
                    Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                        .font(.caption)
                        .foregroundColor(isEditing ? .green : .blue)
                }
                .buttonStyle(.plain)
            }
            
            if isEditing {
                VStack(spacing: 8) {
                    TextField("Enter location", text: $editedLocation)
                        .textFieldStyle(.roundedBorder)
                        .font(.caption)
                    
                    if !locationSuggestions.isEmpty {
                        Button("📍 Quick Options") {
                            showingLocationSuggestions.toggle()
                        }
                        .font(.caption2)
                        .foregroundColor(.blue)
                        
                        if showingLocationSuggestions {
                            VStack(spacing: 4) {
                                ForEach(locationSuggestions, id: \.self) { suggestion in
                                    Button(action: {
                                        editedLocation = suggestion
                                        showingLocationSuggestions = false
                                    }) {
                                        HStack {
                                            Text(suggestion)
                                                .font(.caption2)
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Image(systemName: "arrow.up.left")
                                                .font(.caption2)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(6)
                                }
                            }
                        }
                    }
                    
                    HStack {
                        Button("Cancel") {
                            isEditing = false
                            editedLocation = ""
                            showingLocationSuggestions = false
                        }
                        .font(.caption2)
                        .foregroundColor(.gray)
                        
                        Spacer()
                    }
                }
            } else {
                HStack {
                    Text(event.location)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    // Location type indicator
                    if !workLocation.isEmpty && event.location.contains(workLocation) {
                        Image(systemName: "building.2.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                    } else if event.location.lowercased().contains("online") || event.location.lowercased().contains("remote") {
                        Image(systemName: "wifi")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    } else {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct LocationEditorView: View {
    let initialLocation: String
    let onSave: (String) -> Void
    let onCancel: () -> Void
    
    @State private var newLocation = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Location")) {
                    TextField("Enter new location", text: $newLocation)
                }
                
                Section {
                    Button("Save") {
                        onSave(newLocation)
                        onCancel()
                    }
                    Button("Cancel") {
                        onCancel()
                    }
                }
            }
            .navigationTitle("Edit Location")
        }
        .onAppear {
            newLocation = initialLocation
        }
    }
}

struct ColorLegendItem: View {
    let color: Color
    let label: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 20, height: 20)
                
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundColor(color)
            }
            
            Text(label)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}