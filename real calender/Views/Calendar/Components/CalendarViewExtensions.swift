import SwiftUI

extension View {
    func eventCardStyle(event: CalendarEvent) -> some View {
        self
            .padding(20)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        event.color.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [event.color.opacity(0.9), event.color.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
            )
            .shadow(color: event.color.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    func customNotesEditorStyle() -> some View {
        self
            .font(.caption)
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .frame(minHeight: 80)
    }
}