import SwiftUI

struct TestCalendarView: View {
    let events: [CalendarEvent]
    @State private var currentMode: String = "Month"
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack(spacing: 16) {
            // Debug header
            VStack {
                Text("Test Calendar - Mode: \(currentMode)")
                    .font(.headline)
                Text("Selected: \(selectedDate, formatter: debugFormatter)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.yellow.opacity(0.3))
            .cornerRadius(8)
            
            // Test calendar grid
            testCalendarGrid
            
            // Test buttons
            HStack {
                Button("Test Button 1") {
                    print("🟢 Test Button 1 pressed!")
                    currentMode = "Week"
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("Test Button 2") {
                    print("🔵 Test Button 2 pressed!")
                    currentMode = "Day"
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var testCalendarGrid: some View {
        VStack(spacing: 4) {
            // Simple 7-day grid
            ForEach(0..<4) { week in
                HStack(spacing: 4) {
                    ForEach(1..<8) { day in
                        let dayNumber = (week * 7) + day
                        
                        Button("\(dayNumber)") {
                            print("🔴 Day \(dayNumber) tapped!")
                            selectedDate = Calendar.current.date(byAdding: .day, value: dayNumber - 15, to: Date()) ?? Date()  
                        }
                        .frame(width: 40, height: 40)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                        .font(.system(size: 14, weight: .medium))
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var debugFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }
}

#Preview {
    TestCalendarView(events: [])
}