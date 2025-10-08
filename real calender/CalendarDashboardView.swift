import SwiftUI
import Charts

struct CalendarDashboardView: View {
    @Binding var events: [CalendarEvent]
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @EnvironmentObject var achievementManager: AchievementManager
    
    // MARK: - Computed Properties
    private var hasData: Bool {
        return !events.isEmpty
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    
                    weeklyOverviewSection
                    
                    upcomingEventsSection
                    
                    quickActionsSection
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back!")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(hasData ? "Here's your schedule overview" : "Ready to start scheduling?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Profile avatar with level
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    VStack(spacing: 2) {
                        Image(systemName: "person.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text("Lv.1")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
            }
            
            // Today's date and progress
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(Date().formatted(date: .complete, time: .omitted))
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text(hasData ? "\(todaysEvents.count) events today" : "Add your first event to get started")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var weeklyOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Weekly Overview")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !hasData {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            
            if hasData {
                if #available(iOS 16.0, *) {
                    Chart {
                        ForEach(weeklyData, id: \.day) { data in
                            BarMark(
                                x: .value("Day", data.day),
                                y: .value("Events", data.count)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .cornerRadius(4)
                        }
                    }
                    .frame(height: 200)
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .chartXAxis {
                        AxisMarks(position: .bottom) { _ in
                            AxisValueLabel()
                            AxisTick()
                        }
                    }
                } else {
                    // Fallback for iOS 15
                    VStack(spacing: 8) {
                        ForEach(weeklyData, id: \.day) { data in
                            HStack {
                                Text(data.day)
                                    .font(.caption)
                                    .frame(width: 40, alignment: .leading)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: CGFloat(data.count * 20), height: 20)
                                
                                Text("\(data.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                }
            } else {
                LockedGraphView(
                    title: "Weekly Activity",
                    description: "See your event distribution across the week",
                    icon: "chart.bar.fill",
                    height: 200,
                    unlockMessage: "Add events throughout the week to unlock weekly insights"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var upcomingEventsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Next 3 Events")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if hasData {
                    Button("View All") {
                        // Switch to schedule tab
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
            }
            
            if upcomingEvents.isEmpty {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: hasData ? "calendar.badge.checkmark" : "calendar.badge.plus")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                    
                    Text(hasData ? "No upcoming events" : "Ready to get organized?")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(hasData ? "You're all caught up!" : "Add your first event to unlock analytics and insights")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(Array(upcomingEvents.prefix(3)), id: \.id) { event in
                        EventRowView(event: event)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                DashboardQuickActionButton(
                    title: "Add Event",
                    icon: "plus.circle.fill",
                    color: .blue
                ) {
                    // Add event action
                }
                
                DashboardQuickActionButton(
                    title: "View Schedule",
                    icon: "calendar",
                    color: .green
                ) {
                    // View schedule action
                }
                
                DashboardQuickActionButton(
                    title: "AI Assistant",
                    icon: "brain.head.profile",
                    color: .purple
                ) {
                    // AI assistant action
                }
                
                DashboardQuickActionButton(
                    title: "Upload Photo",
                    icon: "camera.fill",
                    color: .orange
                ) {
                    // Upload photo action
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Computed Properties
    
    private var todaysEvents: [CalendarEvent] {
        let calendar = Calendar.current
        let today = Date()
        
        return events.filter { event in
            calendar.isDate(event.date, inSameDayAs: today)
        }
    }
    
    private var thisWeekEvents: [CalendarEvent] {
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? today
        
        return events.filter { event in
            event.date >= weekStart && event.date < weekEnd
        }
    }
    
    private var completedEvents: [CalendarEvent] {
        let now = Date()
        return events.filter { $0.date < now }
    }
    
    private var upcomingEvents: [CalendarEvent] {
        let now = Date()
        return events.filter { $0.date >= now }.sorted { $0.date < $1.date }
    }
    
    private var weeklyData: [(day: String, count: Int)] {
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "E"
        
        var data: [(day: String, count: Int)] = []
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: i, to: weekStart) ?? weekStart
            let dayName = dayFormatter.string(from: date)
            let count = events.filter { calendar.isDate($0.date, inSameDayAs: date) }.count
            data.append((day: dayName, count: count))
        }
        
        return data
    }
}

struct DashboardStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

struct EventRowView: View {
    let event: CalendarEvent
    
    var body: some View {
        HStack(spacing: 12) {
            // Color indicator
            RoundedRectangle(cornerRadius: 2)
                .fill(event.color)
                .frame(width: 4, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Label(
                        event.date.formatted(date: .omitted, time: .shortened),
                        systemImage: "clock"
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    if !event.location.isEmpty {
                        Label(event.location, systemImage: "location")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            // Time until event
            Text(timeUntilEvent(event.date))
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
    
    private func timeUntilEvent(_ date: Date) -> String {
        let now = Date()
        let interval = date.timeIntervalSince(now)
        
        if interval < 0 {
            return "Past"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d"
        }
    }
}

struct DashboardQuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CalendarDashboardView(events: .constant([
        CalendarEvent(
            title: "Math Class",
            date: Date().addingTimeInterval(3600),
            notes: "Algebra basics",
            color: .blue,
            location: "Room 101"
        ),
        CalendarEvent(
            title: "History Class",
            date: Date().addingTimeInterval(7200),
            notes: "World War II",
            color: .red,
            location: "Room 203"
        )
    ]))
    .environmentObject(ScreenTimeManager())
    .environmentObject(AchievementManager())
}