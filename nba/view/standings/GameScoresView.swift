//
//  GameScoresView.swift
//  nba
//
//  Created by Antigravity on 12/31/24.
//

import SwiftUI

struct GameScoresView: View {
    let games: [GamesModel]
    @Binding var selectedIndex: Int
    
    var body: some View {
        VStack(spacing: 16) {
            // 1. Date Selector (Modern Horizontal Strip)
            DateSelectorView(games: games, selectedIndex: $selectedIndex)
            
            // 2. Games List for Selected Date
            if games.indices.contains(selectedIndex) {
                let selectedDay = games[selectedIndex]
                
                VStack(spacing: 12) {
                    if selectedDay.items.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 28))
                                .foregroundColor(.white.opacity(0.4))
                            Text("No games scheduled on this date")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                    } else {
                        ForEach(selectedDay.items, id: \.self) { game in
                            NavigationLink(destination: GameRecapView(viewModel: HomeAwayViewModel(homeAway: game), gameRecap: games)) {
                                GameScoreRow(game: game)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

struct GameScoreRow: View {
    let game: HomeAway
    
    private var isAwayWinner: Bool {
        isWinner(team: game.away, opponent: game.home)
    }
    
    private var isHomeWinner: Bool {
        isWinner(team: game.home, opponent: game.away)
    }
    
    var body: some View {
        ZStack {
            // Card Background (Glassmorphism)
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.08), Color.white.opacity(0.03)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
            
            HStack(spacing: 0) {
                // Away Team (Left)
                teamSideView(team: game.away, isHome: false, isWinner: isAwayWinner)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Center Score & Status
                centerScoreView
                    .frame(width: 110)
                
                // Home Team (Right)
                teamSideView(team: game.home, isHome: true, isWinner: isHomeWinner)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 3)
    }
    
    // MARK: - Center Score & Status View
    private var centerScoreView: some View {
        VStack(spacing: 5) {
            // Status Badge (FINAL or Scheduled)
            if let final = game.final, !final.isEmpty {
                Text(final.uppercased())
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Capsule())
            } else {
                Text("GAME")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            // Score Display
            HStack(spacing: 6) {
                Text(game.away.score ?? "-")
                    .font(.system(size: 22, weight: isAwayWinner ? .black : .bold, design: .rounded))
                    .foregroundColor(isAwayWinner ? .white : .white.opacity(0.5))
                
                Text(":")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.3))
                
                Text(game.home.score ?? "-")
                    .font(.system(size: 22, weight: isHomeWinner ? .black : .bold, design: .rounded))
                    .foregroundColor(isHomeWinner ? .white : .white.opacity(0.5))
            }
            
            // Series / Playoff Info
            if let series = game.series, !series.isEmpty {
                Text(series)
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0))
                    .lineLimit(1)
            }
        }
    }
    
    // MARK: - Team Side View
    @ViewBuilder
    private func teamSideView(team: Game, isHome: Bool, isWinner: Bool) -> some View {
        let triCode = team.teamCode.nickNameToTriCode
        
        HStack(spacing: 10) {
            if !isHome {
                // Away: Logo First
                teamLogo(code: team.teamCode, triCode: triCode)
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(triCode.isEmpty ? team.teamCode : triCode)
                        .font(.system(size: 15, weight: isWinner ? .black : .bold, design: .rounded))
                        .foregroundColor(isWinner ? .white : .white.opacity(0.7))
                    
                    if isWinner {
                        Text("WIN")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundColor(Color(red: 0.2, green: 0.85, blue: 0.45))
                    }
                }
            } else {
                // Home: Name First
                VStack(alignment: .trailing, spacing: 1) {
                    Text(triCode.isEmpty ? team.teamCode : triCode)
                        .font(.system(size: 15, weight: isWinner ? .black : .bold, design: .rounded))
                        .foregroundColor(isWinner ? .white : .white.opacity(0.7))
                    
                    if isWinner {
                        Text("WIN")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundColor(Color(red: 0.2, green: 0.85, blue: 0.45))
                    }
                }
                
                teamLogo(code: team.teamCode, triCode: triCode)
            }
        }
    }
    
    @ViewBuilder
    private func teamLogo(code: String, triCode: String) -> some View {
        if RemoteConfigManager.shared.shouldUseOfficialTeamData {
            if !triCode.isEmpty {
                Image(triCode)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 34, height: 34)
                    .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 1)
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 34, height: 34)
            }
        } else {
            SafeModeLogoView(originalCode: code, triCode: triCode)
                .frame(width: 34, height: 34)
                .clipShape(Circle())
        }
    }
    
    private func isWinner(team: Game, opponent: Game) -> Bool {
        guard let s1 = Int(team.score ?? "0"), let s2 = Int(opponent.score ?? "0") else { return false }
        return s1 > s2
    }
}
