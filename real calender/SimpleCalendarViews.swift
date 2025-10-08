import SwiftUI

// MARK: - Simple Month View
struct SimpleMonthView: View {
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
                            SimpleDayCell(
                                date: date,
                                events: eventsForDate(date),
                                isCurrentMonth: isCurrentMonth(date),
                                isToday: Calendar.current.isDateInToday(date),
                                isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                                onTap: { 
                                    print("🟦 Day cell tapped: \(date)")
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

// MARK: - Simple Day Cell
struct SimpleDayCell: View {
    let date: Date
    let events: [CalendarEvent]
    let isCurrentMonth: Bool
    let isToday: Bool
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            print("🔴 Button tapped for: \(dayNumber)")
            onTap()
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

// MARK: - Simple Week View
struct SimpleWeekView: View {
    let events: [CalendarEvent]
    let focusedWeek: Date
    @Binding var selectedDate: Date
    let onDayTap: (Date) -> Void
    
    private var weekDays: [Date] {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: focusedWeek) else {
            return []
        }
        
        var days: [Date] = []
        for i in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: i, to: weekInterval.start) {
                days.append(day)
            }
        }
        return days
    }
    
    private func eventsForDate(_ date: Date) -> [CalendarEvent] {
        return events.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.date < $1.date }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Week header with days
            HStack(spacing: 0) {
                ForEach(weekDays, id: \.self) { date in
                    VStack(spacing: 6) {
                        Text(dayNameFormatter.string(from: date))
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        Button(action: {
                            print("🟡 Week day header tapped: \(date)")
                            onDayTap(date)
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Calendar.current.isDateInToday(date) ? Color.blue : 
                                          Calendar.current.isDate(date, inSameDayAs: selectedDate) ? Color.blue.opacity(0.3) : Color.clear)
                                    .frame(width: 28, height: 28)
                                
                                Text(dayNumberFormatter.string(from: date))
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Calendar.current.isDateInToday(date) ? .white : .primary)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            
            // Week calendar body
            ScrollView {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(weekDays, id: \.self) { date in
                        SimpleWeekDayColumn(
                            date: date,
                            events: eventsForDate(date),
                            isToday: Calendar.current.isDateInToday(date),
                            isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                            onTap: { 
                                print("🟢 Week column tapped: \(date)")
                                onDayTap(date) 
                            }
                        )
                    }
                }
                .frame(minHeight: 250)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var dayNameFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }
    
    private var dayNumberFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
}

// MARK: - Simple Week Day Column
struct SimpleWeekDayColumn: View {
    let date: Date
    let events: [CalendarEvent]
    let isToday: Bool
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            print("🟪 Week day column button tapped: \(date)")
            onTap()
        }) {
            VStack(spacing: 4) {
                if events.isEmpty {
                    VStack(spacing: 6) {
                        Image(systemName: "moon.zzz")
                            .font(.callout)
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Free")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 80)
                    .background(Color(.systemGray6).opacity(0.3))
                    .cornerRadius(6)
                } else {
                    ForEach(events.prefix(6), id: \.id) { event in
                        SimpleEventCard(event: event)
                    }
                    
                    if events.count > 6 {
                        Text("+\(events.count - 6)")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                    }
                }
                
                Spacer(minLength: 0)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 2)
        .padding(.vertical, 6)
        .background(isSelected ? Color.blue.opacity(0.05) : (isToday ? Color.orange.opacity(0.05) : Color.clear))
        .overlay(
            Rectangle()
                .frame(width: 0.5)
                .foregroundColor(Color(.systemGray5)),
            alignment: .trailing
        )
    }
}

// MARK: - Simple Event Card
struct SimpleEventCard: View {
    let event: CalendarEvent
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Rectangle()
                    .fill(event.color)
                    .frame(width: 2, height: 16)
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(event.title)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(timeFormatter.string(from: event.date))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer(minLength: 0)
            }
            
            if !event.location.isEmpty {
                Text(event.location)
                    .font(.caption2)
                    .foregroundColor(event.color)
                    .lineLimit(1)
                    .padding(.leading, 4)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(event.color.opacity(0.1))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(event.color.opacity(0.3), lineWidth: 0.5)
        )
    }
}

// MARK: - Simple Day View
struct SimpleDayView: View {
    let events: [CalendarEvent]
    let focusedDay: Date
    @Binding var selectedDate: Date
    
    private var dayEvents: [CalendarEvent] {
        return events.filter { Calendar.current.isDate($0.date, inSameDayAs: focusedDay) }
            .sorted { $0.date < $1.date }
    }
    
    private var timeSlots: [Date] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: focusedDay)
        
        var slots: [Date] = []
        for hour in 6..<23 {
            if let timeSlot = calendar.date(byAdding: .hour, value: hour, to: startOfDay) {
                slots.append(timeSlot)
            }
        }
        return slots
    }
    
    private func eventsForHour(_ hour: Date) -> [CalendarEvent] {
        let calendar = Calendar.current
        return dayEvents.filter { event in
            calendar.component(.hour, from: event.date) == calendar.component(.hour, from: hour)
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0.5) {
                ForEach(timeSlots, id: \.self) { timeSlot in
                    SimpleDayHourRow(
                        hour: timeSlot,
                        events: eventsForHour(timeSlot),
                        isCurrentHour: Calendar.current.isDate(timeSlot, equalTo: Date(), toGranularity: .hour)
                    )
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .padding(.horizontal)
    }
}

// MARK: - Simple Day Hour Row
struct SimpleDayHourRow: View {
    let hour: Date
    let events: [CalendarEvent]
    let isCurrentHour: Bool
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Time label
            VStack {
                Text(timeFormatter.string(from: hour))
                    .font(.caption)
                    .fontWeight(isCurrentHour ? .bold : .medium)
                    .foregroundColor(isCurrentHour ? .blue : .secondary)
                    .frame(width: 50, alignment: .trailing)
                
                Spacer()
            }
            
            // Events column
            VStack(spacing: 6) {
                if events.isEmpty {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 40)
                        .overlay(
                            Rectangle()
                                .stroke(Color(.systemGray5), lineWidth: 0.5),
                            alignment: .top
                        )
                } else {
                    ForEach(events, id: \.id) { event in
                        SimpleDayEventCard(event: event)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 8)
        .background(isCurrentHour ? Color.blue.opacity(0.02) : Color.clear)
    }
}

// MARK: - Simple Day Event Card
struct SimpleDayEventCard: View {
    let event: CalendarEvent
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(event.color)
                .frame(width: 3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                HStack {
                    Image(systemName: "clock")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(timeFormatter.string(from: event.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !event.location.isEmpty {
                    HStack {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                            .foregroundColor(event.color)
                        
                        Text(event.location)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                if !event.notes.isEmpty {
                    Text(event.notes)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
            }
            
            Spacer()
            
            Circle()
                .fill(event.color)
                .frame(width: 8, height: 8)
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 0.5)
    }
}