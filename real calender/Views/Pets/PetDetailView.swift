//
//  PetDetailView.swift
//  real calender
//
//  Created by Mac on 08/10/25.
//

import SwiftUI

// MARK: - Pet Detail View

struct PetDetailView: View {
    var pet: Pet
    @Environment(\.presentationMode) var presentationMode
    @State private var happiness: Double = 25 // Example happiness value
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.green.opacity(0.6)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .medium))
                                Text("Back")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Text(pet.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        HStack(spacing: 6) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.yellow)
                            
                            Text("\(pet.cost)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Pet Image Section
                    VStack {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.2),
                                            Color.white.opacity(0.05)
                                        ]),
                                        center: .center,
                                        startRadius: 20,
                                        endRadius: 100
                                    )
                                )
                                .frame(width: 200, height: 200)
                            
                            Image(systemName: pet.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        }
                        
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Pet Details")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                Text(pet.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                // Edit pet action
                            }) {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.blue)
                                    .background(Color.white)
                                    .clipShape(Circle())
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Happiness")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("\(Int(happiness))%")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(happinessColor)
                            }
                            
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.black.opacity(0.3))
                                    .frame(height: 12)
                                    .cornerRadius(6)
                                
                                Rectangle()
                                    .fill(happinessGradient)
                                    .frame(width: max(0, CGFloat(happiness) / 100 * (geometry.size.width - 40)), height: 12)
                                    .cornerRadius(6)
                                    .shadow(color: happinessColor.opacity(0.3), radius: 2, x: 0, y: 1)
                            }
                            
                            Text("Increase happiness through quests and activities")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        // Level and Evolve Section for future purpose
//                        VStack(alignment: .leading, spacing: 12) {
//                            HStack {
//                                VStack(alignment: .leading, spacing: 4) {
//                                    Text("Level")
//                                        .font(.headline)
//                                        .foregroundColor(.white)
//                                    
//                                    Text("\(2)/10")
//                                        .font(.system(size: 14, weight: .medium))
//                                        .foregroundColor(.gray)
//                                }
//                                
//                                Spacer()
//                                
//                                Button(action: {
//                                    // Evolve action
//                                }) {
//                                    HStack(spacing: 6) {
//                                        Image(systemName: "sparkles")
//                                            .font(.system(size: 14))
//                                        
//                                        Text("Evolve")
//                                            .font(.system(size: 16, weight: .semibold))
//                                    }
//                                    .foregroundColor(.white)
//                                    .padding(.horizontal, 16)
//                                    .padding(.vertical, 10)
//                                    .background(
//                                        LinearGradient(
//                                            gradient: Gradient(colors: [Color.purple, Color.blue]),
//                                            startPoint: .leading,
//                                            endPoint: .trailing
//                                        )
//                                    )
//                                    .cornerRadius(20)
//                                    .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 2)
//                                }
////                                .disabled(pet.level < 10)
////                                .opacity(pet.level >= 10 ? 1.0 : 0.6)
//                            }
//                            
//                            // Level Progress
//                            HStack {
//                                ForEach(1...10, id: \.self) { level in
//                                    Rectangle()
//                                        .fill(Color.gray.opacity(0.3))
//                                        //.fill(level <= pet.level ? Color.blue : Color.gray.opacity(0.3))
//                                        .frame(height: 4)
//                                        .cornerRadius(2)
//                                }
//                            }
//                        }
                    }
                    .padding(20)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.8),
                                Color.black.opacity(0.9)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: -5)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private var happinessColor: Color {
        switch happiness {
        case 0..<30:
            return .red
        case 30..<70:
            return .yellow
        default:
            return .green
        }
    }
    
    private var happinessGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [happinessColor.opacity(0.8), happinessColor]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
