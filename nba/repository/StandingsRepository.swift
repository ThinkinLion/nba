//
//  StandingsRepository.swift
//  nba
//
//  Created on 12/05/24.
//

import Foundation
import FirebaseFirestore
import Firebase

protocol StandingsRepository {
    func fetchStandings(seasonYear: String) async throws -> StandingsModel
    func fetchGameRecap() async throws -> [GamesModel]
    func fetchStatsLeaders(seasonYear: String) async throws -> SeasonLeadersModel
}

final class FirestoreStandingsRepository: StandingsRepository {
    private let db = Firestore.firestore()
    
    func fetchStandings(seasonYear: String) async throws -> StandingsModel {
        return try await db.collection("standings").document(seasonYear).getDocument(as: StandingsModel.self)
    }
    
    func fetchGameRecap() async throws -> [GamesModel] {
        let snapshot = try await db.collection("games")
            .order(by: "date", descending: true)
            .limit(to: 60)
            .getDocuments()
        
        return snapshot.documents.compactMap { documentSnapshot in
            guard let game = try? documentSnapshot.data(as: GamesModel.self) else { return nil }
            return game.items.count > 0 ? game : nil
        }
    }
    
    func fetchStatsLeaders(seasonYear: String) async throws -> SeasonLeadersModel {
        return try await db.collection("statsLeaders").document(seasonYear).getDocument(as: SeasonLeadersModel.self)
    }
}
