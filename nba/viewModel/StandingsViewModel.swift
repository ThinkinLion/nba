//
//  StandingsViewModel.swift
//  nba
//
//  Created by 1100690 on 2023/11/09.
//

import Foundation
import FirebaseFirestoreSwift
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
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    func fetchStandings() {
        //        Task {
        //            await asyncFetch(documentId: "DeKhuCvwKF59FRfTmdom")
        //        }
        fetchStandings(documentId: seasonYear())
//        fetchGames(documentId: today())
//        fetchGames(documentId: "2024-01-03")
        fetchGameRecap()
        
        fetchStatsLeaders(documentId: seasonYear())
    }
    
    @MainActor
    private func asyncFetch(documentId: String) async {
        let docRef = db.collection("standings").document(documentId)
        do {
            self.standings = try await docRef.getDocument(as: StandingsModel.self)
        } catch {
            self.errorMessage = "Error decoding document: \(error.localizedDescription)"
        }
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
    private func fetchStandings(documentId: String) {
        guard !documentId.isEmpty else { return }
        db.collection("standings").document(documentId).getDocument(as: StandingsModel.self) { result in
            switch result {
            case .success(let standings):
                //                self.standings = standings
                //                print("fetchStandings: \(standings)")
                self.lastUpdated = standings.date?.lastUpdated ?? ""
                self.east = self.divideConferenceStandings(conference: standings.east)
                self.west = self.divideConferenceStandings(conference: standings.west)
                self.errorMessage = nil
            case .failure(let error):
                self.errorMessage = "Error decoding document: \(error.localizedDescription)"
            }
        }
    }
    
    func fetchGameRecap() {
        db.collection("games").order(by: "date", descending: true).limit(to: 7)
            .getDocuments() { (snapshot, error) in
                self.gameRecap = snapshot?.documents.compactMap { documentSnapshot in
                    let result = Result { try documentSnapshot.data(as: GamesModel.self) }
                    switch result {
                    case .success(let game):
                        self.errorMessage = nil
                        print("game recap: \(game.date ?? ""), \(game.items.count) game played..(\(String(describing: game.id))")
                        return game.items.count > 0 ? game : nil
                    case .failure(let error):
                        self.errorMessage = "Error decoding document: \(error.localizedDescription)"
                        return nil
                    }
                } ?? []
                
                let lastGameRecap = self.gameRecap.first
//                self.games = lastGameRecap?.items ?? []
                self.hasGames = lastGameRecap?.items.count ?? 0 > 0
        }
    }
    
    /*
     나중에 지우자
    private func fetchGames(documentId: String) {
        guard !documentId.isEmpty else { return }
        db.collection("games").document(documentId).getDocument(as: GamesModel.self) { result in
            switch result {
            case .success(let games):
                self.games = games.items
                self.hasGames = games.items.count > 0
            case .failure(let error):
                self.errorMessage = "Error decoding document: \(error.localizedDescription)"
            }
        }
    } */
    
    private func fetchStatsLeaders(documentId: String) {
        guard !documentId.isEmpty else { return }
        db.collection("statsLeaders").document(documentId).getDocument(as: SeasonLeadersModel.self) { result in
            switch result {
            case .success(let seasonLeaders):
//                print("fetchStatsLeaders: \(seasonLeaders)")
//                self.pointsPerGame = seasonLeaders.seasonLeadersPointsPerGame ?? .empty
//                self.assistsPerGame = seasonLeaders.seasonLeadersAssistsPerGame ?? .empty
//                self.reboundsPerGame = seasonLeaders.seasonLeadersReboundsPerGame ?? .empty
                self.shuffledSeasonLeaders(leaders: [seasonLeaders.seasonLeadersPointsPerGame ?? .empty,
                                                     seasonLeaders.seasonLeadersAssistsPerGame ?? .empty,
                                                     seasonLeaders.seasonLeadersReboundsPerGame ?? .empty,
                                                     
                                                     seasonLeaders.seasonLeadersBlocksPerGame ?? .empty,
                                                     seasonLeaders.seasonLeadersStealsPerGame ?? .empty,
                                                     seasonLeaders.seasonLeadersFieldGoalPercentage ?? .empty,
                                                     
                                                     seasonLeaders.seasonLeadersThreePointersMade ?? .empty,
                                                     seasonLeaders.seasonLeadersThreePointPercentage ?? .empty,
                                                     seasonLeaders.seasonLeadersFantasyPointsPerGame ?? .empty])
                
//                self.blocksPerGame = seasonLeaders.seasonLeadersBlocksPerGame ?? .empty
//                self.stealsPerGame = seasonLeaders.seasonLeadersStealsPerGame ?? .empty
//                self.fieldGoalPercentage = seasonLeaders.seasonLeadersFieldGoalPercentage ?? .empty
//                
//                self.threePointersMade = seasonLeaders.seasonLeadersThreePointersMade ?? .empty
//                self.threePointPercentage = seasonLeaders.seasonLeadersThreePointPercentage ?? .empty
//                self.fantasyPointsPerGame = seasonLeaders.seasonLeadersFantasyPointsPerGame ?? .empty
                
                self.rookiesMinutesPerGame = seasonLeaders.rookiesMinutesPerGame ?? .empty
                self.rookiesPointsPerGame = seasonLeaders.rookiesPointsPerGame ?? .empty
                self.rookiesDoubleDoubles = seasonLeaders.rookiesDoubleDoubles ?? .empty
                
                //season leaders etc
                self.seasonLeadersMostTotalPoints = seasonLeaders.seasonLeadersMostTotalPoints ?? .empty
                self.seasonLeadersMostPointsinaGame = seasonLeaders.seasonLeadersMostPointsinaGame ?? .empty
                self.seasonLeadersMostReboundsinaGame = seasonLeaders.seasonLeadersMostReboundsinaGame ?? .empty
                self.seasonLeadersMostAssistsinaGame = seasonLeaders.seasonLeadersMostAssistsinaGame ?? .empty
                self.seasonLeadersMostStealsinaGame = seasonLeaders.seasonLeadersMostStealsinaGame ?? .empty
                self.seasonLeadersMostBlocksinaGame = seasonLeaders.seasonLeadersMostBlocksinaGame ?? .empty
//                self.seasonLeadersHighestPercentageofPTS3PT = seasonLeaders.seasonLeadersHighestPercentageofPTS3PT ?? .empty
//                self.seasonLeadersHighestPercentageofPTS2PT = seasonLeaders.seasonLeadersHighestPercentageofPTS2PT ?? .empty
//                self.seasonLeadersHighestPercentageofPTSMidRange = seasonLeaders.seasonLeadersHighestPercentageofPTSMidRange ?? .empty
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
            case .failure(let error):
                self.errorMessage = "Error decoding document: \(error.localizedDescription)"
            }
        }
    }
}

extension StandingsViewModel {
    func addSampleItem() {
//        db.collection("nba").document("aa").setData(from: newItem)
        let collectionRef = db.collection("standings")
        do {
            let newDocReference = try collectionRef.addDocument(from: newItem)
            
            print("nba stored with new document reference: \(newDocReference)")
        } catch {
            print(error)
        }
    }
    
    func updateStandings() {
        if let id = standings.id {
            let docRef = db.collection("standings").document(id)
            do {
                try docRef.setData(from: standings)
            } catch {
                print(error)
            }
        }
    }
    
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
    func todayOfWeek() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: currentDate)
    }
    
    private func today() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: currentDate)
    }
    
    private func seasonYear() -> String {
        let currentDate = Date()
        let calendar = Calendar.current

        // 현재 년도
        let currentYear = calendar.component(.year, from: currentDate)

        // NBA 시즌이 10월에 시작하므로, 10월 이전이면 이전 년도를 반환
        if calendar.component(.month, from: currentDate) < 10 {
            return "\(currentYear - 1)"
        } else {
            return "\(currentYear)"
        }
    }
}
