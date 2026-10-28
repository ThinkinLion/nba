//
//  LeadersStore.swift
//  nba
//
//  Firestore statsLeaders.{season} (카테고리 → Top 5 선수) 를 한 번 읽어
//  카테고리 보드와 "선수 → 리더 항목" 역인덱스를 앱 전역에서 제공합니다.
//  크롤러 변경 없이 47개 카테고리 × 5명을 클라이언트에서 뒤집어 씁니다.
//

import Foundation
import FirebaseFirestore

/// 한 선수가 한 카테고리의 Top 5 에 들어 있다는 사실
struct LeaderEntry: Identifiable, Hashable {
    let key: String        // "seasonLeadersPointsPerGame"
    let category: String   // "Season Leaders" / "Hustle" / "Centers" ...
    let title: String      // "Points Per Game"
    let rank: Int          // 1~5
    let value: String      // "36.0"
    let playerId: String
    let name: String
    let teamTriCode: String

    var id: String { "\(key)-\(playerId)" }
    var shortTitle: String { LeadersStore.shortTitle(for: key, title: title) }
    var isSeasonLeaders: Bool { category == "Season Leaders" }
    /// 배지 문구: "PPG" / "Centers · PPG" / "Hustle · DEFLECTIONS"
    var badgeLabel: String { isSeasonLeaders ? shortTitle : "\(category) · \(shortTitle)" }
}

@MainActor
final class LeadersStore: ObservableObject {
    static let shared = LeadersStore()

    @Published private(set) var boards: [String: SeasonLeaders] = [:]
    @Published private(set) var byPlayer: [String: [LeaderEntry]] = [:]
    @Published private(set) var isLoaded = false

    private let db = Firestore.firestore()
    private var inflight: Task<Void, Never>?

    private init() {}

    // MARK: - Loading

    func loadIfNeeded(forceRefresh: Bool = false) async {
        if isLoaded && !forceRefresh { return }
        if let inflight { await inflight.value; return }
        let task = Task { await self.load(forceRefresh: forceRefresh) }
        inflight = task
        await task.value
        inflight = nil
    }

    private func load(forceRefresh: Bool) async {
        let season = SeasonProvider.shared.seasonYear()
        let cacheKey = "statsLeaders.boards.\(season)"
        if !forceRefresh, let cached = NBAFirestoreDayCache.load([String: SeasonLeaders].self, key: cacheKey) {
            apply(cached)
            return
        }
        do {
            let boards = try await db.collection("statsLeaders").document(season).getDocument(as: [String: SeasonLeaders].self)
            apply(boards)
            NBAFirestoreDayCache.save(boards, key: cacheKey)
        } catch {
            print("❌ LeadersStore 로드 실패: \(error)")
        }
    }

    private func apply(_ boards: [String: SeasonLeaders]) {
        var index: [String: [LeaderEntry]] = [:]
        for (key, board) in boards {
            for item in board.items {
                guard let pid = item.playerId, !pid.isEmpty else { continue }
                let entry = LeaderEntry(
                    key: key, category: board.category, title: board.title,
                    rank: Int(item.rank ?? "") ?? 0, value: item.points ?? "",
                    playerId: pid, name: item.name ?? "", teamTriCode: item.teamTriCode ?? ""
                )
                index[pid, default: []].append(entry)
            }
        }
        for pid in index.keys {
            index[pid]?.sort(by: Self.entryOrder)
        }
        self.boards = boards
        self.byPlayer = index
        self.isLoaded = true
        print("LeadersStore: \(boards.count)개 카테고리, \(index.count)명 인덱스")
    }

    // MARK: - Queries

    func entries(for playerId: String) -> [LeaderEntry] {
        byPlayer[playerId] ?? []
    }

    /// 리그 Season Leaders 카테고리 중 가장 높은 순위 항목 (배지 1개짜리 요약용)
    func headline(for playerId: String) -> LeaderEntry? {
        entries(for: playerId).first
    }

    func board(_ key: String) -> SeasonLeaders? {
        boards[key]
    }

    /// 로스터(선수 ID 목록) 중 리더 보드에 든 선수들의 항목
    func entries(forPlayerIds ids: [String]) -> [LeaderEntry] {
        ids.flatMap { entries(for: $0) }.sorted(by: Self.entryOrder)
    }
    
