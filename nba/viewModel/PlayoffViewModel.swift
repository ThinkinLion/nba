//
//  PlayoffViewModel.swift
//  nba
//

import Foundation
import Combine

/// Playoff round bucket for list sections (top → bottom).
enum PlayoffRoundStage: Int, CaseIterable, Identifiable {
    case finals = 0
    case conferenceFinals = 1
    case semifinals = 2
    case firstRound = 3
    
    var id: Int { rawValue }
    
    var sectionTitle: String {
        switch self {
        case .finals: return "FINALS"
        case .conferenceFinals: return "CONF. FINALS"
        case .semifinals: return "CONF. SEMIFINALS"
        case .firstRound: return "FIRST ROUND"
        }
    }
}

/// One round section: title + matchups (sorted by latest update).
struct PlayoffRoundSection: Identifiable {
    let stage: PlayoffRoundStage
    let matchups: [PlayoffSeries]
    
    var id: PlayoffRoundStage { stage }
    var sectionTitle: String { stage.sectionTitle }
}

final class PlayoffViewModel: ObservableObject {
    @Published var activeSeries: [PlayoffSeries] = []
    @Published var roundSections: [PlayoffRoundSection] = []
    @Published var isLoading = false
    
    /// In-memory recap cache to limit repeated `games` collection reads.
    private static var cachedSeries: [PlayoffSeries] = []
    private static var lastRecapFetchTime: Date?
    /// NBA 데이터는 대개 일 단위로 갱신되므로 recap 읽기를 하루에 한 번 수준으로 제한.
    private static let recapCacheTTL: TimeInterval = 24 * 60 * 60
    /// Bump when bracket filtering / round logic changes so stale rows aren’t reused forever.
    private static let cacheSchemaVersion = 24
    private static var cachedSchemaVersion: Int = 0
    
    private let repository: StandingsRepository
    
    var currentYear: String {
        "\(Calendar.current.component(.year, from: Date()))"
    }
    
    init(repository: StandingsRepository = FirestoreStandingsRepository()) {
        self.repository = repository
    }
    
