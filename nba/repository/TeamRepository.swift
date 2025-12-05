//
//  TeamRepository.swift
//  nba
//
//  Created on 12/05/24.
//

import Foundation
import FirebaseFirestore
import Firebase

protocol TeamRepository {
    func fetchTeam(documentId: String) async throws -> TeamModel
    func fetchRoster(teamId: String) async throws -> [PlayerModel]
    func fetchPlayersByCountry(country: String) async throws -> [PlayerModel]
}

final class FirestoreTeamRepository: TeamRepository {
    private let db = Firestore.firestore()
    
    func fetchTeam(documentId: String) async throws -> TeamModel {
        return try await db.collection("teams").document(documentId).getDocument(as: TeamModel.self)
    }
    
    func fetchRoster(teamId: String) async throws -> [PlayerModel] {
        let seasonYear = SeasonProvider.shared.seasonYear()
        let snapshot = try await db.collection("players.\(seasonYear)")
            .whereField("teamId", isEqualTo: teamId)
            .whereField("retired", isEqualTo: false)
            .getDocuments()
        
        return snapshot.documents.compactMap { documentSnapshot in
            try? documentSnapshot.data(as: PlayerModel.self)
        }
    }
    
    func fetchPlayersByCountry(country: String) async throws -> [PlayerModel] {
        let seasonYear = SeasonProvider.shared.seasonYear()
        let snapshot = try await db.collection("players.\(seasonYear)")
            .whereField("country", isEqualTo: country)
            .whereField("retired", isEqualTo: false)
            .getDocuments()
        
        return snapshot.documents.compactMap { documentSnapshot in
            try? documentSnapshot.data(as: PlayerModel.self)
        }
    }
}
