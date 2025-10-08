import SwiftUI

struct DebugInfoView: View {
    let events: [CalendarEvent]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🐛 Debug Information")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("This shows what the AI extracted from your image")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("📊 Extraction Summary")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Group {
                            HStack {
                                Text("Events found:")
                                Spacer()
                                Text("\(events.count)")
                                    .fontWeight(.bold)
                                    .foregroundColor(events.count > 0 ? .green : .red)
                            }
                            
                            HStack {
                                Text("Status:")
                                Spacer()
                                if events.count > 0 {
                                    Text("✅ SUCCESS")
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                } else {
                                    Text("❌ NO EVENTS")
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    if events.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("❌ Troubleshooting")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• Check if your image shows a clear timetable/schedule")
                                Text("• Make sure text is readable and not blurry")
                                Text("• Ensure the image contains actual class information")
                                Text("• Try taking a new photo with better lighting")
                                Text("• Check your internet connection")
                                Text("• The AI might be having temporary issues")
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("✅ Events Extracted")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                            
                            ForEach(Array(events.enumerated()), id: \.offset) { index, event in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Circle()
                                            .fill(event.color)
                                            .frame(width: 12, height: 12)
                                        
                                        Text("Event \(index + 1): \(event.title)")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("📅 Date: \(event.date)")
                                        if let teacher = event.teacher, !teacher.isEmpty {
                                            Text("👨‍🏫 Teacher: \(teacher)")
                                        }
                                        if !event.location.isEmpty {
                                            Text("📍 Location: \(event.location)")
                                        }
                                        
                                        DisclosureGroup("Full Details") {
                                            Text(event.notes)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .padding(.top, 4)
                                        }
                                        .font(.caption)
                                    }
                                    .padding(.leading, 20)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("📋 AI Processing Info")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Check the Xcode console for detailed debug logs showing:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("• Image upload process")
                            Text("• API communication with Gemini")
                            Text("• Raw AI response")
                            Text("• Parsing results")
                            Text("• Error messages (if any)")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("Debug Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}