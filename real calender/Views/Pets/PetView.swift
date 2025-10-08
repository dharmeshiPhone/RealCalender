//
//  PetView.swift
//  real calender
//
//  Created by Mac on 07/10/25.
//


import SwiftUI

struct PetStoreView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var questManager: QuestManager
    @State private var userProfile = UserProfile.shared
    @State private var isAnimating = false
    @State private var selectedPet: Int?
    @State private var pets: [Pet] = []
    @State private var showingUnlockAnimation = false
    @State private var unlockedPetIndex: Int?
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var openPet: Pet? = nil
    
    // Sample initial pet data
    let initialPets = [
        Pet(name: "Fluffy", isUnlocked: false, cost: 50, icon: "pawprint.circle.fill", color: .blue),
        Pet(name: "Sparky", isUnlocked: false, cost: 100, icon: "bolt.circle.fill", color: .yellow),
        Pet(name: "Aqua", isUnlocked: false, cost: 150, icon: "drop.circle.fill", color: .cyan),
        Pet(name: "Rocky", isUnlocked: false, cost: 200, icon: "shield.righthalf.filled", color: .brown),
        Pet(name: "Mystic", isUnlocked: false, cost: 250, icon: "apple.image.playground.fill", color: .purple),
        Pet(name: "Blaze", isUnlocked: false, cost: 300, icon: "flame.circle.fill", color: .orange)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemGroupedBackground),
                        Color(.secondarySystemGroupedBackground)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        headerSection
                        petCollectionSection
                        actionButtonsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                if showingUnlockAnimation, let unlockedIndex = unlockedPetIndex, unlockedIndex < pets.count {
                    UnlockAnimationView(
                        pet: pets[unlockedIndex],
                        isShowing: $showingUnlockAnimation
                    )
                }
            }
            .navigationTitle("Pet Store")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $openPet, destination: { pet in
                PetDetailView(pet: pet)
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .onAppear {
                loadPets()
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isAnimating = true
                }
            }
            .onReceive(timer) { _ in
                withAnimation(.linear(duration: 0.25)) {
                    pets = pets.map { $0 }
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack(spacing: 16) {
            statsCard(
                title: "Total XP",
                value: "\(userProfile.xp)",
                icon: "star.fill",
                color: .purple
            )
            
            statsCard(
                title: "Coins",
                value: "\(userProfile.coins)",
                icon: "dollarsign.circle.fill",
                color: .orange
            )
        }
        .frame(height: 100)
    }
    
    private func statsCard(title: String, value: String, icon: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )
            
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 44, height: 44)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                Spacer()
            }
            .padding(.horizontal, 12)
        }
    }
    
    // MARK: - Pet Collection Section
    private var petCollectionSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Your Pets")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(pets.filter { $0.isUnlocked }.count)/\(pets.count) collected")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                ForEach(Array(pets.enumerated()), id: \.offset) { index, pet in
//                    NavigationLink {
//                        PetDetailView(pet: pet)
//                    } label: {
//
//                    }
                    petCardView(pet: pet, index: index)
                }
            }
        }
    }
    
    private func petCardView(pet: Pet, index: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(pet.isUnlocked ? pet.color.color.opacity(0.3) : Color(.systemGray4), lineWidth: 2)
                )
            
            VStack(spacing: 16) {
                // Pet Icon
                ZStack {
                    Circle()
                        .fill(pet.color.color.opacity(pet.isUnlocked ? 0.2 : 0.1))
                        .frame(width: pet.isUnlocked ? 80 : 95, height: pet.isUnlocked ? 80 : 95)
                    
                    if pet.isUnlocked {
                        Image(systemName: pet.icon)
                            .font(.system(size: 32))
                            .foregroundColor(pet.color.color)
                    } else {
                        Image(.egg)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 80)
                    }
                    
                    if !pet.isUnlocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 25))
                            .foregroundColor(.gray)
                            .background(
                                Circle()
                                    .fill(Color(.systemBackground))
                                    .frame(width: 44, height: 44)
                            )
                            .offset(x: 25, y: 25)
                    }
                }
                
                // Pet Info
                VStack(spacing: 8) {
                    if pet.isUnlocked {
                        Text(pet.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Unlocked")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(12)
                        
                    } else if pet.isHatching {
                        let remaining = pet.timeRemaining ?? 0

                        
                        Text("Hatching...")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        Text(String(format: "%02d:%02d:%02d",
                            Int(remaining) / 3600,
                            (Int(remaining) % 3600) / 60,
                            Int(remaining) % 60))
                        .font(.system(size: 24, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white)
                        
                    } else if pet.isReadyToReveal {
                        Button(action: {
                            revealPet(at: index)
                        }) {
                            Text("Reveal!")
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                        
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            
                            Text("\(pet.cost)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }
            .padding(16)
            .opacity(pet.isUnlocked ? 1.0 : 0.8)
        }
        .scaleEffect(selectedPet == index ? 0.95 : 1.0)
        .onTapGesture {
            handlePetSelection(index: index, pet: pet)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedPet)
    }
    
    private func handlePetSelection(index: Int, pet: Pet) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            selectedPet = index
        }
        
        if pet.isUnlocked {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                selectedPet = nil
//                openPet = pet
//            }
            print("Selected pet: \(pet.name)")
        } else if !pet.isHatching && !pet.isReadyToReveal {
            attemptToUnlockPet(at: index)
        }else{
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                selectedPet = nil
//                openPet = pet
//            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            selectedPet = nil
        }
    }
    
    private func attemptToUnlockPet(at index: Int) {
        let pet = pets[index]
        
        if userProfile.coins >= pet.cost {
            userProfile.coins -= pet.cost
            userProfile.save()
            
            pets[index].unlockTimestamp = Date()
            savePets()
            
            print("🪺 \(pet.name) is now hatching! Will unlock in 24 hours.")
        } else {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                selectedPet = nil
//                openPet = pet
//            }
            print("Not enough coins to unlock \(pet.name).")
        }
    }
    
    private func revealPet(at index: Int) {
        pets[index].isUnlocked = true
        pets[index].unlockTimestamp = nil
        savePets()
        
        unlockedPetIndex = index
        showingUnlockAnimation = true
        
        questManager.completeQuest(named: "Get your first egg from the pet store")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.34) {
            withAnimation(.easeOut(duration: 0.3)){
                questManager.showLevelUp = true
            }
        }
    }
    
    // MARK: - Action Buttons
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            Button(action: { unlockRandomPet() }) {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                    Text("Unlock Random Pet").fontWeight(.semibold)
                    Spacer()
                    Text("250")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(8)
                    Image(systemName: "dollarsign.circle.fill")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing))
                .cornerRadius(16)
                .shadow(color: .purple.opacity(0.3), radius: 8)
            }
        }
    }
    
    // MARK: - UserDefaults
    private func loadPets() {
        if let savedPetsData = UserDefaults.standard.data(forKey: "userPets"),
           let decodedPets = try? JSONDecoder().decode([Pet].self, from: savedPetsData) {
            pets = decodedPets
        } else {
            pets = initialPets
            savePets()
        }
    }
    
    private func savePets() {
        if let encodedPets = try? JSONEncoder().encode(pets) {
            UserDefaults.standard.set(encodedPets, forKey: "userPets")
        }
    }
    
    private func unlockRandomPet() {
        let lockedPets = pets.enumerated().filter { !$0.element.isUnlocked }
        guard !lockedPets.isEmpty else { return }
        
        let randomCost = 250
        guard userProfile.coins >= randomCost else { return }
        
        userProfile.coins -= randomCost
        userProfile.save()
        
        let randomIndex = Int.random(in: 0..<lockedPets.count)
        let (index, _) = lockedPets[randomIndex]
        
        pets[index].isUnlocked = true
        savePets()
        
        unlockedPetIndex = index
        showingUnlockAnimation = true
    }
}



