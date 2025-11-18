//
//  PetDetailView.swift
//  real calender
//
//  Created by Mac on 08/10/25.
//

import SwiftUI

struct PetDetailView: View {
    var pet: Pet
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var questManager: QuestManager
    @State private var happiness: Double = 25
    @State private var scaleEffect: CGFloat = 0.8
    @State private var glowOpacity: Double = 0
    @State private var rotationAngle: Double = 0
    @State private var showStats = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundGradient
                
                VStack(spacing: 0) {
                    headerView
                        .padding(.horizontal)
                        .padding(.top, 10)
                    Spacer()
                    if pet.isUnlocked{
                        petDisplayView
                            .frame(height: geometry.size.height * 0.35)
                    }else{
                        petLockedDisplayView
                            .frame(height: geometry.size.height * 0.35)
                    }
                   
                    Spacer()
                    statsCardView
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            startAnimations()
            initializePetState()
        }
    }
    

    
    private var backgroundGradient: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    pet.isUnlocked ? pet.swiftUIColor.opacity(0.3) : Color.gray.opacity(0.2),
                    Color.black.opacity(0.8),
                    Color.black
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            // Animated background elements
            ForEach(0..<3) { index in
                Circle()
                    .fill(pet.isUnlocked ? pet.swiftUIColor.opacity(0.1) : Color.gray.opacity(0.05))
                    .frame(width: CGFloat(200 + index * 100))
                    .blur(radius: 20)
                    .offset(
                        x: cos(Double(index) * 2.0 + rotationAngle * 0.5) * 50,
                        y: sin(Double(index) * 2.0 + rotationAngle * 0.5) * 50
                    )
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button(action: {
                withAnimation(.spring()) {
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Back")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.4))
                .cornerRadius(12)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text(pet.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: pet.swiftUIColor, radius: 5, x: 0, y: 0)
                
                if pet.isHatching {
                    HStack(spacing: 6) {
                        Image(systemName: "timer")
                            .font(.caption2)
                        Text("Hatching...")
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.yellow)
                }
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.yellow)
                
                Text("\(pet.cost)")
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
    }
    
    // MARK: - Pet Display
    private var petDisplayView: some View {
        ZStack {
            Circle()
                .fill(pet.swiftUIColor.opacity(0.2))
                .frame(width: 220, height: 220)
                .blur(radius: 20)
                .scaleEffect(scaleEffect)
                .opacity(glowOpacity)
            
            ZStack {
                ForEach(0..<3) { ring in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    pet.swiftUIColor.opacity(0.3),
                                    pet.swiftUIColor.opacity(0.1),
                                    pet.swiftUIColor.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: ring == 0 ? 2 : 1
                        )
                        .frame(width: CGFloat(180 + ring * 40), height: CGFloat(180 + ring * 40))
                        .rotationEffect(.degrees(rotationAngle * Double(ring + 1) * 0.5))
                        .scaleEffect(scaleEffect)
                }
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.8),
                                Color.black.opacity(0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 160, height: 160)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [pet.swiftUIColor, .white, pet.swiftUIColor],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    )
                    .shadow(color: pet.swiftUIColor.opacity(0.5), radius: 20, x: 0, y: 0)
                
                Image(systemName: pet.icon)
                    .font(.system(size: 70, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: pet.swiftUIColor, radius: 15, x: 0, y: 0)
                    .scaleEffect(scaleEffect)
            }
        }
    }
    
    // MARK: - PetLoked Display
    private var petLockedDisplayView: some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 220, height: 220)
                .blur(radius: 15)
                .scaleEffect(scaleEffect)
                .opacity(glowOpacity * 0.5)
            
            ZStack {
                ForEach(0..<3) { ring in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.gray.opacity(0.2),
                                    Color.gray.opacity(0.1),
                                    Color.gray.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: ring == 0 ? 1.5 : 0.8
                        )
                        .frame(width: CGFloat(180 + ring * 40), height: CGFloat(180 + ring * 40))
                        .rotationEffect(.degrees(rotationAngle * Double(ring + 1) * 0.3))
                        .scaleEffect(scaleEffect)
                }
                
                Image("egg")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .foregroundColor(.gray)
                    .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 3)
                    .scaleEffect(scaleEffect)
                    .overlay {
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.7))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.gray)
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                            }
                            
                            Text("LOCKED")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
            }
            
            Rectangle()
                .fill(Color.black.opacity(0.3))
                .frame(width: 200, height: 200)
                .cornerRadius(100)
                .allowsHitTesting(false)
        }
    }
    
    // MARK: - Stats Card
    private var statsCardView: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pet Status")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text(pet.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: pet.swiftUIColor.opacity(0.3), radius: 2, x: 0, y: 0)
                }
                
                Spacer()
                
                Button(action: {
                    // Edit pet action
                }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(pet.swiftUIColor)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                }
            }
            
            // Happiness Meter
            happinessMeterView
            
             //Level and Evolution
