//
//  MoversModuleView.swift
//  nba
//
//  Today 피드 "MOVERS" 모듈: 최신 주간 파워랭킹의 상승/하락 Top 3. 내 팀은 강조.
//

import SwiftUI

struct MoversModuleView: View {
    let powerRanking: PowerRankingModel
    @ObservedObject private var favorites = FavoritesManager.shared

    struct Mover: Identifiable {
        let team: NBATeamCatalogItem
        let rank: Int
        let change: Int // +8 / -7
        var id: String { team.triCode }
    }

    var body: some View {
        let movers = computeMovers()
        let risers = movers.filter { $0.change > 0 }.sorted { $0.change > $1.change }.prefix(3)
        let fallers = movers.filter { $0.change < 0 }.sorted { $0.change < $1.change }.prefix(3)

        if !risers.isEmpty || !fallers.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    SectionHeaderView(title: "MOVERS")
                    Spacer()
                    if let week = powerRanking.week {
                        Text(week.uppercased().replacingOccurrences(of: "-", with: " "))
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.45))
                            .padding(.trailing, 16)
                    }
                }

                HStack(alignment: .top, spacing: 10) {
                    column(title: "RISING", icon: "arrow.up.right", color: Color(red: 0.2, green: 0.85, blue: 0.45), movers: Array(risers))
                    column(title: "FALLING", icon: "arrow.down.right", color: Color.red.opacity(0.9), movers: Array(fallers))
                }
                .padding(.horizontal, 16)
            }
        }
    }

    @ViewBuilder
    private func column(title: String, icon: String, color: Color, movers: [Mover]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 9, weight: .heavy))
                Text(title).font(.system(size: 10, weight: .heavy, design: .rounded)).tracking(0.6)
            }
            .foregroundColor(color)
            .padding(.leading, 2)

            if movers.isEmpty {
                Text("—")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.3))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
            } else {
                ForEach(movers) { m in
                    NavigationLink(destination: TeamView(teamId: m.team.teamId)) {
                        moverRow(m, color: color)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func moverRow(_ m: Mover, color: Color) -> some View {
        let isMine = favorites.isFavorite(m.team.triCode)
        HStack(spacing: 8) {
            if RemoteConfigManager.shared.shouldUseOfficialTeamData {
                Image(m.team.triCode)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22)
            } else {
                SafeModeLogoView(originalCode: m.team.nickname, triCode: m.team.triCode)
                    .frame(width: 22, height: 22)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            }
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 3) {
                    Text(m.team.triCode)
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    if isMine {
                        Image(systemName: "star.fill")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0))
                    }
                }
                Text("#\(m.rank)")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
            }
            Spacer(minLength: 2)
            Text(m.change > 0 ? "+\(m.change)" : "\(m.change)")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundColor(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isMine ? Color(m.team.darkColorName).opacity(0.45) : Color.white.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(isMine ? Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1))
        )
    }

    // MARK: - Data

    /// lastWeek("10↑") 는 지난주 순위이므로 변동 = 지난주 순위 - 이번주 순위
    private func computeMovers() -> [Mover] {
        guard let items = powerRanking.items else { return [] }
        return items.compactMap { item in
            guard let rank = Int((item.rank ?? "").filter { $0.isNumber }),
                  let last = Int((item.lastWeek ?? "").filter { $0.isNumber }),
                  let tri = item.teamCode?.nickNameToTriCode, !tri.isEmpty,
                  let team = NBATeamCatalog.item(triCode: tri) else { return nil }
            let change = last - rank
            guard change != 0 else { return nil }
            return Mover(team: team, rank: rank, change: change)
        }
    }
}
