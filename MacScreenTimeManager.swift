// MacScreenTimeManager.swift - macOS Companion App
import Foundation
import Network
import FamilyControls

class MacScreenTimeManager {
    private let listener: NWListener?
    private let port: NWEndpoint.Port = 8080
    
    init() {
        self.listener = nil
        startListener()
    }
    
    private func startListener() {
        do {
            let parameters = NWParameters.tcp
            parameters.allowLocalEndpointReuse = true
            
            listener = try NWListener(using: parameters, on: port)
            
            listener?.newConnectionHandler = { [weak self] connection in
                self?.handleConnection(connection)
            }
            
            listener?.stateUpdateHandler = { [weak self] state in
                switch state {
                case .ready:
                    print("📡 Mac Screen Time Manager listening on port \(self?.port ?? 0)")
                case .failed(let error):
                    print("❌ Mac Screen Time Manager failed: \(error)")
                    // Attempt to restart after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self?.startListener()
                    }
                default:
                    break
                }
            }
            
            listener?.start(queue: .main)
            
        } catch {
            print("❌ Failed to start Mac Screen Time Manager listener: \(error)")
            // Attempt to restart after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.startListener()
            }
        }
    }
    
    private func handleConnection(_ connection: NWConnection) {
        connection.start(queue: .main)
        
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1024) { data, _, isComplete, error in
            if let data = data, !data.isEmpty {
                self.processCommand(data, connection: connection)
            }
            
            if isComplete {
                connection.cancel()
            }
        }
    }
    
    private func processCommand(_ data: Data, connection: NWConnection) {
        do {
            let command = try JSONDecoder().decode(ScreenTimeCommand.self, from: data)
            
            switch command.action {
            case .requestAuthorization:
                requestScreenTimeAccess()
            case .grantAccess:
                grantScreenTimeAccess()
            case .getStatus:
                sendAuthStatus(connection: connection)
            case .enableAppBlocking:
                enableAppBlocking()
            }
            
        } catch {
            print("❌ Failed to decode command: \(error)")
        }
    }
    
    private func requestScreenTimeAccess() {
        print("🔐 Requesting Screen Time access...")
        
        // On macOS, Screen Time access is managed through System Preferences
        let script = """
        tell application "System Preferences"
            activate
            reveal pane "com.apple.preference.screentime"
        end tell
        """
        
        let appleScript = NSAppleScript(source: script)
        appleScript?.executeAndReturnError(nil)
    }
    
    private func grantScreenTimeAccess() {
        print("✅ Granting Screen Time access...")
        
        // This would typically involve:
        // 1. Opening System Preferences
        // 2. Navigating to Screen Time
        // 3. Enabling app restrictions
        
        let center = AuthorizationCenter.shared
        
        Task {
            do {
                try await center.requestAuthorization(for: .child)
                print("✅ Screen Time authorization granted")
            } catch {
                print("❌ Failed to get authorization: \(error)")
            }
        }
    }
    
    private func sendAuthStatus(connection: NWConnection) {
        let center = AuthorizationCenter.shared
        let isAuthorized = center.authorizationStatus == .approved
        
        let response = ScreenTimeResponse(
            success: true,
            isAuthorized: isAuthorized,
            message: isAuthorized ? "Screen Time access granted" : "Screen Time access needed"
        )
        
        do {
            let data = try JSONEncoder().encode(response)
            connection.send(content: data, completion: .contentProcessed { _ in
                connection.cancel()
            })
        } catch {
            print("❌ Failed to send response: \(error)")
        }
    }
    
    private func enableAppBlocking() {
        print("🚫 Enabling app blocking...")
        
        // This would set up the actual app blocking using ManagedSettings
        // For security reasons, this typically requires user interaction
    }
}

// MARK: - Data Models

struct ScreenTimeCommand: Codable {
    enum Action: String, Codable {
        case requestAuthorization = "request_auth"
        case grantAccess = "grant_access"
        case getStatus = "get_status"
        case enableAppBlocking = "enable_blocking"
    }
    
    let action: Action
    let parameters: [String: String]?
}

struct ScreenTimeResponse: Codable {
    let success: Bool
    let isAuthorized: Bool
    let message: String
}