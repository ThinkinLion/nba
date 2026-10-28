//
//  PicksModuleView.swift
//  nba
//
//  Today 피드 "TONIGHT · YOUR PICKS" 모듈: 예정 경기의 승자를 고르고, 전적·연승·어제 채점 결과를 보여줌.
//  참여 장치이지만 글쓰기·서버 쓰기가 없어 모더레이션 부담이 없음.
//

import SwiftUI
import FirebaseAnalytics

struct PicksModuleView: View {
    let schedule: [GamesModel]          // 최신순 (오늘, 내일)
    @ObservedObject private var picks = PicksManager.shared
    @ObservedObject private var favorites = FavoritesManager.shared
    @State private var expanded = false

    private let collapsedCount = 5

    /// 오늘(LA) 경기가 있으면 오늘, 없으면 다음 날
    private var slate: GamesModel? {
        let today = StandingsViewModel.laToday()
        let ascending = schedule.sorted { ($0.date ?? "") < ($1.date ?? "") }
        return ascending.first { ($0.date ?? "") >= today && !$0.items.isEmpty }
    }

    var body: some View {
        if let slate {
            let isToday = slate.date == StandingsViewModel.laToday()
            let games = orderedGames(slate.items)
            let visible = expanded ? games : Array(games.prefix(collapsedCount))

            VStack(alignment: .leading, spacing: 12) {
                // 헤더: 타이틀 + 전적 칩
                HStack(alignment: .center) {
                    SectionHeaderView(title: isToday ? "TONIGHT · YOUR PICKS" : "TOMORROW · YOUR PICKS")
                    Spacer()
                    recordChip
                        .padding(.trailing, 16)
                }

                // 어제 채점 결과
                if let s = picks.lastGradedSummary, s.total > 0 {
                    gradedBanner(s)
                        .padding(.horizontal, 16)
                }

                // 진행 상황
                let pickedCount = games.filter { picks.pickedTeamId(for: $0) != nil }.count
                HStack(spacing: 6) {
                    Text(pickedCount == 0 ? "Tap a team to call the winner" : "\(pickedCount) of \(games.count) picked")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                    if let date = slate.date {
                        Text(date)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.35))
                    }
                }
                .padding(.horizontal, 16)

                VStack(spacing: 10) {
                    ForEach(visible, id: \.self) { game in
                        PickGameRow(game: game, picked: picks.pickedTeamId(for: game)) { teamId in
                            picks.pick(for: game, teamId: teamId)
                            Analytics.logEvent("pick_made", parameters: ["game_id": game.gameId ?? "", "team": teamId.teamIdToTriCode])
                        }
                    }

                    if games.count > collapsedCount {
                        Button(action: { withAnimation(.easeInOut(duration: 0.2)) { expanded.toggle() } }) {
                            HStack(spacing: 4) {
                                Text(expanded ? "Show less" : "Show all \(games.count) games")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                Image(systemName: expanded ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .foregroundColor(.white.opacity(0.7))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 9)
                            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.white.opacity(0.06)))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    /// 내 팀 경기를 앞으로
    private func orderedGames(_ items: [HomeAway]) -> [HomeAway] {
        let ids = favorites.favoriteTeamIds
        let mine = items.filter { ids.contains($0.home.teamId) || ids.contains($0.away.teamId) }
        let rest = items.filter { !(ids.contains($0.home.teamId) || ids.contains($0.away.teamId)) }
        return mine + rest
    }

    // MARK: - Header pieces

    @ViewBuilder
    private var recordChip: some View {
        if picks.gradedCount > 0 {
            HStack(spacing: 6) {
                Text("\(picks.wins)-\(picks.losses)")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("\(Int((picks.accuracy * 100).rounded()))%")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.55))
                if picks.currentStreak >= 2 {
                    HStack(spacing: 2) {
                        Image(systemName: "flame.fill").font(.system(size: 9, weight: .bold))
                        Text("\(picks.currentStreak)").font(.system(size: 10, weight: .black, design: .rounded))
                    }
                    .foregroundColor(.orange)
                }
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(Capsule().fill(Color.white.opacity(0.08)))
            .overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 1))
        }
    }

