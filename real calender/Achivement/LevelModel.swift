//
//  LevelModel.swift
//  real calender
//
//  Created by Mac on 15/12/25.
//

import SwiftUI
import Foundation

// 1. Data Model for a Level
struct Level: Identifiable {
    let id = UUID()
    let number: Int
    let requiredExp: Int
    let reward: String
}

// Dummy Data for demonstration
let allLevels: [Level] = [
    Level(number: 1, requiredExp: 50, reward: "Unlocks Graphs"),
    Level(number: 2, requiredExp: 50, reward: "Unlocks Pets"),
    Level(number: 3, requiredExp: 50, reward: "Unlocks 'Whatever'"),

    Level(number: 4, requiredExp: 250, reward: "Unlocks Feature 4"),
    Level(number: 5, requiredExp: 250, reward: "Unlocks Feature 5"),
    Level(number: 6, requiredExp: 250, reward: "Unlocks Feature 6"),
    Level(number: 7, requiredExp: 250, reward: "Unlocks Feature 7"),
    Level(number: 8, requiredExp: 250, reward: "Unlocks Feature 8"),
    Level(number: 9, requiredExp: 250, reward: "Unlocks Feature 9"),
    Level(number: 10, requiredExp: 250, reward: "Unlocks Feature 10"),

    Level(number: 11, requiredExp: 250, reward: "Unlocks Feature 11"),
    Level(number: 12, requiredExp: 250, reward: "Unlocks Feature 12"),
    Level(number: 13, requiredExp: 250, reward: "Unlocks Feature 13"),
    Level(number: 14, requiredExp: 250, reward: "Unlocks Feature 14"),
    Level(number: 15, requiredExp: 250, reward: "Unlocks Feature 15"),
    Level(number: 16, requiredExp: 250, reward: "Unlocks Feature 16"),
    Level(number: 17, requiredExp: 250, reward: "Unlocks Feature 17"),
    Level(number: 18, requiredExp: 250, reward: "Unlocks Feature 18"),
    Level(number: 19, requiredExp: 250, reward: "Unlocks Feature 19"),
    Level(number: 20, requiredExp: 250, reward: "Unlocks Feature 20"),

    Level(number: 21, requiredExp: 250, reward: "Unlocks Feature 21"),
    Level(number: 22, requiredExp: 250, reward: "Unlocks Feature 22"),
    Level(number: 23, requiredExp: 250, reward: "Unlocks Feature 23"),
    Level(number: 24, requiredExp: 250, reward: "Unlocks Feature 24"),
    Level(number: 25, requiredExp: 250, reward: "Unlocks Feature 25"),
    Level(number: 26, requiredExp: 250, reward: "Unlocks Feature 26"),
    Level(number: 27, requiredExp: 250, reward: "Unlocks Feature 27"),
    Level(number: 28, requiredExp: 250, reward: "Unlocks Feature 28"),
    Level(number: 29, requiredExp: 250, reward: "Unlocks Feature 29"),
    Level(number: 30, requiredExp: 250, reward: "Unlocks Feature 30"),

    Level(number: 31, requiredExp: 250, reward: "Unlocks Feature 31"),
    Level(number: 32, requiredExp: 250, reward: "Unlocks Feature 32"),
    Level(number: 33, requiredExp: 250, reward: "Unlocks Feature 33"),
    Level(number: 34, requiredExp: 250, reward: "Unlocks Feature 34"),
    Level(number: 35, requiredExp: 250, reward: "Unlocks Feature 35"),
    Level(number: 36, requiredExp: 250, reward: "Unlocks Feature 36"),
    Level(number: 37, requiredExp: 250, reward: "Unlocks Feature 37"),
    Level(number: 38, requiredExp: 250, reward: "Unlocks Feature 38"),
    Level(number: 39, requiredExp: 250, reward: "Unlocks Feature 39"),
    Level(number: 40, requiredExp: 250, reward: "Unlocks Feature 40"),

    Level(number: 41, requiredExp: 250, reward: "Unlocks Feature 41"),
    Level(number: 42, requiredExp: 250, reward: "Unlocks Feature 42"),
    Level(number: 43, requiredExp: 250, reward: "Unlocks Feature 43"),
    Level(number: 44, requiredExp: 250, reward: "Unlocks Feature 44"),
    Level(number: 45, requiredExp: 250, reward: "Unlocks Feature 45"),
    Level(number: 46, requiredExp: 250, reward: "Unlocks Feature 46"),
    Level(number: 47, requiredExp: 250, reward: "Unlocks Feature 47"),
    Level(number: 48, requiredExp: 250, reward: "Unlocks Feature 48"),
    Level(number: 49, requiredExp: 250, reward: "Unlocks Feature 49"),
    Level(number: 50, requiredExp: 250, reward: "Unlocks Feature 50"),

    Level(number: 51, requiredExp: 250, reward: "Unlocks Feature 51"),
    Level(number: 52, requiredExp: 250, reward: "Unlocks Feature 52"),
    Level(number: 53, requiredExp: 250, reward: "Unlocks Feature 53"),
    Level(number: 54, requiredExp: 250, reward: "Unlocks Feature 54"),
    Level(number: 55, requiredExp: 250, reward: "Unlocks Feature 55"),
    Level(number: 56, requiredExp: 250, reward: "Unlocks Feature 56"),
    Level(number: 57, requiredExp: 250, reward: "Unlocks Feature 57"),
    Level(number: 58, requiredExp: 250, reward: "Unlocks Feature 58"),
    Level(number: 59, requiredExp: 250, reward: "Unlocks Feature 59"),
    Level(number: 60, requiredExp: 250, reward: "Unlocks Feature 60"),

    Level(number: 61, requiredExp: 250, reward: "Unlocks Feature 61"),
    Level(number: 62, requiredExp: 250, reward: "Unlocks Feature 62"),
    Level(number: 63, requiredExp: 250, reward: "Unlocks Feature 63"),
    Level(number: 64, requiredExp: 250, reward: "Unlocks Feature 64"),
    Level(number: 65, requiredExp: 250, reward: "Unlocks Feature 65"),
    Level(number: 66, requiredExp: 250, reward: "Max Rank Badge")
]



