import SwiftUI

// MARK: - Enhanced Week View
struct EnhancedWeekView: View {
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
            // TEST BANNER - to confirm enhanced view is loading
            Text("🚀 ENHANCED WEEK VIEW LOADED! 🚀")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
            
            // Enhanced week header
            VStack(spacing: 8) {
                // Month/year indicator
                Text(monthYearFormatter.string(from: focusedWeek))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                
                // Day headers with improved design
                HStack(spacing: 0) {
                    ForEach(weekDays, id: \.self) { date in
                        VStack(spacing: 8) {
                            // Day name
                            Text(dayNameFormatter.string(from: date))
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                                .tracking(0.5)
                            
                            // Day number with enhanced styling
                            Button(action: {
                                print("🟡 Week day header tapped: \(date)")
                                onDayTap(date)
                            }) {
                                ZStack {
                                    // Background circle
                                    Circle()
                                        .fill(backgroundColorForDate(date))
                                        .frame(width: 36, height: 36)
                                        .shadow(
                                            color: Calendar.current.isDateInToday(date) ? .blue.opacity(0.3) : .clear,
                                            radius: 4,
                                            x: 0,
                                            y: 2
                                        )
                                    
                                    // Day number
                                    Text(dayNumberFormatter.string(from: date))
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(textColorForDate(date))
                                }
                                .scaleEffect(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? 1.1 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedDate)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Event count indicator
                            let eventCount = eventsForDate(date).count
                            if eventCount > 0 {
                                Text("\(eventCount)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 16, height: 16)
                                    .background(
                                        Circle()
                                            .fill(eventCount > 3 ? .orange : .blue)
                                    )
                                    .offset(y: -2)
                            } else {
                                Spacer()
                                    .frame(height: 16)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 8)
            }
            .padding(.bottom, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
            .padding(.horizontal, 12)
            
            // Enhanced week calendar body
            ScrollView(.vertical, showsIndicators: false) {
                HStack(alignment: .top, spacing: 1) {
                    ForEach(weekDays, id: \.self) { date in
                        EnhancedWeekDayColumn(
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
                .padding(.horizontal, 12)
                .padding(.top, 8)
            }
            .background(Color(.systemGroupedBackground))
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .padding(.horizontal, 8)
    }
    
    private func backgroundColorForDate(_ date: Date) -> Color {
        if Calendar.current.isDateInToday(date) {
            return .blue
        } else if Calendar.current.isDate(date, inSameDayAs: selectedDate) {
            return .blue.opacity(0.2)
        } else {
            return Color(.systemGray5)
        }
    }
    
    private func textColorForDate(_ date: Date) -> Color {
        if Calendar.current.isDateInToday(date) {
            return .white
        } else {
            return .primary
        }
    }
    
    private var dayNameFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }
    
    private var dayNumberFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}

// MARK: - Enhanced Week Day Column
struct EnhancedWeekDayColumn: View {
    let date: Date
    let events: [CalendarEvent]
    let isToday: Bool
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            print("🟪 Week day column button tapped: \(date)")
            
            withAnimation(.spring(response: 0.15, dampingFraction: 0.7)) {
                isPressed = true
            }
            
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                    isPressed = false
                }
                onTap()
            }
        }) {
            VStack(spacing: 6) {
                if events.isEmpty {
                    // Empty state with better design
                    VStack(spacing: 12) {
                        Image(systemName: "calendar")
                            .font(.title2)
                            .foregroundColor(.gray.opacity(0.4))
                        
                        Text("Free Day")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        // Time blocks to show availability
                        VStack(spacing: 2) {
                            ForEach(0..<4) { _ in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color(.systemGray5))
                                    .frame(height: 8)
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                    .frame(maxWidth: .infinity, minHeight: 140)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6).opacity(0.5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                                    .opacity(0.3)
                            )
                    )
                } else {
                    // Events with timeline design
                    VStack(spacing: 4) {
                        ForEach(events.prefix(8), id: \.id) { event in
                            EnhancedEventCard(event: event, isFirst: event.id == events.first?.id)
                        }
                        
                        if events.count > 8 {
                            HStack {
                                Image(systemName: "ellipsis")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                                
                                Text("+\(events.count - 8) more")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                    }
                }
                
                Spacer(minLength: 0)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 3)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(columnBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(columnBorderColor, lineWidth: columnBorderWidth)
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.15, dampingFraction: 0.7), value: isPressed)
    }
    
    private var columnBackgroundColor: Color {
        if isSelected {
            return Color.blue.opacity(0.08)
        } else if isToday {
            return Color.orange.opacity(0.05)
        } else {
            return Color(.systemBackground)
        }
    }
    
    private var columnBorderColor: Color {
        if isSelected {
            return Color.blue.opacity(0.4)
        } else if isToday {
            return Color.orange.opacity(0.4)
        } else {
            return Color(.systemGray5)
        }
    }
    
    private var columnBorderWidth: CGFloat {
        return (isSelected || isToday) ? 1.5 : 0.5
    }
}

// MARK: - Enhanced Event Card
struct EnhancedEventCard: View {
    let event: CalendarEvent
    let isFirst: Bool
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            // Timeline indicator
            VStack(spacing: 0) {
                if isFirst {
                    Circle()
                        .fill(event.color)
                        .frame(width: 6, height: 6)
                } else {
                    Circle()
                        .fill(event.color.opacity(0.6))
                        .frame(width: 4, height: 4)
                }
                
                Rectangle()
                    .fill(event.color.opacity(0.3))
                    .frame(width: 1)
                    .frame(maxHeight: .infinity)
            }
            .frame(width: 6)
            
            // Event content
            VStack(alignment: .leading, spacing: 3) {
                // Time and title
                VStack(alignment: .leading, spacing: 1) {
                    Text(timeFormatter.string(from: event.date))
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(event.color)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(
                            Capsule()
                                .fill(event.color.opacity(0.15))
                        )
                    
                    Text(event.title)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.primary)
                }
                
                // Location if available
                if !event.location.isEmpty {
                    HStack(spacing: 2) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 8))
                            .foregroundColor(event.color.opacity(0.7))
                        
                        Text(event.location)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(event.color.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(event.color.opacity(0.25), lineWidth: 0.5)
                )
        )
        .shadow(color: event.color.opacity(0.2), radius: 1, x: 0, y: 0.5)
    }
}