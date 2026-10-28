//
//  MyTeamsModuleView.swift
//  nba
//
//  Today 피드 상단 "MY TEAMS" 모듈: 관심 팀별 어제 결과 / 전적·시드 / 파워랭킹 순위·등락 카드
//

import SwiftUI

/// Today 모듈에서 팀 상세(PowerRankingDetailView)로 진입하기 위한 해석기
struct TodayTeamLink {
    let viewModel: PowerRankingViewModel
    let resolve: (NBATeamCatalogItem) -> TeamState?
    
    /// TeamState 를 찾으면 NavigationLink 로 감싸고, 없으면 라벨만 표시
    @ViewBuilder
    func wrap<Label: View>(_ team: NBATeamCatalogItem, @ViewBuilder label: () -> Label) -> some View {
        if let state = resolve(team) {
            NavigationLink(destination: PowerRankingDetailView(teamState: state, viewModel: viewModel)) {
                label()
            }
            .buttonStyle(PlainButtonStyle())
        } else {
            label()
        }
    }
}

struct MyTeamsModuleView: View {
    @ObservedObject private var favorites = FavoritesManager.shared
    let games: [GamesModel]            // 최신순
    let standings: StandingsModel
    let powerRanking: PowerRankingModel?
    let teamLink: TodayTeamLink
    let onManage: () -> Void

