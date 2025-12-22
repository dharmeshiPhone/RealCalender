import SwiftUI

//struct TabbedCalendarView: View {
//    @Binding var events: [CalendarEvent]
//    @State private var selectedDate = Date()
//    @StateObject private var streakManager = StreakManager()
//    @EnvironmentObject var screenTimeManager: ScreenTimeManager
//    @EnvironmentObject var aiChatManager: AIChatManager
//    @EnvironmentObject var achievementManager: AchievementManager
//    @EnvironmentObject var questManager: QuestManager
//
//    // Add state for commitment popup
//    @AppStorage("hasShownCommitmentPopup") private var hasShownCommitmentPopup = false
//    @State private var showCommitmentPopup = false
//
//    var body: some View {
//        NavigationView {
//            // Back to the original Dashboard - Analytics, Conflicts, and Insights are now in CalendarReviewView
//            GamifiedCalendarDashboard(
//                streakManager:streakManager, events: $events,
//                selectedDate: $selectedDate
//            )
//            .environmentObject(screenTimeManager)
//            .environmentObject(aiChatManager)
//            .environmentObject(achievementManager)
//            .navigationTitle("Dashboard")
//            .navigationBarTitleDisplayMode(.inline)
//            .overlay(
//                Group {
//
//                    // Commitment Popup - shown once when first starting
//                    if !hasShownCommitmentPopup && showCommitmentPopup {
//                        CommitmentPopupView(
//                            isPresented: $showCommitmentPopup,
//                            onCommit: {
//                                hasShownCommitmentPopup = true
//                            }
//                        )
//                    }
//
//                    if streakManager.shouldShowPopup {
//                        StreakPopupView(
//                            isPresented: .constant(streakManager.shouldShowPopup),
//                            streakCount: streakManager.currentStreak,
//                            previousStreak: max(0, streakManager.currentStreak - 1)
//                        ) {
//                            streakManager.markPopupShown()
//                        }
//                    }
//                }
//            )
//            .onAppear {
//                if !hasShownCommitmentPopup {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                        withAnimation(.easeInOut){
//                            showCommitmentPopup = true
//                        }
//                    }
//                }
//            }
//        }
//    }
//}


struct TabbedCalendarView: View {
    @Binding var events: [CalendarEvent]
    @Binding var userProfile: UserProfile
    @State private var selectedDate = Date()
    @StateObject private var streakManager = StreakManager()
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @EnvironmentObject var aiChatManager: AIChatManager
    @EnvironmentObject var achievementManager: AchievementManager
    @EnvironmentObject var questManager: QuestManager
    
    // Add state for commitment popup
    @AppStorage("hasShownCommitmentPopup") private var hasShownCommitmentPopup = false
    @State private var showCommitmentPopup = false
    
    // State for active popup
    @State private var activeSaverPrice: Int = 0
    @State private var activeSaverTitle: String = ""
    @State private var activeSaverMessage: String = ""
    
    var body: some View {
        NavigationView {
            GamifiedCalendarDashboard(
                streakManager: streakManager,
                events: $events,
                selectedDate: $selectedDate
            )
            .environmentObject(screenTimeManager)
            .environmentObject(aiChatManager)
            .environmentObject(achievementManager)
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(
                Group {
                    // Commitment Popup - shown once when first starting
                    if !hasShownCommitmentPopup && showCommitmentPopup {
                        CommitmentPopupView(
                            isPresented: $showCommitmentPopup,
                            onCommit: {
                                hasShownCommitmentPopup = true
                            }
                        )
                    }
                    
                    // Welcome Back Popup (NEW)
                    if streakManager.shouldShowWelcomeBackPopup {
                        WelcomeBackPopupView(
                            isPresented: .constant(streakManager.shouldShowWelcomeBackPopup),
                            onClaim: {
                                // Apply the 50% happiness restore here
                                // Example: userProfile.petHappiness = min(100, userProfile.petHappiness + 50)
                                // userProfile.save()
                                
                                streakManager.claimWelcomeBackGift()
                            }
                        )
                    }
                    
                    // Streak Freeze Popup
                    if streakManager.shouldShowFreezePopup {
                        StreakFrozenPopupView(
                            isPresented: .constant(streakManager.shouldShowFreezePopup),
                            onContinue: {
                                streakManager.markPopupShown()
                            }
                        )
                    }
                    
                    // Streak Saver Offer Popups
                    if streakManager.shouldShowSaverPopup {
                        if streakManager.currentStreak == 7 {
                            StreakSaverPopupView(
                                isPresented: .constant(streakManager.shouldShowSaverPopup),
                                title: "Protect Your Streak 🔥",
                                message: "You're 7 days in — great job! Want a safety net? Get a Streak Saver for 200 coins to restore your streak if you miss a day.",
                                price: 200,
                                onBuy: {
                                    if userProfile.coins >= 200{
                                        streakManager.buybuyStreakSaver()
                                        userProfile.coins -= 200
                                        userProfile.save()
                                        streakManager.markPopupShown()
                                    }
                                },
                                onSkip: {
                                    streakManager.markPopupShown()
                                }
                            )
                        } else if streakManager.currentStreak == 30 {
                            StreakSaverPopupView(
                                isPresented: .constant(streakManager.shouldShowSaverPopup),
                                title: "You're on Fire 🔥",
                                message: "30 days of commitment is powerful. Protect your progress with a Streak Saver for 500 coins — because momentum matters.",
                                price: 500,
                                onBuy: {
                                    if userProfile.coins >= 500{
                                        streakManager.buybuyStreakSaver()
                                        userProfile.coins -= 500
                                        userProfile.save()
                                        streakManager.markPopupShown()
                                    }
                                },
                                onSkip: {
                                    streakManager.markPopupShown()
                                }
                            )
                        }
                    }
                    
                    // Regular Streak Popup
                    if streakManager.shouldShowStreakPopup {
                        StreakPopupView(
                            isPresented: .constant(streakManager.shouldShowStreakPopup),
                            streakCount: streakManager.currentStreak,
                            previousStreak: max(0, streakManager.currentStreak - 1)
                        ) {
                            streakManager.markPopupShown()
                        }
                    }
                }
            )
            .onAppear {
                if !hasShownCommitmentPopup {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeInOut) {
                            showCommitmentPopup = true
                        }
                    }
                }
            }
        }
    }
}




