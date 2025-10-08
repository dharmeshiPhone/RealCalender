import SwiftUI

class EventDataManager {
    static func getEquipmentText(for event: CalendarEvent, customEquipment: [UUID: String]) -> String {
        // Check if user has custom equipment, otherwise use default from notes
        if let customEquip = customEquipment[event.id], !customEquip.isEmpty {
            return customEquip
        }
        
        // Extract equipment from notes if available
        let lines = event.notes.components(separatedBy: "\n")
        var equipmentLines: [String] = []
        var inEquipmentSection = false
        
        for line in lines {
            if line.contains("🎒 Equipment to bring:") {
                inEquipmentSection = true
                continue
            } else if inEquipmentSection && line.isEmpty {
                break
            } else if inEquipmentSection {
                equipmentLines.append(line)
            }
        }
        
        if !equipmentLines.isEmpty {
            return equipmentLines.joined(separator: "\n")
        }
        
        // Fallback to generic equipment
        return "• Notebook\n• Pens/pencils\n• Textbook\n• Laptop/tablet (if needed)"
    }
    
    static func saveCustomData<T: Codable>(data: [UUID: T], key: String) {
        // Save custom data to UserDefaults
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(data) {
            UserDefaults.standard.set(encodedData, forKey: key)
        }
    }
    
    static func loadCustomData<T: Codable>(key: String, type: T.Type) -> [UUID: T]? {
        // Load custom data from UserDefaults
        if let data = UserDefaults.standard.data(forKey: key) {
            let decoder = JSONDecoder()
            if let savedData = try? decoder.decode([UUID: T].self, from: data) {
                return savedData
            }
        }
        return nil
    }
}