import SwiftUI

// MARK: - Working Day View
struct WorkingDayView: View {
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
                    WorkingDayHourRow(
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

// MARK: - Working Day Hour Row
struct WorkingDayHourRow: View {
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
                        WorkingDayEventCard(event: event)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 8)
        .background(isCurrentHour ? Color.blue.opacity(0.02) : Color.clear)
    }
}

// MARK: - Working Day Event Card
struct WorkingDayEventCard: View {
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