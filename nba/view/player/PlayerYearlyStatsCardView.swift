//
//  PlayerYearlyStatsCardView.swift
//  nba
//
//

import SwiftUI

struct PlayerYearlyStatsCardView<T: StatsGeneratable & Hashable>: View {
    let title: String
    let stats: [T]
    let teamId: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Title
            HStack {
                Rectangle()
                    .fill(Color(teamId.light))
                    .frame(width: 4, height: 18)
                
                Text(title.uppercased())
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.horizontal, 15)
            
            // Horizontal Scroll of Stats Cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(stats.enumerated()), id: \.element) { index, stat in
                        let items = stat.createStatsItemViewModels(teamId: teamId)
                        StatSeasonCard(items: items, teamId: teamId)
                    }
                }
                .padding(.horizontal, 15)
            }
        }
        .padding(.vertical, 10)
    }
}

struct StatSeasonCard: View {
    let items: [PlayerStatsItemViewModel]
    let teamId: String
    
    var body: some View {
        VStack(spacing: 0) {
            // Header (Year)
            if let firstItem = items.first {
                HStack {
                    Text(firstItem.value) // Year
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if firstItem.title == "TOT" {
                         Text("TOTAL")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(4)
                     }
                }
                .padding(12)
                .background(Color(teamId.dark).opacity(0.6))
            }
            
            Divider().background(Color.white.opacity(0.1))
            
            // Stats Grid
            VStack(spacing: 8) {
                ForEach(items.dropFirst(), id: \.title) { item in
                    HStack {
                        Text(item.title)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Spacer()
                        
                        Text(item.value)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
            }
            .padding(12)
        }
        .frame(width: 140)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}
