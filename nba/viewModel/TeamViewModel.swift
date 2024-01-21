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
    var roster = [PlayerModel]()
    @Published var guardsInRoster = [PlayerModel]()
    @Published var forwardsInRoster = [PlayerModel]()
    @Published var centersInRoster = [PlayerModel]()
    var errorMessage: String?
    
    private var db = Firestore.firestore()
}

extension TeamViewModel {
    func fetchTeam(documentId: String) {
        guard !documentId.isEmpty else { return }
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
        guard !teamId.isEmpty else { return }
        db.collection("players").whereField("teamId", isEqualTo: teamId)
//            .whereField("pie", isGreaterThanOrEqualTo: 5)
//            .whereField("position", isEqualTo: "Guard")
            .getDocuments() { (snapshot, error) in
                self.roster = snapshot?.documents.compactMap { documentSnapshot in
                    let result = Result { try documentSnapshot.data(as: PlayerModel.self) }
                    switch result {
                    case .success(let playerModel):
                        self.errorMessage = nil
                        print("roster: \(playerModel.lastName ?? ""), \(playerModel)")
                        return playerModel
                    case .failure(let error):
                        self.errorMessage = "Error decoding document: \(error.localizedDescription)"
                        return nil
                    }
                } ?? []
                self.guardsInRoster = self.classifyByPosition(postion: "G", roster: self.roster)
                self.forwardsInRoster = self.classifyByPosition(postion: "F", roster: self.roster)
                self.centersInRoster = self.classifyByPosition(postion: "C", roster: self.roster)
        }
    }
    
    func classifyByPosition(postion: String, roster: [PlayerModel]) -> [PlayerModel] {
        roster.filter { $0.position?.hasPrefix(postion) ?? false }
    }
}

struct TeamStatsViewModel {
    private let team: TeamModel
    
    init(team: TeamModel) {
        self.team = team
    }
    
    //rank
    var conferenceRankFullName: String {
        guard !conference.isEmpty else { return "" }
        return conferenceRank.ordinal + " in " + conference
    }
    
    var conferenceRank: String {
        team.confRank ?? ""
    }
    
    var conference: String {
        team.conference ?? ""
    }
    
    //ppg
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
    
    //apg
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
    
    //rpg
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
    
    //oppg
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
