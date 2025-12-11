//
//  PlayerBioGridView.swift
//  nba
//
//

import SwiftUI

struct PlayerBioGridView: View {
    let player: PlayerSummaryViewModel
    
    // Grid Item Layout
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            BioItemView(title: player.heightTitle, value: player.height)
            BioItemView(title: player.weightTitle, value: player.weight)
            BioItemView(title: player.ageTitle, value: player.age)
            BioItemView(title: player.birthdateTitle, value: player.birthdate)
            BioItemView(title: player.experienceTitle, value: player.experience)
            BioItemView(title: player.draftTitle, value: player.draft)
            BioItemView(title: player.countryTitle, value: player.country)
            BioItemView(title: player.lastAttendedTitle, value: player.lastAttended)
        }
        .padding(15)
        .background(Color.white.opacity(0.03))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 15)
    }
}

struct BioItemView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.5))
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}
