//
//  PowerRankingRepository.swift
//  nba
//
//  Created on 12/05/24.
//

import Foundation
import FirebaseFirestore
import Firebase

protocol PowerRankingRepository {
    func fetchPowerRankings() async throws -> [PowerRankingModel]
    func fetchPowerRanking(week: String) async throws -> PowerRankingModel?
    func fetchRecentGames(teamId: String) async throws -> [HomeAway]
}

final class FirestorePowerRankingRepository: PowerRankingRepository {
    private let db = Firestore.firestore()
    
    func fetchPowerRankings() async throws -> [PowerRankingModel] {
        let snapshot = try await db.collection("powerRankings.2025")
            .order(by: "week", descending: true)
//            .limit(to: 2)
            .getDocuments()
        
        return snapshot.documents.compactMap { documentSnapshot in
            guard let powerRanking = try? documentSnapshot.data(as: PowerRankingModel.self) else { return nil }
            return (powerRanking.items?.count ?? 0) > 0 ? powerRanking : nil
        }
    }
    
    func fetchPowerRanking(week: String) async throws -> PowerRankingModel? {
        let snapshot = try await db.collection("powerRankings.2025")
            .whereField("week", isEqualTo: week)
            .limit(to: 1)
            .getDocuments()
        
        guard let document = snapshot.documents.first else { return nil }
        let powerRanking = try document.data(as: PowerRankingModel.self)
        return (powerRanking.items?.count ?? 0) > 0 ? powerRanking : nil
    }
    
    func fetchRecentGames(teamId: String) async throws -> [HomeAway] {
        let snapshot = try await db.collection("games")
            .order(by: "date", descending: true)
            .limit(to: 10)
            .getDocuments()
        
        var allGames: [HomeAway] = []
        
        for document in snapshot.documents {
            if let gamesModel = try? document.data(as: GamesModel.self) {
                // 해당 팀이 참여한 경기만 필터링
                let teamGames = gamesModel.items.filter { game in
                    game.home.teamId == teamId || game.away.teamId == teamId
                }
                allGames.append(contentsOf: teamGames)
            }
        }
        
        // 최근 5경기만 반환
        return Array(allGames.prefix(5))
    }
}
