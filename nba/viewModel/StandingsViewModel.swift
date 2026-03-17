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
    
    //Season Leaders
    @Published var firstCardViewSlot: SeasonLeaders = .empty
    @Published var secondCardViewSlot: SeasonLeaders = .empty
    @Published var thirdCardViewSlot: SeasonLeaders = .empty
    
//    @Published var pointsPerGame: SeasonLeaders = .empty
//    @Published var assistsPerGame: SeasonLeaders = .empty
//    @Published var reboundsPerGame: SeasonLeaders = .empty
    
    @Published var firstVStackSlot: SeasonLeaders = .empty
    @Published var secondVStackSlot: SeasonLeaders = .empty
    @Published var thirdVStackSlot: SeasonLeaders = .empty
    @Published var fourthVStackSlot: SeasonLeaders = .empty
    @Published var fifthVStackSlot: SeasonLeaders = .empty
    @Published var sixthVStackSlot: SeasonLeaders = .empty
//    @Published var blocksPerGame: SeasonLeaders = .empty
//    @Published var stealsPerGame: SeasonLeaders = .empty
//    @Published var fieldGoalPercentage: SeasonLeaders = .empty
//    
//    @Published var threePointersMade: SeasonLeaders = .empty
//    @Published var threePointPercentage: SeasonLeaders = .empty
//    @Published var fantasyPointsPerGame: SeasonLeaders = .empty
    
    @Published var rookiesMinutesPerGame: SeasonLeaders = .empty
    @Published var rookiesPointsPerGame: SeasonLeaders = .empty
    @Published var rookiesDoubleDoubles: SeasonLeaders = .empty
    
    //advanced, miscellaneous, player tracking passing, scoring, centers, forwards, guards, rookies, season leaders etc
    @Published var advanced: [SeasonLeaders] = []
    @Published var miscellaneous: [SeasonLeaders] = []
    @Published var playerTrackingPassing: [SeasonLeaders] = []
    @Published var scoring: [SeasonLeaders] = []
    @Published var centers: [SeasonLeaders] = []
    @Published var forwards: [SeasonLeaders] = []
    @Published var guards: [SeasonLeaders] = []
    @Published var rookies: [SeasonLeaders] = []
    @Published var seasonLeaderEtc: [SeasonLeaders] = []
    
    //season leaders etc
    @Published var seasonLeadersMostTotalPoints: SeasonLeaders = .empty
    @Published var seasonLeadersMostPointsinaGame: SeasonLeaders = .empty
    @Published var seasonLeadersMostReboundsinaGame: SeasonLeaders = .empty
    @Published var seasonLeadersMostAssistsinaGame: SeasonLeaders = .empty
    @Published var seasonLeadersMostStealsinaGame: SeasonLeaders = .empty
    @Published var seasonLeadersMostBlocksinaGame: SeasonLeaders = .empty
    @Published var seasonLeadersHighestPercentageofPTS3PT: SeasonLeaders = .empty
    @Published var seasonLeadersHighestPercentageofPTS2PT: SeasonLeaders = .empty
    @Published var seasonLeadersHighestPercentageofPTSMidRange: SeasonLeaders = .empty
    
    var errorMessage: String?
    
    private let standingsRepository: StandingsRepository
    private let powerRankingRepository: PowerRankingRepository
    
    init(standingsRepository: StandingsRepository = FirestoreStandingsRepository(),
         powerRankingRepository: PowerRankingRepository = FirestorePowerRankingRepository()) {
        self.standingsRepository = standingsRepository
        self.powerRankingRepository = powerRankingRepository
    }
    
    func fetchStandings() {
        Task {
            await fetchStandings(documentId: SeasonProvider.shared.seasonYear())
            await fetchGameRecap()
            await fetchStatsLeaders(documentId: SeasonProvider.shared.seasonYear())
            await fetchPowerRankings()
        }
    }
    
    @MainActor
    private func asyncFetch(documentId: String) async {
        // Legacy or unused? Keeping empty for now as it was in original
    }
}

