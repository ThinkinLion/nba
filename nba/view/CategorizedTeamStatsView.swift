//
//  CategorizedTeamStatsView.swift
//  nba
//
//  팀 상세 TEAM STATS 탭의 본문: 시즌 요약 카드 1장 + 분할 기록(SPLITS) 표 1장.
//  (이전: 분할마다 280pt 카드를 가로 스크롤로 나열 → 같은 숫자가 여러 번 반복되고 비교가 어려웠음)
//

import SwiftUI

// MARK: - Key numbers (리그 순위 포함)

struct TeamKeyNumbersView: View {
    let team: TeamModel
    let teamColor: Color

    var body: some View {
        let items: [(String, String?, String?)] = [
            ("PPG", team.ppg, team.ppgRank),
            ("OPP PPG", team.oppg, team.oppgRank),
            ("RPG", team.rpg, team.rpgRank),
            ("APG", team.apg, team.apgRank),
        ]
        if items.contains(where: { !($0.1 ?? "").isEmpty }) {
            VStack(alignment: .leading, spacing: 12) {
                sectionTitle("KEY NUMBERS", trailing: "LEAGUE RANK")
                HStack(spacing: 8) {
                    ForEach(items, id: \.0) { item in
                        keyTile(title: item.0, value: item.1 ?? "-", rank: item.2 ?? "", lowerIsBetter: item.0 == "OPP PPG")
                    }
                }
                .padding(.horizontal, 15)
            }
        }
    }

    @ViewBuilder
    private func keyTile(title: String, value: String, rank: String, lowerIsBetter: Bool) -> some View {
        let rankNum = Int(rank.filter { $0.isNumber }) ?? 0
        let color: Color = rankNum == 0 ? .white.opacity(0.5) : (rankNum <= 10 ? Color(red: 0.2, green: 0.85, blue: 0.45) : (rankNum >= 21 ? Color.red.opacity(0.9) : .white.opacity(0.7)))
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 9, weight: .heavy, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
                .tracking(0.5)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(value.isEmpty ? "-" : value)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(rank.isEmpty ? " " : rank)
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .foregroundColor(color)
                .padding(.horizontal, 6)
                .padding(.vertical, 1.5)
                .background(Capsule().fill(color.opacity(rankNum == 0 ? 0 : 0.15)))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.white.opacity(0.1), lineWidth: 1))
        )
    }
}

// MARK: - Season summary + Splits

struct CategorizedTeamStatsView: View {
    let stats: [TeamStats]
    let teamColor: Color

    private var seasonStat: TeamStats? {
        stats.first { $0.title?.contains("202") == true || $0.title?.lowercased().contains("overall") == true }
    }

    /// 분할 그룹 (시즌 전체와 똑같은 숫자인 분할은 중복이므로 제외)
    private var splitGroups: [(title: String, rows: [TeamStats])] {
        func pick(_ titles: [String]) -> [TeamStats] {
            titles.compactMap { t in stats.first { $0.title?.lowercased() == t } }
        }
        let location = pick(["home", "road", "away"])
        let outcome = pick(["wins", "losses", "won", "lost"])
        let rest = stats.filter { $0.title?.lowercased().contains("days rest") == true }
            .sorted { (Int($0.title?.prefix(1) ?? "") ?? 9) < (Int($1.title?.prefix(1) ?? "") ?? 9) }
        let months = ["oct", "nov", "dec", "jan", "feb", "mar", "apr", "may", "jun"]
        let month = stats.filter { s in months.contains { s.title?.lowercased().hasPrefix($0) == true } }
        let allStar = stats.filter { $0.title?.lowercased().contains("all-star") == true }

        var groups: [(String, [TeamStats])] = []
        if !location.isEmpty { groups.append(("LOCATION", location)) }
        if !outcome.isEmpty { groups.append(("OUTCOME", outcome)) }
        if !rest.isEmpty { groups.append(("DAYS REST", rest)) }
        if month.count > 1 { groups.append(("BY MONTH", month)) }
        if allStar.count > 1 { groups.append(("ALL-STAR BREAK", allStar)) }
        return groups
            .map { ($0.0, $0.1.filter { ($0.gp ?? "0") != "0" && !isDuplicateOfSeason($0) }) }
            .filter { !$0.1.isEmpty }
    }

    private func isDuplicateOfSeason(_ s: TeamStats) -> Bool {
        guard let season = seasonStat else { return false }
        return s.gp == season.gp && s.win == season.win && s.loss == season.loss && s.pts == season.pts
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 26) {
            if let season = seasonStat {
                VStack(alignment: .leading, spacing: 12) {
                    sectionTitle("SEASON SUMMARY", trailing: "\(season.title ?? "") · \(season.gp ?? "0") GP")
                    SeasonSummaryCard(stat: season, color: teamColor)
                        .padding(.horizontal, 15)
                }
            }

            let groups = splitGroups
            if !groups.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    sectionTitle("SPLITS", trailing: "PER GAME")
                    SplitsTableView(groups: groups, color: teamColor)
                        .padding(.horizontal, 15)
                }
            }
        }
    }
}

/// 시즌 전체 요약 카드 (전체 폭 1장)
struct SeasonSummaryCard: View {
    let stat: TeamStats
    let color: Color

