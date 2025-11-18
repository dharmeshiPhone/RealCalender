//
//  UnlockPetAnimationView.swift
//  real calender
//
//  Created by Mac on 09/10/25.
//

import SwiftUI

struct UnlockPetAnimationView: View {
    let pet: Pet
    @Binding var isShowing: Bool
    @State private var animationPhase = 0
    @State private var glowOpacity = 0.0
    @State private var particleScale = 0.0
    @State private var confettiPosition = CGSize.zero
    @State private var rotationAngle = 0.0
    
    var body: some View {
        ZStack {
            backgroundView
            mainContent
        }
        .onAppear {
            startAnimationSequence()
        }
    }
    
    // MARK: - Subviews
    private var backgroundView: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, pet.swiftUIColor.opacity(0.2), Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            Circle()
                .fill(pet.swiftUIColor)
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .opacity(glowOpacity)
                .scaleEffect(animationPhase >= 2 ? 1.5 : 0.1)
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 40) {
            orbitalParticles
            petRevealView
            textRevealView
            continueButton
        }
    }
    
    private var orbitalParticles: some View {
        ZStack {
            ForEach(0..<24) { i in
                Circle()
                    .fill(particleGradient)
                    .frame(width: 12, height: 12)
                    .offset(particleOffset(for: i))
                    .scaleEffect(particleScale)
                    .opacity(animationPhase >= 1 ? 0 : 1)
            }
        }
        .rotationEffect(.degrees(rotationAngle))
        .animation(.easeOut(duration: 1.2).delay(0.3), value: animationPhase)
    }
    
    private var particleGradient: RadialGradient {
        RadialGradient(
            colors: [.white, pet.swiftUIColor, .clear],
            center: .center,
            startRadius: 0,
            endRadius: 6
        )
    }
    
    private func particleOffset(for index: Int) -> CGSize {
        let angle = Double(index) * .pi / 12
        let x = cos(angle) * (120 + confettiPosition.width * 20)
        let y = sin(angle) * (120 + confettiPosition.height * 20)
        return CGSize(width: x, height: y)
    }
    
    private var petRevealView: some View {
        ZStack {
            outerGlowRing
            innerGlow
            mainCircle
            petIcon
        }
        .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.8), value: animationPhase)
    }
    
    private var outerGlowRing: some View {
        Circle()
            .stroke(glowGradient, lineWidth: 4)
            .frame(width: 180, height: 180)
            .blur(radius: 8)
            .opacity(glowOpacity)
            .scaleEffect(animationPhase >= 2 ? 1.1 : 0.0)
    }
    
    private var glowGradient: LinearGradient {
        LinearGradient(
            colors: [pet.swiftUIColor, .white, pet.swiftUIColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var innerGlow: some View {
        Circle()
            .fill(pet.swiftUIColor.opacity(0.4))
            .frame(width: 160, height: 160)
            .blur(radius: 20)
            .scaleEffect(animationPhase >= 2 ? 1.0 : 0.0)
    }
    
    private var mainCircle: some View {
        Circle()
            .fill(Color.black.opacity(0.8))
            .frame(width: 150, height: 150)
            .overlay(circleBorder)
            .scaleEffect(animationPhase >= 2 ? 1.0 : 0.0)
    }
    
    private var circleBorder: some View {
        Circle()
            .stroke(borderGradient, lineWidth: 3)
    }
    
    private var borderGradient: LinearGradient {
        LinearGradient(
            colors: [.white, pet.swiftUIColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var petIcon: some View {
        Image(systemName: pet.icon)
            .font(.system(size: 70, weight: .bold))
            .foregroundColor(.white)
            .shadow(color: pet.swiftUIColor, radius: 10, x: 0, y: 0)
            .scaleEffect(animationPhase >= 2 ? 1.0 : 0.0)
            .rotationEffect(.degrees(animationPhase >= 2 ? 360 : 0))
    }
    
    private var textRevealView: some View {
        VStack(spacing: 15) {
            Text("EPIC UNLOCK!")
                .font(.title2)
                .fontWeight(.black)
                .foregroundColor(.white)
                .shadow(color: pet.swiftUIColor, radius: 10, x: 0, y: 0)
                .opacity(animationPhase >= 3 ? 1 : 0)
                .scaleEffect(animationPhase >= 3 ? 1.0 : 0.5)
            
            Text(pet.name.uppercased())
                .font(.system(size: 42, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: pet.swiftUIColor, radius: 15, x: 0, y: 0)
                .overlay(gradientOverlay)
                .opacity(animationPhase >= 3 ? 1 : 0)
                .scaleEffect(animationPhase >= 3 ? 1.0 : 0.5)
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(1.5), value: animationPhase)
    }
    
    private var gradientOverlay: some View {
        LinearGradient(
            colors: [.white, pet.swiftUIColor, .white],
            startPoint: .leading,
            endPoint: .trailing
        )
        .mask(
            Text(pet.name.uppercased())
                .font(.system(size: 42, weight: .black, design: .rounded))
        )
    }
    
    @ViewBuilder
    private var continueButton: some View {
        if animationPhase >= 3 {
            Button(action: dismissAnimation) {
                HStack {
                    Text("CONTINUE")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
                .background(buttonGradient)
                .cornerRadius(30)
                .shadow(color: pet.swiftUIColor, radius: 10, x: 0, y: 0)
                .overlay(buttonBorder)
            }
            .transition(buttonTransition)
        }
    }
    
    private var buttonGradient: LinearGradient {
        LinearGradient(
            colors: [pet.swiftUIColor, pet.swiftUIColor.opacity(0.8)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var buttonBorder: some View {
        RoundedRectangle(cornerRadius: 30)
            .stroke(Color.white.opacity(0.3), lineWidth: 2)
    }
    
    private var buttonTransition: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.5).combined(with: .opacity),
            removal: .scale(scale: 1.5).combined(with: .opacity)
        )
    }
    
    // MARK: - Actions
    
    private func dismissAnimation() {
        withAnimation(.easeOut(duration: 0.3)) {
            isShowing = false
        }
    }
    
    private func startAnimationSequence() {
        withAnimation(.easeOut(duration: 0.5)) {
            animationPhase = 1
            particleScale = 1.5
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                animationPhase = 2
            }
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                glowOpacity = 0.6
            }
            withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animationPhase = 3
            }
        }
        
        withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
            confettiPosition = CGSize(width: 0.5, height: 0.5)
        }
    }
}