extension StandingsViewModel {
    func shuffledSeasonLeaders(leaders: [SeasonLeaders]) {
        let shuffeld = leaders.shuffled()
        guard shuffeld.count >= 9 else { return }
        
        firstCardViewSlot = shuffeld[0]
        secondCardViewSlot = shuffeld[1]
        thirdCardViewSlot = shuffeld[2]
        
        firstVStackSlot = shuffeld[3]
        secondVStackSlot = shuffeld[4]
        thirdVStackSlot = shuffeld[5]
        
        fourthVStackSlot = shuffeld[6]
        fifthVStackSlot = shuffeld[7]
        sixthVStackSlot = shuffeld[8]
    }
}

extension StandingsViewModel {
    func fetchPowerRankings() async {
        do {
            let rankings = try await powerRankingRepository.fetchPowerRankings()
            await MainActor.run {
                self.powerRankings = rankings
                self.errorMessage = nil
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Error fetching power rankings: \(error.localizedDescription)"
            }
        }
    }
  
    private func fetchStandings(documentId: String) async {
        guard !documentId.isEmpty else { return }
        
        do {
            let standings = try await standingsRepository.fetchStandings(seasonYear: documentId)
            await MainActor.run {
                self.lastUpdated = standings.date?.lastUpdated ?? ""
                self.east = self.divideConferenceStandings(conference: standings.east)
                self.west = self.divideConferenceStandings(conference: standings.west)
                self.errorMessage = nil
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Error fetching standings: \(error.localizedDescription)"
            }
        }
    }
    
    func fetchGameRecap() async {
        do {
            let games = try await standingsRepository.fetchGameRecap()
            await MainActor.run {
                self.gameRecap = games
                let lastGameRecap = self.gameRecap.first
                self.hasGames = (lastGameRecap?.items.count ?? 0) > 0
                if let firstRecap = lastGameRecap {
                    self.updateDailyPerformers(for: firstRecap)
                }
                self.errorMessage = nil
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Error fetching game recap: \(error.localizedDescription)"
            }
        }
    }
    
