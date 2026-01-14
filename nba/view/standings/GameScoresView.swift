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
        VStack(spacing: 20) {
            
            // 1. Date Selector (Shared Component)
            DateSelectorView(games: games, selectedIndex: $selectedIndex)
            
            // 2. Games List for Selected Date
            if games.indices.contains(selectedIndex) {
                let selectedDay = games[selectedIndex]
                
                VStack(spacing: 12) {
                    if selectedDay.items.isEmpty {
                        Text("No games scheduled")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(selectedDay.items, id: \.self) { game in
                            NavigationLink(destination: GameRecapView(viewModel: HomeAwayViewModel(homeAway: game), gameRecap: games)) {
                                GameScoreRow(game: game)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    // Helper: "2023-12-30" -> "SAT"
    func getDayOfWeek(from dateString: String?) -> String {
        guard let dateString = dateString else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return "" }
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }
    
    // Helper: "2023-12-30" -> "30"
    func getDayNumber(from dateString: String?) -> String {
        guard let dateString = dateString else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return "" }
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

struct GameScoreRow: View {
    let game: HomeAway
    
    var body: some View {
        HStack {
            // Away Team
            teamInfo(team: game.away, isHome: false)
            
            Spacer()
            
            // Score / Status
            VStack(spacing: 4) {
                if let final = game.final, !final.isEmpty {
                    Text("FINAL")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                } else if let time = game.home.score { // If score exists but not final? or time
                     // Logic depends on data, usually 'final' field indicates status
                     // If no final, maybe upcoming?
                     // For now assume completed or live
                }
                
                HStack(spacing: 8) {
                    Text(game.away.score ?? "-")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(isWinner(team: game.away, opponent: game.home) ? .white : .gray)
                        .fixedSize() // Prevent wrapping
                    
                    Text("-")
                        .foregroundColor(.gray)
                    
                    Text(game.home.score ?? "-")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(isWinner(team: game.home, opponent: game.away) ? .white : .gray)
                        .fixedSize() // Prevent wrapping
                }
            }
            .frame(width: 100) // Increased width to prevent wrapping
            
            Spacer()
            
            // Home Team
            teamInfo(team: game.home, isHome: true)
        }
        .padding(16)
        .background(Color(white: 0.1))
        .cornerRadius(16)
    }
    
    func isWinner(team: Game, opponent: Game) -> Bool {
        guard let s1 = Int(team.score ?? "0"), let s2 = Int(opponent.score ?? "0") else { return false }
        return s1 > s2
    }
    
    @ViewBuilder
    func teamInfo(team: Game, isHome: Bool) -> some View {
        HStack {
            if !isHome {
                // Logo First
                logo(code: team.teamCode)
                Text(team.teamCode.nickNameToTriCode)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            } else {
                // Name First
                Text(team.teamCode.nickNameToTriCode)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                logo(code: team.teamCode)
            }
        }
        .frame(width: 80, alignment: isHome ? .trailing : .leading)
    }
    
    @ViewBuilder
    func logo(code: String) -> some View {
        if RemoteConfigManager.shared.shouldUseOfficialTeamData {
            let triCode = code.nickNameToTriCode
            if !triCode.isEmpty {
                Image(triCode)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            } else {
                Circle().fill(Color.gray).frame(width: 30, height: 30)
            }
        } else {
            // Safe Mode: Edgy Watermark
            let triCode = code.nickNameToTriCode
            SafeModeLogoView(originalCode: code, triCode: triCode)
                .frame(width: 30, height: 30)
                .clipShape(Circle())
        }
    }
}
