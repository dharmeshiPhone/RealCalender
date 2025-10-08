import SwiftUI

struct SimpleCalendarPopup: View {
    @Binding var isShowing: Bool
    let events: [CalendarEvent]
    let onConfirm: () -> Void
    let onRetakePhoto: () -> Void
    let onAddMorePhotos: () -> Void
    let onEventDeleted: (CalendarEvent) -> Void
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isShowing = false
                }
            
            // Popup content
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Review Schedule")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        isShowing = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                
                // Events list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if events.isEmpty {
                            Text("No events detected")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(events) { event in
                                EventReviewCard(
                                    event: event,
                                    onDelete: {
                                        onEventDeleted(event)
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Stats
                if !events.isEmpty {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Total Events:")
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(events.count)")
                                .fontWeight(.bold)
                        }
                        
                        let realEvents = events.filter { !$0.title.contains(" No Events Found") && !$0.title.contains(" Try Again with Better Photos") }
                        if realEvents.count != events.count {
                            HStack {
                                Text("Real Events:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text("\(realEvents.count)")
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: onConfirm) {
                        Text("✅ Use This Schedule")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                    Button(action: onAddMorePhotos) {
                        Text("➕ Add More Photos")
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(10)
                    }
                    
                    Button(action: onRetakePhoto) {
                        Text("📸 Retake Photos")
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 20)
            .frame(maxWidth: 500)
            .padding(.horizontal)
        }
    }
}

struct EventReviewCard: View {
    let event: CalendarEvent
    let onDelete: () -> Void
    
    private var isFallbackEvent: Bool {
        event.title.contains(" No Events Found") || event.title.contains(" Try Again with Better Photos")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Color indicator
                Rectangle()
                    .fill(event.color)
                    .frame(width: 4)
                    .cornerRadius(2)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(event.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(isFallbackEvent ? .red : .primary)
                        
                        Spacer()
                        
                        Button(action: onDelete) {
                            Image(systemName: "trash")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Date and time
                    Text(formatEventDateTime(event.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Location
                    if !event.location.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "location")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(event.location)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Teacher
                    if let teacher = event.teacher, !teacher.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "person")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(teacher)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Notes preview
                    if !event.notes.isEmpty {
                        Text(event.notes)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                .padding(.leading, 8)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private func formatEventDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
