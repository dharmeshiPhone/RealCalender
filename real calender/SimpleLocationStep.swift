import SwiftUI
import CoreLocation

struct SimpleLocationStep: View {
    @Binding var homeLocation: String
    @Binding var workLocation: String  
    @Binding var travelTimeMinutes: Int
    @Binding var transportMethod: TransportMethod
    
    @StateObject private var locationManager = LocationManager()
    @State private var showingLocationPicker = false
    @State private var locationPickerType: LocationPickerType = .home
    @State private var isValidatingHomeLocation = false
    @State private var isValidatingWorkLocation = false
    @State private var homeLocationSuggestions: [String] = []
    @State private var workLocationSuggestions: [String] = []
    @State private var showingHomeSuggestions = false
    @State private var showingWorkSuggestions = false
    
    enum LocationPickerType {
        case home, work
    }
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Text("📍 Travel & Location Setup")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Help me calculate accurate travel times for your schedule")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 24) {
                // Location inputs
                VStack(spacing: 20) {
                    // Home Location
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🏠 Home Address")
                            .font(.headline)
                            .fontWeight(.semibold)

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                TextField("Enter your home address", text: $homeLocation)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .onChange(of: homeLocation) { _, newValue in
                                        searchLocationSuggestions(for: newValue, locationType: .home)
                                    }
                                    .onSubmit {
                                        // Hide suggestions when user presses Enter
                                        showingHomeSuggestions = false
                                    }
                                
                                Button(action: {
                                    locationPickerType = .home
                                    showingLocationPicker = true
                                }) {
                                    Image(systemName: "location.fill")
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                        .padding(8)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(8)
                                }
                            }
                            
