//
//  BadgeCategoryView.swift
//  real calender
//
//  Created by Mac on 15/12/25.
//

import SwiftUI

// MARK: - Badge Category View
struct BadgeCategoryView: View {
    let category: BadgeCategory
    let badges: [Badge]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Category Header
            HStack {
                Image(systemName: category.icon)
                    .foregroundColor(.blue)
                    .font(.title3)
                
                Text(category.rawValue)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(badges.filter { $0.isUnlocked }.count)/\(badges.count)")
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.1))
                    )
                    .foregroundColor(.blue)
            }
            
            // Badges Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(badges) { badge in
                    BadgeCardView(badge: badge)
                }
            }
        }
        .padding(.vertical)
    }
}
