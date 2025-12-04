//
//  StreakPopupView.swift
//  real calender
//
//  Created by Mac on 03/12/25.
//

import SwiftUI

struct StreakPopupView: View {
    @Binding var isPresented: Bool
    let streakCount: Int
    let previousStreak: Int
    let onDismiss: () -> Void
    
    @State private var animatedStreak = 0
    @State private var showConfetti = false
    @State private var isAnimating = false
    
    var isStreakIncreased: Bool {
        streakCount > previousStreak
    }
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            // Main popup card
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text(isStreakIncreased ? "🔥 Streak Increased! 🔥" : "Keep Going! 💪")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        
                    Spacer()
                    Button(action: {
                        withAnimation(.spring()) {
                            isPresented = false
                            onDismiss()
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: isStreakIncreased ?
                            [Color.orange, Color.red] :
                            [Color.blue, Color.purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                
                // Content
                VStack(spacing: 20) {
                    Spacer().frame(height: 20)
                    
                    // Streak count with animation
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 140, height: 140)
                            .shadow(color: .orange.opacity(0.4), radius: 20)
                        
                        VStack {
                            Text("\(animatedStreak)")
                                .font(.system(size: 48, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2)
                            
                            Text("DAYS")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .overlay {
                        // Confetti effect
                        if showConfetti && isStreakIncreased {
                            ConfettiView()
                        }
                    }
                    
                    // Progress indicator
                    VStack(spacing: 8) {
                        Text("🔥 Your Current Streak")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 8)
                                    .cornerRadius(4)
                                
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.orange, .red],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: min(CGFloat(streakCount) / 30.0 * geometry.size.width, geometry.size.width), height: 8)
                                    .cornerRadius(4)
                            }
                        }
                        .frame(height: 8)
                        
                        HStack {
                            Text("Day \(streakCount)")
                                .font(.caption)
                                .foregroundColor(.orange)
                            
                            Spacer()
                            
                            Text("Goal: 66 days")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Stats
                    HStack(spacing: 30) {
                        StatCards(
                            title: "🔥",
                            value: "\(streakCount)",
                            subtitle: "Current"
                        )
                        
                        Divider()
                            .frame(height: 40)
                        
                        StatCards(
                            title: "🏆",
                            value: "\(streakCount > previousStreak ? streakCount : previousStreak)",
                            subtitle: "Longest"
                        )
                    }
                    .padding(.horizontal)
                    
                    // Motivational message
                    Text(getMotivationalMessage())
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                  
                    
                    // Action button
                    Button(action: {
                        withAnimation(.spring()) {
                            isPresented = false
                            onDismiss()
                        }
                    }) {
                        Text("Continue Journey")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(15)
                            .shadow(color: .blue.opacity(0.3), radius: 10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .background(Color.white)
                
            }
            .frame(width: min(350, UIScreen.main.bounds.width * 0.9))
            .cornerRadius(25)
            .shadow(color: .black.opacity(0.2), radius: 30)
            .scaleEffect(isAnimating ? 1 : 0.8)
            
           
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isAnimating = true
            }
            
            // Animate streak count
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 1.5)) {
                    animatedStreak = streakCount
                }
            }
            
            // Show confetti for increased streak
            if isStreakIncreased {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showConfetti = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showConfetti = false
                    }
                }
            }
        }
    }
    
    private func getMotivationalMessage() -> String {
        switch streakCount {
        case 1:
            return "Great start! Come back tomorrow to keep your streak alive! 🌟"
        case 2...7:
            return "You're building momentum! Keep it up! 💪"
        case 8...14:
            return "Wow! You're on fire! Don't stop now! 🔥"
        case 15...29:
            return "Incredible dedication! You're almost at the goal! 🚀"
        case 30...:
            return "Legendary! You've mastered consistency! 🏆"
        default:
            return "Every day counts! Keep going! ✨"
        }
    }
}

struct StatCards: View {
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.title2)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}


struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    
    struct ConfettiPiece: Identifiable {
        let id = UUID()
        var position: CGPoint
        var color: Color
        var rotation: Double
        var rotationSpeed: Double
        var verticalSpeed: Double
        var horizontalSpeed: Double
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confettiPieces) { piece in
                    Circle()
                        .fill(piece.color)
                        .frame(width: 8, height: 8)
                        .position(piece.position)
                        .rotationEffect(.degrees(piece.rotation))
                }
            }
            .onAppear {
                startConfetti(in: geometry.size)
            }
        }
        .allowsHitTesting(false)
    }
    
    private func startConfetti(in size: CGSize) {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
        
        for _ in 0..<50 {
            let piece = ConfettiPiece(
                position: CGPoint(x: size.width / 2, y: -10),
                color: colors.randomElement()!,
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: 5...20),
                verticalSpeed: Double.random(in: 200...400),
                horizontalSpeed: Double.random(in: -50...50)
            )
            confettiPieces.append(piece)
        }
        
        // Animate confetti
        for (index, _) in confettiPieces.enumerated() {
            withAnimation(.easeOut(duration: 3)) {
                confettiPieces[index].position.y += 800
                confettiPieces[index].position.x += confettiPieces[index].horizontalSpeed
            }
            
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                confettiPieces[index].rotation += 360
            }
        }
        
        // Remove confetti after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            confettiPieces.removeAll()
        }
    }
}
