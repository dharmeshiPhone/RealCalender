//
//  LevelUpCelebrationView.swift
//  real calender
//
//  Created by Mac on 07/10/25.
//

import SwiftUI

struct LevelUpCelebrationView: View {
    @Binding var isShowing: Bool
    let achievementLevel: Int
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var glowScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 1.0
    @State private var confettiScale: CGFloat = 0.8
    @State private var textOpacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
                .opacity(opacity)
            
            VStack(spacing: 20) {
                Text("🎉")
                    .font(.system(size: 80))
                    .scaleEffect(confettiScale)
                
                VStack(spacing: 8) {
                    Text("LEVEL UP!")
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundColor(.yellow)
                        .shadow(color: .yellow.opacity(0.8), radius: 10)
                        .scaleEffect(scale)
                        .opacity(textOpacity)
                    
                    Text("You've reached level \(achievementLevel)!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(textOpacity)
                }
                
                Button("Continue Your Journey") {
                    dismissAnimation()
                }
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.yellow, .orange]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: .yellow.opacity(0.6), radius: 10)
                .padding(.horizontal, 32)
                .opacity(textOpacity)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            if isShowing {
                startAnimation()
            }
        }
        .onChange(of: isShowing) { oldValue, newValue in
            if newValue {
                startAnimation()
            } else {
                resetAnimation()
            }
        }
    }
    
    private func startAnimation() {
        scale = 0.5
        opacity = 0
        glowScale = 1.0
        glowOpacity = 1.0
        confettiScale = 0.8
        textOpacity = 0
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            opacity = 1
            scale = 1.1
        }
        
        withAnimation(.easeInOut(duration: 0.4).delay(0.2)) {
            textOpacity = 1
        }
        
        withAnimation(.interpolatingSpring(stiffness: 100, damping: 8).delay(0.1)) {
            confettiScale = 1.2
        }
        
        withAnimation(.interpolatingSpring(stiffness: 100, damping: 8).delay(0.3)) {
            confettiScale = 1.0
        }
        
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            glowScale = 1.3
            glowOpacity = 0.7
        }
    }
    
    private func dismissAnimation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            scale = 0.8
            opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isShowing = false
        }
    }
    
    private func resetAnimation() {
        scale = 0.5
        opacity = 0
        glowScale = 1.0
        glowOpacity = 1.0
        confettiScale = 0.8
        textOpacity = 0
    }
}
