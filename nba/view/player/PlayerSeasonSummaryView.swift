//
//  PlayerSeasonSummaryView.swift
//  nba
//
//

import SwiftUI

struct PlayerSeasonSummaryView: View {
    let player: PlayerSummaryViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            SeasonStatCard(title: player.ppgTitle, value: player.ppg, color: .green)
            SeasonStatCard(title: player.rpgTitle, value: player.rpg, color: .blue)
            SeasonStatCard(title: player.apgTitle, value: player.apg, color: .orange)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
    }
}

struct SeasonStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
            
            Text(value)
                .font(.system(size: 20, weight: .heavy))
                .foregroundColor(.white)
                .shadow(color: color.opacity(0.5), radius: 5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.6)) // Darker background
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [color.opacity(0.8), color.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: color.opacity(0.2), radius: 5, x: 0, y: 2) // Subtle glow
    }
}
