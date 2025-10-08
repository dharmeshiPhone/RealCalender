import SwiftUI

struct ScheduleView: View {
    @Binding var events: [CalendarEvent]
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @EnvironmentObject var aiChatManager: AIChatManager
    @EnvironmentObject var achievementManager: AchievementManager
    @State private var selectedDate = Date()
    @State private var showingAddEvent = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Zoomable Calendar with tap/zoom functionality
                ZoomableCalendarView(
                    events: events
                )
                
                // Quick actions at bottom
                quickActionsSection
                    .padding(.horizontal)
                    .padding(.bottom)
            }
            .navigationTitle("Schedule")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddEvent = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventView(
                    selectedDate: selectedDate,
                    events: $events,
                    isPresented: $showingAddEvent
                )
                    .environmentObject(aiChatManager)
            }
        }
    }
    
    @ViewBuilder
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.yellow)
                Text("Quick Actions")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }  
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                SharedQuickActionButton(
                    title: "Add Event",
                    icon: "plus.circle.fill",
                    color: .blue
                ) {
                    showingAddEvent = true
                }
                
                SharedQuickActionButton(
                    title: "View Today",
                    icon: "calendar.day.timeline.leading",
                    color: .green
                ) {
                    selectedDate = Date()
                }
                
                SharedQuickActionButton(
                    title: "AI Assistant",
                    icon: "brain.head.profile",
                    color: .purple
                ) {
                    // Navigate to AI chat
                }
                
                SharedQuickActionButton(
                    title: "Optimize Schedule",
                    icon: "arrow.triangle.2.circlepath",
                    color: .orange
                ) {
                    // Trigger schedule optimization
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    ScheduleView(events: .constant([]))
        .environmentObject(ScreenTimeManager())
        .environmentObject(AIChatManager())
        .environmentObject(AchievementManager())
}