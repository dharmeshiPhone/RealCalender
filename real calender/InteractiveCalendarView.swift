import SwiftUI

struct InteractiveCalendarView: View {
    @Binding var selectedDate: Date
    let events: [CalendarEvent]
    
    @State private var currentMonth = Date()
    @State private var highlightedDay: Date?
    @State private var adjacentDays: Set<Date> = [] // Only immediate neighbors
    @State private var dragLocation: CGPoint = .zero
    @State private var isDragging = false
    @State private var cellSize: CGSize = .zero
    @State private var gridFrame: CGRect = .zero
    @State private var lastHighlightTime: Date = Date()
    @State private var highlightClearTimer: Timer?
    
    // Navigation states
    @State private var currentMode: CalendarMode = .month
    @State private var focusedWeek: Date = Date()
    @State private var focusedDay: Date = Date()
    
    enum CalendarMode {
        case month, week, day
    }
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)
    
    private var monthDays: [Date] {
        let monthInterval = calendar.dateInterval(of: .month, for: currentMonth)!
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
    
    private var monthYearText: String {
        currentDateRange
    }
    
    private var monthNavigationHeader: some View {
        EmptyView() // Replaced by navigationHeader
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation header
            navigationHeader
            
            // Main content based on current mode
            ZStack {
                switch currentMode {
                case .month:
                    monthView
                case .week:
                    weekView
                case .day:
                    dayView
                }
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentMode)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .onAppear {
            focusedWeek = selectedDate
            focusedDay = selectedDate
        }
    }
    
    // MARK: - Navigation Header
    private var navigationHeader: some View {
        HStack {
            // Back button for week/day modes
            if currentMode != .month {
                Button(action: navigateBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.caption)
                        Text(previousModeTitle)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(6)
                }
            }
            
            // Navigation arrows (left side)
            Button(action: { changeTimeframe(-1) }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .padding(8)
            }
            
            Spacer()
            
            // Current mode and date range
            VStack(spacing: 2) {
                Text(currentMode == .month ? "Month" : currentMode == .week ? "Week" : "Day")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Text(currentDateRange)
                    .font(.title2)
                    .fontWeight(.bold)
                    .animation(.easeInOut(duration: 0.3), value: currentDateRange)
            }
            
            Spacer()
            
            // Navigation arrows (right side)
            Button(action: { changeTimeframe(1) }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .padding(8)
            }
            
            // Today button
            Button("Today") {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    selectedDate = Date()
                    currentMonth = Date()
                    focusedWeek = Date()
                    focusedDay = Date()
                    currentMode = .month
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .font(.caption)
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
        .background(Color(.systemGray6))
    }
    
    // MARK: - Month View
    @ViewBuilder
    private var monthView: some View {
        VStack(spacing: 0) {
            // Weekday headers
            weekdayHeaders
            
            // Calendar grid with enhanced interaction
            calendarGridContainer
        }
    }
    
    // MARK: - Week View
    @ViewBuilder
    private var weekView: some View {
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
                            navigateToDay(date)
                        }) {
                            ZStack {
                                Circle()
                                    .fill(calendar.isDateInToday(date) ? Color.blue : 
                                          calendar.isDate(date, inSameDayAs: selectedDate) ? Color.blue.opacity(0.3) : Color.clear)
                                    .frame(width: 28, height: 28)
                                
                                Text(dayNumberFormatter.string(from: date))
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(calendar.isDateInToday(date) ? .white : .primary)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            
            // Week body with day columns
            ScrollView {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(weekDays, id: \.self) { date in
                        Button(action: {
                            navigateToDay(date)
                        }) {
                            WeekDayColumn(
                                date: date,
                                events: eventsForDate(date),
                                isToday: calendar.isDateInToday(date),
                                isSelected: calendar.isDate(date, inSameDayAs: selectedDate)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .frame(minHeight: 250)
            }
        }
    }
    
    // MARK: - Day View
    @ViewBuilder
    private var dayView: some View {
        ScrollView {
            LazyVStack(spacing: 0.5) {
                ForEach(timeSlots, id: \.self) { timeSlot in
                    DayHourRow(
                        hour: timeSlot,
                        events: eventsForHour(timeSlot),
                        isCurrentHour: calendar.isDate(timeSlot, equalTo: Date(), toGranularity: .hour)
                    )
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .padding(.horizontal)
    }
    
    private var weekdayHeaders: some View {
        HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { index in
                Text(dayNameFormatter.string(from: calendar.date(byAdding: .day, value: index, to: Date())!))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    private var calendarGridContainer: some View {
        GeometryReader { geometry in
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(monthDays.indices, id: \.self) { index in
                    let date = monthDays[index]
                    InteractiveDayCell(
                        date: date,
                        events: eventsForDate(date),
                        isCurrentMonth: isCurrentMonth(date),
                        isToday: calendar.isDateInToday(date),
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        isHighlighted: highlightedDay != nil && calendar.isDate(date, inSameDayAs: highlightedDay!),
                        isAdjacent: adjacentDays.contains { calendar.isDate(date, inSameDayAs: $0) },
                        onTap: { selectDate(date) },
                        index: index
                    )
                    .background(
                        GeometryReader { cellGeometry in
                            Color.clear
                                .onAppear {
                                    if index == 0 {
                                        cellSize = cellGeometry.size
                                    }
                                }
                        }
                    )
                }
            }
            .padding(8)
            .background(
                GeometryReader { gridGeometry in
                    Color(.systemBackground)
                        .onAppear {
                            gridFrame = gridGeometry.frame(in: .local)
                        }
                        .onChange(of: gridGeometry.frame(in: .local)) { _, newFrame in
                            gridFrame = newFrame
                        }
                }
            )
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        handleDragChanged(value)
                    }
                    .onEnded { value in
                        handleDragEnded(value)
                    }
            )
        }
        .frame(height: calculateGridHeight())
    }
    
    private var weekDays: [Date] {
        let weekInterval = calendar.dateInterval(of: .weekOfYear, for: focusedWeek) ?? 
                          DateInterval(start: focusedWeek, duration: 7 * 24 * 60 * 60)
        
        var days: [Date] = []
        for i in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: i, to: weekInterval.start) {
                days.append(day)
            }
        }
        return days
    }
    
    private var timeSlots: [Date] {
        let startOfDay = calendar.startOfDay(for: focusedDay)
        
        var slots: [Date] = []
        for hour in 6..<23 {
            if let timeSlot = calendar.date(byAdding: .hour, value: hour, to: startOfDay) {
                slots.append(timeSlot)
            }
        }
        return slots
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
    
    private func calculateGridHeight() -> CGFloat {
        // Calculate based on rows needed (usually 6 rows max)
        let rowsNeeded = ceil(Double(monthDays.count) / 7.0)
        let cellHeight: CGFloat = 50
        let spacing: CGFloat = 2
        let padding: CGFloat = 16
        
        return (rowsNeeded * cellHeight) + ((rowsNeeded - 1) * spacing) + padding
    }
    
    private func eventsForDate(_ date: Date) -> [CalendarEvent] {
        return events.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    private func eventsForHour(_ hour: Date) -> [CalendarEvent] {
        return eventsForDate(focusedDay).filter { event in
            calendar.component(.hour, from: event.date) == calendar.component(.hour, from: hour)
        }
    }
    
    private func isCurrentMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }
    
    private func selectDate(_ date: Date) {
        // Show highlight animation on tap
        if let touchedDay = date as Date? {
            withAnimation(.easeOut(duration: 0.08)) {
                highlightedDay = touchedDay
                adjacentDays = getAdjacentDays(for: touchedDay)
            }
            
            // Keep the tap highlight visible briefly
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.2)) {
                    if !isDragging { // Only clear if user isn't dragging
                        highlightedDay = nil
                        adjacentDays.removeAll()
                    }
                }
            }
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedDate = date
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // NAVIGATE TO WEEK VIEW when day is tapped
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            navigateToWeek(date)
        }
    }
    
    private func changeTimeframe(_ direction: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            switch currentMode {
            case .month:
                if let newMonth = calendar.date(byAdding: .month, value: direction, to: currentMonth) {
                    currentMonth = newMonth
                }
            case .week:
                if let newWeek = calendar.date(byAdding: .weekOfYear, value: direction, to: focusedWeek) {
                    focusedWeek = newWeek
                    selectedDate = newWeek
                }
            case .day:
                if let newDay = calendar.date(byAdding: .day, value: direction, to: focusedDay) {
                    focusedDay = newDay
                    selectedDate = newDay
                }
            }
        }
        
        // Clear highlights when changing timeframes
        clearHighlights(immediate: true)
    }
    
    private func handleDragChanged(_ value: DragGesture.Value) {
        isDragging = true
        dragLocation = value.location
        
        // Cancel any pending clear timers since user is actively dragging
        highlightClearTimer?.invalidate()
        highlightClearTimer = nil
        
        // More precise day finding with actual cell dimensions
        if let touchedDay = findDayAtLocationPrecise(value.location) {
            // Only update if it's a different day to prevent excessive updates
            if highlightedDay == nil || !calendar.isDate(touchedDay, inSameDayAs: highlightedDay!) {
                
                // Immediately clear old highlights and set new ones (5 days total)
                withAnimation(.easeOut(duration: 0.08)) {
                    highlightedDay = touchedDay
                    adjacentDays = getAdjacentDays(for: touchedDay)
                    lastHighlightTime = Date()
                }
                
                // Light haptic feedback for smooth tracking
                let impactFeedback = UIImpactFeedbackGenerator(style: .soft)
                impactFeedback.impactOccurred(intensity: 0.3)
            }
        }
    }
    
    private func handleDragEnded(_ value: DragGesture.Value) {
        isDragging = false
        
        // Select the day if it was a tap/short drag
        if let touchedDay = findDayAtLocationPrecise(value.location) {
            selectDate(touchedDay)
        }
        
        // Keep highlights visible for a short time after touch ends
        scheduleHighlightClear()
    }
    
    private func scheduleHighlightClear() {
        // Cancel any existing timer first
        highlightClearTimer?.invalidate()
        
        // Schedule clearing highlights after a short delay
        highlightClearTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { _ in
            clearHighlights(immediate: false)
        }
    }
    
    private func clearHighlights(immediate: Bool) {
        if immediate {
            // Immediate clear (for month changes, etc.)
            highlightedDay = nil
            adjacentDays.removeAll()
        } else {
            // Smooth fade out animation
            withAnimation(.easeOut(duration: 0.3)) {
                highlightedDay = nil
                adjacentDays.removeAll()
            }
        }
        
        // Clear any pending timers
        highlightClearTimer?.invalidate()
        highlightClearTimer = nil
    }
    
    private func findDayAtLocationPrecise(_ location: CGPoint) -> Date? {
        // More accurate calculation using actual grid dimensions
        let gridLocation = CGPoint(
            x: location.x - 8, // Account for padding
            y: location.y - 8
        )
        
        // Use actual cell dimensions if available, otherwise estimate
        let cellWidth = cellSize.width > 0 ? cellSize.width + 2 : (gridFrame.width - 16) / 7 // Include spacing
        let cellHeight = cellSize.height > 0 ? cellSize.height + 2 : 52 // Include spacing
        
        let column = Int(gridLocation.x / cellWidth)
        let row = Int(gridLocation.y / cellHeight)
        
        guard column >= 0, column < 7, row >= 0, row < 6 else { return nil }
        
        let dayIndex = row * 7 + column
        guard dayIndex >= 0, dayIndex < monthDays.count else { return nil }
        
        return monthDays[dayIndex]
    }
    
    private func getAdjacentDays(for date: Date) -> Set<Date> {
        var adjacent = Set<Date>()
        
        // Get the index of the current date in the monthDays array
        guard let currentIndex = monthDays.firstIndex(of: date) else { return adjacent }
        
        let row = currentIndex / 7
        let col = currentIndex % 7
        
        // Get the 4 directly adjacent days (top, bottom, left, right)
        
        // Top
        if row > 0 {
            let topIndex = (row - 1) * 7 + col
            if topIndex < monthDays.count {
                adjacent.insert(monthDays[topIndex])
            }
        }
        
        // Bottom
        if row < 5 {
            let bottomIndex = (row + 1) * 7 + col
            if bottomIndex < monthDays.count {
                adjacent.insert(monthDays[bottomIndex])
            }
        }
        
        // Left
        if col > 0 {
            let leftIndex = row * 7 + (col - 1)
            if leftIndex < monthDays.count {
                adjacent.insert(monthDays[leftIndex])
            }
        }
        
        // Right
        if col < 6 {
            let rightIndex = row * 7 + (col + 1)
            if rightIndex < monthDays.count {
                adjacent.insert(monthDays[rightIndex])
            }
        }
        
        return adjacent
    }
    
    private func navigateBack() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            switch currentMode {
            case .month:
                break
            case .week:
                currentMode = .month
            case .day:
                currentMode = .week
            }
        }
    }
    
    private func navigateToWeek(_ date: Date) {
        print("✅ INTERACTIVE: Navigating to week for date: \(date)")
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        selectedDate = date
        focusedWeek = date
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            currentMode = .week
        }
    }
    
    private func navigateToDay(_ date: Date) {
        print("✅ INTERACTIVE: Navigating to day for date: \(date)")
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        selectedDate = date
        focusedDay = date
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            currentMode = .day
        }
    }
    
    private var previousModeTitle: String {
        switch currentMode {
        case .month: return ""
        case .week: return "Month"
        case .day: return "Week"
        }
    }
    
    private var currentDateRange: String {
        let formatter = DateFormatter()
        
        switch currentMode {
        case .month:
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: currentMonth)
            
        case .week:
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
}

