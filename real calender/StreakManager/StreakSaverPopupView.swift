//
//  StreakSaverPopupView.swift
//  real calender
//
//  Created by Mac on 19/12/25.
//

import SwiftUI

// MARK: - Streak Popup Views

struct StreakFrozenPopupView: View {
    @Binding var isPresented: Bool
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header with icon
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 60, height: 60)
                        
                        Text("❄️")
                            .font(.system(size: 32))
                    }
                    
                    Text("Streak Frozen ❄️")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                // Message
                VStack(spacing: 8) {
                    Text("You missed a day, but your streak is frozen once — so you're still in the game.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    Text("Stay consistent to keep moving forward.")
                        .multilineTextAlignment(.center)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal)
                
                // Divider
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 1)
                    .padding(.horizontal)
                
                // Button
                Button(action: {
                    onContinue()
                    isPresented = false
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 24)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                    
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.8),
                                    Color.cyan.opacity(0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                }
            )
            .shadow(color: Color.black.opacity(0.15), radius: 25, x: 0, y: 10)
            .padding(.horizontal, 40)
        }
    }
}


struct StreakSaverPopupView: View {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let price: Int
    let onBuy: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header with icon
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.1))
                            .frame(width: 60, height: 60)
                        
                        Text("🔥")
                            .font(.system(size: 32))
                    }
                    
                    Text(title)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                // Message
                VStack(spacing: 8) {
                    Text(message)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                // Coin display
                HStack(spacing: 8) {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 20))

                    //Text("🪙")
                    Text("\(price)")
                        .font(.headline)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(10)
                
                // Divider
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 1)
                    .padding(.horizontal)
                
                // Buttons
                VStack(spacing: 12) {
                    // Buy button
                    Button(action: {
                        onBuy()
                        isPresented = false
                    }) {
                        HStack {
                            Text("🪙")
                            Text("Buy for \(price) Coins")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.orange, Color.yellow]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    
                    // Skip button
                    Button(action: {
                        onSkip()
                        isPresented = false
                    }) {
                        Text("Not Now")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 24)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                    
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.orange.opacity(0.6),
                                    Color.yellow.opacity(0.4)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                }
            )
            .shadow(color: Color.black.opacity(0.15), radius: 25, x: 0, y: 10)
            .padding(.horizontal, 40)
        }
    }
}
