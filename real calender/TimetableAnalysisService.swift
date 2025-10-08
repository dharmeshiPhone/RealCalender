import Foundation
import UIKit
import Vision
import SwiftUI

class TimetableAnalysisService {
    static let shared = TimetableAnalysisService()
    
    private init() {}
    
    func analyzeImage(_ data: Data) async throws -> [CalendarEvent] {
        guard let uiImage = UIImage(data: data) else { throw NSError(domain: "Timetable", code: 1) }
        guard let cgImage = uiImage.cgImage else { throw NSError(domain: "Timetable", code: 2) }
        
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.minimumTextHeight = 0.03 // Good for timetables
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([request])
        
        let observations = request.results ?? []
        let lines = observations.compactMap { $0.topCandidates(1).first?.string }
        
        // Debug: print all lines found from OCR
        print("OCR Results:")
        for line in lines {
            print(line)
        }
        
        // --- Timetable Parsing Logic ---
        // Look for stuff like: [DAY] [Time]-[Time] [Class Name] [Room]
        let eventRegex = try! NSRegularExpression(
            pattern: "(Mon|Tue|Wed|Thu|Fri|Sat|Sun)[a-z]*\\s+([0-9]{1,2}:[0-9]{2}|[0-9]{1,2})(am|pm)?\\s*-\\s*([0-9]{1,2}:[0-9]{2}|[0-9]{1,2})(am|pm)?\\s+(.*)",
            options: .caseInsensitive)
        
        var events: [CalendarEvent] = []
        let calendar = Calendar.current
        let now = Date()
        let weekdayMap: [String: Int] = [
            "mon": 2, "tue": 3, "wed": 4, "thu": 5, "fri": 6, "sat": 7, "sun": 1
        ]
        for line in lines {
            let range = NSRange(location: 0, length: line.utf16.count)
            if let match = eventRegex.firstMatch(in: line, options: [], range: range) {
                // Extract details
                let weekdayStr = (line as NSString).substring(with: match.range(at: 1)).lowercased()
                let startStr = (line as NSString).substring(with: match.range(at: 2))
                let endStr = (line as NSString).substring(with: match.range(at: 4))
                let rawTitle = (line as NSString).substring(with: match.range(at: 6)).trimmingCharacters(in: .whitespacesAndNewlines)
                guard let weekdayNum = weekdayMap[weekdayStr] else { continue }
                
                // Construct date for next weekday
                let date = nextDate(weekday: weekdayNum, hourMinute: startStr, now: now)
                // Color based on class hash (stable per name)
                let color = colorForString(rawTitle)
                let notes = "Imported from timetable: \(line)"
                events.append(CalendarEvent(
                    title: rawTitle.isEmpty ? "Imported Event" : rawTitle,
                    date: date,
                    notes: notes,
                    color: color
                ))
            }
        }
        if events.isEmpty {
            throw NSError(domain: "Timetable", code: 9, userInfo: [NSLocalizedDescriptionKey: "No events recognized in OCR"])
        }
        return events
    }

    /// Helper: Find the next occurrence of a weekday and set hour/minute.
    private func nextDate(weekday: Int, hourMinute: String, now: Date) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .weekday, .day], from: now)
        var date = now
        // Advance to target weekday
        while Calendar.current.component(.weekday, from: date) != weekday {
            date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        }
        let parts = hourMinute.split(separator: ":")
        let hour = Int(parts.first ?? "9") ?? 9
        let minute = (parts.count > 1) ? Int(parts[1]) ?? 0 : 0
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: date) ?? date
    }
    
    /// Helper: Color hashing based on event title
    private func colorForString(_ str: String) -> Color {
        let hash = abs(str.hashValue)
        let colors: [Color] = [.blue, .green, .purple, .orange, .pink, .red, .yellow, .cyan]
        return colors[hash % colors.count]
    }
    
    enum AnalysisError: Error {
        case invalidImage
        case apiError
        case invalidResponse
        case noTextFound
    }
}