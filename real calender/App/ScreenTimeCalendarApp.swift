import SwiftUI
import UserNotifications
import CoreLocation
// import FamilyControls - DISABLED

@main
struct ScreenTimeCalendarApp: App {
    @StateObject private var screenTimeManager = ScreenTimeManager()
    @StateObject private var aiChatManager = AIChatManager()
    @StateObject private var achievementManager = AchievementManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(screenTimeManager)
                    .environmentObject(aiChatManager)
                    .environmentObject(achievementManager)
                    .onAppear {
                        setupKeyboardShortcuts()
                    }
            }
            .preferredColorScheme(.dark)
           
        }
        .commands {
            #if DEBUG
            CommandGroup(replacing: .newItem) {
                Button("🔄 Reset App & Restart") {
                    performCompleteAppReset()
                }
                .keyboardShortcut("q", modifiers: .command)
            }
            #endif
        }
    }
    
    private func setupKeyboardShortcuts() {
        #if DEBUG
        print("⌨️ Keyboard shortcuts set up")
        print("   • Cmd+Q: Reset app data and restart")
        print("   • 5-tap gesture: Emergency reset (on screen)")
        #endif
    }
    
 
    
    
    // Deprecated function - kept for compatibility but enhanced above
    private func resetAppData() {
        #if DEBUG
        print("⚠️ Using deprecated resetAppData - use performCompleteAppReset instead")
        performCompleteAppReset()
        #endif
    }
}