                            if isValidatingHomeLocation {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Validating address...")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            // Home location suggestions
                            if showingHomeSuggestions && !homeLocationSuggestions.isEmpty {
                                ScrollView {
                                    LazyVStack(alignment: .leading, spacing: 4) {
                                        ForEach(homeLocationSuggestions, id: \.self) { suggestion in
                                            Button(action: {
                                                homeLocation = suggestion
                                                showingHomeSuggestions = false
                                            }) {
                                                HStack {
                                                    Image(systemName: "location")
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

                    // Work/School Location
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🎓 School/Work Address")
                            .font(.headline)
                            .fontWeight(.semibold)

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                TextField("Enter your school/work address", text: $workLocation)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .onChange(of: workLocation) { _, newValue in
                                        searchLocationSuggestions(for: newValue, locationType: .work)
                                    }
                                    .onSubmit {
                                        // Hide suggestions when user presses Enter
                                        showingWorkSuggestions = false
                                    }
                                
                                Button(action: {
                                    locationPickerType = .work
                                    showingLocationPicker = true
                                }) {
                                    Image(systemName: "location.fill")
                                        .font(.title3)
                                        .foregroundColor(.green)
                                        .padding(8)
                                        .background(Color.green.opacity(0.1))
                                        .cornerRadius(8)
                                }
                            }
                            
                            if isValidatingWorkLocation {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Validating address...")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                            }
                            
                            // Work location suggestions
                            if showingWorkSuggestions && !workLocationSuggestions.isEmpty {
                                ScrollView {
                                    LazyVStack(alignment: .leading, spacing: 4) {
                                        ForEach(workLocationSuggestions, id: \.self) { suggestion in
                                            Button(action: {
                                                workLocation = suggestion
                                                showingWorkSuggestions = false
                                            }) {
                                                HStack {
                                                    Image(systemName: suggestion.contains("University") || suggestion.contains("MIT") || suggestion.contains("UCLA") || suggestion.contains("USC") ? "graduationcap" : "building.2")
                                                        .font(.caption)
                                                        .foregroundColor(.green)
                                                    
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
                }
                
                // Transportation method selection
                VStack(spacing: 16) {
                    Text("🚗 How do you get there?")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(TransportMethod.allCases, id: \.self) { method in
                            TransportOptionCard(
                                method: method,
                                isSelected: transportMethod == method,
                                action: {
                                    transportMethod = method
                                    updateTravelTimeForMethod(method)
                                }
                            )
                        }
                    }
                    
                    // Helpful guidance text
                    VStack(spacing: 8) {
                        Text("💡 Just select your most common transport method")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.center)
                        
                        Text("⚠️ Travel Time Accuracy Notice")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                        
                        Text("This is not 100% accurate - we don't have enough money to use Google's API yet, but once we do it will be a lot more accurate. Thanks! - The Developer")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .italic()
                        
                        Text("Don't worry if some classes or shifts use different transport - you can always change this later in settings. This is just for calculating your general travel times.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.orange.opacity(0.05))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                    )
                }
                
                // Travel time adjustment
                VStack(spacing: 12) {
                    Text("⏱️ Estimated travel time:")
                        .font(.headline)
                        .fontWeight(.semibold)

                    HStack(spacing: 16) {
                        Button(action: {
                            if travelTimeMinutes > 5 {
                                travelTimeMinutes -= 5
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)

                        VStack(spacing: 4) {
                            Text("\(travelTimeMinutes)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(transportMethod.color)
                            
                            Text("minutes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(width: 80)

                        Button(action: {
                            if travelTimeMinutes < 120 {
                                travelTimeMinutes += 5
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Travel time suggestions based on transport method
                    Text(getTravelTimeSuggestion())
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
                .padding()
                .background(transportMethod.color.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(transportMethod.color.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .onAppear {
            // Set default travel time based on transport method if not set
            if travelTimeMinutes == 15 { // Default value
                updateTravelTimeForMethod(transportMethod)
            }
            locationManager.requestPermission()
        }
        .sheet(isPresented: $showingLocationPicker) {
            CurrentLocationPicker(
                locationType: locationPickerType,
                onLocationSelected: { location in
                    if locationPickerType == .home {
                        homeLocation = location
                    } else {
                        workLocation = location
                    }
                    showingLocationPicker = false
                }
            )
        }
    }
    
    private func searchLocationSuggestions(for query: String, locationType: LocationPickerType) {
        guard !query.isEmpty && query.count > 2 else {
            if locationType == .home {
                showingHomeSuggestions = false
                homeLocationSuggestions = []
            } else {
                showingWorkSuggestions = false
                workLocationSuggestions = []
            }
            return
        }
        
        // Use the enhanced LocationDatabase for smart suggestions
        if locationType == .home {
            let suggestions = LocationDatabase.shared.searchLocations(query: query, type: .homeAddress)
            homeLocationSuggestions = Array(suggestions.prefix(8))
            showingHomeSuggestions = !homeLocationSuggestions.isEmpty
        } else {
            // For work/school, get mixed suggestions from universities, high schools, and workplaces
            let universitySuggestions = LocationDatabase.shared.searchLocations(query: query, type: .university).prefix(3)
            let highSchoolSuggestions = LocationDatabase.shared.searchLocations(query: query, type: .highSchool).prefix(2)
            let workplaceSuggestions = LocationDatabase.shared.searchLocations(query: query, type: .workplace).prefix(3)
            
            var combinedSuggestions: [String] = []
            combinedSuggestions.append(contentsOf: universitySuggestions)
            combinedSuggestions.append(contentsOf: highSchoolSuggestions)
            combinedSuggestions.append(contentsOf: workplaceSuggestions)
            
            workLocationSuggestions = Array(Set(combinedSuggestions)).sorted().prefix(8).map { String($0) }
            showingWorkSuggestions = !workLocationSuggestions.isEmpty
        }
        
        // Also search using geocoding for real addresses (keep existing functionality)
        searchGeocodedLocations(for: query, locationType: locationType)
    }
    
    private func searchGeocodedLocations(for query: String, locationType: LocationPickerType) {
        let geocoder = CLGeocoder()
        
        if locationType == .home {
            isValidatingHomeLocation = true
        } else {
            isValidatingWorkLocation = true
        }
        
        geocoder.geocodeAddressString(query) { placemarks, error in
            DispatchQueue.main.async {
                if locationType == .home {
                    self.isValidatingHomeLocation = false
                } else {
                    self.isValidatingWorkLocation = false
                }
                
                guard let placemarks = placemarks, !placemarks.isEmpty else { return }
                
                let suggestions = placemarks.compactMap { placemark -> String? in
                    var components: [String] = []
                    
                    if let name = placemark.name { components.append(name) }
                    if let locality = placemark.locality { components.append(locality) }
                    if let state = placemark.administrativeArea { components.append(state) }
                    
                    return components.isEmpty ? nil : components.joined(separator: ", ")
                }.prefix(3)
                
                if locationType == .home {
                    let existingSuggestions = self.homeLocationSuggestions
                    self.homeLocationSuggestions = Array(Set(existingSuggestions + suggestions)).prefix(5).map { $0 }
                    self.showingHomeSuggestions = !self.homeLocationSuggestions.isEmpty
                } else {
                    let existingSuggestions = self.workLocationSuggestions
                    self.workLocationSuggestions = Array(Set(existingSuggestions + suggestions)).prefix(5).map { $0 }
                    self.showingWorkSuggestions = !self.workLocationSuggestions.isEmpty
                }
            }
        }
    }
    
    private func updateTravelTimeForMethod(_ method: TransportMethod) {
        switch method {
        case .walking:
            travelTimeMinutes = 25
        case .cycling:
            travelTimeMinutes = 15
        case .car:
            travelTimeMinutes = 12
        case .publicTransport:
            travelTimeMinutes = 30
        }
    }
    
    private func getTravelTimeSuggestion() -> String {
        switch transportMethod {
        case .walking:
            return "🚶‍♂️ Walking typically takes 20-40 minutes for most school distances"
        case .cycling:
            return "🚴‍♂️ Cycling is usually 10-25 minutes depending on distance and bike lanes"
        case .car:
            return "🚗 Driving time varies by traffic - consider rush hour delays"
        case .publicTransport:
            return "🚌 Public transport includes waiting time and transfers"
        }
    }
}

struct CurrentLocationPicker: View {
    let locationType: SimpleLocationStep.LocationPickerType
    let onLocationSelected: (String) -> Void
    
    @StateObject private var locationManager = LocationManager()
    @Environment(\.dismiss) private var dismiss
    @State private var currentLocationString = ""
    @State private var isLoadingLocation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Use Current Location")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("We'll use your current location as your \(locationType == .home ? "home" : "school/work") address")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                if isLoadingLocation {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        
                        Text("Getting your current location...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else if !currentLocationString.isEmpty {
                    VStack(spacing: 16) {
                        Text("📍 Current Location:")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(currentLocationString)
                            .font(.body)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        
                        Button("Use This Location") {
                            onLocationSelected(currentLocationString)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                } else {
                    VStack(spacing: 16) {
                        Button("📍 Get Current Location") {
                            getCurrentLocation()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        
                        Text("Make sure location services are enabled for this app")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Current Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            getCurrentLocation()
        }
    }
    
    private func getCurrentLocation() {
        isLoadingLocation = true
        
        locationManager.getCurrentLocationAddress { address in
            DispatchQueue.main.async {
                if let address = address {
                    self.currentLocationString = address
                } else {
                    print("Failed to get current location address")
                }
                self.isLoadingLocation = false
            }
        }
    }
}

struct TransportOptionCard: View {
    let method: TransportMethod
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? method.color : Color(.systemGray5))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: method.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : .secondary)
                }
                
                Text(method.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? method.color : .primary)
                    .multilineTextAlignment(.center)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(method.color)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                isSelected ? 
                method.color.opacity(0.1) : 
                Color(.systemGray6)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? method.color : Color(.systemGray4),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}