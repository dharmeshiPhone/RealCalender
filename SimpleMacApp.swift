// SimpleMacApp.swift - Minimal Mac Server
import Foundation
import Network

print("🖥️ Starting Mac Screen Time Server...")

let listener: NWListener
let port: NWEndpoint.Port = 8081

do {
    let parameters = NWParameters.tcp
    parameters.allowLocalEndpointReuse = true
    
    // Bind specifically to localhost IPv4 for iOS simulator compatibility
    let host = NWEndpoint.Host("127.0.0.1")
    let endpoint = NWEndpoint.hostPort(host: host, port: port)
    
    listener = try NWListener(using: parameters, on: endpoint)
    print("✅ Created listener on port \(port) (127.0.0.1)")
    
    listener.newConnectionHandler = { connection in
        print("📱 New connection from iOS!")
        print("📱 Connection from: \(connection.endpoint)")
        
        connection.start(queue: .main)
        
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1024) { data, _, _, error in
            if let error = error {
                print("❌ Receive error: \(error)")
                return
            }
            
            if let data = data {
                print("📨 Received data: \(data.count) bytes")
                
                // Try to decode the command
                do {
                    let command = try JSONDecoder().decode(MacScreenTimeCommand.self, from: data)
                    print("📋 Command: \(command.action)")
                    
                    let response = MacScreenTimeResponse(
                        success: true,
                        isAuthorized: false,
                        message: "Mac Screen Time Manager received your request! Please configure Screen Time manually in System Preferences."
                    )
                    
                    let responseData = try JSONEncoder().encode(response)
                    connection.send(content: responseData, completion: .contentProcessed { _ in
                        print("✅ Sent response")
                        connection.cancel()
                    })
                    
                } catch {
                    print("❌ Failed to decode command: \(error)")
                    
                    // Send simple response
                    let response = MacScreenTimeResponse(
                        success: false,
                        isAuthorized: false,
                        message: "Error processing command"
                    )
                    
                    if let responseData = try? JSONEncoder().encode(response) {
                        connection.send(content: responseData, completion: .contentProcessed { _ in
                            connection.cancel()
                        })
                    }
                }
            }
        }
    }
    
    listener.stateUpdateHandler = { state in
        switch state {
        case .ready:
            print("🎉 Server is ready and listening on 127.0.0.1:\(port)")
            print("🎉 Ready to accept connections from iOS simulator")
        case .failed(let error):
            print("❌ Server failed: \(error)")
        case .cancelled:
            print("🛑 Server cancelled")
        default:
            print("🔄 Server state: \(state)")
        }
    }
    
    listener.start(queue: .main)
    print("🚀 Starting server...")
    
} catch {
    print("❌ Failed to create server: \(error)")
    exit(1)
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

// Keep the app running
print("⏳ Server running... Press Ctrl+C to stop")
RunLoop.main.run()