//            levelEvolutionView
            
            // Additional Stats (for future use)
//            if showStats {
//                additionalStatsView
//            }
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [
                    Color.black.opacity(0.7),
                    Color.black.opacity(0.9)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.2), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
    }
    
    private var happinessMeterView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: happinessIcon)
                        .font(.system(size: 16))
                        .foregroundColor(happinessColor)
                    
                    Text("Happiness")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("\(Int(happiness))%")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(happinessColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(happinessColor.opacity(0.2))
                    .cornerRadius(8)
            }
            
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.black.opacity(0.4))
                    .frame(height: 16)
                
                Capsule()
                    .fill(happinessGradient)
                    .frame(width: CGFloat(happiness) / 100 * (UIScreen.main.bounds.width - 88), height: 16)
                    .shadow(color: happinessColor.opacity(0.5), radius: 3, x: 0, y: 2)
                
                Capsule()
                    .fill(happinessColor)
                    .frame(width: CGFloat(happiness) / 100 * (UIScreen.main.bounds.width - 88), height: 16)
                    .blur(radius: 8)
                    .opacity(0.3)
            }
            
            Text(happinessDescription)
                .font(.caption)
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("Increase happiness though complete quests")
                .font(.caption)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var levelEvolutionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Level")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("\(8)/10")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    triggerEvolution()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16))
                        
                        Text("Evolve")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(evolutionButtonGradient)
                    .cornerRadius(20)
                    .shadow(color: pet.swiftUIColor.opacity(0.5), radius: 8, x: 0, y: 4)
                    .scaleEffect(8 >= 10 ? 1.0 : 0.95)
                }
                .disabled(8 < 10)
                .opacity(8 >= 10 ? 1.0 : 0.5)
            }
            
            // Level Progress
            HStack(spacing: 4) {
                ForEach(1...10, id: \.self) { level in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(levelGradient)
                        //.fill(level <= 8 ? levelGradient : Color.gray.opacity(0.3))
                        .frame(height: 6)
                        .shadow(color: level <= 8 ? pet.swiftUIColor.opacity(0.3) : .clear, radius: 2, x: 0, y: 1)
                }
            }
        }
    }
    
    private var additionalStatsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Stats")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack {
                StatView(icon: "clock", title: "Age", value: "2 days", color: .blue)
                StatView(icon: "star.fill", title: "Rarity", value: "Common", color: .yellow)
                StatView(icon: "heart.fill", title: "Health", value: "100%", color: .green)
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Computed Properties
    private var happinessColor: Color {
        switch happiness {
        case 0..<30: return .red
        case 30..<70: return .yellow
        default: return .green
        }
    }
    
    private var happinessIcon: String {
        switch happiness {
        case 0..<30: return "heart.slash"
        case 30..<70: return "heart"
        default: return "heart.fill"
        }
    }
    
    private var happinessDescription: String {
        switch happiness {
        case 0..<30: return "Your pet is unhappy. Try playing with it more!"
        case 30..<70: return "Your pet is content. Keep up the good work!"
        default: return "Your pet is extremely happy! Great job!"
        }
    }
    
    private var happinessGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [happinessColor.opacity(0.8), happinessColor]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var evolutionButtonGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                pet.swiftUIColor,
                pet.swiftUIColor.opacity(0.8),
                pet.swiftUIColor
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var levelGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.blue, Color.purple]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    // MARK: - Methods
    
    private func initializePetState() {
        let allQuests = questManager.getCurrentBatchQuests()
        guard !allQuests.isEmpty else {
            happiness = 10
            return
        }
        
        // Count completed quests
        let completedCount = allQuests.filter { $0.isCompleted }.count
        let totalCount = allQuests.count
        
        // Calculate percentage of completion
        let completionRatio = Double(completedCount) / Double(totalCount)
        var value = completionRatio * 100
        
//        // Adjust based on pet state
//        if pet.isReadyToReveal {
//            // If ready to reveal, boost baseline happiness slightly
//            value = max(value, 70)
//        } else if pet.isUnlocked {
//            // If fully unlocked, happiness should be 100
//            value = 100
//        } else if completedCount == 0 {
//            // If no quests started
//            value = 10
//        } else {
//            // Clamp the value between 10–100
//            value = min(max(value, 25), 100)
//        }
        
        happiness = max(value,10)
    }

    
    private func startAnimations() {
        // Reset state first
        scaleEffect = 0.3
        glowOpacity = 0
        rotationAngle = 0
        showStats = false
        
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            scaleEffect = 1.0
            glowOpacity = 0.6
            showStats = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                glowOpacity = 0.8
            }
        }
    }

    private func triggerEvolution() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            scaleEffect = 1.3
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                scaleEffect = 1.0
            }
        }
    }
}

// MARK: - Supporting Views
struct StatView: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
    }
}

