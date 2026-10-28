//
//  LeadersModuleView.swift
//  nba
//
//  Today 피드 "LEAGUE LEADERS" 모듈: 카테고리 4개를 날마다 로테이션, 각 Top 3. 내 선수(★)·내 팀 강조.
//  (레거시 StatsView 대체 — statsLeaders 데이터를 기존 콘텐츠 흐름에 녹임)
//

import SwiftUI

struct LeadersModuleView: View {
    @ObservedObject private var leaders = LeadersStore.shared
    @ObservedObject private var favorites = FavoritesManager.shared

    var body: some View {
        let rotation = leaders.todayRotation(count: 4)
        if !rotation.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    SectionHeaderView(title: "LEAGUE LEADERS")
                    Spacer()
                    Text("TOP 5 · ROTATES DAILY")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.trailing, 16)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(rotation, id: \.key) { slot in
                            LeaderBoardCard(short: slot.short, board: slot.board)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

struct LeaderBoardCard: View {
    let short: String
    let board: SeasonLeaders
    @ObservedObject private var favorites = FavoritesManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 1) {
                Text(short)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text(board.category == "Season Leaders" ? board.title : "\(board.category) · \(board.title)")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.white.opacity(0.45))
                    .lineLimit(1)
            }

            VStack(spacing: 5) {
                ForEach(Array(board.items.prefix(3).enumerated()), id: \.element.id) { idx, item in
                    let tri = item.teamTriCode ?? ""
                    let teamId = tri.triCodeToTeamId
                    NavigationLink(destination: PlayerView(playerId: item.playerId ?? "", teamId: teamId)) {
                        leaderRow(item: item, rank: idx + 1, teamId: teamId)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(12)
        .frame(width: 200, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(LinearGradient(colors: [Color.white.opacity(0.08), Color.white.opacity(0.03)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.white.opacity(0.12), lineWidth: 1))
        )
    }

    @ViewBuilder
    private func leaderRow(item: SeasonLeader, rank: Int, teamId: String) -> some View {
        let pid = item.playerId ?? ""
        let tri = item.teamTriCode ?? ""
        let isMyPlayer = favorites.isFavoritePlayer(pid)
        let isMyTeam = favorites.isFavorite(tri)

        HStack(spacing: 8) {
            Text("\(rank)")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundColor(rank == 1 ? .black : .white.opacity(0.8))
                .frame(width: 18, height: 18)
                .background(Circle().fill(rank == 1 ? Color(red: 1.0, green: 0.84, blue: 0.0) : Color.white.opacity(0.1)))

            if RemoteConfigManager.shared.shouldUseOfficialTeamData, !tri.isEmpty {
                Image(tri)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
            }

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 3) {
                    Text(shortName(item.name ?? ""))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    if isMyPlayer {
                        Image(systemName: "star.fill")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0))
                    }
                }
                Text(tri)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(isMyTeam ? Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.9) : .white.opacity(0.45))
            }

            Spacer(minLength: 2)

            Text(item.points ?? "")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill((isMyPlayer || isMyTeam) ? Color(teamId.dark).opacity(0.5) : Color.clear)
        )
    }

    /// "Luka Dončić" → "L. Dončić"
    private func shortName(_ full: String) -> String {
        let parts = full.split(separator: " ")
        guard parts.count >= 2, let first = parts.first?.first else { return full }
        return "\(first). \(parts.dropFirst().joined(separator: " "))"
    }
}
