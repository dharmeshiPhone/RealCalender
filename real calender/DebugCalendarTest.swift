import SwiftUI

struct DebugCalendarTest: View {
    @State private var lastTapped = "none"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Debug Calendar Test")
                .font(.title)
                .padding()
            
            Text("Last tapped: \(lastTapped)")
                .font(.headline)
                .foregroundColor(.blue)
                .padding()
                .background(Color.yellow.opacity(0.3))
                .cornerRadius(8)
            
            // Just a simple 3x3 grid to test
            VStack(spacing: 2) {
                ForEach(0..<3) { row in
                    HStack(spacing: 2) {
                        ForEach(0..<7) { col in
                            let day = (row * 7) + col + 1
                            
                            Button(action: {
                                print("🟢 DEBUG: Day \(day) button tapped!")
                                lastTapped = "Day \(day)"
                                
                                let impact = UIImpactFeedbackGenerator(style: .medium)
                                impact.impactOccurred()
                            }) {
                                Text("\(day)")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                    .frame(width: 40, height: 40)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    DebugCalendarTest()
}