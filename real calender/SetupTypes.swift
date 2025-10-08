import Foundation
import SwiftUI

// MARK: - Enums and Types for Setup

enum TransportMethod: String, CaseIterable {
    case car = "Car"
    case publicTransport = "Public Transport"
    case walking = "Walking"
    case cycling = "Cycling"

    var icon: String {
        switch self {
        case .car: return "car.fill"
        case .publicTransport: return "bus.fill"
        case .walking: return "figure.walk"
        case .cycling: return "bicycle"
        }
    }

    var color: Color {
        switch self {
        case .car: return .blue
        case .publicTransport: return .green
        case .walking: return .orange
        case .cycling: return .purple
        }
    }
}

enum InputMethod: String, CaseIterable {
    case template = "Choose Template"
    case screenshot = "Upload Screenshot"
    case audio = "Record Audio" 
    case createOwn = "Create Own Schedule"

    var icon: String {
        switch self {
        case .template: return "list.bullet.rectangle"
        case .screenshot: return "camera.fill"
        case .audio: return "mic.fill"
        case .createOwn: return "calendar.badge.plus"
        }
    }

    var color: Color {
        switch self {
        case .template: return .blue
        case .screenshot: return .green
        case .audio: return .orange
        case .createOwn: return .purple
        }
    }
}

enum ScheduleType: String, CaseIterable {
    case highSchool = "High School"
    case university = "University"
    case work = "Work"

    var icon: String {
        switch self {
        case .highSchool: return "graduationcap"
        case .university: return "building.columns"
        case .work: return "briefcase.fill"
        }
    }

    var color: Color {
        switch self {
        case .highSchool: return .blue
        case .university: return .purple
        case .work: return .green
        }
    }

    var locationName: String {
        switch self {
        case .highSchool: return "School"
        case .university: return "University"
        case .work: return "Work"
        }
    }
}

enum ProcessingError: Error {
    case invalidImage
    case processingFailed
    case noEventsFound
}
enum SubscriptionPlan: String, CaseIterable {
    case trial = "Trial"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    
    var title: String {
        switch self {
        case .trial: return "Free Trial"
        case .weekly: return "Weekly Plan"
        case .monthly: return "Monthly Plan"
        case .yearly: return "Yearly Plan"
        }
    }
    
    var description: String {
        switch self {
        case .trial: return "20 days free trial"
        case .weekly: return "Perfect for short-term goals"
        case .monthly: return "Most popular choice"
        case .yearly: return "Best value - save 60%"
        }
    }
    
    var price: String {
        switch self {
        case .trial: return "FREE"
        case .weekly: return "$9"
        case .monthly: return "$25"
        case .yearly: return "$250"
        }
    }
    
    var originalPrice: String? {
        switch self {
        case .trial: return nil
        case .weekly: return nil
        case .monthly: return "$35"
        case .yearly: return "$325"
        }
    }
    
    var badge: String? {
        switch self {
        case .trial: return nil
        case .weekly: return nil
        case .monthly: return "MOST POPULAR"
        case .yearly: return "BEST VALUE"
        }
    }
    
    var badgeColor: Color {
        switch self {
        case .trial: return .blue
        case .weekly: return .green
        case .monthly: return .purple
        case .yearly: return .orange
        }
    }
    
    var buttonColor: LinearGradient {
        switch self {
        case .trial:
            return LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .leading,
                endPoint: .trailing
            )
        case .weekly:
            return LinearGradient(
                gradient: Gradient(colors: [.green, .mint]),
                startPoint: .leading,
                endPoint: .trailing
            )
        case .monthly:
            return LinearGradient(
                gradient: Gradient(colors: [.purple, .pink]),
                startPoint: .leading,
                endPoint: .bottomTrailing
            )
        case .yearly:
            return LinearGradient(
                gradient: Gradient(colors: [.orange, .red]),
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    var shadowColor: Color {
        switch self {
        case .trial: return .blue.opacity(0.4)
        case .weekly: return .green.opacity(0.4)
        case .monthly: return .purple.opacity(0.4)
        case .yearly: return .orange.opacity(0.4)
        }
    }
}
