import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    // Create shared instances
    private let screenTimeManager = ScreenTimeManager()
    private let aiChatManager = AIChatManager()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let contentView = ContentView()
            .environmentObject(screenTimeManager)
            .environmentObject(aiChatManager)

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
            
            // Set up keyboard shortcuts
            setupKeyboardShortcuts()
        }
        
        // Handle URL schemes if app opened via URL
        for urlContext in connectionOptions.urlContexts {
            handleURLScheme(urlContext.url)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        NotificationCenter.default.post(name: Notification.Name("appWillEnterForeground"), object: nil)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
    
    // MARK: - URL Handling
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for urlContext in URLContexts {
            handleURLScheme(urlContext.url)
        }
    }
    
    private func handleURLScheme(_ url: URL) {
        if url.scheme == "realcalendar" {
            NotificationCenter.default.post(
                name: Notification.Name("shortcutURLReceived"),
                object: nil,
                userInfo: ["url": url]
            )
        }
    }
    
    // MARK: - Keyboard Shortcuts Setup
    private func setupKeyboardShortcuts() {
        #if DEBUG
        // For debug builds, we'll use NotificationCenter instead of UIKeyCommand
        // since UIKeyCommand on UIHostingController has limitations
        print("🔄 Debug keyboard shortcuts available via 5-tap gesture")
        #endif
    }
    
    @objc func handleResetAppShortcut() {
        #if DEBUG
        print("🔄 Reset app shortcut triggered - Resetting app data and restarting...")
        
        // Trigger haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        // Post notification to reset app data
        NotificationCenter.default.post(name: NSNotification.Name("DevResetApp"), object: nil)
        
        // Small delay then restart the scene
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.restartApp()
        }
        #endif
    }
    
    private func restartApp() {
        #if DEBUG
        print("🚀 Restarting app...")
        
        // Create a new content view with fresh state
        let contentView = ContentView()
            .environmentObject(screenTimeManager)
            .environmentObject(aiChatManager)
        
        // Replace the root view controller
        if let window = self.window {
            let newHostingController = UIHostingController(rootView: contentView)
            
            // Animate the transition
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.rootViewController = newHostingController
            }, completion: nil)
        }
        #endif
    }
}

// MARK: - SceneDelegate Singleton Access
extension SceneDelegate {
    static var shared: SceneDelegate {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let delegate = windowScene.delegate as? SceneDelegate else {
            fatalError("SceneDelegate not found")
        }
        return delegate
    }
}