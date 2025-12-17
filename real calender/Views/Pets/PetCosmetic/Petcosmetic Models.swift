//
//  Petcosmetic Models.swift
//  real calender
//
//  Created by Mac on 12/12/25.
//

import SwiftUI


var intials: [CosmeticTier] = [
    CosmeticTier(
        id: 1,
        name: "Tier 1",
        slots: [
            CosmeticSlot(name: "Basic Hat", cost: 200, isOwned: false),
            CosmeticSlot(name: "Red Scarf", cost: 200, isOwned: false),
            CosmeticSlot(name: "Blue Vest", cost: 200, isOwned: false),
            CosmeticSlot(name: "Green Shoes", cost: 200, isOwned: false)
        ],
        isLocked: false, // Tier 1 starts unlocked
        isUnlocked: false, needTounlock: false
    ),
    CosmeticTier(
        id: 2,
        name: "Tier 2",
        slots: [
            CosmeticSlot(name: "Crown", cost: 300, isOwned: false),
            CosmeticSlot(name: "Wings", cost: 300, isOwned: false),
            CosmeticSlot(name: "Halo", cost: 300, isOwned: false),
            CosmeticSlot(name: "Mystic Aura", cost: 300, isOwned: false)
        ],
        isLocked: true,
        isUnlocked: false, needTounlock: false
    ),
    CosmeticTier(
        id: 3,
        name: "Tier 3",
        slots: [
            CosmeticSlot(name: "Mech Suit", cost: 400, isOwned: false),
            CosmeticSlot(name: "Dragon Scale", cost: 400, isOwned: false),
            CosmeticSlot(name: "Time Traveler", cost: 400, isOwned: false),
            CosmeticSlot(name: "Cosmic Glow", cost: 400, isOwned: false)
        ],
        isLocked: true,
        isUnlocked: false, needTounlock: false
    ),
    CosmeticTier(
        id: 4,
        name: "Tier 4",
        slots: [
            CosmeticSlot(name: "Mech Suit", cost: 500, isOwned: false),
            CosmeticSlot(name: "Dragon Scale", cost: 500, isOwned: false),
            CosmeticSlot(name: "Time Traveler", cost: 500, isOwned: false),
            CosmeticSlot(name: "Cosmic Glow", cost: 500, isOwned: false)
        ],
        isLocked: true,
        isUnlocked: false, needTounlock: false
    )
]

// MARK: - Data Models
struct CosmeticSlot: Identifiable, Equatable, Codable {
    let id = UUID()
    let name: String
    let cost: Int
    var isOwned: Bool
}

struct CosmeticTier: Identifiable, Codable {
    let id: Int // Now with explicit ID for tier identification
    let name: String
    var slots: [CosmeticSlot]
    var isLocked: Bool
    var isUnlocked: Bool
    var needTounlock:Bool // level based
    
}


// MARK: - Supproting Views


// MARK: - Cosmetic Slot View
struct CosmeticSlotView: View {
    let slot: CosmeticSlot
    let userCoins: Int
    let tierId: Int
    let isTierUnlocked: Bool
    
    private var canAfford: Bool {
        !slot.isOwned && userCoins >= slot.cost && isTierUnlocked
    }
    
    private var isAvailable: Bool {
        isTierUnlocked
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Background Box Style
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        isAvailable ?
                        (slot.isOwned ? Color.green.opacity(0.3) : Color.gray.opacity(0.2)) :
                            Color.black.opacity(0.5)
                    )
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(
                                isAvailable ?
                                (slot.isOwned ? Color.green : Color.gray.opacity(0.3)) :
                                    Color.red.opacity(0.3),
                                lineWidth: 2
                            )
                    )
                
                // Content
                if !isTierUnlocked {
                    // Locked Tier View
                    VStack(spacing: 8) {
                        Image(systemName: "lock.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.red)
                        
                        Text("Locked Tier")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                } else if slot.isOwned {
                    // Owned Item View
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.green)
                        
                        Text(slot.name)
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Owned")
                            .font(.system(size: 10))
                            .foregroundColor(.green)
                    }
                } else {
                    // Available for Purchase
                    VStack(spacing: 8) {
                        Image(systemName: "lock.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(canAfford ? .yellow : .gray)
                        
                        Text(slot.name)
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        // Cost Display
                        HStack(spacing: 4) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.caption)
                                .foregroundColor(canAfford ? .yellow : .red)
                            
                            Text("\(slot.cost)")
                                .font(.caption.bold())
                                .foregroundColor(canAfford ? .yellow : .red)
                        }
                    }
                }
            }
            .frame(width: UIScreen.main.bounds.width / 2.2,
                   height: UIScreen.main.bounds.width / 2.2)
        }
    }
}


// MARK: - Tier Section View
struct TierSectionView: View {
    @Binding var tier: CosmeticTier
    var coins: Int
    var tierUnlockPrice: Int
    var onSlotTapped: (CosmeticSlot, Int) -> Void
    var onUnlockTier: (CosmeticTier) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Tier Header with Unlock Button
            HStack {
                Text(tier.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(tier.isUnlocked ? .white : .gray)
                
                Spacer()
                
                if !tier.isUnlocked {
                    Button(action: {
                        if tier.needTounlock {
                            onUnlockTier(tier)
                        }
                    }) {
                        if tier.needTounlock {
                            HStack(spacing: 6) {
                                Image(systemName: "lock.open.fill")
                                    .font(.caption)
                                
                                Text("\(tierUnlockPrice)")
                                    .font(.caption.bold())
                                
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.caption)
                            }
                            .foregroundColor(coins >= tierUnlockPrice ? .yellow : .red)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(coins >= tierUnlockPrice ?
                                          Color.yellow.opacity(0.1) :
                                            Color.red.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(coins >= tierUnlockPrice ?
                                            Color.yellow.opacity(0.5) :
                                                Color.red.opacity(0.5),
                                            lineWidth: 1)
                            )
                        }else{
                            HStack(spacing: 6) {
                                Image(systemName: "lock")
                                    .font(.caption)
                                
                                Text("Locked")
                                    .font(.caption.bold())
                            }
                            .foregroundColor(.gray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.gray.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.5),
                                            lineWidth: 1)
                            )
                        }
                    }
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.open.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        Text("Unlocked")
                            .font(.caption.bold())
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.green.opacity(0.5), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal)
            
            // Tier Status Text
            Text(tier.isUnlocked ?
                 "Unlocked • \(tier.slots.filter { $0.isOwned }.count)/\(tier.slots.count) items purchased" :
                    "Locked • Unlock for \(tierUnlockPrice) coins")
            .font(.caption)
            .foregroundColor(tier.isUnlocked ? .green.opacity(0.8) : .red.opacity(0.8))
            .padding(.horizontal)
            
            // Cosmetic Items
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(tier.slots) { slot in
                        CosmeticSlotView(
                            slot: slot,
                            userCoins: coins,
                            tierId: tier.id,
                            isTierUnlocked: tier.isUnlocked
                        )
                        .onTapGesture {
                            if tier.isUnlocked && !slot.isOwned {
                                onSlotTapped(slot, tier.id)
                            }
                        }
                        .opacity(tier.isUnlocked ? 1.0 : 0.6)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 10)
     
    }
}
