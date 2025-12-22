//
//  WelcomeBackPopupView.swift
//  real calender
//
//  Created by Mac on 20/12/25.
//

import SwiftUI

struct WelcomeBackPopupView: View {
    @Binding var isPresented: Bool
    @State private var  petName: String = "Fluffy"
    let onClaim: () -> Void
    
    var body: some View {
        ZStack {
            // Gradient background - dark theme
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.7),
                    Color(red: 0.1, green: 0.1, blue: 0.2).opacity(0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("We've missed you!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Here's a special treat to help \(petName) feel better.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                // Reward Card
                VStack(spacing: 12) {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                    
                    Text("🎁 Welcome Back Gift")
                        .font(.headline)
                    
                    Text("Instantly restores 50% of \(petName)'s happiness")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.18, green: 0.12, blue: 0.1),
                            Color(red: 0.1, green: 0.07, blue: 0.05)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                //.background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Claim Button
                Button(action: {
                    withAnimation {
                        onClaim()
                        isPresented = false
                    }
                }) {
                    Text("Claim Gift")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
            .padding(.vertical, 30)
            .frame(width: 320)
            .background(
                // Dark gradient background for the card
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.15, green: 0.15, blue: 0.25),
                        Color(red: 0.08, green: 0.08, blue: 0.15)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(20)
            .shadow(radius: 20)
        }
        .transition(.opacity.combined(with: .scale))
        .zIndex(1000)
        .onAppear {
            loadPets()
        }
    }
    
    private func loadPets() {
        if let savedPetsData = UserDefaults.standard.data(forKey: "userPets"),
           let decodedPets = try? JSONDecoder().decode([Pet].self, from: savedPetsData) {
            petName = decodedPets.first?.name ?? "Fluffy"
        }
    }
    
}

