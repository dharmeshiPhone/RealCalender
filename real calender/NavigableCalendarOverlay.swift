import SwiftUI

struct NavigableCalendarOverlay: View {
    @Binding var selectedDate: Date
    let eventsForSelectedDate: [CalendarEvent]
    let onAddEvent: () -> Void
    let onCalendarReview: () -> Void
    let trackCalendarUsage: () -> Void
    
    @State private var currentMode: CalendarMode = .month
    @State private var focusedWeek: Date = Date()
    @State private var focusedDay: Date = Date()
    
    enum CalendarMode {
        case month, week, day
    }
    
    var body: some View {
        ZStack {
            // Original CalendarSection (with all animations intact)
            CalendarSection(
                selectedDate: $selectedDate,
                eventsForSelectedDate: eventsForSelectedDate,
                onAddEvent: onAddEvent,
                onCalendarReview: onCalendarReview,
                trackCalendarUsage: trackCalendarUsage
            )
            
            // Invisible overlay for navigation
            if currentMode == .month {
                invisibleMonthOverlay
            } else if currentMode == .week {
                invisibleWeekOverlay
            } else if currentMode == .day {
                invisibleDayOverlay
            }
        }
        .onAppear {
            focusedWeek = selectedDate
            focusedDay = selectedDate
        }
    }
    
    // MARK: - Invisible Month Overlay
    private var invisibleMonthOverlay: some View {
        VStack(spacing: 0) {
            // Space for header (skip the calendar header area)
            Rectangle()
                .fill(Color.clear)
                .frame(height: 60)
            
            // Invisible calendar grid overlay
            VStack(spacing: 1) {
                // Skip weekday headers
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 30)
                
                // 6 weeks of invisible day buttons
                ForEach(0..<6) { weekIndex in
                    HStack(spacing: 1) {
                        ForEach(0..<7) { dayIndex in
                            invisibleDayButton(weekIndex: weekIndex, dayIndex: dayIndex)
                        }
                    }
                    .frame(height: 45) // Match day cell height
                }
            }
            
            Spacer()
        }
    }
    
    private func invisibleDayButton(weekIndex: Int, dayIndex: Int) -> some View {
        Button(action: {
            // Calculate the actual date for this position
            let calendar = Calendar.current
            guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate) else { return }
            
            let startOfMonth = monthInterval.start
            let startWeekday = calendar.component(.weekday, from: startOfMonth)
            let daysFromPreviousMonth = (startWeekday - calendar.firstWeekday + 7) % 7
            
            guard let calendarStart = calendar.date(byAdding: .day, value: -daysFromPreviousMonth, to: startOfMonth) else { return }
            
            let dayOffset = (weekIndex * 7) + dayIndex
            guard let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: calendarStart) else { return }
            
            print("✅ OVERLAY: Day tapped - \(targetDate)")
            
            // Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            // Update selected date and navigate
            selectedDate = targetDate
            focusedWeek = targetDate
            focusedDay = targetDate
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                currentMode = .week
            }
            
            trackCalendarUsage()
        }) {
            Rectangle()
                .fill(Color.clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Invisible Week Overlay
    private var invisibleWeekOverlay: some View {
        VStack(spacing: 0) {
            // Header area with back button
            HStack {
                Button("← Back to Month") {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentMode = .month
                    }
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(6)
                
                Spacer()
                
                Text("Week View")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Today") {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        selectedDate = Date()
                        focusedWeek = Date()
                        focusedDay = Date()
                        currentMode = .month
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding()
            .background(Color(.systemBackground))
            
            // Week header with day buttons
            HStack(spacing: 0) {
                ForEach(weekDays, id: \.self) { date in
                    Button(action: {
                        print("✅ OVERLAY: Week day tapped - \(date)")
                        
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        
                        selectedDate = date
                        focusedDay = date
                        
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentMode = .day
                        }
                        
                        trackCalendarUsage()
                    }) {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(maxWidth: .infinity).frame(height: 50)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // Week body - clickable day columns
            HStack(alignment: .top, spacing: 0) {
                ForEach(weekDays, id: \.self) { date in
                    Button(action: {
                        print("✅ OVERLAY: Week column tapped - \(date)")
                        
                        let impact = UIImpactFeedbackGenerator(style: .medium) 
                        impact.impactOccurred()
                        
                        selectedDate = date
                        focusedDay = date
                        
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentMode = .day
                        }
                        
                        trackCalendarUsage()
                    }) {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(maxWidth: .infinity, minHeight: 250)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Invisible Day Overlay 
    private var invisibleDayOverlay: some View {
        VStack(spacing: 0) {
            // Header area with back button
            HStack {
                Button("← Back to Week") {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentMode = .week
                    }
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(6)
                
                Spacer()
                
                Text("Day View")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Today") {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        selectedDate = Date()
                        focusedWeek = Date()
                        focusedDay = Date()
                        currentMode = .month
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding()
            .background(Color(.systemBackground))
            
            Spacer()
        }
    }
    
    // MARK: - Computed Properties
    private var weekDays: [Date] {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: focusedWeek) else { return [] }
        
        var days: [Date] = []
        for i in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: i, to: weekInterval.start) {
                days.append(day)
            }
        }
        return days
    }
}

#Preview {
    NavigableCalendarOverlay(
        selectedDate: .constant(Date()),
        eventsForSelectedDate: [],
        onAddEvent: {},
        onCalendarReview: {},
        trackCalendarUsage: {}
    )
}
