import SwiftUI

// MARK: - Export Tab View
struct CalendarExportTabView: View {
    let events: [CalendarEvent]
    @State private var selectedFormat: ExportFormat = .calendar
    @State private var showingShareSheet = false
    @State private var exportedData = ""
    
    enum ExportFormat: String, CaseIterable {
        case calendar = "Calendar (.ics)"
        case csv = "Spreadsheet (.csv)"
        case json = "JSON (.json)"
        case text = "Text (.txt)"
        
        var icon: String {
            switch self {
            case .calendar: return "calendar"
            case .csv: return "tablecells"
            case .json: return "doc.text"
            case .text: return "doc.plaintext"
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Export format selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Export Format")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    ForEach(ExportFormat.allCases, id: \.self) { format in
                        Button {
                            selectedFormat = format
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: format.icon)
                                    .font(.title2)
                                    .foregroundColor(selectedFormat == format ? .white : .blue)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(format.rawValue)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(selectedFormat == format ? .white : .primary)
                                    
                                    Text(getFormatDescription(format))
                                        .font(.caption)
                                        .foregroundColor(selectedFormat == format ? .white.opacity(0.8) : .secondary)
                                }
                                
                                Spacer()
                                
                                if selectedFormat == format {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .background(selectedFormat == format ? Color.blue : Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Export options
                VStack(alignment: .leading, spacing: 12) {
                    Text("Export Options")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 12) {
                        Button {
                            exportData()
                        } label: {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export & Share")
                                Spacer()
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        
                        Button {
                            copyToClipboard()
                        } label: {
                            HStack {
                                Image(systemName: "doc.on.clipboard")
                                Text("Copy to Clipboard")
                                Spacer()
                            }
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        Button {
                            emailSchedule()
                        } label: {
                            HStack {
                                Image(systemName: "envelope")
                                Text("Email Schedule")
                                Spacer()
                            }
                            .font(.headline)
                            .foregroundColor(.green)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                }
                
                // Preview
                VStack(alignment: .leading, spacing: 12) {
                    Text("Preview")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    ScrollView {
                        Text(generatePreview())
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 200)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingShareSheet) {
            ActivityViewController(activityItems: [exportedData])
        }
    }
    
    private func getFormatDescription(_ format: ExportFormat) -> String {
        switch format {
        case .calendar: return "Import into Apple Calendar, Google Calendar, Outlook"
        case .csv: return "Open in Excel, Numbers, Google Sheets"
        case .json: return "For developers and data analysis"
        case .text: return "Simple text format for viewing and printing"
        }
    }
    
    private func generatePreview() -> String {
        switch selectedFormat {
        case .calendar:
            return generateICSPreview()
        case .csv:
            return generateCSVPreview()
        case .json:
            return generateJSONPreview()
        case .text:
            return generateTextPreview()
        }
    }
    
    private func generateICSPreview() -> String {
        let preview = events.prefix(3).map { event in
            """
            BEGIN:VEVENT
            SUMMARY:\(event.title)
            DTSTART:\(formatDateForICS(event.date))
            LOCATION:\(event.location)
            DESCRIPTION:\(event.notes)
            END:VEVENT
            """
        }.joined(separator: "\n\n")
        
        return "BEGIN:VCALENDAR\nVERSION:2.0\n\n\(preview)\n\nEND:VCALENDAR"
    }
    
    private func generateCSVPreview() -> String {
        let header = "Title,Date,Time,Location,Teacher,Notes\n"
        let rows = events.prefix(5).map { event in
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            
            return "\"\(event.title)\",\"\(formatter.string(from: event.date))\",\"\(event.location)\",\"\(event.teacher ?? "")\",\"\(event.notes.replacingOccurrences(of: "\n", with: " "))\""
        }.joined(separator: "\n")
        
        return header + rows
    }
    
    private func generateJSONPreview() -> String {
        let preview = events.prefix(3).map { event in
            """
            {
              "title": "\(event.title)",
              "date": "\(ISO8601DateFormatter().string(from: event.date))",
              "location": "\(event.location)",
              "teacher": "\(event.teacher ?? "")",
              "notes": "\(event.notes.replacingOccurrences(of: "\n", with: "\\n"))"
            }
            """
        }.joined(separator: ",\n")
        
        return "[\n\(preview)\n]"
    }
    
    private func generateTextPreview() -> String {
        return events.prefix(5).map { event in
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            formatter.timeStyle = .short
            
            return """
            \(event.title)
            \(formatter.string(from: event.date))
            \(event.location)
            \(event.teacher ?? "No teacher specified")
            \(event.notes)
            """
        }.joined(separator: "\n\n---\n\n")
    }
    
    private func formatDateForICS(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }
    
    private func exportData() {
        exportedData = generatePreview()
        showingShareSheet = true
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = generatePreview()
    }
    
    private func emailSchedule() {
        // Implementation for email functionality
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}