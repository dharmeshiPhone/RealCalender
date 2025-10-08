// PersonalTrainerAI.swift
import Foundation
import HealthKit
import UserNotifications
import Contacts

@MainActor
class PersonalTrainerAI: NSObject, ObservableObject {
    @Published var isTrackingHealth = false
    @Published var dailyInsights: [String] = []
    @Published var recommendations: [String] = []
    
    private let healthStore = HKHealthStore()
    
    // Health metrics we can track
    private let healthTypesToRead: Set<HKSampleType> = [
        HKQuantityType.quantityType(forIdentifier: .stepCount)!,
        HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!,
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
    ]
    
    override init() {
        super.init()
        setupHealthKit()
    }
    
    // MARK: - Health Tracking
    
    private func setupHealthKit() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        healthStore.requestAuthorization(toShare: [], read: healthTypesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isTrackingHealth = success
            }
        }
    }
    
    func generatePersonalizedPlan() -> [String] {
        return [
            "🌅 Morning: Start with 10 minutes of stretching",
            "📅 Schedule: Block 30 minutes for exercise",
            "📱 Digital Wellness: Set 2-hour limits on social media",
            "🎯 Health Goal: Aim for 10,000 steps",
            "🌙 Evening: Wind down screen-free time before bed"
        ]
    }
    
    private func addInsight(_ insight: String) {
        dailyInsights.append(insight)
        if dailyInsights.count > 10 {
            dailyInsights.removeFirst()
        }
    }
    
    private func addRecommendation(_ recommendation: String) {
        recommendations.append(recommendation)
        if recommendations.count > 5 {
            recommendations.removeFirst()
        }
    }
}