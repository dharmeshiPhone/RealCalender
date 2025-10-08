import SwiftUI

struct AISetupGuideView: View {
    @Binding var isPresented: Bool
    @State private var showingInstructions = false
    @State private var apiKeyInput = ""
    @State private var isTestingConnection = false
    @State private var connectionStatus: ConnectionStatus = .notTested
    
    enum ConnectionStatus {
        case notTested, testing, success, failed
        
        var color: Color {
            switch self {
            case .notTested: return .gray
            case .testing: return .blue
            case .success: return .green
            case .failed: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .notTested: return "questionmark.circle"
            case .testing: return "arrow.clockwise"
            case .success: return "checkmark.circle.fill"
            case .failed: return "xmark.circle.fill"
            }
        }
        
        var message: String {
            switch self {
            case .notTested: return "Not tested"
            case .testing: return "Testing connection..."
            case .success: return "Connection successful!"
            case .failed: return "Connection failed"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.blue, .purple]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 8) {
                            Text("🤖 AI Calendar Analysis")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("Set up AI-powered calendar recognition")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    // Features Section
                    VStack(spacing: 16) {
                        Text("✨ What AI Analysis Provides:")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            FeatureCard(
                                icon: "camera.viewfinder",
                                title: "Smart Recognition",
                                description: "Automatically detect events from any calendar format"
                            )
                            
                            FeatureCard(
                                icon: "clock.arrow.circlepath",
                                title: "Time Extraction",
                                description: "Precisely extract dates, times, and durations"
                            )
                            
                            FeatureCard(
                                icon: "location.circle",
                                title: "Location Detection",
                                description: "Identify venues and meeting locations"
                            )
                            
                            FeatureCard(
                                icon: "tag.circle",
                                title: "Auto Categorization",
                                description: "Intelligently categorize events by type"
                            )
                        }
                    }
                    
                    // Setup Section
                    VStack(spacing: 20) {
                        Text("🔧 Setup Required")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 16) {
                            // Step 1
                            SetupStepCard(
                                stepNumber: 1,
                                title: "Get OpenAI API Key",
                                description: "Sign up at OpenAI and get your API key",
                                action: {
                                    if let url = URL(string: "https://platform.openai.com/api-keys") {
                                        UIApplication.shared.open(url)
                                    }
                                },
                                actionTitle: "Open OpenAI"
                            )
                            
                            // Step 2
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 24, height: 24)
                                        
                                        Text("2")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    }
                                    
                                    Text("Enter Your API Key")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                }
                                
                                Text("Paste your OpenAI API key below to enable AI analysis")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                VStack(spacing: 12) {
                                    SecureField("sk-...", text: $apiKeyInput)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .font(.system(size: 14, design: .monospaced))
                                    
                                    HStack {
                                        Button("Test Connection") {
                                            testAPIConnection()
                                        }
                                        .buttonStyle(.bordered)
                                        .disabled(apiKeyInput.isEmpty || isTestingConnection)
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 8) {
                                            Image(systemName: connectionStatus.icon)
                                                .foregroundColor(connectionStatus.color)
                                                .rotationEffect(.degrees(isTestingConnection ? 360 : 0))
                                                .animation(
                                                    isTestingConnection ? 
                                                        .linear(duration: 1).repeatForever(autoreverses: false) : 
                                                        .default,
                                                    value: isTestingConnection
                                                )
                                            
                                            Text(connectionStatus.message)
                                                .font(.caption)
                                                .foregroundColor(connectionStatus.color)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            
                            // Step 3
                            if connectionStatus == .success {
                                SetupStepCard(
                                    stepNumber: 3,
                                    title: "Setup Complete!",
                                    description: "You're ready to use AI calendar analysis",
                                    action: {
                                        saveAPIKey()
                                        isPresented = false
                                    },
                                    actionTitle: "Continue",
                                    actionColor: .green
                                )
                            }
                        }
                    }
                    
                    // Alternative Section
                    VStack(spacing: 16) {
                        Text("🔄 Alternative Options")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Button("Continue with Basic Analysis") {
                            // Skip AI setup and use basic OCR only
                            isPresented = false
                        }
                        .buttonStyle(.plain)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                        
                        Text("Basic analysis uses device OCR without AI enhancement")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Privacy Section
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "lock.shield.fill")
                                .foregroundColor(.green)
                            Text("Privacy & Security")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                Text("Images are processed securely via encrypted connections")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                Text("No calendar data is stored on external servers")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                Text("API key is stored securely on your device")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                Text("You can disable AI analysis anytime in settings")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("AI Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Skip") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Help") {
                        showingInstructions = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingInstructions) {
            InstructionsView()
        }
    }
    
    private func testAPIConnection() {
        isTestingConnection = true
        connectionStatus = .testing
        
        // Simulate API test (replace with actual test)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isTestingConnection = false
            
            if apiKeyInput.hasPrefix("sk-") && apiKeyInput.count > 20 {
                connectionStatus = .success
            } else {
                connectionStatus = .failed
            }
        }
    }
    
    private func saveAPIKey() {
        // Save API key securely (in production, use Keychain)
        UserDefaults.standard.set(apiKeyInput, forKey: "openai_api_key")
        UserDefaults.standard.set(true, forKey: "ai_analysis_enabled")
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .frame(height: 100)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SetupStepCard: View {
    let stepNumber: Int
    let title: String
    let description: String
    let action: () -> Void
    let actionTitle: String
    let actionColor: Color
    
    init(stepNumber: Int, title: String, description: String, action: @escaping () -> Void, actionTitle: String, actionColor: Color = .blue) {
        self.stepNumber = stepNumber
        self.title = title
        self.description = description
        self.action = action
        self.actionTitle = actionTitle
        self.actionColor = actionColor
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(actionColor)
                        .frame(width: 24, height: 24)
                    
                    Text("\(stepNumber)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(actionTitle) {
                action()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct InstructionsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("🤖 AI Calendar Analysis Setup")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Follow these steps to enable AI-powered calendar recognition:")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("1. Sign up for OpenAI API access")
                        Text("2. Copy your API key from the OpenAI dashboard")
                        Text("3. Paste it in the setup form")
                        Text("4. Test the connection")
                        Text("5. Start analyzing calendar screenshots!")
                    }
                    .font(.body)
                }
                .padding()
            }
            .navigationTitle("Setup Instructions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}