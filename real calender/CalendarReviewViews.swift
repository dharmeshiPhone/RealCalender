import SwiftUI

// MARK: - Supporting Types
// Existing code...

// MARK: - Calendar Review Main View
struct CalendarReviewView: View {
    @EnvironmentObject var questManager: QuestManager
    let events: [CalendarEvent]
    @Binding var isPresented: Bool
    let onEventUpdated: (CalendarEvent) -> Void 
    let onEventDeleted: (CalendarEvent) -> Void 
    @State private var selectedTab: CalendarReviewView.ReviewTab = .schedule
    @State private var showTravelEvents = true

    enum ReviewTab: String, CaseIterable {
        case schedule = "All Events"
        case analytics = "Analytics"
        case conflicts = "Conflicts"
        case insights = "Insights"
        
        var icon: String {
            switch self {
            case .schedule: return "calendar"
            case .analytics: return "chart.bar.fill"
            case .conflicts: return "exclamationmark.triangle.fill"
            case .insights: return "lightbulb.fill"
            }
        }
    }
    
    private var eventsWithTravel: [CalendarEvent] {
        if showTravelEvents {
            return events.withTravelEvents()
        } else {
            return events
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with stats
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Calendar Review")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            HStack(spacing: 12) {
                                Text("\(eventsWithTravel.count) events")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                if showTravelEvents {
                                    Text("• Travel included")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(4)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 8) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 40))
                                .foregroundColor(.purple)
                        }
                    }
                    
                    // Enhanced travel toggle section
                    HStack {
                        HStack(spacing: 12) {
                            Image(systemName: showTravelEvents ? "car.fill" : "car")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(showTravelEvents ? .blue : .secondary)
                                .animation(.easeInOut(duration: 0.2), value: showTravelEvents)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Travel Time")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text(showTravelEvents ? "Included in schedule" : "Hidden from view")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Toggle(isOn: $showTravelEvents) {
                                EmptyView()
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                            .scaleEffect(0.9)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(showTravelEvents ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                        .animation(.easeInOut(duration: 0.2), value: showTravelEvents)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .onAppear {
                    print("📊 CalendarReviewView: === DETAILED EVENT ANALYSIS ===")
                    print("📊 CalendarReviewView: Received \(events.count) total events")
                    print("📊 CalendarReviewView: Events with travel: \(eventsWithTravel.count)")
                    print("📊 CalendarReviewView: === END ANALYSIS ===")
                   
                }
                
                // Tab content
                TabView(selection: $selectedTab) {
                    ScheduleTabView(
                        events: eventsWithTravel,
                        onEventUpdated: onEventUpdated,
                        onEventDeleted: onEventDeleted
                    )
                    .tabItem {
                        Image(systemName: ReviewTab.schedule.icon)
                        Text(ReviewTab.schedule.rawValue)
                    }
                    .tag(ReviewTab.schedule)
                    
                    EnhancedAnalyticsTabView(events: eventsWithTravel)
                        .tabItem {
                            Image(systemName: questManager.currentBatch > 11 ? ReviewTab.analytics.icon : "lock.fill")
                            Text(ReviewTab.analytics.rawValue)
                        }
                        .tag(ReviewTab.analytics)
                        .disabled(questManager.currentBatch < 11)
                        
                    
                    EnhancedConflictsTabView(events: eventsWithTravel)
                        .tabItem {
                            Image(systemName: ReviewTab.conflicts.icon)
                            Text(ReviewTab.conflicts.rawValue)
                        }
                        .tag(ReviewTab.conflicts)
                    if questManager.currentBatch > 11{ // hide up to level 13
                        EnhancedInsightsTabView(events: eventsWithTravel)
                            .tabItem {
                                Image(systemName: ReviewTab.insights.icon)
                                Text(ReviewTab.insights.rawValue)
                            }
                            .tag(ReviewTab.insights)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - Schedule Tab (Simplified - No Time Frame Picker)
struct ScheduleTabView: View {
    let events: [CalendarEvent]
    let onEventUpdated: (CalendarEvent) -> Void
    let onEventDeleted: (CalendarEvent) -> Void
    @EnvironmentObject var aiChatManager: AIChatManager

    private var groupedEvents: [Date: [CalendarEvent]] {
        Dictionary(grouping: events) { event in
            Calendar.current.startOfDay(for: event.date)
        }
    }
    
    private var sortedDates: [Date] {
        groupedEvents.keys.sorted()
    }

    var body: some View {
        ScrollView {
            if events.isEmpty {
                emptyStateView
            } else {
                EventListView(
                    events: events,
                    groupedEvents: groupedEvents,
                    sortedDates: sortedDates,
                    onEventUpdated: onEventUpdated,
                    onEventDeleted: onEventDeleted
                )
            }
        }
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No Events Found")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("No events in your calendar. Try adding some events to get started.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Ask AI to help plan your day") {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                let dateString = formatter.string(from: Date())
                
                aiChatManager.sendMessage("Help me plan my day for \(dateString). I need suggestions for organizing my schedule and adding productive activities.")
            }
            .buttonStyle(.plain)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.blue)
            .cornerRadius(10)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Event List View (All Events)
struct EventListView: View {
    let events: [CalendarEvent]
    let groupedEvents: [Date: [CalendarEvent]]
    let sortedDates: [Date]
    let onEventUpdated: (CalendarEvent) -> Void
    let onEventDeleted: (CalendarEvent) -> Void
    
    var body: some View {
        LazyVStack(spacing: 20) {
            ForEach(sortedDates, id: \.self) { date in
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(formatDateHeader(date))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(groupedEvents[date]?.count ?? 0) events")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 16)
                    
                    VStack(spacing: 8) {
                        ForEach(groupedEvents[date]?.sorted(by: { $0.date < $1.date }) ?? [], id: \.id) { event in
                            CleanEventRow(
                                event: event,
                                onEventUpdated: onEventUpdated,
                                onEventDeleted: onEventDeleted
                            )
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    private func formatDateHeader(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
            formatter.dateFormat = "EEEE" 
            return formatter.string(from: date)
        } else {
            formatter.dateFormat = "EEEE, MMM d" 
            return formatter.string(from: date)
        }
    }
}

// MARK: - Clean Event Row
struct CleanEventRow: View {
    let event: CalendarEvent
    let onEventUpdated: (CalendarEvent) -> Void
    let onEventDeleted: (CalendarEvent) -> Void
    @State private var showingEventDetail = false
    @State private var eventToEdit: CalendarEvent
    
    init(event: CalendarEvent, onEventUpdated: @escaping (CalendarEvent) -> Void, onEventDeleted: @escaping (CalendarEvent) -> Void) {
        self.event = event
        self.onEventUpdated = onEventUpdated
        self.onEventDeleted = onEventDeleted
        self._eventToEdit = State(initialValue: event)
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        Button(action: {
            eventToEdit = event
            showingEventDetail = true
        }) {
            HStack(spacing: 0) {
                Rectangle()
                    .fill(event.color)
                    .frame(width: 4)
                    .cornerRadius(2)
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.title)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                            
                            HStack(spacing: 12) {
                                Text(timeFormatter.string(from: event.date))
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.blue)
                                
                                if !event.location.isEmpty {
                                    HStack(spacing: 2) {
                                        Image(systemName: "location")
                                            .font(.system(size: 11))
                                            .foregroundColor(.secondary)
                                        
                                        Text(event.location)
                                            .font(.system(size: 13))
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                }
                            
                                if let teacher = event.teacher, !teacher.isEmpty {
                                    HStack(spacing: 2) {
                                        Image(systemName: "person")
                                            .font(.system(size: 11))
                                            .foregroundColor(.secondary)
                                        
                                        Text(teacher)
                                            .font(.system(size: 13))
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    
                    Text(getEventType(event))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(event.color.opacity(0.8))
                        .cornerRadius(6)
                    
                    if !event.notes.isEmpty {
                        Text(event.notes)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                .padding(.leading, 12)
                .padding(.vertical, 12)
                .padding(.trailing, 16)
            }
        }
        .buttonStyle(.plain)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray4), lineWidth: 0.5)
        )
        .sheet(isPresented: $showingEventDetail) {
            EventDetailView(
                event: $eventToEdit,
                isPresented: $showingEventDetail,
                onSave: { updatedEvent in
                    onEventUpdated(updatedEvent)
                },
                onDelete: {
                    onEventDeleted(event)
                }
            )
        }
    }
    
    private func getEventType(_ event: CalendarEvent) -> String {
        let title = event.title.lowercased()
        if title.contains("lecture") || title.contains("class") {
            return "Class"
        } else if title.contains("lab") {
            return "Lab"
        } else if title.contains("meeting") {
            return "Meeting"
        } else if title.contains("exam") || title.contains("test") {
            return "Exam"
        } else if title.contains("break") || title.contains("lunch") {
            return "Break"
        } else {
            return "Event"
        }
    }
}

// MARK: - Rest of the file remains the same

// MARK: - Import the Analytics, Conflicts, and Insights Tab Views from their separate files
