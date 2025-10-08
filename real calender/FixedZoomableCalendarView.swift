import SwiftUI

enum CalendarMode: String, CaseIterable {
    case month = "Month"
    case week = "Week" 
    case day = "Day"
}

struct FixedZoomableCalendarView: View {
    @Binding var events: [CalendarEvent]
    @State private var currentMode: CalendarMode = .month
    @State private var selectedDate = Date()
    @State private var focusedWeek: Date = Date()
    @State private var focusedDay: Date = Date()
    
    var body: some View {
        VStack(spacing: 8) {
            // Header
            calendarHeader
            
            // Main content with smooth transitions
            ZStack {
                calendarContent
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentMode)
            
            // Controls
            controlsBar
        }
        .onAppear {
            focusedWeek = selectedDate
            focusedDay = selectedDate
        }
    }
    
    private var calendarHeader: some View {
        VStack(spacing: 8) {
            HStack {
                if currentMode != .month {
                    Button("← \(previousMode)") {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            zoomOut()
                        }
                    }
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(6)
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text(currentMode.rawValue)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(dateRangeText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Today") {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        selectedDate = Date()
                        focusedWeek = Date()
                        focusedDay = Date()
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            
            HStack {
                Button(action: navigatePrevious) {
                    Image(systemName: "chevron.left.circle")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text("Tap day numbers to navigate")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: navigateNext) {
                    Image(systemName: "chevron.right.circle")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    @ViewBuilder
    private var calendarContent: some View {
        switch currentMode {
        case .month:
            FixedMonthView(
                events: events,
                selectedDate: $selectedDate,
                onDayTap: handleDayTap
            )
            
        case .week:
            FixedWeekView(
                events: events,
                focusedWeek: focusedWeek,
                selectedDate: $selectedDate,
                onDayTap: handleDayTap
            )
            
        case .day:
            FixedDayView(
                events: events,
                focusedDay: focusedDay
            )
        }
    }
    
    private var controlsBar: some View {
        HStack(spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: "calendar.badge.plus")
                    .foregroundColor(.blue)
                Text("\(eventsCount) events")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            // Zoom controls
            HStack(spacing: 8) {
                if currentMode != .month {
                    Button(action: { withAnimation(.spring()) { zoomOut() } }) {
                        Image(systemName: "minus.magnifyingglass")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.orange)
                            .clipShape(Circle())
                    }
                }
                
                if currentMode != .day {
                    Button(action: { withAnimation(.spring()) { zoomIn() } }) {
                        Image(systemName: "plus.magnifyingglass")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }
            }
            
            // Mode switcher
            HStack(spacing: 4) {
                ForEach(CalendarMode.allCases, id: \.self) { mode in
                    Button(mode.rawValue.prefix(1).uppercased()) {
                        withAnimation(.spring()) {
                            switchToMode(mode)
                        }
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(mode == currentMode ? .white : .blue)
                    .frame(width: 24, height: 24)
                    .background(mode == currentMode ? Color.blue : Color.blue.opacity(0.1))
                    .cornerRadius(4)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Computed Properties
    private var previousMode: String {
        switch currentMode {
        case .month: return ""
        case .week: return "Month"
        case .day: return "Week"
        }
    }
    
    private var dateRangeText: String {
        let formatter = DateFormatter()
        
        switch currentMode {
        case .month:
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: selectedDate)
            
        case .week:
            let calendar = Calendar.current
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: focusedWeek) ?? 
                              DateInterval(start: focusedWeek, duration: 7 * 24 * 60 * 60)
            formatter.dateFormat = "MMM d"
            let start = formatter.string(from: weekInterval.start)
            let end = formatter.string(from: calendar.date(byAdding: .day, value: 6, to: weekInterval.start) ?? weekInterval.start)
            return "\(start) - \(end)"
            
        case .day:
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: focusedDay)
        }
    }
    
    private var eventsCount: Int {
        let calendar = Calendar.current
        
        switch currentMode {
        case .month:
            return events.filter { calendar.isDate($0.date, equalTo: selectedDate, toGranularity: .month) }.count
        case .week:
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: focusedWeek) ?? 
                              DateInterval(start: focusedWeek, duration: 7 * 24 * 60 * 60)
            return events.filter { weekInterval.contains($0.date) }.count
        case .day:
            return events.filter { calendar.isDate($0.date, inSameDayAs: focusedDay) }.count
        }
    }
    
    // MARK: - Navigation Methods
    private func handleDayTap(_ date: Date) {
        print("✅ Fixed calendar day tapped: \(date)")
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        selectedDate = date
        focusedDay = date
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            switch currentMode {
            case .month:
                focusedWeek = date
                currentMode = .week
                
            case .week:
                currentMode = .day
                
            case .day:
                break
            }
        }
    }
    
    private func zoomIn() {
        switch currentMode {
        case .month:
            focusedWeek = selectedDate
            currentMode = .week
        case .week:
            focusedDay = selectedDate
            currentMode = .day
        case .day:
            break
        }
    }
    
    private func zoomOut() {
        switch currentMode {
        case .month:
            break
        case .week:
            currentMode = .month
        case .day:
            currentMode = .week
        }
    }
    
    private func switchToMode(_ mode: CalendarMode) {
        guard mode != currentMode else { return }
        
        currentMode = mode
        
        if mode == .week && !Calendar.current.isDate(focusedWeek, equalTo: selectedDate, toGranularity: .weekOfYear) {
            focusedWeek = selectedDate
        } else if mode == .day && !Calendar.current.isDate(focusedDay, inSameDayAs: selectedDate) {
            focusedDay = selectedDate
        }
    }
    
    private func navigatePrevious() {
        let calendar = Calendar.current
        
        withAnimation(.easeInOut(duration: 0.3)) {
            switch currentMode {
            case .month:
                if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
                    selectedDate = newDate
                }
            case .week:
                if let newWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: focusedWeek) {
                    focusedWeek = newWeek
                    selectedDate = newWeek
                }
            case .day:
                if let newDay = calendar.date(byAdding: .day, value: -1, to: focusedDay) {
                    focusedDay = newDay
                    selectedDate = newDay
                }
            }
        }
    }
    
    private func navigateNext() {
        let calendar = Calendar.current
        
        withAnimation(.easeInOut(duration: 0.3)) {
            switch currentMode {
            case .month:
                if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
                    selectedDate = newDate
                }
            case .week:
                if let newWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: focusedWeek) {
                    focusedWeek = newWeek
                    selectedDate = newWeek
                }
            case .day:
                if let newDay = calendar.date(byAdding: .day, value: 1, to: focusedDay) {
                    focusedDay = newDay
                    selectedDate = newDay
                }
            }
        }
    }
}

// MARK: - Fixed Month View (Using Working Button Structure)
struct FixedMonthView: View {
    let events: [CalendarEvent]
    @Binding var selectedDate: Date
    let onDayTap: (Date) -> Void
    
