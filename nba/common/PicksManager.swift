//
//  PicksManager.swift
//  nba
//
//  승자 예측(My Picks): 예정 경기에 대해 사용자가 고른 팀을 로컬(UserDefaults)에 저장하고,
//  다음날 games 결과가 들어오면 채점해 전적·연승을 계산합니다. 서버 쓰기 없음.
//

import Foundation
import Combine

struct Pick: Codable, Hashable, Identifiable {
    let gameId: String
    let date: String          // "2026-10-28" (LA 기준 경기일)
    var pickedTeamId: String
    let homeTeamId: String
    let awayTeamId: String
    var isCorrect: Bool?      // nil = 미채점
    var gradedAt: Date?
    
    var id: String { gameId }
}

/// 하루치 채점 요약 ("Yesterday: 3 of 5")
struct PicksDaySummary: Codable, Equatable {
    let date: String
    let correct: Int
    let total: Int
}

final class PicksManager: ObservableObject {
    static let shared = PicksManager()
    
    @Published private(set) var picks: [String: Pick] = [:]   // gameId → Pick
    @Published private(set) var lastGradedSummary: PicksDaySummary?
    
    private let picksKey = "com.nba.powerranking.picks"
    private let summaryKey = "com.nba.powerranking.picks.lastSummary"
    private let defaults = UserDefaults.standard
    
    private init() { load() }
    
    // MARK: - Picking
    
    func pick(for game: HomeAway, teamId: String) {
        guard let gameId = game.gameId, !gameId.isEmpty else { return }
        if var existing = picks[gameId] {
            guard existing.isCorrect == nil else { return } // 채점된 예측은 변경 불가
            existing.pickedTeamId = teamId
            picks[gameId] = existing
        } else {
            picks[gameId] = Pick(gameId: gameId, date: game.date ?? "", pickedTeamId: teamId,
                                 homeTeamId: game.home.teamId, awayTeamId: game.away.teamId,
                                 isCorrect: nil, gradedAt: nil)
        }
        save()
    }
    
    func pickedTeamId(for game: HomeAway) -> String? {
        guard let gameId = game.gameId else { return nil }
        return picks[gameId]?.pickedTeamId
    }
    
    func pickCount(for date: String) -> Int {
        picks.values.filter { $0.date == date }.count
    }
    
    // MARK: - Grading (games 결과로 채점)
    
    /// 결과가 들어온 경기와 대조해 미채점 예측을 채점. 새로 채점된 건이 있으면 그날 요약을 갱신하고 true 반환
    @discardableResult
    func grade(with results: [GamesModel]) -> Bool {
        var gradedAny = false
        var gradedDates = Set<String>()
        let pending = picks.values.filter { $0.isCorrect == nil }
        print("PicksManager.grade: 예측 \(picks.count)건(미채점 \(pending.count)) vs 결과 \(results.count)일 \(results.reduce(0) { $0 + $1.items.count })경기")
        for day in results {
            for game in day.items {
                guard let gameId = game.gameId, var p = picks[gameId], p.isCorrect == nil,
                      let hs = Int(game.home.score ?? ""), let as_ = Int(game.away.score ?? ""), hs != as_ else { continue }
                let winner = hs > as_ ? game.home.teamId : game.away.teamId
                p.isCorrect = (winner == p.pickedTeamId)
                p.gradedAt = Date()
                picks[gameId] = p
                gradedAny = true
                gradedDates.insert(p.date)
            }
        }
        print("PicksManager.grade: 새로 채점 \(gradedAny ? gradedDates.sorted().description : "없음")")
        if gradedAny {
            // 가장 최근 채점된 날짜의 요약
            if let latest = gradedDates.max() {
                let dayPicks = picks.values.filter { $0.date == latest && $0.isCorrect != nil }
                lastGradedSummary = PicksDaySummary(date: latest, correct: dayPicks.filter { $0.isCorrect == true }.count, total: dayPicks.count)
            }
            save()
        }
        return gradedAny
    }
    
    // MARK: - Stats
    
    var wins: Int { picks.values.filter { $0.isCorrect == true }.count }
    var losses: Int { picks.values.filter { $0.isCorrect == false }.count }
    var gradedCount: Int { wins + losses }
    var accuracy: Double { gradedCount == 0 ? 0 : Double(wins) / Double(gradedCount) }
    
    /// 현재 연승 (채점된 예측을 날짜·경기ID 순으로 늘어놓고 끝에서부터 연속 적중 수)
    var currentStreak: Int {
        let ordered = picks.values.filter { $0.isCorrect != nil }.sorted { ($0.date, $0.gameId) < ($1.date, $1.gameId) }
        var streak = 0
        for p in ordered.reversed() {
            if p.isCorrect == true { streak += 1 } else { break }
        }
        return streak
    }
    
    var bestStreak: Int {
        let ordered = picks.values.filter { $0.isCorrect != nil }.sorted { ($0.date, $0.gameId) < ($1.date, $1.gameId) }
        var best = 0, run = 0
        for p in ordered {
            run = p.isCorrect == true ? run + 1 : 0
            best = max(best, run)
        }
        return best
    }
    
    // MARK: - Persistence
    
    private func load() {
        if let data = defaults.data(forKey: picksKey) {
            do {
                picks = try JSONDecoder().decode([String: Pick].self, from: data)
                print("PicksManager.load: \(picks.count)건 \(picks.values.map { "\($0.gameId):\($0.isCorrect.map { $0 ? "W" : "L" } ?? "-")" }.sorted())")
            } catch {
                print("❌ PicksManager: 저장된 예측 디코딩 실패: \(error)")
            }
        }
        if let data = defaults.data(forKey: summaryKey), let s = try? JSONDecoder().decode(PicksDaySummary.self, from: data) {
            lastGradedSummary = s
        }
    }
    
    private func save() {
        print("PicksManager.save: \(picks.count)건, summary=\(lastGradedSummary.map { "\($0.date) \($0.correct)/\($0.total)" } ?? "nil")")
        if let data = try? JSONEncoder().encode(picks) { defaults.set(data, forKey: picksKey) }
        if let s = lastGradedSummary, let data = try? JSONEncoder().encode(s) { defaults.set(data, forKey: summaryKey) }
    }
}
