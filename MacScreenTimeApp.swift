// MacScreenTimeApp.swift - Simple Mac App
import Cocoa
import Foundation
import Network

class MacScreenTimeApp: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var screenTimeManager: MacScreenTimeManager?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("🖥️ Mac Screen Time App Started")
        
        // Create menu bar item
        setupMenuBar()
        
        // Start screen time manager
        screenTimeManager = MacScreenTimeManager()
        
        // Keep app running
        NSApp.setActivationPolicy(.accessory)
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.title = "📱"
            button.toolTip = "Screen Time Manager"
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Status: Starting...", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Open Screen Time", action: #selector(openScreenTime), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    func updateStatus(_ status: String) {
        DispatchQueue.main.async {
            if let menu = self.statusItem?.menu {
                menu.item(at: 0)?.title = "Status: \(status)"
            }
        }
    }
    
    @objc private func openScreenTime() {
        let script = """
        tell application "System Preferences"
            activate
            reveal pane "com.apple.preference.screentime"
        end tell
        """
        
        let appleScript = NSAppleScript(source: script)
        appleScript?.executeAndReturnError(nil)
    }
    
    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}

// MARK: - Screen Time Manager

class MacScreenTimeManager {
    private var listener: NWListener?
    private let port: NWEndpoint.Port = 8080
    weak var app: MacScreenTimeApp?
    
    init() {
        // Get reference to app delegate
        if let appDelegate = NSApp.delegate as? MacScreenTimeApp {
            self.app = appDelegate
        }
        
        setupListener()
    }
    
    private func setupListener() {
        do {
            let parameters = NWParameters.tcp
            parameters.allowLocalEndpointReuse = true
            
            listener = try NWListener(using: parameters, on: port)
            
            listener?.newConnectionHandler = { [weak self] connection in
                print("📱 New iOS connection")
                self?.handleConnection(connection)
            }
            
            listener?.stateUpdateHandler = { [weak self] state in
                DispatchQueue.main.async {
                    switch state {
                    case .ready:
                        print("🖥️ Successfully listening on port 8080")
                        self?.app?.updateStatus("Listening on port 8080")
                    case .failed(let error):
                        print("❌ Listener failed: \(error)")
                        self?.app?.updateStatus("Failed - \(error.localizedDescription)")
                        
                        // Try to restart listener after a delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self?.setupListener()
                        }
                    case .cancelled:
                        print("🛑 Listener cancelled")
                        self?.app?.updateStatus("Stopped")
                    default:
                        print("🔄 Listener state: \(state)")
                        self?.app?.updateStatus("Starting...")
                    }
                }
            }
            
            listener?.start(queue: .main)
            
        } catch {
            print("❌ Failed to create listener: \(error)")
            app?.updateStatus("Failed to start - \(error.localizedDescription)")
        }
    }
    
    private func handleConnection(_ connection: NWConnection) {
        print("🔗 Handling new connection")
        
        connection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("✅ Connection ready")
            case .failed(let error):
                print("❌ Connection failed: \(error)")
            case .cancelled:
                print("🛑 Connection cancelled")
            default:
                print("🔄 Connection state: \(state)")
            }
        }
        
        connection.start(queue: .main)
        
        // Receive data
        receiveData(from: connection)
    }
    
    private func receiveData(from connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1024) { [weak self] data, _, isComplete, error in
            if let error = error {
                print("❌ Receive error: \(error)")
                return
            }
            
            if let data = data, !data.isEmpty {
                print("📨 Received \(data.count) bytes")
                self?.processCommand(data, connection: connection)
            }
            
            if isComplete {
                print("✅ Connection complete")
                connection.cancel()
            } else {
                // Continue listening for more data
                self?.receiveData(from: connection)
            }
        }
    }
    
    private func processCommand(_ data: Data, connection: NWConnection) {
        do {
            let command = try JSONDecoder().decode(MacScreenTimeCommand.self, from: data)
            print("📨 Processing command: \(command.action)")
            
            let response: MacScreenTimeResponse
            
            switch command.action {
            case .requestAuthorization:
                response = MacScreenTimeResponse(
                    success: true,
                    isAuthorized: false,
                    message: "Screen Time authorization requested. Please configure in System Preferences."
                )
                
                // Open System Preferences
                DispatchQueue.main.async {
                    self.openSystemPreferences()
                }
                
            case .grantAccess:
                response = MacScreenTimeResponse(
                    success: true,
                    isAuthorized: false,
                    message: "Please grant Screen Time access manually in System Preferences."
                )
                
                DispatchQueue.main.async {
                    self.openSystemPreferences()
                }
                
            case .getStatus:
                response = MacScreenTimeResponse(
                    success: true,
                    isAuthorized: false,
                    message: "Mac Screen Time Manager is running. Manual configuration required."
                )
                
            case .enableAppBlocking:
                response = MacScreenTimeResponse(
                    success: true,
                    isAuthorized: false,
                    message: "App blocking setup requires manual configuration in System Preferences."
                )
                
                DispatchQueue.main.async {
                    self.openSystemPreferences()
                }
            }
            
            // Send response
            let responseData = try JSONEncoder().encode(response)
            connection.send(content: responseData, completion: .contentProcessed { error in
                if let error = error {
                    print("❌ Failed to send response: \(error)")
                } else {
                    print("✅ Response sent successfully")
                }
                connection.cancel()
            })
            
        } catch {
            print("❌ Error processing command: \(error)")
            
            // Send error response
            let errorResponse = MacScreenTimeResponse(
                success: false,
                isAuthorized: false,
                message: "Error processing command: \(error.localizedDescription)"
            )
            
            if let errorData = try? JSONEncoder().encode(errorResponse) {
                connection.send(content: errorData, completion: .contentProcessed { _ in
                    connection.cancel()
                })
            }
        }
    }
    
    private func openSystemPreferences() {
        let script = """
        tell application "System Preferences"
            activate
            reveal pane "com.apple.preference.screentime"
        end tell
        """
        
        let appleScript = NSAppleScript(source: script)
        var error: NSDictionary?
        appleScript?.executeAndReturnError(&error)
        
        if let error = error {
            print("❌ Failed to open System Preferences: \(error)")
        } else {
            print("✅ Opened System Preferences")
        }
    }
}

// MARK: - Data Models

struct MacScreenTimeCommand: Codable {
    enum Action: String, Codable {
        case requestAuthorization = "request_auth"
        case grantAccess = "grant_access"
        case getStatus = "get_status"
        case enableAppBlocking = "enable_blocking"
    }
    
    let action: Action
    let parameters: [String: String]?
}

struct MacScreenTimeResponse: Codable {
    let success: Bool
    let isAuthorized: Bool
    let message: String
}

// MARK: - Main Entry Point

let app = NSApplication.shared
let delegate = MacScreenTimeApp()
app.delegate = delegate
app.run()