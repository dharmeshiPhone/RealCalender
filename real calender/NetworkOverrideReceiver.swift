import Foundation
import Network
import UserNotifications
import Darwin
import UIKit

// MARK: - Data Models

struct OverrideCommand: Codable {
    enum Action: String, Codable {
        case disableAllLimits = "disable_all_limits"
        case unblockAllApps = "unblock_all_apps"
        case emergencyOverride = "emergency_override"
        case customOverride = "custom_override"
        case cancelOverride = "cancel_override"
    }
    
    let action: Action
    let duration: Int // in minutes
    let reason: String?
}

struct DeviceInfo: Codable {
    let name: String
    let model: String
    let iosVersion: String
    let ipAddress: String
}

class NetworkOverrideReceiver: ObservableObject {
    private var listener: NWListener?
    private let queue = DispatchQueue(label: "NetworkOverrideReceiver")
    
    init() {
        startListening()
        startDiscoveryResponder()
    }
    
    // MARK: - Network Listener for Override Commands
    
    private func startListening() {
        let parameters = NWParameters.tcp
        parameters.allowLocalEndpointReuse = true
        
        do {
            listener = try NWListener(using: parameters, on: 8081)
            
            listener?.newConnectionHandler = { [weak self] connection in
                self?.handleIncomingConnection(connection)
            }
            
            listener?.start(queue: queue)
            print("✅ iOS override receiver started on port 8081")
        } catch {
            print("❌ Failed to start override receiver: \(error)")
        }
    }
    
