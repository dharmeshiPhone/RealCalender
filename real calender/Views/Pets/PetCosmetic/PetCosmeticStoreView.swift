//
//  PetCosmeticStoreView.swift
//  real calender
//
//  Created by Mac on 12/12/25.
//


import SwiftUI

struct PetCosmeticStoreView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var questManager: QuestManager
    var pet: Pet
    @State private var showingPurchaseAlert = false
    @State private var showingUnlockAlert = false
    @State private var selectedSlot: CosmeticSlot?
    @State private var selectedTierForUnlock: CosmeticTier?
    @State private var purchaseMessage: String = ""
    @State private var userProfile = UserProfile.shared
    
    // MARK: - Tier Prices
    private let tierUnlockPrices: [Int] = [150, 600, 800,1500] // Prices to unlock Tier 1, 2, 3
    
    @State private var tiers: [CosmeticTier] = intials
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                headerView
                    .padding(.top, 10)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 40) {
                        ForEach($tiers) { $tier in
                            TierSectionView(
                                tier: $tier,
                                coins: userProfile.coins,
                                tierUnlockPrice: getTierUnlockPrice(tierId: tier.id),
                                onSlotTapped: handleSlotTap,
                                onUnlockTier: unlockTierTapped
                            )
                        }
                    }
                    .padding(.vertical, 20)
                }
                .scrollIndicators(.hidden)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Purchase \(selectedSlot?.name ?? "Item")?", isPresented: $showingPurchaseAlert) {
            Button("Buy for \(selectedSlot?.cost ?? 0) Coins", role: .destructive) {
                if let slot = selectedSlot {
                    attemptPurchase(slot: slot)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(purchaseMessage)
        }
        .alert("Unlock \(selectedTierForUnlock?.name ?? "Tier")?", isPresented: $showingUnlockAlert) {
            Button("Unlock for \(getTierUnlockPrice(tierId: selectedTierForUnlock?.id ?? 0)) Coins", role: .destructive) {
                if let tier = selectedTierForUnlock {
                    attemptUnlockTier(tier: tier)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Do you want to spend \(getTierUnlockPrice(tierId: selectedTierForUnlock?.id ?? 0)) coins to unlock \(selectedTierForUnlock?.name ?? "this tier") and access all its cosmetics?")
        }
        .onAppear {
            loadTiers()
            unlockTierIfEligible()
        }
        .onDisappear {
            saveTiers()
        }
        .preferredColorScheme(.dark)
    }
    
    private func getTierUnlockPrice(tierId: Int) -> Int {
        let index = tierId - 1
        guard index >= 0 && index < tierUnlockPrices.count else { return 999 }
        return tierUnlockPrices[index]
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Button(action: {
                withAnimation(.spring()) {
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(14)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.25))
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                            )
                    )
            }
            
            
            Spacer()
            
            
            Text("Cosmetic store")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
            
            HStack(spacing: 8) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.yellow)
                
                Text("\(userProfile.coins)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                LinearGradient(
                    colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.2)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
            )
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Purchase Logic
    private func handleSlotTap(slot: CosmeticSlot, tierId: Int) {
        if slot.isOwned {
            self.selectedSlot = slot
            self.purchaseMessage = "You already own the \(slot.name)!"
            self.showingPurchaseAlert = true
            return
        }
        
        if userProfile.coins >= slot.cost {
            self.selectedSlot = slot
            self.purchaseMessage = "Do you want to spend \(slot.cost) coins to unlock the \(slot.name)?"
            self.showingPurchaseAlert = true
        } else {
            self.selectedSlot = slot
            self.purchaseMessage = "You need \(slot.cost - userProfile.coins) more coins to buy the \(slot.name)."
            self.showingPurchaseAlert = true
        }
    }
    
    private func unlockTierTapped(tier: CosmeticTier) {
        if tier.isUnlocked {
            // Already unlocked, just show info
            self.selectedTierForUnlock = tier
            self.purchaseMessage = "\(tier.name) is already unlocked!"
            self.showingPurchaseAlert = true
            return
        }
        
        let unlockPrice = getTierUnlockPrice(tierId: tier.id)
        
        if userProfile.coins >= unlockPrice {
            self.selectedTierForUnlock = tier
            self.showingUnlockAlert = true
        } else {
            self.selectedTierForUnlock = tier
            self.showingUnlockAlert = true
            //            self.purchaseMessage = "You need \(unlockPrice - userProfile.coins) more coins to unlock \(tier.name)."
            //            self.showingPurchaseAlert = true
        }
    }
    
    private func attemptPurchase(slot: CosmeticSlot) {
        guard userProfile.coins >= slot.cost else { return }
        
        // Find the slot and update its state
        for i in 0..<tiers.count {
            for j in 0..<tiers[i].slots.count {
                if tiers[i].slots[j].id == slot.id {
                    tiers[i].slots[j].isOwned = true
                    userProfile.coins -= slot.cost
                    userProfile.save()
                    saveTiers()
                    break
                }
            }
        }
        self.selectedSlot = nil
    }
    
    private func attemptUnlockTier(tier: CosmeticTier) {
        let unlockPrice = getTierUnlockPrice(tierId: tier.id)
        guard userProfile.coins >= unlockPrice else { return }
        
        // Unlock the tier
        if let index = tiers.firstIndex(where: { $0.id == tier.id }) {
            tiers[index].isLocked = false
            tiers[index].isUnlocked = true
            userProfile.coins -= unlockPrice
            userProfile.save()
            saveTiers()
        }
        self.selectedTierForUnlock = nil
    }
    
    // MARK: - Save/Load Tiers
    
    private func loadTiers() {
        if let savedTiersData = UserDefaults.standard.data(forKey: "petCosmeticTiers"),
           let decodedTiers = try? JSONDecoder().decode([CosmeticTier].self, from: savedTiersData) {
            tiers = decodedTiers
        } else {
            saveTiers()
        }
    }
    
    private func saveTiers() {
        if let encodedTiers = try? JSONEncoder().encode(tiers) {
            UserDefaults.standard.set(encodedTiers, forKey: "petCosmeticTiers")
        }
    }
    
    private func unlockTierIfEligible() {
        if userProfile.level > 5{
            if let index = tiers.firstIndex(where: { $0.id == 1 }) {
                tiers[index].needTounlock = true
            }
        }
        
        if userProfile.level > 8{
            if let index = tiers.firstIndex(where: { $0.id == 2 }) {
                tiers[index].needTounlock = true
            }
        }
        
        if userProfile.level > 15{
            if let index = tiers.firstIndex(where: { $0.id == 3 }) {
                tiers[index].needTounlock = true
            }
        }
        if userProfile.level > 43{
            if let index = tiers.firstIndex(where: { $0.id == 4 }) {
                tiers[index].needTounlock = true
            }
        }
        // Save immediately
        saveTiers()
    }
    
    
    private func checkPurchasedValueForQuest() {
        var totalPurchasedValue = 0
        var numberofPurchased = 0
        
        for tier in tiers {
            for slot in tier.slots {
                if slot.isOwned {
                    totalPurchasedValue += slot.cost
                    numberofPurchased += 1
                                        if tier.id == 3{
                                            if questManager.currentBatch == 48{
                                                questManager.completeQuestWithIncremnetStaticForce(named: "Buy a Tier 3 cosmetic", num: 1 , Quebatch: 48)
                                            }
                                        }
                }
                
            }
        }
        
        if totalPurchasedValue >= 400 {
            questManager.completeQuestWithIncremnetStaticForce(named: "Buy a pet cosmetic", num: 1, Quebatch: 10)
        }
        
        if totalPurchasedValue >= 550 {
            questManager.completeQuestWithIncremnetStaticForce(named: "Buy 2 pet cosmetics", num: 1, Quebatch: 19)
        }
        
        if totalPurchasedValue >= 700 {
            questManager.completeQuestWithIncremnetStaticForce(named: "Buy 2 pet cosmetics", num: 2, Quebatch: 19)
        }
        
        if totalPurchasedValue >= 950 {
            questManager.completeQuestWithIncremnetStaticForce(named: "Buy pet cosmetic", num: 1, Quebatch: 28)
        }
        
        
        
        if numberofPurchased > 5 {
            questManager.completeQuestWithIncremnetStaticForce(named: "Buy 2 pet cosmetics", num: numberofPurchased - 4 , Quebatch: 34)
        }
        
        if numberofPurchased > 7 {
            questManager.completeQuestWithIncremnetStaticForce(named: "Buy 3 pet cosmetics", num: numberofPurchased - 7 , Quebatch: 41)
        }
        
//        if questManager.currentBatch == 48{
//            questManager.completeQuestWithIncremnetStaticForce(named: "Buy a Tier 3 cosmetic", num: 1 , Quebatch: 48)
//        }
        
        if numberofPurchased > 11{
            questManager.completeQuestWithIncremnetStaticForce(named: "Buy 4 pet cosmetics", num: numberofPurchased - 11 , Quebatch: 55)
        }
        
        checkOwnOneFromEachTier()
        
        
    }
    
    private func checkOwnOneFromEachTier() {
        // Dictionary: [tierId: countOwned]
        var ownedPerTier: [Int : Int] = [:]
        
        for tier in tiers {
            let ownedCount = tier.slots.filter { $0.isOwned }.count
            ownedPerTier[tier.id] = ownedCount
        }
        
        // Check if ALL tiers have 1 or more owned slots
        let allTiersCompleted = ownedPerTier.values.allSatisfy { $0 > 0 }
        
        if allTiersCompleted {
            questManager.completeQuestWithIncremnetStaticForce(
                named: "own one cosmetic from each tire",
                num: 1,
                Quebatch: 63
            )
        }
    }
}
