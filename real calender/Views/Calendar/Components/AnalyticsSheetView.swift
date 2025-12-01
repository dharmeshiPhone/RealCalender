//
//  AnalyticsSheetView.swift
//  real calender
//
//  Created by Mac on 28/11/25.
//

import SwiftUI

struct AnalyticsSheetView: View {
    let missedEvents: [CalendarEvent]
    let todayCompletionRate: Double
    let totalEvents: Int
    
    @Environment(\.dismiss) private var dismiss
    @State private var refreshId = UUID()
    
    private var calendar = Calendar.current
    
    init(missedEvents: [CalendarEvent], todayCompletionRate: Double, totalEvents: Int) {
        self.missedEvents = missedEvents
        self.todayCompletionRate = todayCompletionRate
        self.totalEvents = totalEvents
    }

    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Stats
                    headerStatsSection
                    
                    // Completion Rate Card
                    completionRateSection
                    
                    // Missed Events List
                    missedEventsSection
                    
                    // Quick Insights
                    insightsSection
                }
                .padding(.vertical)
            }
            .id(refreshId)
            .navigationTitle("Calendar Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("EventsModified"))) { _ in
                refreshId = UUID()
            }
        }
    }
    
    // MARK: - Header Stats
    private var headerStatsSection: some View {
        HStack(spacing: 16) {
            StatsCard(
                icon: "calendar", title: "Total Events",
                value: "\(totalEvents)",
                color: .blue
            )
            
            StatsCard(
                icon: "exclamationmark.triangle", title: "Missed Responses",
                value: "\(missedEvents.count)",
                color: missedEvents.isEmpty ? .green : .red
            )
            
            StatsCard(
                icon: "checkmark.circle", title: "Today's Rate",
                value: "\(Int(todayCompletionRate * 100))%",
                color: todayCompletionColor
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Completion Rate Section
    private var completionRateSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundColor(.blue)
                
                Text("Completion Progress")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(Int(todayCompletionRate * 100))%")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(todayCompletionColor)
            }
            
            VStack(spacing: 12) {
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5))
                            .frame(height: 16)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(todayCompletionColor)
                            .frame(width: geometry.size.width * CGFloat(todayCompletionRate), height: 16)
                    }
                }
                .frame(height: 16)
                
                // Progress Labels
                HStack {
                    Text("Needs Attention")
                        .font(.caption)
                        .foregroundColor(.red)
                    
                    Spacer()
                    
                    Text("On Track")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Missed Events Section
    private var missedEventsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                
                Text("Missed Responses")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !missedEvents.isEmpty {
                    Text("\(missedEvents.count)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .clipShape(Capsule())
                }
            }
            
            if missedEvents.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(missedEvents.sorted(by: { $0.date > $1.date })) { event in
                        MissedEventRow(event: event)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Insights Section
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                
                Text("Quick Insights")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            LazyVStack(spacing: 12) {
                if missedEvents.isEmpty {
                    InsightsRow(
                        icon: "checkmark.circle.fill",
                        title: "Great Job!",
                        description: "All events have been properly responded to.",
                        color: .green
                    )
                } else {
                    InsightsRow(
                        icon: "exclamationmark.circle.fill",
                        title: "Attention Needed",
                        description: "You have \(missedEvents.count) events that require follow-up.",
                        color: .orange
                    )
                }
                
                if todayCompletionRate >= 0.8 {
                    InsightsRow(
                        icon: "star.fill",
                        title: "Excellent Progress",
                        description: "You're completing most of your daily events.",
                        color: .green
                    )
                } else if todayCompletionRate >= 0.5 {
                    InsightsRow(
                        icon: "clock.fill",
                        title: "Good Progress",
                        description: "You're halfway through today's events.",
                        color: .orange
                    )
                } else {
                    InsightsRow(
                        icon: "bell.fill",
                        title: "Catch Up Time",
                        description: "Try to complete more events today.",
                        color: .red
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.green)
            
            Text("All Caught Up!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("No missed responses found. Great job staying on top of your events!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
    
    private var todayCompletionColor: Color {
        switch todayCompletionRate {
        case 0.8...1.0: return .green
        case 0.5..<0.8: return .orange
        default: return .red
        }
    }
}


struct MissedEventRow: View {
    let event: CalendarEvent
    @State private var showCompletionConfirmation = false
    @State private var isProcessing = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Color indicator
            Rectangle()
                .fill(event.color)
                .frame(width: 4)
                .cornerRadius(2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(timeFormatter.string(from: event.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !event.location.isEmpty {
                    Text(event.location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Text("\(daysSince)d ago")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.red)
                
                // Checkbox button
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.orange)
                    .font(.title3)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .contentShape(.rect)
        .onTapGesture {
            showCompletionConfirmation = true
        }
        .confirmationDialog("Mark as completed?", isPresented: $showCompletionConfirmation) {
            Button("Yes, I attended this event") {
                markEventAsCompleted(true)
            }
            Button("I didn’t attend") {
                markEventAsCompleted(false)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Did you attend \"\(event.title)\"?")
        }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    private var daysSince: Int {
        Calendar.current.dateComponents([.day], from: event.date, to: Date()).day ?? 0
    }
    
    private func markEventAsCompleted(_ isCompleted:Bool) {
        isProcessing = true
        
        // Update the event in storage
        updateEventStatus(eventId: event.id, isCompleted: isCompleted)
        
        // Simulate processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isProcessing = false
            NotificationCenter.default.post(
                name: Notification.Name("EventsModified"),
                object: nil,
                userInfo: ["shouldLoadEvent": true]
            )

        }
    }
    
    private func updateEventStatus(eventId: UUID, isCompleted: Bool) {
        if var events = loadEventsFromStorage() {
            if let index = events.firstIndex(where: { $0.id == eventId }) {
                events[index].isCompleted = isCompleted
                events[index].isRespond = true
                saveEventsToStorage(events)
            }
        }
    }

    private func loadEventsFromStorage() -> [CalendarEvent]? {
        guard let data = UserDefaults.standard.data(forKey: "calendarEvents") else { return nil }
        return try? JSONDecoder().decode([CalendarEvent].self, from: data)
    }

    private func saveEventsToStorage(_ events: [CalendarEvent]) {
        if let data = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(data, forKey: "calendarEvents")
        }
    }
}

struct InsightsRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}


struct StatsCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.callout)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
        .background(color.opacity(0.1))
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}