    /// - Parameters:
    ///   - precachedRecap: Pass `StandingsViewModel.gameRecap` after `fetchStandingsAsync()` so we don’t read the `games` collection twice in one flow.
    ///   - forceRefresh: Bypass TTL (e.g. pull-to-refresh).
    @MainActor
    func fetchAndBacktrackPlayoffs(
        standings: StandingsModel,
        precachedRecap: [GamesModel]? = nil,
        forceRefresh: Bool = false
    ) async {
        if !forceRefresh,
           Self.cachedSchemaVersion == Self.cacheSchemaVersion,
           !Self.cachedSeries.isEmpty,
           let last = Self.lastRecapFetchTime,
           Date().timeIntervalSince(last) < Self.recapCacheTTL {
            applyStandingsToCachedSeries(standings: standings)
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        do {
            let games: [GamesModel]
            if let precachedRecap, !precachedRecap.isEmpty {
                games = precachedRecap
            } else {
                games = try await repository.fetchGameRecap()
            }
            
            let lookup = buildConferenceLookup(from: standings)
            let raw = backtrackSeries(from: games)
            let enriched = raw.map { s -> PlayoffSeries in
                PlayoffSeries(
                    awayTeamCode: s.awayTeamCode,
                    homeTeamCode: s.homeTeamCode,
                    awayTeamId: s.awayTeamId,
                    homeTeamId: s.homeTeamId,
                    awayTeamName: s.awayTeamName,
                    homeTeamName: s.homeTeamName,
                    status: s.status,
                    latestDate: s.latestDate,
                    conference: resolveConference(for: s, lookup: lookup)
                )
            }
            .filter { !Self.statusExcludedFromPlayoffBracket($0.status) }
            
            self.activeSeries = enriched
            self.roundSections = buildRoundSections(from: enriched)
            Self.cachedSeries = enriched
            Self.lastRecapFetchTime = Date()
            Self.cachedSchemaVersion = Self.cacheSchemaVersion
        } catch {
            print("Error loading playoffs: \(error)")
        }
    }
    
    /// Re-resolve conferences from current standings and rebuild sections without hitting Firestore.
    @MainActor
    private func applyStandingsToCachedSeries(standings: StandingsModel) {
        let lookup = buildConferenceLookup(from: standings)
        let remapped = Self.cachedSeries.map { s in
            PlayoffSeries(
                awayTeamCode: s.awayTeamCode,
                homeTeamCode: s.homeTeamCode,
                awayTeamId: s.awayTeamId,
                homeTeamId: s.homeTeamId,
                awayTeamName: s.awayTeamName,
                homeTeamName: s.homeTeamName,
                status: s.status,
                latestDate: s.latestDate,
                conference: resolveConference(for: s, lookup: lookup)
            )
        }
        self.activeSeries = remapped
        self.roundSections = buildRoundSections(from: remapped)
    }
    
    private func backtrackSeries(from gamesModel: [GamesModel]) -> [PlayoffSeries] {
        var dict: [String: PlayoffSeries] = [:]
        let days = gamesModel.sorted { ($0.date ?? "") < ($1.date ?? "") }
        for day in days {
            for game in day.items {
                guard let text = game.series, !text.isEmpty else { continue }
                let key = [game.away.teamCode, game.home.teamCode].sorted().joined(separator: "-vs-")
                dict[key] = PlayoffSeries(
                    awayTeamCode: game.away.teamCode,
                    homeTeamCode: game.home.teamCode,
                    awayTeamId: game.away.teamId,
                    homeTeamId: game.home.teamId,
                    awayTeamName: game.away.teamCode.nickNameToTriCode,
                    homeTeamName: game.home.teamCode.nickNameToTriCode,
                    status: text,
                    latestDate: day.date ?? "",
                    conference: ""
                )
            }
        }
        return dict.values.sorted { $0.latestDate > $1.latestDate }
    }
    
    private func buildConferenceLookup(from standings: StandingsModel) -> [String: String] {
        var map: [String: String] = [:]
        func add(_ team: StandingsTeam, _ conf: String) {
            guard !team.teamCode.isEmpty else { return }
            map[team.teamCode.lowercased()] = conf
            let tri = team.teamCode.nickNameToTriCode
            if !tri.isEmpty {
                map[tri.lowercased()] = conf
                map[tri.uppercased()] = conf
                let longNick = tri.uppercased().triCodeToNickName
                if !longNick.isEmpty { map[longNick.lowercased()] = conf }
            }
            if !team.teamId.isEmpty { map[team.teamId] = conf }
        }
        standings.east.forEach { add($0, "East") }
        standings.west.forEach { add($0, "West") }
        return map
    }
    
    /// Rows that are not main-draw best-of playoff series (play-in, seed clinch, elimination banner copy, etc.).
    private static func statusExcludedFromPlayoffBracket(_ status: String) -> Bool {
        let u = status.uppercased()
        if u.contains("PLAY-IN") || u.contains("PLAY IN") || u.contains("PLAYIN") { return true }
        // e.g. "ORL clinch 8 seed", "PHI clinch 7 seed" — inflates per-conference counts
        if u.contains("CLINCH"), u.contains("SEED") { return true }
        // e.g. "MIA eliminated", "LAC eliminated" — series outcome tag, not an active bracket row
        if u.contains("ELIMINATED") { return true }
        return false
    }
    
    private func resolveConference(for s: PlayoffSeries, lookup: [String: String]) -> String {
        let a = lookupTeam(s.awayTeamCode, s.awayTeamId, lookup)
        let h = lookupTeam(s.homeTeamCode, s.homeTeamId, lookup)
        if !a.isEmpty && !h.isEmpty { return a == h ? a : "Finals" }
        if !a.isEmpty { return a }
        if !h.isEmpty { return h }
        return inferFromStaticTris(s.awayTeamCode, s.homeTeamCode)
    }
    
    private func lookupTeam(_ code: String, _ teamId: String, _ lookup: [String: String]) -> String {
        if let c = matchLookup(code, lookup) { return c }
        let tid = teamId.trimmingCharacters(in: .whitespacesAndNewlines)
        if !tid.isEmpty, let c = lookup[tid] { return c }
        return ""
    }
    
    private func matchLookup(_ raw: String, _ lookup: [String: String]) -> String? {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return nil }
        if let c = lookup[t.lowercased()] { return c }
        if t.count == 3 {
            let nick = t.uppercased().triCodeToNickName
            if !nick.isEmpty, let c = lookup[nick.lowercased()] { return c }
        }
        let tri = t.nickNameToTriCode
        if !tri.isEmpty {
            if let c = lookup[tri.lowercased()] { return c }
            if let c = lookup[tri.uppercased()] { return c }
        }
        return nil
    }
    
