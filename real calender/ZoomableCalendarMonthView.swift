import SwiftUI

// MARK: - Working Month View
struct WorkingMonthView: View {
    let events: [CalendarEvent]
    @Binding var selectedDate: Date
    let onDayTap: (Date) -> Void
    
    private var monthDays: [Date] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate) else {
            return []
        }
        
        let startOfMonth = monthInterval.start
        let startWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysFromPreviousMonth = (startWeekday - calendar.firstWeekday + 7) % 7
        
        guard let calendarStart = calendar.date(byAdding: .day, value: -daysFromPreviousMonth, to: startOfMonth) else {
            return []
        }
        
        var days: [Date] = []
        for i in 0..<42 {
            if let day = calendar.date(byAdding: .day, value: i, to: calendarStart) {
                days.append(day)
            }
        }
        return days
    }
    
    private var weeks: [[Date]] {
        var weeks: [[Date]] = []
        let days = monthDays
        
        for i in stride(from: 0, to: days.count, by: 7) {
            let endIndex = min(i + 7, days.count)
            weeks.append(Array(days[i..<endIndex]))
        }
        return weeks
    }
    
    private func eventsForDate(_ date: Date) -> [CalendarEvent] {
        return events.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    private func isCurrentMonth(_ date: Date) -> Bool {
        Calendar.current.isDate(date, equalTo: selectedDate, toGranularity: .month)
    }
    
    var body: some View {
        VStack(spacing: 2) {
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
            }
            .background(Color(.systemGray6))
            
            // Calendar grid
            VStack(spacing: 1) {
                ForEach(weeks.indices, id: \.self) { weekIndex in
                    let week = weeks[weekIndex]
                    
                    HStack(spacing: 1) {
                        ForEach(week, id: \.self) { date in
                            WorkingDayCell(
                                date: date,
                                events: eventsForDate(date),
                                isCurrentMonth: isCurrentMonth(date),
                                isToday: Calendar.current.isDateInToday(date),
                                isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                                onTap: { 
                                    print("🟦 Month day cell tapped: \(date)")
                                    onDayTap(date) 
                                }
                            )
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 1)
                    )
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Working Day Cell (With beautiful selected animation)
struct WorkingDayCell: View {
    let date: Date
    let events: [CalendarEvent]
    let isCurrentMonth: Bool
    let isToday: Bool
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            print("🔴 Day button pressed: \(dayNumber)")
            
            // Beautiful press animation
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            // Quick haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            
            // Call the tap handler after short animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed = false
                }
                onTap()
            }
        }) {
            VStack(spacing: 3) {
                Text(dayNumber)
                    .font(.system(size: 14, weight: isToday ? .bold : .medium))
                    .foregroundColor(textColor)
                
                // Event indicators
                HStack(spacing: 1) {
                    ForEach(events.prefix(3), id: \.id) { event in
                        Circle()
                            .fill(event.color)
                            .frame(width: 4, height: 4)
                    }
                    
                    if events.count > 3 {
                        Text("+")
                            .font(.system(size: 6, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(height: 8)
            }
            .frame(maxWidth: .infinity, minHeight: 45)
            .background(backgroundColor)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(borderColor, lineWidth: isSelected ? 1.5 : 0)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var textColor: Color {
        if isToday {
            return .white
        } else if !isCurrentMonth {
            return .secondary
        } else {
            return .primary
        }
    }
    
    private var backgroundColor: Color {
        if isToday {
            return .blue
        } else if isSelected {
            return .blue.opacity(0.2)
        } else {
            return .clear
        }
    }
    
    private var borderColor: Color {
        isSelected ? .blue : .clear
    }
}