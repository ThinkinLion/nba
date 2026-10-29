//
//  StandingsViewModel.swift
//  nba
//
//  Created by 1100690 on 2023/11/09.
//

import Foundation
import FirebaseFirestore
import Firebase

final class StandingsViewModel: ObservableObject {
    @Published var standings = StandingsModel.empty
    @Published var newItem = StandingsModel.sample
    @Published var lastUpdated = ""
    @Published var east: ([StandingsTeam], [StandingsTeam], [StandingsTeam]) = ([], [], [])
    @Published var west: ([StandingsTeam], [StandingsTeam], [StandingsTeam]) = ([], [], [])
    
    @Published var roster = [PlayerModel]()
//    @Published var gameRecap: [GamesModel] = []
    @Published var gameRecap: [GamesModel] = []
//    @Published var games: [HomeAway] = []
    @Published var hasGames: Bool = false
    @Published var powerRankings: [PowerRankingModel] = []
    @Published var dailyPerformer: DailyPerformer? = nil
    @Published var dailyCandidates: [DailyPerformer] = []
    
    var errorMessage: String?
    
    private let standingsRepository: StandingsRepository
    private let powerRankingRepository: PowerRankingRepository
    
    init(standingsRepository: StandingsRepository = FirestoreStandingsRepository(),
         powerRankingRepository: PowerRankingRepository = FirestorePowerRankingRepository()) {
        self.standingsRepository = standingsRepository
        self.powerRankingRepository = powerRankingRepository
    }
    
    func fetchStandings(forceRefresh: Bool = false) {
        Task {
            await fetchStandingsAsync(forceRefresh: forceRefresh)
        }
    }
    
    /// Aggregated refresh. Uses `NBAFirestoreDayCache` (24h) per resource unless `forceRefresh` (e.g. pull-to-refresh).
    func fetchStandingsAsync(forceRefresh: Bool = false) async {
        let season = SeasonProvider.shared.seasonYear()
        await fetchStandings(documentId: season, forceRefresh: forceRefresh)
        await fetchGameRecap(forceRefresh: forceRefresh)
        await fetchPowerRankings(forceRefresh: forceRefresh)
    }

    
    @MainActor
    private func asyncFetch(documentId: String) async {
        // Legacy or unused? Keeping empty for now as it was in original
    }
}

extension StandingsViewModel {
    func fetchPowerRankings(forceRefresh: Bool = false) async {
        let cacheKey = "powerRankings.list"
        if !forceRefresh, let cached = NBAFirestoreDayCache.load([PowerRankingModel].self, key: cacheKey) {
            await MainActor.run {
                self.powerRankings = cached
                self.errorMessage = nil
            }
            return
        }
        do {
            let rankings = try await powerRankingRepository.fetchPowerRankings()
            await MainActor.run {
                self.powerRankings = rankings
                self.errorMessage = nil
            }
            NBAFirestoreDayCache.save(rankings, key: cacheKey)
        } catch {
            await MainActor.run {
                self.errorMessage = "Error fetching power rankings: \(error.localizedDescription)"
            }
        }
    }
  
    private func fetchStandings(documentId: String, forceRefresh: Bool) async {
        guard !documentId.isEmpty else { return }
        let cacheKey = "standings.\(documentId)"
        if !forceRefresh, let cached = NBAFirestoreDayCache.load(StandingsModel.self, key: cacheKey) {
            await MainActor.run { applyStandings(cached) }
            return
        }
        do {
            let standings = try await standingsRepository.fetchStandings(seasonYear: documentId)
            await MainActor.run {
                applyStandings(standings)
                self.errorMessage = nil
            }
            NBAFirestoreDayCache.save(standings, key: cacheKey)
        } catch {
            await MainActor.run {
                self.errorMessage = "Error fetching standings: \(error.localizedDescription)"
            }
        }
    }
    
    func fetchGameRecap(forceRefresh: Bool = false) async {
        let cacheKey = "gameRecap"
        if !forceRefresh, let cached = NBAFirestoreDayCache.load([GamesModel].self, key: cacheKey) {
            await MainActor.run { applyGameRecap(cached) }
            return
        }
        do {
            let games = try await standingsRepository.fetchGameRecap()
            await MainActor.run {
                applyGameRecap(games)
                self.errorMessage = nil
            }
            NBAFirestoreDayCache.save(games, key: cacheKey)
        } catch {
            await MainActor.run {
                self.errorMessage = "Error fetching game recap: \(error.localizedDescription)"
            }
        }
    }
    
