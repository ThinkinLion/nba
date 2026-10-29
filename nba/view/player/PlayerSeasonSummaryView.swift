//
//  PlayerSeasonSummaryView.swift
//  nba
//
//  Created by ThinkinLion on 2026/10/27.
//

import SwiftUI

struct PlayerSeasonSummaryView: View {
    let player: PlayerSummaryViewModel
    @ObservedObject private var leaders = LeadersStore.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header Label: Clean English Only
            HStack {
                Text("\(SeasonProvider.shared.seasonDisplayString()) SEASON")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundColor(.white.opacity(0.65))
                    .tracking(0.8)
                
                if player.isRookie {
                    Text("ROOKIE")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(.black)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(Color(red: 1.0, green: 0.84, blue: 0.0))
                        .clipShape(Capsule())
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            
            // Stat Cards Grid (PPG, RPG, APG, PIE)
            HStack(spacing: 8) {
                SeasonStatCard(title: player.ppgTitle, value: player.ppg, color: .green)
                SeasonStatCard(title: player.rpgTitle, value: player.rpg, color: .blue)
                SeasonStatCard(title: player.apgTitle, value: player.apg, color: .orange)
                if !player.pie.isEmpty && player.pie != "-" {
                    SeasonStatCard(title: player.pieTitle, value: player.pie, color: .purple)
                }
            }
            .padding(.horizontal, 16)
            
            // 리그 Top 5 배지 (statsLeaders 역인덱스) — 해당 항목이 있을 때만
            let entries = leaders.entries(for: player.playerId)
            if !entries.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(entries.prefix(8)) { entry in
                        LeaderBadgeView(entry: entry)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
            }
        }
    }
}

struct SeasonStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    private var isDash: Bool {
        value == "-" || value.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 3) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
            
            Text(value)
                .font(.system(size: isDash ? 18 : 20, weight: .heavy, design: .rounded))
                .foregroundColor(isDash ? .white.opacity(0.4) : .white)
                .shadow(color: isDash ? Color.clear : color.opacity(0.4), radius: 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.45))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [color.opacity(0.6), color.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: color.opacity(0.12), radius: 4, x: 0, y: 2)
    }
}
