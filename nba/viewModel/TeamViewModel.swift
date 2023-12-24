//
//  TeamViewModel.swift
//  nba
//
//  Created by 1100690 on 12/22/23.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase

final class TeamViewModel: ObservableObject {
    @Published var team = TeamModel.empty
    @Published var roster = [PlayerModel]()
    var errorMessage: String?
    
    private var db = Firestore.firestore()
}

extension TeamViewModel {
    func fetchTeam(documentId: String) {
        db.collection("teams").document(documentId).getDocument(as: TeamModel.self) { result in
            switch result {
            case .success(let team):
                print("team: \(team)")
                self.team = team
                self.errorMessage = nil
            case .failure(let error):
                self.errorMessage = "Error decoding document: \(error.localizedDescription)"
            }
        }
    }
    
    func fetchRoster(teamId: String) {
        db.collection("players").whereField("teamId", isEqualTo: teamId)
//            .whereField("pie", isGreaterThanOrEqualTo: 5)
//            .whereField("position", isEqualTo: "Guard")
            .getDocuments() { (snapshot, error) in
            self.roster = snapshot?.documents.compactMap { documentSnapshot in
                let result = Result { try documentSnapshot.data(as: PlayerModel.self) }
                switch result {
                case .success(let playerModel):
                    self.errorMessage = nil
                    print("roster: \(playerModel.firstName ?? ""), \(playerModel.lastName ?? "")")
                    return playerModel
                case .failure(let error):
                    self.errorMessage = "Error decoding document: \(error.localizedDescription)"
                    return nil
                }
            } ?? []
        }
    }
}

struct TeamStatsViewModel {
    private let team: TeamModel
    
    init(team: TeamModel) {
        self.team = team
    }
    
    var ppgTitle: String {
        "PPG"
    }
    
    var ppg: String {
        team.ppg ?? ""
    }
    
    var ppgRank: String {
        guard let ppgRank = team.ppgRank else { return "" }
        guard !ppgRank.isEmpty else { return "" }
        return ppgRank
    }
    
    var apgTitle: String {
        "APG"
    }
    
    var apg: String {
        team.apg ?? ""
    }
    
    var apgRank: String {
        guard let apgRank = team.apgRank else { return "" }
        guard !apgRank.isEmpty else { return "" }
        return apgRank
    }
    
    var rpgTitle: String {
        "RPG"
    }
    
    var rpg: String {
        team.rpg ?? ""
    }
    
    var rpgRank: String {
        guard let rpgRank = team.rpgRank else { return "" }
        guard !rpgRank.isEmpty else { return "" }
        return rpgRank
    }
    
    var oppgTitle: String {
        "OPPG"
    }
    
    var oppg: String {
        team.oppg ?? ""
    }
    
    var oppgRank: String {
        guard let oppgRank = team.oppgRank else { return "" }
        guard !oppgRank.isEmpty else { return "" }
        return oppgRank
    }
}