struct InteractiveDayCell: View {
    let date: Date
    let events: [CalendarEvent]
    let isCurrentMonth: Bool
    let isToday: Bool
    let isSelected: Bool
    let isHighlighted: Bool
    let isAdjacent: Bool
    let onTap: () -> Void
    let index: Int
    
    @State private var bounceScale: CGFloat = 1.0
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    // Individual square radial gradient from center to edges
    private var radialGradientBackground: some View {
        if isHighlighted {
            // Main day: Use orange gradient if it's today, otherwise blue
            let gradientColor: Color = isToday ? .orange : .blue
            return AnyView(
                RadialGradient(
                    gradient: Gradient(colors: [
                        gradientColor.opacity(0.9),    // Strong color in center
                        gradientColor.opacity(0.7),    // Medium color
                        gradientColor.opacity(0.4),    // Light color
                        gradientColor.opacity(0.1),    // Very light color
                        .clear                         // Transparent at edges
                    ]),
                    center: .center,
                    startRadius: 5,
                    endRadius: 22
                )
            )
        } else if isAdjacent {
            // Adjacent days: Use orange gradient if it's today, otherwise blue
            let gradientColor: Color = isToday ? .orange : .blue
            return AnyView(
                RadialGradient(
                    gradient: Gradient(colors: [
                        gradientColor.opacity(0.6),    // Medium color in center
                        gradientColor.opacity(0.4),    // Light color
                        gradientColor.opacity(0.2),    // Very light color
                        gradientColor.opacity(0.05),   // Barely visible color
                        .clear                         // Transparent at edges
                    ]),
                    center: .center,
                    startRadius: 3,
                    endRadius: 22
                )
            )
        } else {
            return AnyView(Color.clear)
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                // Day number
                Text(dayNumber)
                    .font(.system(size: 16, weight: isToday ? .bold : .medium))
                    .foregroundColor(textColor)
                    .scaleEffect(textScale)
                    .animation(.easeInOut(duration: 0.08), value: isHighlighted)
                    .animation(.easeInOut(duration: 0.08), value: isAdjacent)
                
                // Event indicators with enhanced visibility
                HStack(spacing: 2) {
                    ForEach(events.prefix(3), id: \.id) { event in
                        Circle()
                            .fill(event.color)
                            .frame(width: eventDotSize, height: eventDotSize)
                            .scaleEffect(eventDotScale)
                            .animation(.easeInOut(duration: 0.08), value: isHighlighted)
                            .animation(.easeInOut(duration: 0.08), value: isAdjacent)
                    }
                    
                    if events.count > 3 {
                        Circle()
                            .fill(Color.secondary)
                            .frame(width: eventDotSize, height: eventDotSize)
                            .scaleEffect(eventDotScale)
                            .animation(.easeInOut(duration: 0.08), value: isHighlighted)
                            .animation(.easeInOut(duration: 0.08), value: isAdjacent)
                    }
                }
                .frame(height: 8)
            }
            .frame(width: 44, height: 44)
            .background(baseBackground)
            .background(radialGradientBackground) // Radial gradient overlay
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
                    .animation(.easeInOut(duration: 0.08), value: isHighlighted)
                    .animation(.easeInOut(duration: 0.08), value: isAdjacent)
            )
            .scaleEffect(overallScale * bounceScale)
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: shadowOffset
            )
            .animation(.spring(response: 0.12, dampingFraction: 0.7), value: isHighlighted)
            .animation(.spring(response: 0.12, dampingFraction: 0.7), value: isAdjacent)
            .onChange(of: isHighlighted) { oldValue, newValue in
                if newValue && !oldValue {
                    // Small bounce animation when highlighted
                    withAnimation(.easeInOut(duration: 0.06)) {
                        bounceScale = 1.05
                    }
                    withAnimation(.easeInOut(duration: 0.06).delay(0.06)) {
                        bounceScale = 1.0
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Base background (for non-highlighted states)
    private var baseBackground: Color {
        if isSelected {
            return .blue
        } else if isToday {
            return .orange.opacity(0.15)
        } else {
            return isCurrentMonth ? Color(.systemBackground) : Color(.systemGray6)
        }
    }
    
    private var textColor: Color {
        if isHighlighted || isSelected {
            return .white
        } else if isAdjacent {
            return .white.opacity(0.95)
        } else if isToday {
            return .orange
        } else {
            return isCurrentMonth ? .primary : .secondary
        }
    }
    
    private var borderColor: Color {
        if isHighlighted {
            return Color.clear // No border for main highlighted day
        } else if isAdjacent {
            return Color.clear // No border for adjacent days either (gradient handles the effect)
        } else if isSelected {
            return .blue
        } else if isToday {
            return .orange.opacity(0.7)
        } else {
            return Color.clear
        }
    }
    
    private var shadowColor: Color {
        if isHighlighted {
            return .blue.opacity(0.5)
        } else if isAdjacent {
            return .blue.opacity(0.3)
        } else {
            return .black.opacity(0.1)
        }
    }
    
    private var borderWidth: CGFloat {
        if isHighlighted {
            return 0 // No border for main highlighted day
        } else if isAdjacent {
            return 0 // No border for adjacent days
        } else if isSelected {
            return 2.5
        } else if isToday {
            return 1.5
        } else {
            return 0
        }
    }
    
    private var cornerRadius: CGFloat {
        if isHighlighted {
            return 12
        } else if isAdjacent {
            return 10
        } else {
            return 8
        }
    }
    
    private var overallScale: CGFloat {
        if isHighlighted {
            return 1.20
        } else if isAdjacent {
            return 1.10
        } else {
            return 1.0
        }
    }
    
    private var textScale: CGFloat {
        if isHighlighted {
            return 1.15
        } else if isAdjacent {
            return 1.08
        } else {
            return 1.0
        }
    }
    
    private var eventDotScale: CGFloat {
        if isHighlighted {
            return 1.3
        } else if isAdjacent {
            return 1.15
        } else {
            return 1.0
        }
    }
    
    private var shadowRadius: CGFloat {
        if isHighlighted {
            return 10
        } else if isAdjacent {
            return 6
        } else {
            return 2
        }
    }
    
    private var shadowOffset: CGFloat {
        if isHighlighted {
            return 5
        } else if isAdjacent {
            return 3
        } else {
            return 1
        }
    }
    
    private var eventDotSize: CGFloat {
        if isHighlighted {
            return 6
        } else if isAdjacent {
            return 5
        } else {
            return 4
        }
    }
}

// MARK: - Supporting Views
private struct WeekDayColumn: View {
    let date: Date
    let events: [CalendarEvent]
    let isToday: Bool
    let isSelected: Bool
    
    var body: some View {
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
                    InteractiveEventCard(event: event)
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

struct InteractiveEventCard: View {
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

struct DayHourRow: View {
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
            VStack {
                Text(timeFormatter.string(from: hour))
                    .font(.caption)
                    .fontWeight(isCurrentHour ? .bold : .medium)
                    .foregroundColor(isCurrentHour ? .blue : .secondary)
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
                        InteractiveDayEventCard(event: event)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 8)
        .background(isCurrentHour ? Color.blue.opacity(0.02) : Color.clear)
    }
}

struct InteractiveDayEventCard: View {
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