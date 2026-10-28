//
//  PerformanceOfTheNightModuleView.swift
//  nba
//
//  Today 피드 "PERFORMANCE OF THE NIGHT" 모듈 (기존 GamesView 의 히어로 카드 + Honorable Mentions 이전)
//  + 개인화 맥락: 내 선수(★) 강조, 리그 Top 5 배지
//

import SwiftUI

struct PerformanceOfTheNightModuleView: View {
    let performer: DailyPerformer
    let candidates: [DailyPerformer]
    @ObservedObject private var favorites = FavoritesManager.shared
    @ObservedObject private var leaders = LeadersStore.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeaderView(title: "PERFORMANCE OF THE NIGHT")
                .padding(.horizontal, 16)

            NavigationLink(destination: PlayerView(playerId: performer.player.playerId ?? "", teamId: performer.teamId)) {
                heroCard(performer: performer)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 16)

            if !candidates.isEmpty {
                honorableMentions(candidates: candidates)
            }
        }
    }

    // MARK: - Context chips (★ MY PLAYER / TOP 5 PPG · #3)

    @ViewBuilder
    private func contextChips(playerId: String?) -> some View {
        let pid = playerId ?? ""
        let isMine = favorites.isFavoritePlayer(pid)
        let headline = leaders.headline(for: pid)
        if isMine || headline != nil {
            HStack(spacing: 6) {
                if isMine {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill").font(.system(size: 8, weight: .bold))
                        Text("MY PLAYER").font(.system(size: 9, weight: .heavy, design: .rounded))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color(red: 1.0, green: 0.84, blue: 0.0))
                    .clipShape(Capsule())
                }
                if let h = headline {
                    LeaderBadgeView(entry: h, compact: true)
                }
            }
        }
    }

    // MARK: - Hero Card

    @ViewBuilder
    private func heroCard(performer: DailyPerformer) -> some View {
        let teamCode = performer.teamCode
        let triCode = teamCode.nickNameToTriCode

        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(teamCode.lowercased() + ".dark").opacity(0.85), Color.black.opacity(0.92)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(LinearGradient(colors: [Color.white.opacity(0.25), Color.white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.4), radius: 8, x: 0, y: 4)

            // 선수 이미지 (우측, 얼굴 영역은 텍스트와 겹치지 않음)
            if let playerId = performer.player.playerId {
                HStack {
                    Spacer()
                    AsyncImage(url: URL(string: playerId.imageUrl)) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fit)
                        } else {
                            Color.clear
                        }
                    }
                    .frame(height: 165)
                    .offset(x: 5, y: 0)
                    .mask(LinearGradient(colors: [.white, .white.opacity(0.9), .clear], startPoint: .trailing, endPoint: .leading))
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    if !triCode.isEmpty {
                        Image(triCode)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22)
                    }
                    Text(triCode)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                    Text("vs \(performer.opponentTriCode)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.65))
                    Text(performer.gameResultText)
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.85, blue: 0.45))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Capsule())
                }

                contextChips(playerId: performer.player.playerId)

                Spacer()

                VStack(alignment: .leading, spacing: 0) {
                    Text(performer.player.firstName ?? "")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white.opacity(0.75))
                    Text(performer.player.lastName ?? "")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }

                HStack(spacing: 6) {
                    statPill(title: "PTS", value: performer.player.pts ?? "0")
                    statPill(title: "REB", value: performer.player.reb ?? "0")
                    statPill(title: "AST", value: performer.player.ast ?? "0")
                    if let stl = performer.player.stl, stl != "0" { statPill(title: "STL", value: stl) }
                    if let blk = performer.player.blk, blk != "0" { statPill(title: "BLK", value: blk) }
                }
                .padding(.top, 2)
            }
            .padding(14)
            .padding(.trailing, 120)
        }
        .frame(height: 165)
    }

    @ViewBuilder
    private func statPill(title: String, value: String) -> some View {
        HStack(spacing: 3) {
            Text(title)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
            Text(value)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color.black.opacity(0.45))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 0.8))
    }

    // MARK: - Honorable Mentions

    @ViewBuilder
    private func honorableMentions(candidates: [DailyPerformer]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.yellow)
                Text("HONORABLE MENTIONS")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .tracking(0.6)
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(candidates) { candidate in
                        NavigationLink(destination: PlayerView(playerId: candidate.player.playerId ?? "", teamId: candidate.teamId)) {
                            candidateMiniCard(performer: candidate)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            }
        }
    }

    @ViewBuilder
    private func candidateMiniCard(performer: DailyPerformer) -> some View {
        let teamCode = performer.teamCode
        let triCode = teamCode.nickNameToTriCode
        let isMine = favorites.isFavoritePlayer(performer.player.playerId ?? "")

        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(LinearGradient(colors: [Color(teamCode.lowercased() + ".dark").opacity(0.9), Color.black.opacity(0.92)], startPoint: .top, endPoint: .bottom))

            if let playerId = performer.player.playerId {
                VStack(spacing: 0) {
                    AsyncImage(url: URL(string: playerId.imageUrl)) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fit)
                        } else {
                            Color.clear
                        }
                    }
                    .frame(height: 112)
                    .offset(y: 4)
                    Spacer(minLength: 0)
                }
            }

            VStack {
                HStack {
                    Text(triCode)
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                    if isMine {
                        Image(systemName: "star.fill")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0))
                    }
                    Spacer()
                    Text(performer.isWin ? "W" : "L")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(performer.isWin ? Color(red: 0.2, green: 0.8, blue: 0.4) : Color.red.opacity(0.85))
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 10)
                .padding(.top, 8)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(performer.player.lastName?.uppercased() ?? "")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Text("\(performer.player.pts ?? "0") PTS")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                    if let reb = performer.player.reb, reb != "0" {
                        Text("· \(reb)R").font(.system(size: 10, weight: .bold)).foregroundColor(.white.opacity(0.65))
                    }
                    if let ast = performer.player.ast, ast != "0" {
                        Text("· \(ast)A").font(.system(size: 10, weight: .bold)).foregroundColor(.white.opacity(0.65))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                Rectangle()
                    .fill(Color.black.opacity(0.88))
                    .overlay(Rectangle().fill(Color.white.opacity(0.08)).frame(height: 0.5), alignment: .top)
            )
        }
        .frame(width: 130, height: 165)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(
                    isMine
                    ? LinearGradient(colors: [Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.8), Color.white.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    : LinearGradient(colors: [Color.white.opacity(0.25), Color.white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 3)
    }
}

/// 리그 Top 5 배지 ("TOP 5 PPG · #3"). 선수 상세·팀 상세·Today 에서 공용
struct LeaderBadgeView: View {
    let entry: LeaderEntry
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "crown.fill")
                .font(.system(size: compact ? 8 : 9, weight: .bold))
            Text(compact ? "\(entry.badgeLabel) #\(entry.rank)" : "TOP 5 \(entry.badgeLabel) · #\(entry.rank)")
                .font(.system(size: compact ? 9 : 10, weight: .heavy, design: .rounded))
                .lineLimit(1)
        }
        .foregroundColor(entry.rank == 1 ? .black : .white)
        .padding(.horizontal, compact ? 7 : 8)
        .padding(.vertical, compact ? 3 : 4)
        .background(
            Capsule().fill(
                entry.rank == 1
                ? LinearGradient(colors: [Color(red: 1.0, green: 0.84, blue: 0.0), Color(red: 1.0, green: 0.65, blue: 0.1)], startPoint: .leading, endPoint: .trailing)
                : LinearGradient(colors: [Color.purple.opacity(0.75), Color.blue.opacity(0.6)], startPoint: .leading, endPoint: .trailing)
            )
        )
        .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: 0.8))
    }
}
