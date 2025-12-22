//
//  CommitmentPopupView.swift
//  real calender
//
//  Created by Mac on 19/12/25.
//

import SwiftUI


struct CommitmentPopupView: View {
    @Binding var isPresented: Bool
    let onCommit: () -> Void
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            // Popup card with border
            VStack(spacing: 20) {
                // Header with icon
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 60, height: 60)
                        
                        Text("📅")
                            .font(.system(size: 32))
                    }
                    
                    Text("66-Day Commitment")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                // Message
                VStack(spacing: 8) {
                    Text("This calendar works only if you commit yourself for the next 66 days.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    Text("Real progress comes from showing up every day.")
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
                
                // Buttons
                Button(action: {
                    onCommit()
                    isPresented = false
                }) {
                    Text("I'm Committed")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
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
                                    Color.blue.opacity(0.3),
                                    Color.purple.opacity(0.2),
                                    Color.blue.opacity(0.3)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
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