    private func inferFromStaticTris(_ away: String, _ home: String) -> String {
        guard let aTri = NBAStaticConference.normalizedTriCode(fromTeamCode: away),
              let hTri = NBAStaticConference.normalizedTriCode(fromTeamCode: home),
              let a = NBAStaticConference.leagueConference(forTriCode: aTri),
              let h = NBAStaticConference.leagueConference(forTriCode: hTri) else {
            return ""
        }
        return a == h ? a : "Finals"
    }
    
    // MARK: - Round sections (conference-wise layered allocation)
    
    private func parseRecapDay(_ raw: String) -> Date? {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return nil }
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: t)
    }
    
    private func normalizedTri(fromTeamCode raw: String) -> String {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.count == 3 {
            return NBAStaticConference.normalizeTriAlias(t.uppercased())
        }
        let tri = t.nickNameToTriCode
        if !tri.isEmpty {
            return NBAStaticConference.normalizeTriAlias(tri.uppercased())
        }
        return t.uppercased()
    }
    
    private func teamTriSet(of s: PlayoffSeries) -> Set<String> {
        [normalizedTri(fromTeamCode: s.awayTeamCode), normalizedTri(fromTeamCode: s.homeTeamCode)]
    }
    
    /// Tries to extract winner tri code from recap copy like `NYK wins 4-2`.
    private func winnerTri(of s: PlayoffSeries) -> String? {
        guard s.isFinished else { return nil }
        let u = s.status.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !u.isEmpty else { return nil }
        
        if let r = u.range(of: #"^[A-Z]{2,3}(?=\s+WINS)"#, options: .regularExpression) {
            return NBAStaticConference.normalizeTriAlias(String(u[r]))
        }
        
        let awayTri = normalizedTri(fromTeamCode: s.awayTeamCode)
        let homeTri = normalizedTri(fromTeamCode: s.homeTeamCode)
        if u.contains("\(awayTri) WINS") { return awayTri }
        if u.contains("\(homeTri) WINS") { return homeTri }
        return nil
    }
    
    private func conferenceBucket(_ s: PlayoffSeries) -> String {
        if s.conference == "Finals" { return "Finals" }
        if s.conference == "East" || s.conference == "West" { return s.conference }
        let inferred = inferFromStaticTris(s.awayTeamCode, s.homeTeamCode)
        return inferred.isEmpty ? s.conference : inferred
    }
    
    private func buildRoundSections(from series: [PlayoffSeries]) -> [PlayoffRoundSection] {
        let finals = series.filter { conferenceBucket($0) == "Finals" }
        
        let east = series.filter { conferenceBucket($0) == "East" }
        let west = series.filter { conferenceBucket($0) == "West" }
        
        var semis: [PlayoffSeries] = []
        var first: [PlayoffSeries] = []
        var conferenceFinals: [PlayoffSeries] = []
        
        let eastLayers = allocateConferenceLayers(east)
        conferenceFinals.append(contentsOf: eastLayers.conferenceFinals)
        semis.append(contentsOf: eastLayers.semifinals)
        first.append(contentsOf: eastLayers.firstRound)
        
        let westLayers = allocateConferenceLayers(west)
        conferenceFinals.append(contentsOf: westLayers.conferenceFinals)
        semis.append(contentsOf: westLayers.semifinals)
        first.append(contentsOf: westLayers.firstRound)
        
        func sortByDateDesc(_ list: [PlayoffSeries]) -> [PlayoffSeries] {
            list.sorted {
                (parseRecapDay($0.latestDate) ?? .distantPast) > (parseRecapDay($1.latestDate) ?? .distantPast)
            }
        }
        
        var sections: [PlayoffRoundSection] = []
        if !finals.isEmpty {
            sections.append(.init(stage: .finals, matchups: sortByDateDesc(finals)))
        }
        if !conferenceFinals.isEmpty {
            sections.append(.init(stage: .conferenceFinals, matchups: sortByDateDesc(conferenceFinals)))
        }
        if !semis.isEmpty {
            sections.append(.init(stage: .semifinals, matchups: sortByDateDesc(semis)))
        }
        if !first.isEmpty {
            sections.append(.init(stage: .firstRound, matchups: sortByDateDesc(first)))
        }
        return sections
    }
    
    /// Core rule: teams that **won** a lower series appear in an upper series.
    /// Build winner -> next-series links inside the same conference and assign round by graph depth:
    /// depth 0 = FIRST ROUND, depth 1 = CONF. SEMIFINALS, depth 2+ = CONF. FINALS.
    private func allocateConferenceLayers(_ input: [PlayoffSeries]) -> (conferenceFinals: [PlayoffSeries], semifinals: [PlayoffSeries], firstRound: [PlayoffSeries]) {
        guard !input.isEmpty else { return ([], [], []) }
        
        let sorted = input.sorted {
            (parseRecapDay($0.latestDate) ?? .distantPast) > (parseRecapDay($1.latestDate) ?? .distantPast)
        }
        let n = sorted.count
        let dates = sorted.map { parseRecapDay($0.latestDate) ?? .distantPast }
        let teamSets = sorted.map { teamTriSet(of: $0) }
        let winners = sorted.map { winnerTri(of: $0) }
        
        var preds: [[Int]] = Array(repeating: [], count: n)
        for i in 0..<n {
            guard let w = winners[i] else { continue } // only completed series can advance a winner
            for j in 0..<n where i != j {
                // Winner must appear in the next series, and next series date should be same/later.
                if teamSets[j].contains(w), dates[i] <= dates[j] {
                    preds[j].append(i)
                }
            }
        }
        
        // Longest predecessor chain depth as round index.
        var depth = Array(repeating: 0, count: n)
        if n > 1 {
            for _ in 0..<(n * 2) {
                var changed = false
                for j in 0..<n {
                    let candidate = preds[j].map { depth[$0] + 1 }.max() ?? 0
                    if candidate != depth[j] {
                        depth[j] = candidate
                        changed = true
                    }
                }
                if !changed { break }
            }
        }
        
        var conferenceFinals: [PlayoffSeries] = []
        var semifinals: [PlayoffSeries] = []
        var firstRound: [PlayoffSeries] = []
        
        for idx in 0..<n {
            switch depth[idx] {
            case 0:
                firstRound.append(sorted[idx])
            case 1:
                semifinals.append(sorted[idx])
            default:
                conferenceFinals.append(sorted[idx])
            }
        }
        
        // If links were sparse (winner text missing), fallback by alive-count shape.
        if conferenceFinals.isEmpty && semifinals.isEmpty {
            let unfinished = sorted.filter { !$0.isFinished }
            switch unfinished.count {
            case 1:
                conferenceFinals = Array(unfinished.prefix(1))
                let finished = sorted.filter { $0.isFinished }
                semifinals = Array(finished.prefix(2))
                firstRound = Array(finished.dropFirst(2).prefix(4))
            case 2:
                semifinals = Array(unfinished.prefix(2))
                firstRound = Array(sorted.filter { $0.isFinished }.suffix(4))
            default:
                firstRound = Array(sorted.prefix(4))
            }
        }
        
        return (
            conferenceFinals.sorted { (parseRecapDay($0.latestDate) ?? .distantPast) > (parseRecapDay($1.latestDate) ?? .distantPast) },
            semifinals.sorted { (parseRecapDay($0.latestDate) ?? .distantPast) > (parseRecapDay($1.latestDate) ?? .distantPast) },
            firstRound.sorted { (parseRecapDay($0.latestDate) ?? .distantPast) > (parseRecapDay($1.latestDate) ?? .distantPast) }
        )
    }
    
}
