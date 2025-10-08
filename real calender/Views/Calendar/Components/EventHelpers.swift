import SwiftUI

struct EventHelpers {
    static func formatEventDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    static func getSubjectCategory(for title: String) -> String {
        let titleLower = title.lowercased()
        
        if titleLower.contains("math") || titleLower.contains("calculus") || titleLower.contains("algebra") {
            return "MATH"
        } else if titleLower.contains("chemistry") || titleLower.contains("biology") || titleLower.contains("physics") || titleLower.contains("science") {
            return "SCIENCE"
        } else if titleLower.contains("english") || titleLower.contains("literature") || titleLower.contains("language") {
            return "LANGUAGE"
        } else if titleLower.contains("history") || titleLower.contains("geography") || titleLower.contains("social") {
            return "HISTORY"
        } else if titleLower.contains("art") || titleLower.contains("music") || titleLower.contains("drama") {
            return "ARTS"
        } else if titleLower.contains("computer") || titleLower.contains("technology") || titleLower.contains("coding") {
            return "TECH"
        } else if titleLower.contains("physical") || titleLower.contains("pe") || titleLower.contains("gym") {
            return "PE"
        } else if titleLower.contains("lunch") || titleLower.contains("break") {
            return "BREAK"
        } else {
            return "CLASS"
        }
    }
    
    static func extractDetailCards(from notes: String) -> [DetailCard] {
        var cards: [DetailCard] = []
        let lines = notes.components(separatedBy: "\n")
        
        for line in lines {
            if line.contains("Class type:") {
                let content = line.replacingOccurrences(of: "🎓 Class type:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                if !content.isEmpty {
                    cards.append(DetailCard(icon: "graduationcap.fill", color: .purple, title: "Type", content: content))
                }
            } else if line.contains("Duration:") {
                let content = line.replacingOccurrences(of: "⏱️ Duration:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                if !content.isEmpty {
                    cards.append(DetailCard(icon: "timer", color: .blue, title: "Duration", content: content))
                }
            } else if line.contains("Building:") {
                let content = line.replacingOccurrences(of: "🏢 Building:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                if !content.isEmpty {
                    cards.append(DetailCard(icon: "building.2.fill", color: .gray, title: "Building", content: content))
                }
            } else if line.contains("Floor:") {
                let content = line.replacingOccurrences(of: "🏗️ Floor:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                if !content.isEmpty {
                    cards.append(DetailCard(icon: "stairs", color: .gray, title: "Floor", content: content))
                }
            } else if line.contains("Credits:") {
                let content = line.replacingOccurrences(of: "📊 Credits:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                if !content.isEmpty {
                    cards.append(DetailCard(icon: "star.fill", color: .yellow, title: "Credits", content: content))
                }
            } else if line.contains("Level:") {
                let content = line.replacingOccurrences(of: "🎓 Level:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                if !content.isEmpty {
                    cards.append(DetailCard(icon: "graduationcap", color: .blue, title: "Level", content: content))
                }
            } else if line.contains("Semester:") {
                let content = line.replacingOccurrences(of: "📅 Semester:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                if !content.isEmpty {
                    cards.append(DetailCard(icon: "calendar", color: .green, title: "Semester", content: content))
                }
            }
        }
        
        return Array(cards.prefix(4))
    }
}