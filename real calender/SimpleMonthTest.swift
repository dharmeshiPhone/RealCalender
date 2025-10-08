import SwiftUI

struct SimpleMonthTest: View {
    let events: [CalendarEvent]
    @State private var selectedDate = Date()
    @State private var lastTapped = "none"
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Month Test - Last tapped: \(lastTapped)")
                .font(.headline)
                .padding()
                .background(Color.yellow.opacity(0.3))
                .cornerRadius(8)
            
            // Simple month grid similar to working debug test
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
                
                // Calendar days - using the EXACT same structure as debug test
                VStack(spacing: 1) {
                    ForEach(0..<6) { weekIndex in
                        HStack(spacing: 1) {
                            ForEach(0..<7) { dayIndex in
                                let dayNumber = (weekIndex * 7) + dayIndex + 1
                                
                                Button(action: {
                                    print("🟢 MONTH TEST: Day \(dayNumber) tapped!")
                                    lastTapped = "Day \(dayNumber)"
                                    
                                    let impact = UIImpactFeedbackGenerator(style: .medium)
                                    impact.impactOccurred()
                                }) {
                                    Text("\(dayNumber)")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity, minHeight: 45)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(6)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    SimpleMonthTest(events: [])
}