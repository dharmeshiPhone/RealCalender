import SwiftUI

// MARK: - Working Zoomable Calendar View Main
struct ZoomableCalendarMainView: View {
    let events: [CalendarEvent]
    @State private var currentMode: CalendarViewMode = .month
    @State private var selectedDate = Date()
    @State private var focusedWeek: Date = Date()
    @State private var focusedDay: Date = Date()
    @State private var isTransitioning = false
    
    var body: some View {
        VStack(spacing: 8) {
            // Header with current mode and navigation
            calendarHeader
            
            // Main calendar content with smooth animations
            ZStack {
                calendarContent
                    .opacity(isTransitioning ? 0.9 : 1.0)
                    .scaleEffect(isTransitioning ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: isTransitioning)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentMode)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            
            // Quick action buttons with zoom controls
            quickActionsBar
        }
        .onAppear {
            focusedWeek = selectedDate
            focusedDay = selectedDate
        }
    }
    
    // MARK: - Calendar Header
    private var calendarHeader: some View {
        VStack(spacing: 8) {
            HStack {
                // Back button (for week and day modes)
                if currentMode != .month {
                    Button(action: zoomOut) {
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
                
                Spacer()
                
                // Current mode indicator
                VStack(alignment: .center, spacing: 2) {
                    HStack(spacing: 6) {
                        Image(systemName: modeIcon)
                            .font(.callout)
                            .foregroundColor(.primary)
                        
                        Text(currentMode.rawValue)
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    
                    Text(currentDateRange)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Today button
                Button("Today") {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        selectedDate = Date()
                        focusedWeek = Date()
                        focusedDay = Date()
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .font(.caption)
            }
            
            // Date navigation arrows
            HStack {
                Button(action: navigatePrevious) {
                    Image(systemName: "chevron.left.circle")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text("Tap day → Week → Day view")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
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
    
    // MARK: - Calendar Content
    @ViewBuilder
    private var calendarContent: some View {
        switch currentMode {
        case .month:
            WorkingMonthView(
                events: events,
                selectedDate: $selectedDate,
                onDayTap: handleDayTap
            )
            
        case .week:
            EnhancedWeekView(
                events: events,
                focusedWeek: focusedWeek,
                selectedDate: $selectedDate,
                onDayTap: handleDayTap
            )
            
        case .day:
            WorkingDayView(
                events: events,
                focusedDay: focusedDay,
                selectedDate: $selectedDate
            )
        }
    }
    
    // MARK: - Quick Actions Bar
    private var quickActionsBar: some View {
        HStack(spacing: 16) {
            // Events count for current view
            HStack(spacing: 6) {
                Image(systemName: "calendar.badge.plus")
                    .foregroundColor(.blue)
                    .font(.caption)
                
                Text("\(eventsForCurrentView.count) events")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            // Zoom controls
            HStack(spacing: 8) {
                // Zoom out button
                if currentMode != .month {
                    Button(action: zoomOut) {
                        Image(systemName: "minus.magnifyingglass")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.orange)
                            .clipShape(Circle())
                    }
                }
                
                // Zoom in button
                if currentMode != .day {
                    Button(action: zoomIn) {
                        Image(systemName: "plus.magnifyingglass")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }
            }
            
            // Quick mode switcher
            HStack(spacing: 4) {
                ForEach(CalendarViewMode.allCases, id: \.self) { mode in
                    Button(mode.rawValue.prefix(1).uppercased()) {
                        switchToMode(mode)
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
    private var modeIcon: String {
        switch currentMode {
        case .month: return "calendar"
        case .week: return "calendar.day.timeline.left"
        case .day: return "clock.fill"
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
    
    private var eventsForCurrentView: [CalendarEvent] {
        let calendar = Calendar.current
        
        switch currentMode {
        case .month:
            return events.filter { event in
                calendar.isDate(event.date, equalTo: selectedDate, toGranularity: .month)
            }
            
        case .week:
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: focusedWeek) ?? 
                              DateInterval(start: focusedWeek, duration: 7 * 24 * 60 * 60)
            return events.filter { event in
                weekInterval.contains(event.date)
            }
            
        case .day:
            return events.filter { event in
                calendar.isDate(event.date, inSameDayAs: focusedDay)
            }
        }
    }
    
    // MARK: - Navigation Functions
    private func zoomIn() {
        print("🔍 Zoom in button pressed, current mode: \(currentMode)")
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        withAnimation(.easeInOut(duration: 0.4)) {
            isTransitioning = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            switch currentMode {
            case .month:
                print("🔍 Zooming from month to week")
                currentMode = .week
                focusedWeek = selectedDate
                
            case .week:
                print("🔍 Zooming from week to day")  
                currentMode = .day
                focusedDay = selectedDate
                
            case .day:
                print("🔍 Already at maximum zoom")
                break
            }
            
            withAnimation(.easeInOut(duration: 0.2)) {
                isTransitioning = false
            }
        }
    }
    
    private func zoomOut() {
        print("🔍 Zoom out called, current mode: \(currentMode)")
        guard currentMode != .month else { return }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        withAnimation(.easeInOut(duration: 0.3)) {
            isTransitioning = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            switch currentMode {
            case .month:
                break
                
            case .week:
                print("🔍 Zooming from week to month")
                currentMode = .month
                
            case .day:
                print("🔍 Zooming from day to week")
                currentMode = .week
            }
            
            withAnimation(.easeInOut(duration: 0.15)) {
                isTransitioning = false
            }
        }
    }
    
    private func switchToMode(_ mode: CalendarViewMode) {
        guard mode != currentMode else { return }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            currentMode = mode
            
            // Ensure we have appropriate focus dates
            if mode == .week && !Calendar.current.isDate(focusedWeek, equalTo: selectedDate, toGranularity: .weekOfYear) {
                focusedWeek = selectedDate
            } else if mode == .day && !Calendar.current.isDate(focusedDay, inSameDayAs: selectedDate) {
                focusedDay = selectedDate
            }
        }
    }
    
    private func navigatePrevious() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        withAnimation(.easeInOut(duration: 0.3)) {
            let calendar = Calendar.current
            
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
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        withAnimation(.easeInOut(duration: 0.3)) {
            let calendar = Calendar.current
            
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
    
    // MARK: - Tap Handlers
    private func handleDayTap(_ date: Date) {
        print("✅ Day tapped: \(date)")
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        selectedDate = date
        focusedDay = date
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            switch currentMode {
            case .month:
                print("📅 Switching to week view")
                focusedWeek = date
                currentMode = .week
                
            case .week:
                print("📋 Switching to day view")
                currentMode = .day
                
            case .day:
                print("📍 Already in day view")
                break
            }
        }
    }
}