    private func applyStandings(_ standings: StandingsModel) {
        self.standings = standings
        self.lastUpdated = standings.date?.lastUpdated ?? ""
        self.east = self.divideConferenceStandings(conference: standings.east)
        self.west = self.divideConferenceStandings(conference: standings.west)
    }
    
    private func applyGameRecap(_ games: [GamesModel]) {
        self.gameRecap = games
        let lastGameRecap = self.gameRecap.first
        self.hasGames = (lastGameRecap?.items.count ?? 0) > 0
        if let firstRecap = lastGameRecap {
            self.updateDailyPerformers(for: firstRecap)
        }
    }
    
}

/*
extension StandingsViewModel {
    func addSampleItem() {
//        db.collection("nba").document("aa").setData(from: newItem)
        let collectionRef = Firestore.firestore().collection("standings")
        do {
            // newItem is not defined in this scope, so this code was likely broken or incomplete.
            // let newDocReference = try collectionRef.addDocument(from: newItem)
            
            // print("nba stored with new document reference: \(newDocReference)")
        } catch {
            print(error)
        }
    }
    
    func updateStandings() {
        if let id = standings.id {
            let docRef = Firestore.firestore().collection("standings").document(id)
            do {
                try docRef.setData(from: standings)
            } catch {
                print(error)
            }
        }
    }
}
*/    
extension StandingsViewModel {
    func divideConferenceStandings(conference: [StandingsTeam]) -> ([StandingsTeam], [StandingsTeam], [StandingsTeam]) {
        guard conference.count == 15 else { return ([], [], []) }
        
        // 배열을 나누고자 하는 각 섹션의 길이
        let sectionLengths = [6, 4, 5]
        
        // 배열을 나누어서 튜플로 반환
        let dividedSections = sectionLengths.reduce(into: ([StandingsTeam](), [StandingsTeam](), [StandingsTeam]())) { result, length in
            var startIndex = result.0.count
            if !result.0.isEmpty && !result.1.isEmpty {
                startIndex = result.0.count + result.1.count
            }
            
            let endIndex = startIndex + length
            let section = Array(conference[startIndex..<endIndex])
            
            if result.0.isEmpty {
                result.0 = section
            } else if result.1.isEmpty {
                result.1 = section
            } else {
                result.2 = section
            }
        }
        
        return dividedSections
    }
}

extension StandingsViewModel {

    func updateDailyPerformers(for games: GamesModel) {
        var performances: [DailyPerformer] = []
        
        for match in games.items {
            // Helper to format score: "110 - 105"
            let awayScore = Int(match.away.score ?? "0") ?? 0
            let homeScore = Int(match.home.score ?? "0") ?? 0
            let scoreText = "\(match.away.score ?? "0") - \(match.home.score ?? "0")"
            
            // Check Away Leader
            if let leader = match.away.leader, let pts = Int(leader.pts ?? "0") {
                let reb = Int(leader.reb ?? "0") ?? 0
                let ast = Int(leader.ast ?? "0") ?? 0
                let stl = Int(leader.stl ?? "0") ?? 0
                let blk = Int(leader.blk ?? "0") ?? 0
                let score = pts + reb + ast + stl + blk
                
                let isWin = awayScore > homeScore
                let resultText = (isWin ? "W " : "L ") + scoreText
                
                performances.append(DailyPerformer(
                    player: leader,
                    teamId: match.away.teamId,
                    teamCode: match.away.teamCode,
                    opponentTriCode: match.home.teamCode.nickNameToTriCode,
                    gameDate: games.date ?? "",
                    score: score,
                    gameScoreText: scoreText,
                    gameResultText: resultText,
                    game: match,
                    isWin: isWin
                ))
            }
            
            // Check Home Leader
            if let leader = match.home.leader, let pts = Int(leader.pts ?? "0") {
                let reb = Int(leader.reb ?? "0") ?? 0
                let ast = Int(leader.ast ?? "0") ?? 0
                let stl = Int(leader.stl ?? "0") ?? 0
                let blk = Int(leader.blk ?? "0") ?? 0
                let score = pts + reb + ast + stl + blk
                
                let isWin = homeScore > awayScore
                let resultText = (isWin ? "W " : "L ") + scoreText
                
                performances.append(DailyPerformer(
                    player: leader,
                    teamId: match.home.teamId,
                    teamCode: match.home.teamCode,
                    opponentTriCode: match.away.teamCode.nickNameToTriCode,
                    gameDate: games.date ?? "",
                    score: score,
                    gameScoreText: scoreText,
                    gameResultText: resultText,
                    game: match,
                    isWin: isWin
                ))
            }
        }
        
        // 1. 점수(score) 내림차순 정렬
        let sorted = performances.sorted { $0.score > $1.score }
        
        // 2. 1위 POTN은 '팀 승리(isWin)' 선수 중에서 최고 활약자 선발 (승리팀 우선 원칙)
        if let bestWinner = sorted.first(where: { $0.isWin }) {
            self.dailyPerformer = bestWinner
            // 후보군(Runners Up): 1위를 제외한 상위 4명 (패배팀 에이스의 괴물 스탯도 후보군엔 포함 가능)
            self.dailyCandidates = Array(sorted.filter { $0.id != bestWinner.id }.prefix(4))
        } else if let best = sorted.first {
            // 승패 구분이 없거나 특이 케이스 fallback
            self.dailyPerformer = best
            self.dailyCandidates = Array(sorted.dropFirst().prefix(4))
        } else {
            self.dailyPerformer = nil
            self.dailyCandidates = []
        }
    }
}

