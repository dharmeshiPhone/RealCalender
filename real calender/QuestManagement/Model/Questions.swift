//
//  Questions.swift
//  real calender
//
//  Created by Mac on 04/12/25.
//

import SwiftUI
import Foundation

// Define all quests here
let questItems = [
    
    // MARK: - Week 1
    
    // Batch 1
    QuestItem(title: "Set up the basics of your calendar", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 1),
    QuestItem(title: "Complete two graphs in your profile", completedCount: 0, totalCount: 2, xP: 50, coins: 25, batch: 1),
    QuestItem(title: "Get your first egg from the pet store", completedCount: 0, totalCount: 1, xP: 50, coins: 50, batch: 1),
    
    // temps
    // Batch 2
    QuestItem(title: "Log 3 calendar event", completedCount: 0, totalCount: 3, xP: 75, coins: 50, batch: 2),
    QuestItem(title: "Turn on notifications", completedCount: 0, totalCount: 1, xP: 75, coins: 50, batch: 2),
    QuestItem(title: "Complete 1 scheduled event", completedCount: 0, totalCount: 1, xP: 100, coins: 75, batch: 2),
    
    // Batch 3
    QuestItem(title: "Complete 2 scheduled event", completedCount: 0, totalCount: 2, xP: 75, coins: 75, batch: 3),
    QuestItem(title: "Add 5 new event", completedCount: 0, totalCount: 5, xP: 100, coins: 50, batch: 3),
    QuestItem(title: "Use Task Prioritisation", completedCount: 0, totalCount: 1, xP: 75, coins: 75, batch: 3),
    
    // Batch 4
    QuestItem(title: "Complete 3 scheduled event", completedCount: 0, totalCount: 3, xP: 100, coins: 75, batch: 4),
    QuestItem(title: "Check pet happiness (just open pet page)", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 4),
    QuestItem(title: "Use Sick or Holiday prompt", completedCount: 0, totalCount: 1, xP: 100, coins: 50, batch: 4),
    
    // Batch 5
    QuestItem(title: "Use Sick or Holiday prompt", completedCount: 0, totalCount: 1, xP: 100, coins: 75, batch: 5),
    QuestItem(title: "Complete 3 scheduled event", completedCount: 0, totalCount: 3, xP: 100, coins: 75, batch: 5),
    QuestItem(title: "Update Running graph or gym graph", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 5),
    
    // Batch 6
    QuestItem(title: "Complete 4 scheduled event", completedCount: 0, totalCount: 4, xP: 125, coins: 100, batch: 6),
    QuestItem(title: "Fill out Gym or Swimming graph or income", completedCount: 0, totalCount: 1, xP: 75, coins: 50, batch: 6),
    QuestItem(title: "Use Task Prioritisation on 1 task", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 6),
    
    // Batch 7
    QuestItem(title: "Maintain 7-day streak", completedCount: 0, totalCount: 1, xP: 0, coins: 100, batch: 7),
    QuestItem(title: "Complete 4 scheduled event", completedCount: 0, totalCount: 4, xP: 200, coins: 75, batch: 7),
    QuestItem(title: "Update 2 different graphs", completedCount: 0, totalCount: 2, xP: 50, coins: 25, batch: 7),
    
    
    // MARK: - Week 2
    
    
    // Batch 8
    QuestItem(title: "Complete 4 scheduled event", completedCount: 0, totalCount: 4, xP: 125, coins: 75, batch: 8),
    QuestItem(title: "Add 3 new event", completedCount: 0, totalCount: 3, xP: 75, coins: 75, batch: 8),
    QuestItem(title: "Update running graph", completedCount: 0, totalCount: 1, xP: 150, coins: 25, batch: 8),
    
    // Batch 9
    QuestItem(title: "Complete 5 scheduled event", completedCount: 0, totalCount: 5, xP: 125, coins: 100, batch: 9),
    QuestItem(title: "Add 2 new event", completedCount: 0, totalCount: 2, xP: 75, coins: 50, batch: 9),
    QuestItem(title: "Check Daily Summary from yesterday", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 9),
    
    // Batch 10
    QuestItem(title: "Complete 5 scheduled event", completedCount: 0, totalCount: 5, xP: 125, coins: 100, batch: 10),
    QuestItem(title: "Add 2 new event", completedCount: 0, totalCount: 2, xP: 75, coins: 50, batch: 10),
    QuestItem(title: "Buy a pet cosmetic", completedCount: 0, totalCount: 1, xP: 50, coins: 0, batch: 10),
    
    // incompletes
    
    // Batch 11
    QuestItem(title: "Complete 3 scheduled event", completedCount: 0, totalCount: 3, xP: 125, coins: 100, batch: 11),
    QuestItem(title: "Add 2 new event", completedCount: 0, totalCount: 2, xP: 75, coins: 50, batch: 11),
    QuestItem(title: "Update Running graph or gym graph or Fill out Academic Graph if applicable", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 11),
    
    // Batch 12
    QuestItem(title: "Complete 2 scheduled event", completedCount: 0, totalCount: 2, xP: 125, coins: 100, batch: 12),
    QuestItem(title: "Update 2 different graphs", completedCount: 0, totalCount: 2, xP: 75, coins: 50, batch: 12),
    QuestItem(title: "Add 2 new events", completedCount: 0, totalCount: 2, xP: 50, coins: 25, batch: 12),
    
    // Batch 13
    QuestItem(title: "Complete 3 scheduled event", completedCount: 0, totalCount: 3, xP: 125, coins: 100, batch: 13),
    QuestItem(title: "Add 2 new event", completedCount: 0, totalCount: 2, xP: 75, coins: 50, batch: 13),
    QuestItem(title: "Update one graph", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 13),
    
    // Batch 14
    QuestItem(title: "Maintain 14-day streak", completedCount: 0, totalCount: 1, xP: 0, coins: 125, batch: 14),
    QuestItem(title: "Complete 2 scheduled event", completedCount: 0, totalCount: 2, xP: 200, coins: 50, batch: 14),
    QuestItem(title: "Update BMI or Running graph", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 14),
    
    
    
    
    // MARK: - Week 3
    
    // Batch 15
    QuestItem(title: "Complete 2 scheduled event", completedCount: 0, totalCount: 2, xP: 125, coins: 100, batch: 15),
    QuestItem(title: "Add 3 new event", completedCount: 0, totalCount: 3, xP: 75, coins: 50, batch: 15),
    QuestItem(title: "Check Weekly Analytics", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 15),
    
    
    // Batch 16
    QuestItem(title: "Complete 3 scheduled event", completedCount: 0, totalCount: 3, xP: 125, coins: 100, batch: 16),
    QuestItem(title: "Update Swimming or Gym graph", completedCount: 0, totalCount: 1, xP: 75, coins: 50, batch: 16),
    QuestItem(title: "Add 1 new event", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 16),
    
    
    // Batch 17
    QuestItem(title: "Complete 6 scheduled event", completedCount: 0, totalCount: 6, xP: 125, coins: 100, batch: 17),
    QuestItem(title: "Add 3 new event", completedCount: 0, totalCount: 3, xP: 75, coins: 50, batch: 17),
    QuestItem(title: "Check Daily Summary", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 17),
    
    
    // Batch 18
    QuestItem(title: "Complete 5 scheduled event", completedCount: 0, totalCount: 5, xP: 125, coins: 100, batch: 18),
    QuestItem(title: "Update 3 different graphs", completedCount: 0, totalCount: 3, xP: 75, coins: 50, batch: 18),
    QuestItem(title: "Update one graph", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 18),
    
    // Batch 19
    QuestItem(title: "Complete 2 scheduled event", completedCount: 0, totalCount: 2, xP: 125, coins: 100, batch: 19),
    QuestItem(title: "Add 1 new event", completedCount: 0, totalCount: 1, xP: 75, coins: 50, batch: 19),
    QuestItem(title: "Buy 2 pet cosmetics", completedCount: 0, totalCount: 1, xP: 50, coins: 0, batch: 19),
    
    // Batch 20
    QuestItem(title: "Maintain 20-day streak", completedCount: 0, totalCount: 1, xP: 0, coins: 125, batch: 20),
    QuestItem(title: "Complete 5 scheduled event", completedCount: 0, totalCount: 5, xP: 200, coins: 50, batch: 20),
    QuestItem(title: "Update 2 graphs", completedCount: 0, totalCount: 2, xP: 50, coins: 25, batch: 20),
    
    // Batch 21
    QuestItem(title: "Maintain 21-day streak", completedCount: 0, totalCount: 1, xP: 0, coins: 150, batch: 21),
    QuestItem(title: "Complete 2 scheduled event", completedCount: 0, totalCount: 2, xP: 200, coins: 50, batch: 21),
    QuestItem(title: "Update all unlocked graphs", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 21),
    
    
    // MARK: - Week 4
    
    // Batch 22
    QuestItem(title: "Complete 3 scheduled event", completedCount: 0, totalCount: 3, xP: 125, coins: 100, batch: 22),
    QuestItem(title: "Add 1 new event", completedCount: 0, totalCount: 1, xP: 75, coins: 50, batch: 22),
    QuestItem(title: "Check Daily Summary 7 days in a row", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 22),
    
    // Batch 23
    QuestItem(title: "Complete 3 scheduled event", completedCount: 0, totalCount: 3, xP: 125, coins: 100, batch: 23),
    QuestItem(title: "BMI or running graph", completedCount: 0, totalCount: 1, xP: 75, coins: 50, batch: 23),
    QuestItem(title: "Add 2 new events", completedCount: 0, totalCount: 2, xP: 50, coins: 25, batch: 23),
    
    // Batch 24
    QuestItem(title: "Complete 3 scheduled event", completedCount: 0, totalCount: 3, xP: 125, coins: 100, batch: 24),
    QuestItem(title: "Add 2 new events", completedCount: 0, totalCount: 2, xP: 75, coins: 50, batch: 24),
    QuestItem(title: "Open analytics page", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 24),
    
    // Batch 25
    QuestItem(title: "Complete 5 scheduled event", completedCount: 0, totalCount: 5, xP: 125, coins: 100, batch: 25),
    QuestItem(title: "Update gym graph and Running graphs", completedCount: 0, totalCount: 1, xP: 75, coins: 50, batch: 25),
    QuestItem(title: "Update 2 graphs", completedCount: 0, totalCount: 2, xP: 50, coins: 25, batch: 25),
    
    
    // Batch 26
    QuestItem(title: "Complete 4 scheduled event", completedCount: 0, totalCount: 4, xP: 125, coins: 100, batch: 26),
    QuestItem(title: "Add 2 new events", completedCount: 0, totalCount: 2, xP: 75, coins: 50, batch: 26),
    QuestItem(title: "Check Weekly Analytics", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 26),
    
    
    // Batch 27
    QuestItem(title: "Complete 3 scheduled event", completedCount: 0, totalCount: 3, xP: 125, coins: 100, batch: 27),
    QuestItem(title: "Update 3 different graphs", completedCount: 0, totalCount: 3, xP: 75, coins: 50, batch: 27),
    QuestItem(title: "Check Daily Summary days in a row", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 27),
    
    
    // Batch 28
    QuestItem(title: "Maintain 28-day streak", completedCount: 0, totalCount: 1, xP: 0, coins: 125, batch: 28),
    QuestItem(title: "Complete 3 scheduled event", completedCount: 0, totalCount: 3, xP: 200, coins: 50, batch: 28),
    QuestItem(title: "Buy pet cosmetic", completedCount: 0, totalCount: 1, xP: 50, coins: 0, batch: 28),
    
    
    // MARK: - Week 5
    
    // Batch 29
    QuestItem(title: "Complete 4 scheduled event", completedCount: 0, totalCount: 4, xP: 125, coins: 100, batch: 29),
    QuestItem(title: "Add 1 new event", completedCount: 0, totalCount: 1, xP: 75, coins: 50, batch: 29),
    QuestItem(title: "Check Daily Summary", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 29),
    
    
    // Batch 30
    QuestItem(title: "Maintain 30-day streak", completedCount: 0, totalCount: 1, xP: 0, coins: 150, batch: 30),
    QuestItem(title: "Complete 3 scheduled event", completedCount: 0, totalCount: 3, xP: 200, coins: 50, batch: 30),
    QuestItem(title: "Update all graphs", completedCount: 0, totalCount: 5, xP: 50, coins: 25, batch: 30),
    
    // Batch 31
    QuestItem(title: "Complete 4 scheduled event", completedCount: 0, totalCount: 4, xP: 125, coins: 100, batch: 31),
    QuestItem(title: "Add 1 new event", completedCount: 0, totalCount: 1, xP: 75, coins: 50, batch: 31),
    QuestItem(title: "Update one graph", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 31),
    
    // Batch 32
    QuestItem(title: "Complete 3 scheduled event", completedCount: 0, totalCount: 3, xP: 125, coins: 100, batch: 32),
    QuestItem(title: "Use Task Prioritisation on 1 task", completedCount: 0, totalCount: 1, xP: 75, coins: 50, batch: 32),
    QuestItem(title: "Check Daily Summary 14 days in a row", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 32),
    
    // Batch 33
    QuestItem(title: "Complete 4 scheduled event", completedCount: 0, totalCount: 4, xP: 125, coins: 100, batch: 33),
    QuestItem(title: "Update BMI and Running graphs", completedCount: 0, totalCount: 2, xP: 75, coins: 50, batch: 33),
    QuestItem(title: "Add 1 new event", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 33),
    
    // Batch 34
    QuestItem(title: "Complete 3 scheduled event", completedCount: 0, totalCount: 3, xP: 125, coins: 100, batch: 34),
    QuestItem(title: "Add 1 new event", completedCount: 0, totalCount: 1, xP: 75, coins: 50, batch: 34),
    QuestItem(title: "Buy 2 pet cosmetics", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 34),
    
    // Batch 35
    QuestItem(title: "Maintain 35-day streak", completedCount: 0, totalCount: 0, xP: 0, coins: 150, batch: 35),
    QuestItem(title: "Complete 3 scheduled event", completedCount: 0, totalCount: 3, xP: 200, coins: 50, batch: 35),
    QuestItem(title: "Check Weekly Analytics", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 35),
    
    
    // MARK: - Week 6 (Days 36-42)
    
    // Batch 36
    QuestItem(title: "Complete 4 scheduled event", completedCount: 0, totalCount: 4, xP: 125, coins: 100, batch: 36),
    QuestItem(title: "Add 1 new event", completedCount: 0, totalCount: 1, xP: 75, coins: 50, batch: 36),
    QuestItem(title: "Update 3 graphs", completedCount: 0, totalCount: 3, xP: 50, coins: 25, batch: 36),

    //Unlocks: Social: "Join Team," "Feedback," "Follow Instagram" buttons
    
    // Batch 37
    QuestItem(title: "Complete 3 scheduled event", completedCount: 0, totalCount: 3, xP: 125, coins: 100, batch: 37),
    QuestItem(title: "Use Task Prioritisation on 3 tasks", completedCount: 0, totalCount: 3, xP: 75, coins: 50, batch: 37),
    QuestItem(title: "Check on pets happiness", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 37),
    
    
    // Batch 38
    QuestItem(title: "Complete 3 scheduled event", completedCount: 0, totalCount: 3, xP: 125, coins: 100, batch: 38),
    QuestItem(title: "Add 1 new event", completedCount: 0, totalCount: 1, xP: 75, coins: 50, batch: 38),
    QuestItem(title: "Check Weekly Analytics 6 weeks in a row", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 38),
    
    // Batch 39
    QuestItem(title: "Complete 4 scheduled event", completedCount: 0, totalCount: 4, xP: 125, coins: 100, batch: 39),
    QuestItem(title: "Update all unlocked graphs", completedCount: 0, totalCount: 5, xP: 75, coins: 50, batch: 39),
    QuestItem(title: "Add 2 new events", completedCount: 0, totalCount: 2, xP: 50, coins: 25, batch: 39),


    // Batch 40
    QuestItem(title: "Maintain 40-day streak", completedCount: 0, totalCount: 0, xP: 0, coins: 150, batch: 40),
    QuestItem(title: "Complete 2 scheduled event", completedCount: 0, totalCount: 2, xP: 200, coins: 50, batch: 40),
    QuestItem(title: "Check Daily Summary", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 40),
    
    // Batch 41
    QuestItem(title: "Complete 3 scheduled event", completedCount: 0, totalCount: 3, xP: 125, coins: 100, batch: 41),
    QuestItem(title: "Add 1 new event", completedCount: 0, totalCount: 1, xP: 75, coins: 50, batch: 41),
    QuestItem(title: "Buy 3 pet cosmetics", completedCount: 0, totalCount: 3, xP: 50, coins: 0, batch: 41),
    
    // Batch 42
    QuestItem(title: "Complete 1 scheduled event", completedCount: 0, totalCount: 1, xP: 125, coins: 100, batch: 42),
    QuestItem(title: "Update 4 graphs", completedCount: 0, totalCount: 4, xP: 75, coins: 50, batch: 42),
    QuestItem(title: "Add 2 new events", completedCount: 0, totalCount: 2, xP: 50, coins: 25, batch: 42),
    
    
    // MARK: - Week 7 (Days 43-49)
    
    // Batch 43
    QuestItem(title: "Complete 4 scheduled event", completedCount: 0, totalCount: 4, xP: 125, coins: 100, batch: 43),
    QuestItem(title: "Add 1 new event", completedCount: 0, totalCount: 1, xP: 75, coins: 50, batch: 43),
    QuestItem(title: "Update Income graph", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 43),
    
    // Batch 44
    QuestItem(title: "Complete 2 scheduled event", completedCount: 0, totalCount: 2, xP: 125, coins: 100, batch: 44),
    QuestItem(title: "Check Daily Summary 21 days in a row", completedCount: 0, totalCount: 1, xP: 75, coins: 50, batch: 44),
    QuestItem(title: "Add 2 new events", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 44),
    
    // Batch 45
    QuestItem(title: "Maintain 45-day streak", completedCount: 0, totalCount: 1, xP: 0, coins: 150, batch: 45),
    QuestItem(title: "Complete 3 scheduled event", completedCount: 0, totalCount: 3, xP: 200, coins: 50, batch: 45),
    QuestItem(title: "Update 3 graphs", completedCount: 0, totalCount: 3, xP: 50, coins: 25, batch: 45),
    
    // Batch 46
    QuestItem(title: "Complete 3 scheduled event", completedCount: 0, totalCount: 3, xP: 125, coins: 100, batch: 46),
    QuestItem(title: "Add 1 new event", completedCount: 0, totalCount: 1, xP: 75, coins: 50, batch: 46),
    QuestItem(title: "Update 4 different graphs", completedCount: 0, totalCount: 4, xP: 50, coins: 25, batch: 46),
    
    // Batch 47
    QuestItem(title: "Complete 2 scheduled event", completedCount: 0, totalCount: 2, xP: 125, coins: 100, batch: 47),
    QuestItem(title: "Update 2 graphs", completedCount: 0, totalCount:2, xP: 75, coins: 50, batch: 47),
    QuestItem(title: "Check daily summary", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 47),
    
    // Batch 48
    QuestItem(title: "Complete 2 scheduled event", completedCount: 0, totalCount: 2, xP: 125, coins: 100, batch: 48),
    QuestItem(title: "Add 1 new event", completedCount: 0, totalCount:1, xP: 75, coins: 50, batch: 48),
    QuestItem(title: "Buy a Tier 3 cosmetic", completedCount: 0, totalCount: 1, xP: 50, coins: 0, batch: 48),
    
    // Batch 49
    QuestItem(title: "Complete 4 scheduled event", completedCount: 0, totalCount: 4, xP: 125, coins: 100, batch: 49),
    QuestItem(title: "Check Weekly Analytics 8 weeks in a row", completedCount: 0, totalCount:1, xP: 75, coins: 50, batch: 49),
    QuestItem(title: "Add 2 new events", completedCount: 0, totalCount: 2, xP: 50, coins: 25, batch: 49),
    
    
    // MARK: - Week 8 (Days 50-56)
    
    // Batch 50
    QuestItem(title: "Maintain 50-day streak", completedCount: 0, totalCount: 1, xP: 0, coins: 175, batch: 50),
    QuestItem(title: "Complete 5 scheduled event", completedCount: 0, totalCount:5, xP: 200, coins: 50, batch: 50),
    QuestItem(title: "Update all graphs", completedCount: 0, totalCount: 5, xP: 50, coins: 25, batch: 50),
    
    // Batch 51
    QuestItem(title: "Complete 3 scheduled event", completedCount: 0, totalCount: 3, xP: 125, coins: 100, batch: 51),
    QuestItem(title: "Add 1 new event", completedCount: 0, totalCount:1, xP: 75, coins: 50, batch: 51),
    QuestItem(title: "Check Daily Summary", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 51),
    
    // Batch 52
    QuestItem(title: "Complete 3 scheduled event", completedCount: 0, totalCount: 3, xP: 125, coins: 100, batch: 52),
    QuestItem(title: "Update 2 graphs", completedCount: 0, totalCount:2, xP: 75, coins: 50, batch: 52),
    QuestItem(title: "Check Weekly Analytics", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 52),
    
    // Batch 53
    QuestItem(title: "Complete 4 scheduled event", completedCount: 0, totalCount: 4, xP: 125, coins: 100, batch: 53),
    QuestItem(title: "Update 4 graphs", completedCount: 0, totalCount:4, xP: 75, coins: 50, batch: 53),
    QuestItem(title: "Check Daily Summary", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 53),
    
    // Batch 54
    QuestItem(title: "Complete 2 scheduled event", completedCount: 0, totalCount: 2, xP: 125, coins: 100, batch: 54),
    QuestItem(title: "Add 2 new event", completedCount: 0, totalCount:2, xP: 75, coins: 50, batch: 54),
    QuestItem(title: "Update one graph", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 54),
    
    // Batch 55
    QuestItem(title: "Maintain 55-day streak", completedCount: 0, totalCount: 1, xP: 0, coins: 175, batch: 55),
    QuestItem(title: "Complete 3 scheduled event", completedCount: 0, totalCount:3, xP: 75, coins: 50, batch: 55),
    QuestItem(title: "Buy 4 pet cosmetics", completedCount: 0, totalCount: 4, xP: 50, coins: 25, batch: 55),//800 coins
    
    // Batch 56
    QuestItem(title: "Complete 2 scheduled event", completedCount: 0, totalCount: 2, xP: 125, coins: 100, batch: 56),
    QuestItem(title: "Add 3 new events", completedCount: 0, totalCount:3, xP: 75, coins: 50, batch: 56),
    QuestItem(title: "Buy 4 pet cosmetics", completedCount: 0, totalCount: 4, xP: 50, coins: 25, batch: 56),
    
    
    
    // MARK: - Week 9 (Days 57-63)
    
    // Batch 57
    QuestItem(title: "Complete 5 scheduled event", completedCount: 0, totalCount: 5, xP: 125, coins: 100, batch: 57),
    QuestItem(title: "Add 1 new event", completedCount: 0, totalCount:1, xP: 75, coins: 50, batch: 57),
    QuestItem(title: "Update 2 graphs", completedCount: 0, totalCount: 2, xP: 50, coins: 25, batch: 57),
    
    
    // Batch 58
    QuestItem(title: "Complete 1 scheduled event", completedCount: 0, totalCount: 1, xP: 125, coins: 100, batch: 58),
    QuestItem(title: "Check Weekly Analytics 10 weeks in a row", completedCount: 0, totalCount:1, xP: 75, coins: 50, batch: 58),
    QuestItem(title: "Update 1 graph", completedCount: 0, totalCount: 1, xP: 50, coins: 25, batch: 58),
    
    
    // Batch 59
    QuestItem(title: "Complete 4 scheduled event", completedCount: 0, totalCount: 4, xP: 125, coins: 100, batch: 59),
    QuestItem(title: "Update 5 different graphs", completedCount: 0, totalCount:5, xP: 75, coins: 50, batch: 59),
    QuestItem(title: "Add 2 new events", completedCount: 0, totalCount: 2, xP: 50, coins: 25, batch: 59),
    
    
    // Batch 60
    QuestItem(title: "Maintain 60-day streak", completedCount: 0, totalCount: 1, xP: 0, coins: 200, batch: 60),
    QuestItem(title: "Complete 3 scheduled event", completedCount: 0, totalCount:3, xP: 200, coins: 50, batch: 60),
    QuestItem(title: "Check all analytics tabs", completedCount: 0, totalCount: 3, xP: 50, coins: 25, batch: 60),
    
    // Batch 61
    QuestItem(title: "Complete 4 scheduled event", completedCount: 0, totalCount: 4, xP: 125, coins: 100, batch: 61),
    QuestItem(title: "Add 2 new event", completedCount: 0, totalCount:2, xP: 75, coins: 50, batch: 61),
    QuestItem(title: "Update all graphs", completedCount: 0, totalCount: 5, xP: 50, coins: 25, batch: 61),
    
    // Batch 62
    QuestItem(title: "Complete 3 scheduled event", completedCount: 0, totalCount: 3, xP: 125, coins: 100, batch: 62),
    QuestItem(title: "Check all analytics tabs", completedCount: 0, totalCount:3, xP: 75, coins: 50, batch: 62),
    QuestItem(title: "Check Daily Summary", completedCount: 0, totalCount:1, xP: 50, coins: 25, batch: 62),
    
    // Batch 63
    QuestItem(title: "Complete 5 scheduled event", completedCount: 0, totalCount: 5, xP: 125, coins: 100, batch: 63),
    QuestItem(title: "Update all graphs", completedCount: 0, totalCount:5, xP: 75, coins: 200, batch: 63),
    QuestItem(title: "own one cosmetic from each tire", completedCount: 0, totalCount:1, xP: 50, coins: 0, batch: 63),
    
    // MARK: - Week 10 (Days 64)
    
    // Batch 64
    QuestItem(title: "Complete 4 scheduled event", completedCount: 0, totalCount: 4, xP: 125, coins: 100, batch: 64),
    QuestItem(title: "Add 1 new event", completedCount: 0, totalCount:1, xP: 75, coins: 50, batch: 64),
    QuestItem(title: "Check Daily Summary", completedCount: 0, totalCount:1, xP: 50, coins: 25, batch: 64),
]
    
