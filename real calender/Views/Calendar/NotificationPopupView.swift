//
//  NotificationPopupView.swift
//  real calender
//
//  Created by Mac on 27/11/25.
//

import SwiftUI

struct NotificationPopupView: View {
    var onEnable: () -> Void
    var onSkip: () -> Void

    var body: some View {
        ZStack {
            // Dim background
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                
                Image(systemName: "bell.fill") // your illustration
                    .resizable()
                    .scaledToFit()
                    .frame(height: 140)

                Text("Stay on Track!")
                    .font(.system(size: 24, weight: .bold))

                Text("Enable notifications to complete your Day 2 quest and never miss rewards.")
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                Button(action: {
                    requestNotificationPermission { granted in
                        if granted {
                            print("✅ Notification permission granted")
                            onEnable()
                        } else {
                            print("❌ Notification permission denied")
                            onSkip()
                        }
                    }

                   
                }) {
                    Text("Enable Notifications")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(14)
                }
                .padding(.horizontal)

//                Button(action: onSkip) {
//                    Text("Not Now")
//                        .font(.system(size: 16, weight: .regular))
//                        .foregroundColor(.blue)
//                }

            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.black)
                    .shadow(radius: 20)
            )
            .padding(.horizontal, 30)
        }
    }
    
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()

        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {

            case .notDetermined:
                // First time: Show permission alert
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if granted {
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                        completion(true)
                    } else {
                        completion(false)
                    }
                }

            case .denied:
                completion(false)

            case .authorized, .provisional, .ephemeral:
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                completion(true)

            @unknown default:
                completion(false)
            }
        }
    }


}

