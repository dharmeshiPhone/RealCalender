//
//  BadgeUnlockAnimation.swift
//  real calender
//
//  Created by Mac on 15/12/25.
//

import SwiftUI

struct BadgeUnlockAnimation: View {
    let badge: Badge
    @Binding var isShowing: Bool
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Background Blur
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isShowing = false
                    }
                }
            
            // Celebration Effect
            ForEach(0..<30) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: badge.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 10, height: 10)
                    .offset(
                        x: animate ? cos(Double(index) * .pi / 15) * 200 : 0,
                        y: animate ? sin(Double(index) * .pi / 15) * 200 : 0
                    )
                    .opacity(animate ? 0 : 1)
            }
            
            // Badge Card
            VStack(spacing: 20) {
                // Animated Badge
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: badge.gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(animate ? 1 : 0.5)
                        .blur(radius: animate ? 0 : 20)
                    
                    Image(systemName: badge.iconName)
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .yellow],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(animate ? 1 : 0.3)
                }
                
                VStack(spacing: 8) {
                    Text("Badge Unlocked!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(badge.title)
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundStyle(
                            LinearGradient(
                                colors: badge.gradientColors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text(badge.description)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                    
                    if let reward = badge.reward {
                        Text("Reward: \(reward)")
                            .font(.headline)
                            .foregroundColor(.yellow)
                            .padding(.top, 8)
                    }
                }
                
                Button("Awesome!") {
                    withAnimation {
                        isShowing = false
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color.blue)
                )
                .padding(.top, 20)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(
                        LinearGradient(
                            colors: [Color(.systemGray6), Color(.systemBackground)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .padding(40)
            .scaleEffect(animate ? 1 : 0.8)
            .opacity(animate ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animate = true
            }
        }
    }
}
