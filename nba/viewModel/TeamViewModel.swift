//
//  TeamViewModel.swift
//  nba
//
//  Created by 1100690 on 12/22/23.
//

import SwiftUI
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
        let seasonYear = SeasonProvider.shared.seasonYear()
        db.collection("players.\(seasonYear)").whereField("teamId", isEqualTo: teamId)
            .whereField("retired", isEqualTo: false)
//            .whereField("pie", isGreaterThanOrEqualTo: 5)
//            .whereField("position", isEqualTo: "Guard")
            .getDocuments() { (snapshot, error) in
                self.roster = snapshot?.documents.compactMap { documentSnapshot in
                    let result = Result { try documentSnapshot.data(as: PlayerModel.self) }
                    switch result {
                    case .success(let playerModel):
                        self.errorMessage = nil
                      print("roster: \(playerModel.lastName ?? ""), retired: \(String(describing: playerModel.retired)),  pie: \(String(describing: playerModel.advanced?.first?.pie))")
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
    
    var teamId: String {
        team.teamId
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

extension TeamStatsViewModel {
  //stats
  var stats: [TeamStats] {
      team.stats ?? []
  }
  
  var currentSeasonStats: [PlayerStatsItemViewModel] {
      stats.first { $0.title == "2023-24" }
          .map {
              makeTeamStatsItemViewModels(with: $0)
          } ?? []
  }
  
  var homeStats: TeamStats? {
      stats.first { $0.title == "Home" }
  }
  
  var roadStats: TeamStats? {
      stats.first { $0.title == "Road" }
  }
  
  private func makeTeamStatsItemViewModels(with teamStats: TeamStats) -> [PlayerStatsItemViewModel] {
    guard teamId.count >= 10 else { return [] }
    let transformed = Transform.transformTeamId(teamId)
//        print("transformed: \(transformed)")
    return [
      PlayerStatsItemViewModel(title: "GP", value: teamStats.gp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(0))),
      PlayerStatsItemViewModel(title: "MIN", value: teamStats.min ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
      PlayerStatsItemViewModel(title: "PTS", value: teamStats.pts ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
      PlayerStatsItemViewModel(title: "WIN", value: teamStats.win ?? "", colors: Transform.randomColors(transformed.characterAtIndex(3))),
      PlayerStatsItemViewModel(title: "LOSS", value: teamStats.loss ?? "", colors: Transform.randomColors(transformed.characterAtIndex(3))),
      PlayerStatsItemViewModel(title: "WIN%", value: teamStats.wp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(3))),
      PlayerStatsItemViewModel(title: "FGM", value: teamStats.fgm ?? "", colors: Transform.randomColors(transformed.characterAtIndex(4))),
      PlayerStatsItemViewModel(title: "FGA", value: teamStats.fga ?? "", colors: Transform.randomColors(transformed.characterAtIndex(4))),
      PlayerStatsItemViewModel(title: "FG%", value: teamStats.fgp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(4))),
      PlayerStatsItemViewModel(title: "3PM", value: teamStats.tpm ?? "", colors: Transform.randomColors(transformed.characterAtIndex(5))),
      PlayerStatsItemViewModel(title: "3PA", value: teamStats.tpa ?? "", colors: Transform.randomColors(transformed.characterAtIndex(5))),
      PlayerStatsItemViewModel(title: "3P%", value: teamStats.tpp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(5))),
        
      PlayerStatsItemViewModel(title: "FTM", value: teamStats.ftm ?? "", colors: Transform.randomColors(transformed.characterAtIndex(6))),
      PlayerStatsItemViewModel(title: "FTA", value: teamStats.fta ?? "", colors: Transform.randomColors(transformed.characterAtIndex(6))),
      PlayerStatsItemViewModel(title: "FT%", value: teamStats.ftp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(6))),
      PlayerStatsItemViewModel(title: "OREB", value: teamStats.oreb ?? "", colors: Transform.randomColors(transformed.characterAtIndex(7))),
      PlayerStatsItemViewModel(title: "DREB", value: teamStats.dreb ?? "", colors: Transform.randomColors(transformed.characterAtIndex(7))),
      PlayerStatsItemViewModel(title: "REB", value: teamStats.reb ?? "", colors: Transform.randomColors(transformed.characterAtIndex(7))),
      PlayerStatsItemViewModel(title: "AST", value: teamStats.ast ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
      PlayerStatsItemViewModel(title: "TOV", value: teamStats.tov ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
      PlayerStatsItemViewModel(title: "STL", value: teamStats.stl ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
      PlayerStatsItemViewModel(title: "BLK", value: teamStats.blk ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
      PlayerStatsItemViewModel(title: "PF", value: teamStats.pf ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
      PlayerStatsItemViewModel(title: "+/-", value: teamStats.pm ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
        
    ]
  }
}
