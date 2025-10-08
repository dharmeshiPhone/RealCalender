import SwiftUI

// MARK: - Week Calendar View with Days Left
struct WeekCalendarView: View {
    let events: [CalendarEvent]
    
    private var weekDays: [Date] {
        let calendar = Calendar.current
        let today = Date()
        let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today)!
        
        var days: [Date] = []
        for i in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: i, to: weekInterval.start) {
                days.append(day)
            }
        }
        return days
    }
    
    private var daysLeftInWeek: Int {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        return 8 - weekday // Days remaining including today
    }
    
    private func eventsForDate(_ date: Date) -> [CalendarEvent] {
        return events.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.date < $1.date }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Week header with countdown
            VStack(spacing: 8) {
                HStack {
                    Text("This Week")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(daysLeftInWeek) days left")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .fontWeight(.semibold)
                        
                        Text(DateFormatter.weekRangeFormatter.string(from: weekDays.first ?? Date()))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Week progress bar
                ProgressView(value: Double(7 - daysLeftInWeek), total: 7.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(x: 1, y: 2)
                    .cornerRadius(4)
            }
            
            // Week grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 2) {
                // Day headers
                ForEach(weekDays, id: \.self) { date in
                    VStack(spacing: 4) {
                        Text(DateFormatter.dayAbbreviationFormatter.string(from: date))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Text(DateFormatter.dayNumberFormatter.string(from: date))
                            .font(.title3)
                            .fontWeight(Calendar.current.isDateInToday(date) ? .bold : .medium)
                            .foregroundColor(Calendar.current.isDateInToday(date) ? .white : .primary)
                    }
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
                    .background(Calendar.current.isDateInToday(date) ? Color.blue : Color.clear)
                    .cornerRadius(8)
                }
                
                // Events for each day
                ForEach(weekDays, id: \.self) { date in
                    WeekDayColumn(events: eventsForDate(date))
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Week stats
            HStack(spacing: 20) {
                WeekStatCard(
                    title: "Total Events",
                    value: "\(events.filter { event in weekDays.contains { day in Calendar.current.isDate(day, inSameDayAs: event.date) } }.count)",
                    icon: "calendar",
                    color: .blue
                )
                
                WeekStatCard(
                    title: "Today",
                    value: "\(eventsForDate(Date()).count)",
                    icon: "star.fill",
                    color: .orange
                )
                
                WeekStatCard(
                    title: "Completed",
                    value: "\(7 - daysLeftInWeek)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }
        }
    }
}

// MARK: - Month Calendar View with Days Left
struct MonthCalendarView: View {
    let events: [CalendarEvent]
    @State private var selectedDate = Date()
    
    private var monthDays: [Date] {
        let calendar = Calendar.current
        let monthInterval = calendar.dateInterval(of: .month, for: selectedDate)!
        let startOfMonth = monthInterval.start
        
        // Find the start of the week containing the first day of the month
        let startWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysFromPreviousMonth = (startWeekday - calendar.firstWeekday + 7) % 7
        let calendarStart = calendar.date(byAdding: .day, value: -daysFromPreviousMonth, to: startOfMonth)!
        
        var days: [Date] = []
        for i in 0..<42 { // 6 weeks x 7 days
            if let day = calendar.date(byAdding: .day, value: i, to: calendarStart) {
                days.append(day)
            }
        }
        return days
    }
    
    private var daysLeftInMonth: Int {
        let calendar = Calendar.current
        let today = Date()
        let range = calendar.range(of: .day, in: .month, for: today)!
        let dayOfMonth = calendar.component(.day, from: today)
        return range.count - dayOfMonth + 1 // Including today
    }
    
    private var monthProgress: Double {
        let calendar = Calendar.current
        let today = Date()
        let range = calendar.range(of: .day, in: .month, for: today)!
        let dayOfMonth = calendar.component(.day, from: today)
        return Double(dayOfMonth) / Double(range.count)
    }
    
    private func eventsForDate(_ date: Date) -> [CalendarEvent] {
        return events.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    private func isCurrentMonth(_ date: Date) -> Bool {
        Calendar.current.isDate(date, equalTo: selectedDate, toGranularity: .month)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Month header with countdown
            VStack(spacing: 12) {
                HStack {
                    Text("This Month")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(daysLeftInMonth) days left")
                            .font(.caption)
                            .foregroundColor(.purple)
                            .fontWeight(.semibold)
                        
                        Text(DateFormatter.monthYearFormatter.string(from: selectedDate))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Month progress
                VStack(spacing: 8) {
                    HStack {
                        Text("Month Progress")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(monthProgress * 100))%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.purple)
                    }
                    
                    ProgressView(value: monthProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                        .scaleEffect(x: 1, y: 2)
                        .cornerRadius(4)
                }
            }
            
            // Month calendar
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 1), count: 7), spacing: 1) {
                // Weekday headers
                ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(height: 30)
                }
                
                // Calendar days
                ForEach(monthDays, id: \.self) { date in
                    MonthCalendarDay(
                        date: date,
                        events: eventsForDate(date),
                        isCurrentMonth: isCurrentMonth(date),
                        isToday: Calendar.current.isDateInToday(date)
                    )
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Month stats
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                MonthStatCard(
                    title: "Events",
                    value: "\(events.filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .month) }.count)",
                    icon: "calendar.badge.plus",
                    color: .blue
                )
                
                MonthStatCard(
                    title: "Completed",
                    value: "\(Int(monthProgress * 100))%",
                    icon: "chart.pie.fill",
                    color: .green
                )
                
                MonthStatCard(
                    title: "Remaining",
                    value: "\(daysLeftInMonth)d",
                    icon: "clock.fill",
                    color: .orange
                )
                
                MonthStatCard(
                    title: "Today",
                    value: "\(eventsForDate(Date()).count)",
                    icon: "star.fill",
                    color: .purple
                )
            }
        }
    }
}

