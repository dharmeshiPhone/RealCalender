import SwiftUI

struct TabbedCalendarView: View {
    @Binding var events: [CalendarEvent]
    @State private var selectedDate = Date()
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @EnvironmentObject var aiChatManager: AIChatManager
    @EnvironmentObject var achievementManager: AchievementManager
    
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
        }
    }
}
