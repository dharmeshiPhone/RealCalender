import SwiftUI

struct CalendarPopupViews {
    static func eventHeader(_ event: CalendarEvent) -> some View {
        HStack {
            eventColorIndicator(event)
            
            eventTitleSection(event)
            
            Spacer()
            
            subjectCategoryBadge(event)
        }
    }
    
    private static func eventColorIndicator(_ event: CalendarEvent) -> some View {
        ZStack {
            Circle()
                .fill(event.color.opacity(0.3))
                .frame(width: 24, height: 24)
            
            Circle()
                .fill(event.color)
                .frame(width: 16, height: 16)
            
            Circle()
                .stroke(event.color, lineWidth: 2)
                .frame(width: 28, height: 28)
                .opacity(0.6)
        }
    }
    
    private static func eventTitleSection(_ event: CalendarEvent) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(event.title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            if event.title.contains("-") {
                let components = event.title.components(separatedBy: " - ")
                if components.count >= 2 {
                    Text("Course Code: \(components[0])")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray5))
                        .cornerRadius(4)
                }
            }
        }
    }
    
    private static func subjectCategoryBadge(_ event: CalendarEvent) -> some View {
        Text(EventHelpers.getSubjectCategory(for: event.title))
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(event.color)
            .cornerRadius(6)
    }
    
    static func eventDetailsGrid(_ event: CalendarEvent,
                                editableEvents: [UUID: CalendarEvent],
                                eventEquipment: [UUID: String],
                                updateLocation: @escaping (String) -> Void) -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            
            DetailInfoCard(
                icon: "clock.fill",
                iconColor: .blue,
                title: "Schedule",
                content: EventHelpers.formatEventDate(event.date)
            )
            
            EditableLocationCard(
                event: event,
                onLocationChanged: updateLocation
            )
            
            if let teacher = event.teacher, !teacher.isEmpty {
                DetailInfoCard(
                    icon: "person.fill",
                    iconColor: .orange,
                    title: "Instructor",
                    content: teacher
                )
            }
            
            ForEach(EventHelpers.extractDetailCards(from: event.notes), id: \.title) { card in
                DetailInfoCard(
                    icon: card.icon,
                    iconColor: card.color,
                    title: card.title,
                    content: card.content
                )
            }
        }
    }
    
    static func extraInformationSection(_ event: CalendarEvent,
                                      eventEquipment: [UUID: String],
                                      showingInfoForEvent: UUID?,
                                      toggleInfo: @escaping () -> Void,
                                      updateEquipment: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            extraInformationHeader(event, showingInfoForEvent: showingInfoForEvent, toggleInfo: toggleInfo)
            
            if showingInfoForEvent == event.id {
                extraInformationContent(event, eventEquipment: eventEquipment, updateEquipment: updateEquipment)
                    .padding(.leading, 16)
                    .transition(.slide.combined(with: .opacity))
            }
        }
    }
    
    private static func extraInformationHeader(_ event: CalendarEvent,
                                              showingInfoForEvent: UUID?,
                                              toggleInfo: @escaping () -> Void) -> some View {
        Button(action: toggleInfo) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 24, height: 24)
                    
                    Circle()
                        .stroke(Color.blue, lineWidth: 1.5)
                        .frame(width: 24, height: 24)
                    
                    Text("i")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                Text("Extra Information")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: showingInfoForEvent == event.id ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .buttonStyle(.plain)
    }
    
    private static func extraInformationContent(_ event: CalendarEvent,
                                               eventEquipment: [UUID: String],
                                               updateEquipment: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            equipmentSection(event, eventEquipment: eventEquipment, updateEquipment: updateEquipment)
            
            Divider()
                .padding(.vertical, 4)
        }
    }
    
    private static func equipmentSection(_ event: CalendarEvent,
                                        eventEquipment: [UUID: String],
                                        updateEquipment: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "backpack.fill")
                    .font(.caption)
                    .foregroundColor(.purple)
                
                Text("Equipment to bring")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: updateEquipment) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.caption)
                        .foregroundColor(.purple)
                }
                .buttonStyle(.plain)
            }
            
            Text(EventDataManager.getEquipmentText(for: event, customEquipment: eventEquipment))
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(8)
        }
    }
}