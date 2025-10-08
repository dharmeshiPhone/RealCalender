//
//  PetView.swift
//  real calender
//
//  Created by Mac on 07/10/25.
//


import SwiftUI


struct PetStoreView: View {
    @Environment(\.dismiss) var dismiss
    @State private var userProfile = UserProfile.shared
    @State private var isAnimating = false
    @State private var selectedPet: Int?
    
    // Sample pet data
    let pets = [
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
                // Refined background
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
            }
            .navigationTitle("Pet Store")
            .navigationBarTitleDisplayMode(.large)
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
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isAnimating = true
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
                        .stroke(pet.isUnlocked ? pet.color.opacity(0.3) : Color(.systemGray4), lineWidth: 2)
                )
            
            VStack(spacing: 16) {
                // Pet Icon
                ZStack {
                    Circle()
                        .fill(pet.color.opacity(pet.isUnlocked ? 0.2 : 0.1))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: pet.icon)
                        .font(.system(size: 32))
                        .foregroundColor(pet.isUnlocked ? pet.color : .gray)
                    
                    if !pet.isUnlocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                            .background(
                                Circle()
                                    .fill(Color(.systemBackground))
                                    .frame(width: 24, height: 24)
                            )
                            .offset(x: 25, y: 25)
                    }
                }
                
                // Pet Info
                VStack(spacing: 8) {
                    Text(pet.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(pet.isUnlocked ? .primary : .secondary)
                    
                    if !pet.isUnlocked {
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
                    } else {
                        Text("Unlocked")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
            }
            .padding(16)
            .opacity(pet.isUnlocked ? 1.0 : 0.7)
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
        
        // Handle pet interaction
        if pet.isUnlocked {
            // Navigate to pet details or interact with pet
            print("Selected pet: \(pet.name)")
        } else {
            // Show unlock confirmation
            print("Attempting to unlock \(pet.name) for \(pet.cost) coins")
        }
        
        // Reset selection after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                selectedPet = nil
            }
        }
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            // Unlock Random Pet Button
            Button(action: {
                // Handle random unlock
                print("Unlock random pet tapped!")
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.headline)
                    
                    Text("Unlock Random Pet")
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("250")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(8)
                    
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.caption)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.purple, .blue]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            
            // Purchase Coins Button
            Button(action: {
                // Handle purchase
                print("Purchase coins tapped!")
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.headline)
                    
                    Text("Get More Coins")
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                }
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
        }
    }
}