// MARK: - Unlock Animation View
struct UnlockAnimationView: View {
    let pet: Pet
    @Binding var isShowing: Bool
    @State private var animationPhase = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
            
            VStack(spacing: 30) {
                ZStack {
                    ForEach(0..<12) { i in
                        Circle()
                            .fill(Color.white)
                            .frame(width: 8, height: 8)
                            .offset(x: cos(Double(i) * .pi / 6) * 100,
                                    y: sin(Double(i) * .pi / 6) * 100)
                            .scaleEffect(animationPhase >= 1 ? 1.5 : 0.5)
                            .opacity(animationPhase >= 1 ? 0 : 1)
                    }
                }
                .animation(.easeOut(duration: 0.8).delay(0.5), value: animationPhase)
                
                ZStack {
                    Circle()
                        .fill(pet.color.color.opacity(0.3))
                        .frame(width: 150, height: 150)
                        .scaleEffect(animationPhase >= 2 ? 1.2 : 0.1)
                    
                    Image(systemName: pet.icon)
                        .font(.system(size: 60))
                        .foregroundColor(pet.color.color)
                        .scaleEffect(animationPhase >= 2 ? 1.0 : 0.1)
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(1.0), value: animationPhase)
                
                VStack(spacing: 10) {
                    Text("Pet Unlocked!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .opacity(animationPhase >= 3 ? 1 : 0)
                    
                    Text(pet.name)
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(pet.color.color)
                        .opacity(animationPhase >= 3 ? 1 : 0)
                }
                .animation(.easeIn(duration: 0.5).delay(1.8), value: animationPhase)
                
                if animationPhase >= 3 {
                    Button("Continue") {
                        withAnimation(.easeOut(duration: 0.3)) { isShowing = false }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 12)
                    .background(pet.color.color)
                    .cornerRadius(25)
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .onAppear { startAnimationSequence() }
    }
    
    private func startAnimationSequence() {
        withAnimation(.easeOut(duration: 0.3)) { animationPhase = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { animationPhase = 2 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeIn(duration: 0.5)) { animationPhase = 3 }
        }
    }
}
