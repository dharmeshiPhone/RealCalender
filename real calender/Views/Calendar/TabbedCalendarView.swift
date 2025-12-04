import SwiftUI

struct TabbedCalendarView: View {
    @Binding var events: [CalendarEvent]
    @State private var selectedDate = Date()
    @StateObject private var streakManager = StreakManager()
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @EnvironmentObject var aiChatManager: AIChatManager
    @EnvironmentObject var achievementManager: AchievementManager
    @EnvironmentObject var questManager: QuestManager
    
    var body: some View {
        NavigationView {
            // Back to the original Dashboard - Analytics, Conflicts, and Insights are now in CalendarReviewView
            GamifiedCalendarDashboard(
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
                    if streakManager.shouldShowPopup {
                        StreakPopupView(
                            isPresented: .constant(streakManager.shouldShowPopup),
                            streakCount: streakManager.currentStreak,
                            previousStreak: max(0, streakManager.currentStreak - 1)
                        ) {
                            streakManager.markPopupShown()
                        }
                        
                    }
                }
            )
        }
    }
}