    /// 배지 우선순위: Season Leaders → 핵심 지표(PPG/RPG/APG… curated 순) → 순위
    nonisolated static func entryOrder(_ a: LeaderEntry, _ b: LeaderEntry) -> Bool {
        if a.isSeasonLeaders != b.isSeasonLeaders { return a.isSeasonLeaders }
        let pa = curatedIndex[a.key] ?? Int.max
        let pb = curatedIndex[b.key] ?? Int.max
        if pa != pb { return pa < pb }
        if a.rank != b.rank { return a.rank < b.rank }
        return a.title < b.title
    }
    
    nonisolated private static let curatedIndex: [String: Int] = Dictionary(uniqueKeysWithValues: curated.enumerated().map { ($1.key, $0) })

    // MARK: - Today 피드 로테이션

    /// Today 피드에 노출할 카테고리 (우선순위 순). 매일 시작 위치를 옮겨 4개씩 노출
    nonisolated static let curated: [(key: String, short: String)] = [
        ("seasonLeadersPointsPerGame", "PPG"),
        ("seasonLeadersReboundsPerGame", "RPG"),
        ("seasonLeadersAssistsPerGame", "APG"),
        ("seasonLeadersThreePointersMade", "3PM"),
        ("seasonLeadersStealsPerGame", "SPG"),
        ("seasonLeadersBlocksPerGame", "BPG"),
        ("miscellaneousPointsInThePaintPerGame", "PITP"),
        ("hustleDeflectionsPerGame", "DEFLECTIONS"),
        ("seasonLeadersThreePointPercentage", "3P%"),
        ("seasonLeadersFieldGoalPercentage", "FG%"),
        ("miscellaneousFastBreakPointsPerGame", "FB PTS"),
        ("hustleScreenAssistsPerGame", "SCREEN AST"),
        ("advancedUsagePercentage", "USG%"),
        ("clutchTotalPoints", "CLUTCH PTS"),
        ("seasonLeadersFantasyPointsPerGame", "FPTS"),
        ("miscellaneous2ndChancePointsPerGame", "2ND CHANCE"),
        ("advancedTrueShootingPercentage", "TS%"),
        ("hustleLooseBallsRecPerGame", "LOOSE BALLS"),
        ("seasonLeadersMostPointsinaGame", "SEASON HIGH"),
        ("shootingbyZoneCorner3PPercentage", "CORNER 3P%"),
    ]

    nonisolated private static let shortByKey: [String: String] = Dictionary(uniqueKeysWithValues: curated.map { ($0.key, $0.short) })

    nonisolated static func shortTitle(for key: String, title: String) -> String {
        if let s = shortByKey[key] { return s }
        // 포지션/바이오 카테고리 등: 제목 기반 축약
        let t = title
            .replacingOccurrences(of: "Points Per Game", with: "PPG")
            .replacingOccurrences(of: "Rebounds Per Game", with: "RPG")
            .replacingOccurrences(of: "Assists Per Game", with: "APG")
            .replacingOccurrences(of: "Percentage", with: "%")
            .replacingOccurrences(of: "Per Game", with: "/G")
        return t.uppercased()
    }

    func todayRotation(count: Int = 4, date: Date = Date()) -> [(key: String, short: String, board: SeasonLeaders)] {
        let available = Self.curated.compactMap { c -> (key: String, short: String, board: SeasonLeaders)? in
            guard let b = boards[c.key], !b.items.isEmpty else { return nil }
            return (c.key, c.short, b)
        }
        guard !available.isEmpty else { return [] }
        let day = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 0
        // 하루에 count 개씩 창을 옮기되 첫 슬롯은 항상 핵심 지표(PPG/RPG/APG/3PM) 중 하나
        let core = Array(available.prefix(4))
        let rest = Array(available.dropFirst(4))
        var picked: [(key: String, short: String, board: SeasonLeaders)] = []
        if !core.isEmpty { picked.append(core[day % core.count]) }
        if !rest.isEmpty {
            let start = (day * 3) % rest.count
            for i in 0..<min(count - picked.count, rest.count) {
                picked.append(rest[(start + i) % rest.count])
            }
        }
        return picked
    }
}