    private func fetchStatsLeaders(documentId: String) async {
        guard !documentId.isEmpty else { return }
        
        do {
            let seasonLeaders = try await standingsRepository.fetchStatsLeaders(seasonYear: documentId)
            await MainActor.run {
                self.shuffledSeasonLeaders(leaders: [seasonLeaders.seasonLeadersPointsPerGame ?? .empty,
                                                     seasonLeaders.seasonLeadersAssistsPerGame ?? .empty,
                                                     seasonLeaders.seasonLeadersReboundsPerGame ?? .empty,
                                                     
                                                     seasonLeaders.seasonLeadersBlocksPerGame ?? .empty,
                                                     seasonLeaders.seasonLeadersStealsPerGame ?? .empty,
                                                     seasonLeaders.seasonLeadersFieldGoalPercentage ?? .empty,
                                                     
                                                     seasonLeaders.seasonLeadersThreePointersMade ?? .empty,
                                                     seasonLeaders.seasonLeadersThreePointPercentage ?? .empty,
                                                     seasonLeaders.seasonLeadersFantasyPointsPerGame ?? .empty])
                
                self.rookiesMinutesPerGame = seasonLeaders.rookiesMinutesPerGame ?? .empty
                self.rookiesPointsPerGame = seasonLeaders.rookiesPointsPerGame ?? .empty
                self.rookiesDoubleDoubles = seasonLeaders.rookiesDoubleDoubles ?? .empty
                
                self.seasonLeadersMostTotalPoints = seasonLeaders.seasonLeadersMostTotalPoints ?? .empty
                self.seasonLeadersMostPointsinaGame = seasonLeaders.seasonLeadersMostPointsinaGame ?? .empty
                self.seasonLeadersMostReboundsinaGame = seasonLeaders.seasonLeadersMostReboundsinaGame ?? .empty
                self.seasonLeadersMostAssistsinaGame = seasonLeaders.seasonLeadersMostAssistsinaGame ?? .empty
                self.seasonLeadersMostStealsinaGame = seasonLeaders.seasonLeadersMostStealsinaGame ?? .empty
                self.seasonLeadersMostBlocksinaGame = seasonLeaders.seasonLeadersMostBlocksinaGame ?? .empty
                
                self.seasonLeaderEtc = [
                    seasonLeaders.seasonLeadersHighestPercentageofPTS3PT ?? .empty,
                    seasonLeaders.seasonLeadersHighestPercentageofPTS2PT ?? .empty,
                    seasonLeaders.seasonLeadersHighestPercentageofPTSMidRange ?? .empty,
                ]
                
                self.advanced = [
                    seasonLeaders.advancedUsagePercentage ?? .empty,
                    seasonLeaders.advancedTrueShootingPercentage ?? .empty,
                    seasonLeaders.advancedOffensiveReboundPercentage ?? .empty
                ]
                
                self.miscellaneous = [
                    seasonLeaders.miscellaneous2ndChancePointsPerGame ?? .empty,
                    seasonLeaders.miscellaneousFastBreakPointsPerGame ?? .empty,
                    seasonLeaders.miscellaneousPointsInThePaintPerGame ?? .empty,
                ]
                
                self.playerTrackingPassing = [
                    seasonLeaders.playerTrackingPassingPassesPerGame ?? .empty,
                    seasonLeaders.playerTrackingPassingPotentialAssistsPerGame ?? .empty,
                    seasonLeaders.playerTrackingPassingPointsFromAssistsPerGame ?? .empty,
                ]
                
                self.scoring = [
                    seasonLeaders.scoringPercentageofPoints3PT ?? .empty,
                    seasonLeaders.scoringPercentageofPointsinthePaint ?? .empty,
                    seasonLeaders.scoringPercentageofPointsMidRange ?? .empty,
                ]
                
                self.centers = [
                    seasonLeaders.centersPointsPerGame ?? .empty,
                    seasonLeaders.centersAssistsPerGame ?? .empty,
                    seasonLeaders.centersReboundsPerGame ?? .empty,
                ]
                
                self.forwards = [
                    seasonLeaders.forwardsPointsPerGame ?? .empty,
                    seasonLeaders.forwardsAssistsPerGame ?? .empty,
                    seasonLeaders.forwardsReboundsPerGame ?? .empty
                ]
                
                self.guards = [
                    seasonLeaders.guardsPointsPerGame ?? .empty,
                    seasonLeaders.guardsAssistsPerGame ?? .empty,
                    seasonLeaders.guardsReboundsPerGame ?? .empty,
                ]
                
                self.rookies = [
                    seasonLeaders.rookiesDoubleDoubles ?? .empty,
                    seasonLeaders.rookiesPointsPerGame ?? .empty,
                    seasonLeaders.rookiesMinutesPerGame ?? .empty,
                ]
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Error fetching stats leaders: \(error.localizedDescription)"
            }
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
                    teamCode: match.away.teamCode,
                    opponentTriCode: match.home.teamCode.nickNameToTriCode,
                    gameDate: games.date ?? "",
                    score: score,
                    gameScoreText: scoreText,
                    gameResultText: resultText,
                    game: match
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
                    teamCode: match.home.teamCode,
                    opponentTriCode: match.away.teamCode.nickNameToTriCode,
                    gameDate: games.date ?? "",
                    score: score,
                    gameScoreText: scoreText,
                    gameResultText: resultText,
                    game: match
                ))
            }
        }
        
        // Sort by score descending
        let sorted = performances.sorted { $0.score > $1.score }
        
        if let best = sorted.first {
            self.dailyPerformer = best
            // Next 4 as candidates
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
    let teamCode: String // Nickname
    let opponentTriCode: String // VS Team
    let gameDate: String
    let score: Int // Efficiency Score
    let gameScoreText: String // "110 - 105"
    let gameResultText: String // "W 110 - 105"
    let game: HomeAway // The Full Game Object for navigation
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