    @ViewBuilder
    private func gradedBanner(_ s: PicksDaySummary) -> some View {
        let good = s.correct * 2 >= s.total
        HStack(spacing: 8) {
            Image(systemName: good ? "checkmark.seal.fill" : "xmark.seal.fill")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(good ? Color(red: 0.2, green: 0.85, blue: 0.45) : .orange)
            Text("Last slate: \(s.correct) of \(s.total) correct")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
            Spacer()
            if picks.bestStreak >= 3 {
                Text("Best streak \(picks.bestStreak)")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.45))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill((good ? Color(red: 0.2, green: 0.85, blue: 0.45) : Color.orange).opacity(0.12))
        )
    }
}

/// 경기 한 줄: [원정팀 선택 영역] 시각 [홈팀 선택 영역]
struct PickGameRow: View {
    let game: HomeAway
    let picked: String?
    let onPick: (String) -> Void
    @ObservedObject private var favorites = FavoritesManager.shared

    var body: some View {
        HStack(spacing: 8) {
            teamSide(game.away, isHome: false)

            VStack(spacing: 2) {
                Text("@")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.3))
                Text(game.statusText?.replacingOccurrences(of: " ET", with: "").uppercased() ?? "")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(width: 62)

            teamSide(game.home, isHome: true)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(LinearGradient(colors: [Color.white.opacity(0.07), Color.white.opacity(0.03)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.white.opacity(0.1), lineWidth: 1))
        )
    }

    @ViewBuilder
    private func teamSide(_ team: Game, isHome: Bool) -> some View {
        let tri = NBAStaticConference.normalizedTriCode(fromTeamCode: team.teamCode) ?? team.teamId.teamIdToTriCode
        let isPicked = picked == team.teamId
        let isOtherPicked = picked != nil && !isPicked
        let isMine = favorites.favoriteTeamIds.contains(team.teamId)
        let teamColor = Color(team.teamId.dark)

        Button(action: { onPick(team.teamId) }) {
            HStack(spacing: 8) {
                if isHome { Spacer(minLength: 0) }

                if !isHome { logo(tri: tri, nickname: team.teamCode) }

                VStack(alignment: isHome ? .trailing : .leading, spacing: 1) {
                    HStack(spacing: 3) {
                        if isHome, isMine { star }
                        Text(tri)
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundColor(.white.opacity(isOtherPicked ? 0.45 : 1))
                        if !isHome, isMine { star }
                    }
                    Text(team.record ?? "")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(isOtherPicked ? 0.3 : 0.55))
                }

                if isHome { logo(tri: tri, nickname: team.teamCode) }

                if !isHome { Spacer(minLength: 0) }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(isPicked ? teamColor.opacity(0.85) : Color.black.opacity(0.25))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .stroke(isPicked ? Color.white.opacity(0.6) : Color.white.opacity(0.08), lineWidth: isPicked ? 1.5 : 1)
            )
            .overlay(alignment: isHome ? .topLeading : .topTrailing) {
                if isPicked {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .background(Circle().fill(teamColor).padding(2))
                        .offset(x: isHome ? -5 : 5, y: -6)
                }
            }
            .opacity(isOtherPicked ? 0.75 : 1)
            .scaleEffect(isPicked ? 1.0 : 0.98)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPicked)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var star: some View {
        Image(systemName: "star.fill")
            .font(.system(size: 8, weight: .bold))
            .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0))
    }

    @ViewBuilder
    private func logo(tri: String, nickname: String) -> some View {
        if RemoteConfigManager.shared.shouldUseOfficialTeamData, !tri.isEmpty {
            Image(tri)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
        } else {
            SafeModeLogoView(originalCode: nickname, triCode: tri)
                .frame(width: 30, height: 30)
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        }
    }
}
