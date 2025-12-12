//
//  LocalNotificationManager.swift
//  Whiskers
//
//  Created by Mac on 29/11/25.
//

import Foundation
import UserNotifications
import UIKit

final class LocalNotificationManager {
    static let shared = LocalNotificationManager()
    private init() {}

    func requestAuthorizationIfNeeded() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                return granted
            } catch {
                return false
            }
        @unknown default:
            return false
        }
    }
    
    func openNotificationSettings() {
        if let url = URL(string: UIApplication.openNotificationSettingsURLString),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let url = URL(string: UIApplication.openSettingsURLString),
                  UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Pet Happiness Notifications
    func schedulePetHappinessNotifications(
        petName: String
    ) async {
        
        // 1. Check last fired timestamp
        let lastFired = UserDefaults.standard.object(forKey: "petHappinessLastNotification") as? Date
        
        if let lastFired = lastFired {
            let diff = Date().timeIntervalSince(lastFired)
            if diff < 1800 { // 1800 seconds = 30 minutes
                print("⏳ Notification cooldown active. Will not fire again yet.")
                return
            }
        }

        let _ = await requestAuthorizationIfNeeded()
        let center = UNUserNotificationCenter.current()

        var messages: [String] = []

        messages.append("\(petName) is hungry! 🍖 please complete quests.")

        // If nothing to notify, skip
        guard messages.isEmpty == false else { return }

        // send one notification per message
        for (index, msg) in messages.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "Your pet needs attention!"
            content.body = msg
            content.sound = .default

            if #available(iOS 15.0, *) {
                content.interruptionLevel = .timeSensitive
            }

            // Fire after a short delay (you can change to 5 sec, 10 sec, etc.)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3 + Double(index), repeats: false)

            let request = UNNotificationRequest(
                identifier: "pet.happiness.\(UUID())",
                content: content,
                trigger: trigger
            )

            try? await center.add(request)
        }
    }


    
}

