//
//  TeamLeagueLeadersRow.swift
//  nba
//
//  팀 상세 "LEAGUE LEADERS" 행: 로스터 중 리그 Top 5(statsLeaders)에 든 선수·항목을 칩으로 노출
//

import SwiftUI

struct TeamLeagueLeadersRow: View {
    let roster: [PlayerModel]
    let teamId: String
    @ObservedObject private var leaders = LeadersStore.shared
    
    var body: some View {
        let entries = leaders.entries(forPlayerIds: roster.compactMap { $0.playerId })
        if !entries.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0))
                    Text("LEAGUE LEADERS")
                        .textStyle(color: .white.opacity(0.9), font: .system(size: 20), weight: .bold)
                    Spacer()
                }
                .padding(.horizontal, 15)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(entries.prefix(10)) { entry in
                            let player = roster.first { $0.playerId == entry.playerId }
                            NavigationLink(destination: PlayerView(playerId: entry.playerId, teamId: teamId)) {
                                chip(entry: entry, player: player)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 15)
                }
            }
        }
    }
    
    @ViewBuilder
    private func chip(entry: LeaderEntry, player: PlayerModel?) -> some View {
        HStack(spacing: 8) {
            if RemoteConfigManager.shared.shouldUseOfficialTeamData {
                AsyncImage(url: URL(string: entry.playerId.smallImageUrl)) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.white.opacity(0.1)
                }
                .frame(width: 34, height: 34)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(player?.lastName ?? entry.name)
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                HStack(spacing: 5) {
                    LeaderBadgeView(entry: entry, compact: true)
                    Text(entry.value)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.3))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))
        )
    }
}
