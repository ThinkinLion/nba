//
//  PlayoffPictureView.swift
//  nba
//
//  Created by Antigravity on 12/30/24.
//

import SwiftUI

struct PlayoffPictureView: View {
    let eastTeams: [StandingsTeam]
    let westTeams: [StandingsTeam]
    @Binding var selectedConference: StandingsView.Conference
    
    // Derived properties based on selected conference
    var currentTeams: [StandingsTeam] {
        return selectedConference == .east ? eastTeams : westTeams
    }
    
    // Matchups (1 vs 8, 2 vs 7, 3 vs 6, 4 vs 5)
    var matchups: [(highSeed: StandingsTeam?, lowSeed: StandingsTeam?)] {
        // Sort by rank just in case, though usually pre-sorted
        let sorted = currentTeams.sorted {
            (Int($0.confRank) ?? 99) < (Int($1.confRank) ?? 99)
        }
        
        // Ensure we have at least 8 teams to show a full bracket, otherwise show what we have
        // But typically we show top 8.
        
        func team(at rank: Int) -> StandingsTeam? {
            return sorted.first { (Int($0.confRank) ?? 99) == rank }
        }
        
        return [
            (team(at: 1), team(at: 8)),
            (team(at: 2), team(at: 7)),
            (team(at: 3), team(at: 6)),
            (team(at: 4), team(at: 5))
        ]
    }
    
    // Play-in specifically (7 vs 8, 9 vs 10)
    var playInMatchups: [(highSeed: StandingsTeam?, lowSeed: StandingsTeam?)] {
        let sorted = currentTeams.sorted {
            (Int($0.confRank) ?? 99) < (Int($1.confRank) ?? 99)
        }
        
        func team(at rank: Int) -> StandingsTeam? {
            return sorted.first { (Int($0.confRank) ?? 99) == rank }
        }
        
        return [
            (team(at: 7), team(at: 8)),
            (team(at: 9), team(at: 10))
        ]
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // Section Title
                VStack(spacing: 8) {
                    Text("IF THE PLAYOFFS STARTED TODAY")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                    
                    Text(selectedConference == .east ? "EASTERN CONFERENCE" : "WESTERN CONFERENCE")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundColor(selectedConference.color)
                }
                
                // 1. Play-in Tournament Section
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("PLAY-IN TOURNAMENT")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        if playInMatchups.count >= 2 {
                            PlayoffMatchupRow(
                                highSeed: playInMatchups[0].highSeed,
                                lowSeed: playInMatchups[0].lowSeed,
                                title: "7 vs 8 (Winner gets #7)"
                            )
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            PlayoffMatchupRow(
                                highSeed: playInMatchups[1].highSeed,
                                lowSeed: playInMatchups[1].lowSeed,
                                title: "9 vs 10 (Winner plays Loser of 7/8)"
                            )
                        } else {
                            Text("Not enough data")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    .background(Color(white: 0.1))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                
                // 2. Playoff Bracket (Projected Top 6 + Play-in Winners)
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                        Text("PROJECTED FIRST ROUND")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        ForEach(0..<matchups.count, id: \.self) { index in
                            let pair = matchups[index]
                            PlayoffMatchupRow(
                                highSeed: pair.highSeed,
                                lowSeed: pair.lowSeed,
                                title: nil // Standard 1v8 etc implied by order, or can add
                            )
                            
                            if index < matchups.count - 1 {
                                Divider().background(Color.white.opacity(0.1))
                            }
                        }
                    }
                    .background(Color(white: 0.1))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                
                // Legend / disclaimer
                Text("*Rankings based on current Winning Percentage")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 40)
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

// Subview for a single matchup row
struct PlayoffMatchupRow: View {
    let highSeed: StandingsTeam?
    let lowSeed: StandingsTeam?
    let title: String?
    
    var body: some View {
        VStack(spacing: 12) {
            if let title = title {
                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            HStack(spacing: 0) {
                // High Seed (Left)
                teamView(team: highSeed, alignment: .leading)
                
                // VS
                Text("VS")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(.white.opacity(0.3))
                    .frame(width: 40)
                
                // Low Seed (Right)
                teamView(team: lowSeed, alignment: .trailing)
            }
        }
        .padding(16)
    }
    
    @ViewBuilder
    func teamView(team: StandingsTeam?, alignment: Alignment) -> some View {
        if let team = team {
            HStack {
                if alignment == .leading {
                    rankView(rank: team.confRank)
                    logoView(team: team)
                    nameView(name: team.teamName)
                    Spacer()
                } else {
                    Spacer()
                    nameView(name: team.teamName)
                    logoView(team: team)
                    rankView(rank: team.confRank)
                }
            }
            .frame(maxWidth: .infinity)
        } else {
            // Placeholder
            Text("TBD")
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    func rankView(rank: String) -> some View {
        Text(rank)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.gray)
            .frame(width: 20, alignment: .center)
            .padding(4)
            .background(Color.white.opacity(0.1))
            .cornerRadius(4)
    }
    
    @ViewBuilder
    func logoView(team: StandingsTeam) -> some View {
        let triCode = team.teamCode.nickNameToTriCode
        if !triCode.isEmpty {
            Image(triCode)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
        } else {
            Circle()
                .fill(Color.gray)
                .frame(width: 32, height: 32)
        }
    }
    
    @ViewBuilder
    func nameView(name: String) -> some View {
        Text(name)
            .font(.system(size: 15, weight: .heavy, design: .rounded))
            .foregroundColor(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }
}
