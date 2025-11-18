//
//  QuestItem.swift
//  real calender
//
//  Created by Mac on 07/10/25.
//

import SwiftUI

struct QuestStorageKeys {
    static let currentBatch = "questCurrentBatch"
    static let allQuests = "questAllQuests"
    static let lastBatchResetDate = "questLastBatchResetDate"
}

// MARK: - Data Model

struct QuestItem: Identifiable, Codable {
    let id: UUID
    let title: String
    var completedCount: Int
    let totalCount: Int
    let xP: Int
    let coins: Int
    let batch: Int
    
    init(id: UUID = UUID(), title: String, completedCount: Int, totalCount: Int, xP: Int, coins: Int, batch: Int) {
        self.id = id
        self.title = title
        self.completedCount = completedCount
        self.totalCount = totalCount
        self.xP = xP
        self.coins = coins
        self.batch = batch
    }
    
    var isCompleted: Bool {
        completedCount >= totalCount
    }
    
    var progress: Double {
        totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0
    }
    
    mutating func incrementProgress() {
        if completedCount < totalCount {
            completedCount += 1
        }
    }
    
    mutating func incrementforceProgress(num:Int) {
        if completedCount < totalCount {
            completedCount += num
        }
    }
    
    mutating func resetProgress() {
        completedCount = 0
    }
}