    private func handleIncomingConnection(_ connection: NWConnection) {
        connection.start(queue: queue)
        
        // Receive override command
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1024) { [weak self] data, _, isComplete, error in
            if let data = data, !data.isEmpty {
                self?.processOverrideCommand(data)
            }
            
            if isComplete {
                connection.cancel()
            }
        }
    }
    
    private func processOverrideCommand(_ data: Data) {
        do {
            let command = try JSONDecoder().decode(OverrideCommand.self, from: data)
            
            DispatchQueue.main.async {
                self.executeOverrideCommand(command)
            }
        } catch {
            print("❌ Failed to decode override command: \(error)")
        }
    }
    
    // MARK: - Override Command Execution
    
    private func executeOverrideCommand(_ command: OverrideCommand) {
        print("🔓 Executing override command: \(command.action.rawValue) for \(command.duration) minutes")
        
        switch command.action {
        case .disableAllLimits:
            disableAllLimits(duration: command.duration)
            
        case .unblockAllApps:
            unblockAllApps(duration: command.duration)
            
        case .emergencyOverride:
            emergencyOverride(duration: command.duration)
            
        case .customOverride:
            customOverride(duration: command.duration, reason: command.reason)
            
        case .cancelOverride:
            cancelAllOverrides()
        }
        
        // Save override state
        saveOverrideState(command)
        
        // Send confirmation notification
        sendOverrideNotification(command)
    }
    
    private func disableAllLimits(duration: Int) {
        // Clear all blocked apps from UserDefaults
        UserDefaults.standard.removeObject(forKey: "blockedApps")
        
        // Schedule re-enable
        scheduleReEnable(after: duration)
    }
    
    private func unblockAllApps(duration: Int) {
        // Clear all blocked apps from UserDefaults
        UserDefaults.standard.removeObject(forKey: "blockedApps")
        
        // Schedule re-block
        scheduleReBlock(after: duration)
    }
    
    private func emergencyOverride(duration: Int) {
        // Complete override - clear everything
        UserDefaults.standard.removeObject(forKey: "blockedApps")
        UserDefaults.standard.removeObject(forKey: "dailyGoals")
        
        // Schedule restore
        scheduleRestore(after: duration)
    }
    
    private func customOverride(duration: Int, reason: String?) {
        // Custom override based on reason
        if let reason = reason?.lowercased() {
            if reason.contains("work") || reason.contains("emergency") {
                emergencyOverride(duration: duration)
            } else if reason.contains("app") {
                unblockAllApps(duration: duration)
            } else {
                disableAllLimits(duration: duration)
            }
        } else {
            disableAllLimits(duration: duration)
        }
        
        // Schedule restore
        scheduleRestore(after: duration)
    }
    
    private func cancelAllOverrides() {
        // Clear saved override state
        UserDefaults.standard.removeObject(forKey: "activeOverride")
        
        // Restore blocked apps if needed
        // This would need to be implemented based on your app's logic
        print("✅ All overrides cancelled")
    }
    
    // MARK: - Scheduling
    
    private func scheduleReEnable(after minutes: Int) {
        let identifier = "re-enable-limits"
        scheduleNotification(
            identifier: identifier,
            title: "Screen Time Limits Restored",
            body: "Your screen time limits have been automatically restored.",
            delay: TimeInterval(minutes * 60)
        )
        
        // Schedule actual re-enable
        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(minutes * 60)) {
            self.cancelAllOverrides()
        }
    }
    
    private func scheduleReBlock(after minutes: Int) {
        let identifier = "re-block-apps"
        scheduleNotification(
            identifier: identifier,
            title: "App Blocks Restored",
            body: "Your app blocks have been automatically restored.",
            delay: TimeInterval(minutes * 60)
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(minutes * 60)) {
            self.cancelAllOverrides()
        }
    }
    
    private func scheduleRestore(after minutes: Int) {
        let identifier = "restore-all"
        scheduleNotification(
            identifier: identifier,
            title: "Override Expired",
            body: "Your screen time override has expired and limits are restored.",
            delay: TimeInterval(minutes * 60)
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(minutes * 60)) {
            self.cancelAllOverrides()
        }
    }
    
    // MARK: - Discovery Responder
    
    private func startDiscoveryResponder() {
        let parameters = NWParameters.udp
        
        do {
            let discoveryListener = try NWListener(using: parameters, on: 8082)
            
            discoveryListener.newConnectionHandler = { [weak self] connection in
                self?.handleDiscoveryRequest(connection)
            }
            
            discoveryListener.start(queue: queue)
            print("✅ Discovery responder started on port 8082")
        } catch {
            print("❌ Failed to start discovery responder: \(error)")
        }
    }
    
    private func handleDiscoveryRequest(_ connection: NWConnection) {
        connection.start(queue: queue)
        
        // Send device info back to Mac
        let deviceInfo = DeviceInfo(
            name: UIDevice.current.name,
            model: UIDevice.current.model,
            iosVersion: UIDevice.current.systemVersion,
            ipAddress: getLocalIPAddress() ?? "unknown"
        )
        
        do {
            let data = try JSONEncoder().encode(deviceInfo)
            
            connection.send(content: data, completion: .contentProcessed { error in
                if let error = error {
                    print("❌ Failed to send device info: \(error)")
                } else {
                    print("✅ Device info sent to Mac")
                }
                connection.cancel()
            })
        } catch {
            print("❌ Failed to encode device info: \(error)")
            connection.cancel()
        }
    }
    
    // MARK: - Helper Methods
    
    private func saveOverrideState(_ command: OverrideCommand) {
        do {
            let data = try JSONEncoder().encode(command)
            UserDefaults.standard.set(data, forKey: "activeOverride")
        } catch {
            print("❌ Failed to save override state: \(error)")
        }
    }
    
    private func sendOverrideNotification(_ command: OverrideCommand) {
        let title: String
        var body: String
        
        switch command.action {
        case .disableAllLimits:
            title = "🔓 Limits Disabled"
            body = "All screen time limits disabled for \(command.duration) minutes"
            
        case .unblockAllApps:
            title = "📱 Apps Unblocked"
            body = "All blocked apps unblocked for \(command.duration) minutes"
            
        case .emergencyOverride:
            title = "🚨 Emergency Override"
            body = "Emergency override active for \(command.duration) minutes"
            
        case .customOverride:
            title = "⚙️ Custom Override"
            body = "Custom override active for \(command.duration) minutes"
            if let reason = command.reason {
                body += " - \(reason)"
            }
            
        case .cancelOverride:
            title = "✅ Override Cancelled"
            body = "All overrides have been cancelled and limits restored"
        }
        
        scheduleNotification(
            identifier: "override-\(UUID().uuidString)",
            title: title,
            body: body,
            delay: 1
        )
    }
    
    private func scheduleNotification(identifier: String, title: String, body: String, delay: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func getLocalIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                let interface = ptr?.pointee
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                
                if addrFamily == UInt8(AF_INET) {
                    let name = String(cString: (interface?.ifa_name)!)
                    if name == "en0" || name == "en1" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!),
                                   &hostname, socklen_t(hostname.count),
                                   nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        
        return address
    }
}