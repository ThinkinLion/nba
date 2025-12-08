//
//  WeeklyHighlightsView.swift
//  nba
//
//  Created by Antigravity on 12/08/24.
//

import SwiftUI

struct WeeklyHighlightsView: View {
    let highlights: PowerRankingViewModel.WeeklyHighlights
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("WEEKLY HIGHLIGHTS")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white.opacity(0.5))
                .padding(.horizontal, 15)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    if let biggestMover = highlights.biggestMover {
                        highlightCard(
                            icon: "🔥",
                            title: "BIGGEST MOVER",
                            team: biggestMover,
                            gradientColors: [Color(red: 1.0, green: 0.3, blue: 0.0), Color(red: 1.0, green: 0.6, blue: 0.0)]
                        )
                    }
                    
                    if let biggestFaller = highlights.biggestFaller {
                        highlightCard(
                            icon: "📉",
                            title: "BIGGEST FALLER",
                            team: biggestFaller,
                            gradientColors: [Color(red: 0.2, green: 0.4, blue: 0.8), Color(red: 0.4, green: 0.6, blue: 1.0)]
                        )
                    }
                    
                    if let newNumberOne = highlights.newNumberOne {
                        highlightCard(
                            icon: "👑",
                            title: "NEW #1",
                            team: newNumberOne,
                            gradientColors: [Color(red: 1.0, green: 0.84, blue: 0.0), Color(red: 1.0, green: 0.6, blue: 0.0)]
                        )
                    }
                }
                .padding(.horizontal, 15)
            }
        }
    }
    
    @ViewBuilder
    private func highlightCard(
        icon: String,
        title: String,
        team: PowerRankingViewModel.TeamHighlight,
        gradientColors: [Color]
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack(spacing: 4) {
                Text(icon)
                    .font(.system(size: 16))
                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            // Team Logo
            if !team.teamCode.isEmpty {
                Image(team.teamCode)
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .foregroundColor(.white.opacity(0.15))
                    .offset(x: 40, y: 10)
            }
            
            // Team Name
            Text(team.teamName.uppercased())
                .font(.system(size: 14, weight: .heavy))
                .foregroundColor(.white)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            // Rank Change
            HStack(spacing: 4) {
                Text("#\(team.previousRank)")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(.white.opacity(0.5))
                
                Image(systemName: team.rankChange > 0 ? "arrow.right" : "arrow.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("#\(team.currentRank)")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(.white)
            }
            
            // Rank Change Badge
            Text(team.rankChangeText)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                )
        }
        .frame(width: 160, height: 180)
        .padding(16)
        .background(
            ZStack {
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Subtle pattern overlay
                Color.black.opacity(0.1)
            }
        )
        .cornerRadius(16)
        .shadow(color: gradientColors[0].opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Preview
#Preview {
    let sampleHighlight = PowerRankingViewModel.TeamHighlight(
        id: "OKC",
        teamCode: "OKC",
        teamName: "Oklahoma City Thunder",
        currentRank: 3,
        previousRank: 8,
        rankChange: 5,
        record: "15-5"
    )
    
    let highlights = PowerRankingViewModel.WeeklyHighlights(
        biggestMover: sampleHighlight,
        biggestFaller: nil,
        newNumberOne: nil
    )
    
    return WeeklyHighlightsView(highlights: highlights)
        .background(Color.black)
}