// MARK: - Supporting Views

private struct WeekDayColumn: View {
    let events: [CalendarEvent]
    
    var body: some View {
        VStack(spacing: 2) {
            if events.isEmpty {
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 100)
            } else {
                ForEach(events.prefix(3), id: \.id) { event in
                    WeekEventDot(event: event)
                }
                
                if events.count > 3 {
                    Text("+\(events.count - 3)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .fontWeight(.semibold)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .padding(2)
    }
}

struct WeekEventDot: View {
    let event: CalendarEvent
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(event.color)
                .frame(width: 6, height: 6)
            
            Text(event.title)
                .font(.caption2)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
    }
}

struct MonthCalendarDay: View {
    let date: Date
    let events: [CalendarEvent]
    let isCurrentMonth: Bool
    let isToday: Bool
    
    var body: some View {
        VStack(spacing: 2) {
            Text(DateFormatter.dayNumberFormatter.string(from: date))
                .font(.caption)
                .fontWeight(isToday ? .bold : .medium)
                .foregroundColor(isCurrentMonth ? (isToday ? .white : .primary) : .secondary)
            
            // Event indicators
            HStack(spacing: 1) {
                ForEach(events.prefix(3), id: \.id) { event in
                    Circle()
                        .fill(event.color)
                        .frame(width: 4, height: 4)
                }
                
                if events.count > 3 {
                    Circle()
                        .fill(Color.secondary)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(height: 6)
        }
        .frame(width: 40, height: 50)
        .background(isToday ? Color.blue : Color(.systemBackground))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isToday ? Color.blue : Color.clear, lineWidth: 1)
        )
    }
}

struct WeekStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct MonthStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Date Formatters
extension DateFormatter {
    static let weekRangeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d - MMM d"
        return formatter
    }()
    
    static let dayAbbreviationFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()
    
    static let dayNumberFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
}