    private var monthDays: [Date] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate) else { return [] }
        
        let startOfMonth = monthInterval.start
        let startWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysFromPreviousMonth = (startWeekday - calendar.firstWeekday + 7) % 7
        
        guard let calendarStart = calendar.date(byAdding: .day, value: -daysFromPreviousMonth, to: startOfMonth) else { return [] }
        
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
            
            // Calendar grid - EXACTLY like working debug test
            VStack(spacing: 1) {
                ForEach(weeks.indices, id: \.self) { weekIndex in
                    let week = weeks[weekIndex]
                    
                    HStack(spacing: 1) {
                        ForEach(week, id: \.self) { date in
                            // Using the EXACT working button structure
                            Button(action: {
                                print("🟢 FIXED: Day \(dayFormatter.string(from: date)) tapped!")
                                onDayTap(date)
                            }) {
                                VStack(spacing: 3) {
                                    Text(dayFormatter.string(from: date))
                                        .font(.system(size: 14, weight: Calendar.current.isDateInToday(date) ? .bold : .medium))
                                        .foregroundColor(textColor(for: date))
                                    
                                    // Event indicators
                                    HStack(spacing: 1) {
                                        ForEach(eventsForDate(date).prefix(3), id: \.id) { event in
                                            Circle()
                                                .fill(event.color)
                                                .frame(width: 4, height: 4)
                                        }
                                        
                                        if eventsForDate(date).count > 3 {
                                            Text("+")
                                                .font(.system(size: 6, weight: .bold))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .frame(height: 8)
                                }
                                .frame(maxWidth: .infinity, minHeight: 45)
                                .background(backgroundColor(for: date))
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? Color.blue : Color.clear, lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
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
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
    
    private func eventsForDate(_ date: Date) -> [CalendarEvent] {
        return events.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    private func textColor(for date: Date) -> Color {
        if Calendar.current.isDateInToday(date) {
            return .white
        } else if !Calendar.current.isDate(date, equalTo: selectedDate, toGranularity: .month) {
            return .secondary
        } else {
            return .primary
        }
    }
    
    private func backgroundColor(for date: Date) -> Color {
        if Calendar.current.isDateInToday(date) {
            return .blue
        } else if Calendar.current.isDate(date, inSameDayAs: selectedDate) {
            return .blue.opacity(0.2)
        } else {
            return .clear
        }
    }
}

// MARK: - Fixed Week View
struct FixedWeekView: View {
    let events: [CalendarEvent]
    let focusedWeek: Date
    @Binding var selectedDate: Date
    let onDayTap: (Date) -> Void
    
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
    
    var body: some View {
        VStack(spacing: 0) {
            // Week header
            HStack(spacing: 0) {
                ForEach(weekDays, id: \.self) { date in
                    VStack(spacing: 6) {
                        Text(dayNameFormatter.string(from: date))
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        Button(action: {
                            print("🟡 Week header day tapped: \(date)")
                            onDayTap(date)
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Calendar.current.isDateInToday(date) ? Color.blue : 
                                          Calendar.current.isDate(date, inSameDayAs: selectedDate) ? Color.blue.opacity(0.3) : Color.clear)
                                    .frame(width: 28, height: 28)
                                
                                Text(dayFormatter.string(from: date))
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
            
            // Week body
            ScrollView {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(weekDays, id: \.self) { date in
                        Button(action: {
                            print("🟢 Week day column tapped: \(date)")
                            onDayTap(date)
                        }) {
                            VStack(spacing: 4) {
                                let dayEvents = eventsForDate(date)
                                
                                if dayEvents.isEmpty {
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
                                    ForEach(dayEvents.prefix(6), id: \.id) { event in
                                        EventCard(event: event)
                                    }
                                    
                                    if dayEvents.count > 6 {
                                        Text("+\(dayEvents.count - 6)")
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
                        .background(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? Color.blue.opacity(0.05) : 
                                   (Calendar.current.isDateInToday(date) ? Color.orange.opacity(0.05) : Color.clear))
                        .overlay(
                            Rectangle()
                                .frame(width: 0.5)
                                .foregroundColor(Color(.systemGray5)),
                            alignment: .trailing
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
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
    
    private func eventsForDate(_ date: Date) -> [CalendarEvent] {
        return events.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.date < $1.date }
    }
}

// MARK: - Fixed Day View
struct FixedDayView: View {
    let events: [CalendarEvent]
    let focusedDay: Date
    
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
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0.5) {
                ForEach(timeSlots, id: \.self) { timeSlot in
                    HourRow(hour: timeSlot, events: eventsForHour(timeSlot))
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .padding(.horizontal)
    }
    
    private func eventsForHour(_ hour: Date) -> [CalendarEvent] {
        let calendar = Calendar.current
        return dayEvents.filter { event in
            calendar.component(.hour, from: event.date) == calendar.component(.hour, from: hour)
        }
    }
}

// MARK: - Supporting Views
private struct EventCard: View {
    let event: CalendarEvent
    
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
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

struct HourRow: View {
    let hour: Date
    let events: [CalendarEvent]
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack {
                Text(timeFormatter.string(from: hour))
                    .font(.caption)
                    .fontWeight(Calendar.current.isDate(hour, equalTo: Date(), toGranularity: .hour) ? .bold : .medium)
                    .foregroundColor(Calendar.current.isDate(hour, equalTo: Date(), toGranularity: .hour) ? .blue : .secondary)
                    .frame(width: 50, alignment: .trailing)
                
                Spacer()
            }
            
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
                        DayEventCard(event: event)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 8)
        .background(Calendar.current.isDate(hour, equalTo: Date(), toGranularity: .hour) ? Color.blue.opacity(0.02) : Color.clear)
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

struct DayEventCard: View {
    let event: CalendarEvent
    
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
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

#Preview {
    FixedZoomableCalendarView(events: .constant([]))
}