struct DailyPerformer: Identifiable {
    var id: String { player.id.uuidString }
    let player: BoxScore
    let teamId: String // 소속 팀 ID (boxscore leader에는 teamId가 없어 경기 팀 정보에서 보완)
    let teamCode: String // Nickname
    let opponentTriCode: String // VS Team
    let gameDate: String
    let score: Int // Efficiency Score
    let gameScoreText: String // "110 - 105"
    let gameResultText: String // "W 110 - 105"
    let game: HomeAway // The Full Game Object for navigation
    let isWin: Bool
}

import SwiftUI

extension StandingsViewModel {
    
    // MARK: - Business Logic for View
    
    func rankColor(rank: String) -> Color {
        guard let rankInt = Int(rank) else { return .white }
        if rankInt <= 10 { return .white } // Playoff & Play-in (Active)
        return .gray.opacity(0.5) // Lottery (Faded)
    }
    
    func rankIndicatorColor(rank: String) -> Color {
        guard let rankInt = Int(rank) else { return .clear }
        if rankInt <= 6 { return .green } // Guaranteed Playoff
        if rankInt <= 10 { return .yellow } // Play-in Tournament
        return .clear
    }
    
    func createTeamState(from team: StandingsTeam, powerRankings: [PowerRankingTeamModel]?) -> TeamState {
        let triCode = team.teamCode.nickNameToTriCode
        let backgroundColorName = PowerRankingFormatter.makeBackgroundColorName(from: team.teamCode)
        
        // 1. Try to find the actual PowerRanking model for this team
        var realModel: PowerRankingTeamModel? = nil
        
        if let currentItems = powerRankings {
            // Match by ID
            if let match = currentItems.first(where: { $0.id == team.teamId }) {
                realModel = match
            }
            // Match by TriCode
            else if !triCode.isEmpty, let match = currentItems.first(where: { $0.teamCode == triCode || $0.teamCode?.nickNameToTriCode == triCode }) {
                realModel = match
            }
        }
        
        // 2. Use real model if found, otherwise fallback to dummy
        if let model = realModel {
            // Apply real data
             let rankChange = PowerRankingFormatter.makeRankChange(from: model.lastWeek)
             
             return TeamState(
                 id: model.id ?? team.teamId,
                 displayRank: Int(team.confRank) ?? 0,
                 name: PowerRankingFormatter.makeDisplayName(from: model), // Use formatted name
                 record: "\(team.win)-\(team.loss)",
                 rankChangeText: rankChange.text,
                 rankChangeStyle: rankChange.style,
                 triCode: triCode.isEmpty ? nil : triCode,
                 backgroundColorName: backgroundColorName,
                 model: model,
                 isFromStandings: true
             )
        } else {
            // Fallback Dummy
            let dummyModel = PowerRankingTeamModel(
                id: team.teamId,
                rank: team.confRank,
                record: "\(team.win)-\(team.loss)",
                teamName: team.teamName,
                teamCode: team.teamCode,
                lastWeek: nil,
                advanced: nil,
                overview: nil,
                takeaways: nil,
                upcomming: nil
            )
            
            return TeamState(
                id: team.teamId,
                displayRank: Int(team.confRank) ?? 0,
                name: team.teamName,
                record: "\(team.win)-\(team.loss)",
                rankChangeText: "-",
                rankChangeStyle: .same,
                triCode: triCode.isEmpty ? nil : triCode,
                backgroundColorName: backgroundColorName,
                model: dummyModel,
                isFromStandings: true
            )
        }
    }
}