    var body: some View {
        let teams = favorites.favoriteTeamCodes.sorted().compactMap { NBATeamCatalog.item(triCode: $0) }

        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(colors: [Color(red: 1.0, green: 0.84, blue: 0.0), Color(red: 1.0, green: 0.55, blue: 0.0)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                Text("MY TEAMS")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                    .tracking(0.8)
                if !teams.isEmpty {
                    Text("\(teams.count)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(Color(red: 1.0, green: 0.84, blue: 0.0))
                        .clipShape(Capsule())
                }
                Spacer()
                Button(action: onManage) {
                    Text(teams.isEmpty ? "Pick" : "Edit")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 16)

            if teams.isEmpty {
                emptyCTA
                    .padding(.horizontal, 16)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(teams) { team in
                            teamLink.wrap(team) {
                                MyTeamCard(team: team, snapshot: snapshot(for: team))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                }
            }
        }
    }

    // MARK: - Data

    struct Snapshot {
        var record: String?        // "7-3"
        var seed: String?          // "3rd West"
        var lastGame: HomeAway?
        var lastGameDate: String?
        var isWin: Bool?
        var prRank: String?        // "#4"
        var prChange: Int?         // 지난주 순위 - 이번주 순위 (+6 상승 / -3 하락)
    }

    private func snapshot(for team: NBATeamCatalogItem) -> Snapshot {
        var s = Snapshot()

        // 순위표: 전적 + 컨퍼런스 시드
        if let row = (standings.east + standings.west).first(where: { $0.teamId == team.teamId }) {
            s.record = "\(row.win)-\(row.loss)"
            s.seed = "\(row.confRank.ordinal) \(team.conference)"
        }

        // 최근 경기: games 는 최신순이므로 처음 발견되는 경기가 가장 최근
        outer: for day in games {
            for match in day.items {
                if match.home.teamId == team.teamId || match.away.teamId == team.teamId {
                    s.lastGame = match
                    s.lastGameDate = day.date
                    let isHome = match.home.teamId == team.teamId
                    let mine = Int((isHome ? match.home.score : match.away.score) ?? "") ?? 0
                    let theirs = Int((isHome ? match.away.score : match.home.score) ?? "") ?? 0
                    s.isWin = mine > theirs
                    break outer
                }
            }
        }

        // 파워랭킹: teamCode 는 닉네임("Thunder") → TriCode 변환으로 매칭
        if let item = powerRanking?.items?.first(where: {
            ($0.teamCode?.nickNameToTriCode ?? "") == team.triCode || $0.teamName == team.name
        }) {
            s.prRank = item.rank
            if let rank = Int((item.rank ?? "").filter { $0.isNumber }),
               let last = Int((item.lastWeek ?? "").filter { $0.isNumber }) {
                s.prChange = last - rank
            }
        }
        return s
    }

    // MARK: - Empty CTA

    @ViewBuilder
    private var emptyCTA: some View {
        Button(action: onManage) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(Color.white.opacity(0.08)).frame(width: 36, height: 36)
                    Image(systemName: "star.dashed")
                        .font(.system(size: 15))
                        .foregroundColor(.yellow.opacity(0.85))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Pick your teams")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Their games, rank and stars show up here first.")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.55))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.05))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.white.opacity(0.1), lineWidth: 1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MyTeamCard: View {
    let team: NBATeamCatalogItem
    let snapshot: MyTeamsModuleView.Snapshot

    var body: some View {
        let baseColor = Color(team.darkColorName)

        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(LinearGradient(colors: [baseColor.opacity(0.85), Color.black.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(LinearGradient(colors: [Color.white.opacity(0.35), Color.white.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                )
                .shadow(color: baseColor.opacity(0.3), radius: 6, x: 0, y: 3)

            // 워터마크
            if RemoteConfigManager.shared.shouldUseOfficialTeamData {
                HStack {
                    Spacer()
                    Image(team.triCode)
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.white.opacity(0.07))
                        .offset(x: 12, y: 14)
                }
                .clipped()
            }

            VStack(alignment: .leading, spacing: 7) {
                // 1행: 로고 + 팀 + 전적/시드
                HStack(spacing: 7) {
                    logo.frame(width: 26, height: 26)
                    VStack(alignment: .leading, spacing: 0) {
                        Text(team.triCode)
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        if let record = snapshot.record {
                            Text(snapshot.seed.map { "\(record) · \($0)" } ?? record)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                                .lineLimit(1)
                        }
                    }
                    Spacer(minLength: 0)
                }

                // 2행: 최근 경기 결과
                if let game = snapshot.lastGame, let isWin = snapshot.isWin {
                    let isHome = game.home.teamId == team.teamId
                    let opp = (isHome ? game.away : game.home)
                    let oppTri = NBAStaticConference.normalizedTriCode(fromTeamCode: opp.teamCode) ?? opp.teamId.teamIdToTriCode
                    let mine = (isHome ? game.home.score : game.away.score) ?? "-"
                    let theirs = (isHome ? game.away.score : game.home.score) ?? "-"
                    HStack(spacing: 5) {
                        Text(isWin ? "W" : "L")
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1.5)
                            .background(isWin ? Color(red: 0.2, green: 0.8, blue: 0.4) : Color.red.opacity(0.85))
                            .clipShape(Capsule())
                        Text("\(mine)-\(theirs)")
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                        Text("\(isHome ? "vs" : "@") \(oppTri)")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white.opacity(0.65))
                    }
                } else {
                    Text("No recent game")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.45))
                }

                // 3행: 파워랭킹 순위 + 등락
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("PR")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundColor(.white.opacity(0.5))
                    Text(snapshot.prRank ?? "-")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    if let change = snapshot.prChange, change != 0 {
                        let style: RankChangeStyle = change > 0 ? .up : .down
                        HStack(spacing: 2) {
                            Image(systemName: change > 0 ? "arrow.up" : "arrow.down")
                                .font(.system(size: 7, weight: .bold))
                            Text("\(abs(change))")
                                .font(.system(size: 9, weight: .bold))
                        }
                        .foregroundColor(PowerRankingFormatter.rankChangeColor(for: style))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1.5)
                        .background(Capsule().fill(PowerRankingFormatter.rankChangeColor(for: style).opacity(0.18)))
                    }
                    Spacer(minLength: 0)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 9)
        }
        .frame(width: 160, height: 104)
    }

    @ViewBuilder
    private var logo: some View {
        if RemoteConfigManager.shared.shouldUseOfficialTeamData {
            Image(team.triCode)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 1)
        } else {
            SafeModeLogoView(originalCode: team.nickname, triCode: team.triCode)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
    }
}