    var body: some View {
        VStack(spacing: 0) {
            // 전적 행
            HStack(spacing: 0) {
                bigBox(label: "RECORD", value: "\(stat.win ?? "0")-\(stat.loss ?? "0")")
                divider
                bigBox(label: "WIN%", value: stat.wp ?? "-")
                divider
                bigBox(label: "+/-", value: stat.pm ?? "-", tint: plusMinusColor(stat.pm))
            }
            .padding(.vertical, 12)
            .background(color.opacity(0.35))

            VStack(spacing: 0) {
                statRow(label: "SCORING", items: [("PTS", stat.pts), ("FG%", stat.fgp), ("3P%", stat.tpp), ("FT%", stat.ftp)])
                Divider().background(Color.white.opacity(0.08))
                statRow(label: "REBOUNDS", items: [("REB", stat.reb), ("OREB", stat.oreb), ("DREB", stat.dreb)])
                Divider().background(Color.white.opacity(0.08))
                statRow(label: "PLAYMAKING · D", items: [("AST", stat.ast), ("TOV", stat.tov), ("STL", stat.stl), ("BLK", stat.blk)])
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
        }
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(LinearGradient(colors: [color.opacity(0.6), Color.white.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
        )
    }

    private var divider: some View {
        Rectangle().fill(Color.white.opacity(0.12)).frame(width: 1, height: 30)
    }

    @ViewBuilder
    private func bigBox(label: String, value: String, tint: Color = .white) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(size: 9, weight: .heavy, design: .rounded))
                .foregroundColor(.white.opacity(0.55))
                .tracking(0.5)
            Text(value)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(tint)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func statRow(label: String, items: [(String, String?)]) -> some View {
        HStack(alignment: .center, spacing: 0) {
            Text(label)
                .font(.system(size: 9, weight: .heavy, design: .rounded))
                .foregroundColor(.white.opacity(0.4))
                .tracking(0.4)
                .frame(width: 92, alignment: .leading)
            ForEach(items, id: \.0) { item in
                VStack(spacing: 2) {
                    Text(item.1 ?? "-")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.92))
                    Text(item.0)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.white.opacity(0.45))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 10)
    }
}

/// 분할 기록 표: 행 = Home/Road/Wins/Losses/휴식일…, 열 = GP · W-L · PTS · +/- · FG%
struct SplitsTableView: View {
    let groups: [(title: String, rows: [TeamStats])]
    let color: Color

    private let columns = ["GP", "W-L", "PTS", "+/-", "FG%"]

    var body: some View {
        VStack(spacing: 0) {
            // 열 머리
            HStack(spacing: 0) {
                Text("SPLIT")
                    .frame(width: 96, alignment: .leading)
                ForEach(columns, id: \.self) { c in
                    Text(c).frame(maxWidth: .infinity)
                }
            }
            .font(.system(size: 9, weight: .heavy, design: .rounded))
            .foregroundColor(.white.opacity(0.45))
            .tracking(0.4)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.06))

            ForEach(Array(groups.enumerated()), id: \.offset) { gIdx, group in
                // 그룹 라벨
                HStack {
                    Text(group.title)
                        .font(.system(size: 9, weight: .heavy, design: .rounded))
                        .foregroundColor(color.opacity(0.95))
                        .tracking(0.6)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.top, gIdx == 0 ? 8 : 10)
                .padding(.bottom, 2)

                ForEach(Array(group.rows.enumerated()), id: \.offset) { rIdx, s in
                    HStack(spacing: 0) {
                        Text(displayTitle(s.title))
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .frame(width: 96, alignment: .leading)
                        cell(s.gp ?? "-")
                        cell("\(s.win ?? "0")-\(s.loss ?? "0")")
                        cell(s.pts ?? "-")
                        cell(s.pm ?? "-", tint: plusMinusColor(s.pm))
                        cell(s.fgp ?? "-")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(rIdx % 2 == 1 ? Color.white.opacity(0.025) : Color.clear)
                }
            }
            Spacer(minLength: 6)
        }
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }

    @ViewBuilder
    private func cell(_ value: String, tint: Color = .white.opacity(0.9)) -> some View {
        Text(value)
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundColor(tint)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .frame(maxWidth: .infinity)
    }

    private func displayTitle(_ raw: String?) -> String {
        let t = raw ?? ""
        if t.lowercased().hasSuffix("days rest") { return t.replacingOccurrences(of: " Days Rest", with: "d rest").replacingOccurrences(of: " days rest", with: "d rest") }
        return t
    }
}

// MARK: - Helpers

@ViewBuilder
func sectionTitle(_ title: String, trailing: String? = nil) -> some View {
    HStack(alignment: .firstTextBaseline) {
        Text(title)
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.white.opacity(0.7))
        Spacer()
        if let trailing, !trailing.isEmpty {
            Text(trailing)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.4))
                .tracking(0.4)
        }
    }
    .padding(.horizontal, 15)
}

func plusMinusColor(_ raw: String?) -> Color {
    guard let v = Double(raw ?? "") else { return .white.opacity(0.9) }
    if v > 0 { return Color(red: 0.2, green: 0.85, blue: 0.45) }
    if v < 0 { return Color.red.opacity(0.9) }
    return .white.opacity(0.9)
}
