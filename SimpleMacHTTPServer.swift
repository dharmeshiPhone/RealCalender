// SimpleMacHTTPServer.swift - HTTP-based Mac Server for iOS compatibility
import Foundation
import Network

print("🖥️ Starting Mac Screen Time HTTP Server...")

let listener: NWListener
let port: NWEndpoint.Port = 8081

do {
    let parameters = NWParameters.tcp
    parameters.allowLocalEndpointReuse = true
    
    listener = try NWListener(using: parameters, on: port)
    print("✅ Created HTTP listener on port \(port)")
    
    listener.newConnectionHandler = { connection in
        print("📱 New HTTP connection from iOS!")
        
        connection.start(queue: .main)
        
        // Handle HTTP request
        connection.receive(minimumIncompleteLength: 1, maximumLength: 2048) { data, _, _, error in
            if let error = error {
                print("❌ Receive error: \(error)")
                return
            }
            
            if let data = data, let requestString = String(data: data, encoding: .utf8) {
                print("📨 Received HTTP request: \(requestString.prefix(100))")
                
                // Parse simple HTTP request
                let lines = requestString.components(separatedBy: "\r\n")
                if let firstLine = lines.first, firstLine.contains("POST") {
                    
                    // Find the JSON body
                    if let bodyStart = requestString.range(of: "\r\n\r\n") {
                        let body = String(requestString[bodyStart.upperBound...])
                        
                        // Try to decode the command
                        if let bodyData = body.data(using: .utf8),
                           let command = try? JSONDecoder().decode(MacScreenTimeCommand.self, from: bodyData) {
                            print("📋 Command: \(command.action)")
                            
                            let response = MacScreenTimeResponse(
                                success: true,
                                isAuthorized: false,
                                message: "Mac Screen Time Manager received your request! Please configure Screen Time manually in System Preferences."
                            )
                            
                            if let responseData = try? JSONEncoder().encode(response) {
                                let httpResponse = """
                                HTTP/1.1 200 OK\r
                                Content-Type: application/json\r
                                Content-Length: \(responseData.count)\r
                                Access-Control-Allow-Origin: *\r
                                \r
                                \(String(data: responseData, encoding: .utf8) ?? "")
                                """
                                
                                connection.send(content: httpResponse.data(using: .utf8), completion: .contentProcessed { _ in
                                    print("✅ Sent HTTP response")
                                    connection.cancel()
                                })
                            }
                        }
                    }
                } else {
                    // Handle OPTIONS request for CORS
                    let httpResponse = """
                    HTTP/1.1 200 OK\r
                    Access-Control-Allow-Origin: *\r
                    Access-Control-Allow-Methods: POST, GET, OPTIONS\r
                    Access-Control-Allow-Headers: Content-Type\r
                    \r
                    
                    """
                    
                    connection.send(content: httpResponse.data(using: .utf8), completion: .contentProcessed { _ in
                        print("✅ Sent CORS response")
                        connection.cancel()
                    })
                }
            }
        }
    }
    
    listener.stateUpdateHandler = { state in
        switch state {
        case .ready:
            print("🎉 HTTP Server is ready and listening on port \(port)")
            print("🎉 Ready to accept HTTP connections from iOS simulator")
        case .failed(let error):
            print("❌ Server failed: \(error)")
        case .cancelled:
            print("🛑 Server cancelled")
        default:
            print("🔄 Server state: \(state)")
        }
    }
    
    listener.start(queue: .main)
    print("🚀 Starting HTTP server...")
    
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
print("⏳ HTTP Server running... Press Ctrl+C to stop")
RunLoop.main.run()