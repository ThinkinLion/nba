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
    
    //stats
    var stats: [TeamStats] {
        team.stats ?? []
    }
    
    var currentSeasonStats: [TeamStatsItemViewModel] {
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
}

extension TeamStatsViewModel {
    private func makeTeamStatsItemViewModels(with teamStats: TeamStats) -> [TeamStatsItemViewModel] {
//        print("randomcolor: \(randomColors(teamId)), \(teamId)")
        //teamId
        //1610 6127 37 >> 8387 3894 04
        //1610 6127 38 >> 9498 4905 16
        //1610 6127 66 >> 7376 2793 22
        let transformed = transformTeamId(teamId)
        print("transformed: \(transformed)")
        return [
            TeamStatsItemViewModel(title: "GP", value: teamStats.gp ?? "", colors: randomColors(transformed.characterAtIndex(0))),
            TeamStatsItemViewModel(title: "MIN", value: teamStats.min ?? "", colors: randomColors(transformed.characterAtIndex(1))),
            TeamStatsItemViewModel(title: "PTS", value: teamStats.pts ?? "", colors: randomColors(transformed.characterAtIndex(2))),
            TeamStatsItemViewModel(title: "WIN", value: teamStats.win ?? "", colors: randomColors(transformed.characterAtIndex(3))),
            TeamStatsItemViewModel(title: "LOSS", value: teamStats.loss ?? "", colors: randomColors(transformed.characterAtIndex(3))),
            TeamStatsItemViewModel(title: "WIN%", value: teamStats.wp ?? "", colors: randomColors(transformed.characterAtIndex(3))),
            TeamStatsItemViewModel(title: "FGM", value: teamStats.fgm ?? "", colors: randomColors(transformed.characterAtIndex(4))),
            TeamStatsItemViewModel(title: "FGA", value: teamStats.fga ?? "", colors: randomColors(transformed.characterAtIndex(4))),
            TeamStatsItemViewModel(title: "FG%", value: teamStats.fgp ?? "", colors: randomColors(transformed.characterAtIndex(4))),
            TeamStatsItemViewModel(title: "3PM", value: teamStats.tpm ?? "", colors: randomColors(transformed.characterAtIndex(5))),
            TeamStatsItemViewModel(title: "3PA", value: teamStats.tpa ?? "", colors: randomColors(transformed.characterAtIndex(5))),
            TeamStatsItemViewModel(title: "3P%", value: teamStats.tpp ?? "", colors: randomColors(transformed.characterAtIndex(5))),
            
            TeamStatsItemViewModel(title: "FTM", value: teamStats.ftm ?? "", colors: randomColors(transformed.characterAtIndex(6))),
            TeamStatsItemViewModel(title: "FTA", value: teamStats.fta ?? "", colors: randomColors(transformed.characterAtIndex(6))),
            TeamStatsItemViewModel(title: "FT%", value: teamStats.ftp ?? "", colors: randomColors(transformed.characterAtIndex(6))),
            TeamStatsItemViewModel(title: "OREB", value: teamStats.oreb ?? "", colors: randomColors(transformed.characterAtIndex(7))),
            TeamStatsItemViewModel(title: "DREB", value: teamStats.dreb ?? "", colors: randomColors(transformed.characterAtIndex(7))),
            TeamStatsItemViewModel(title: "REB", value: teamStats.reb ?? "", colors: randomColors(transformed.characterAtIndex(7))),
            TeamStatsItemViewModel(title: "AST", value: teamStats.ast ?? "", colors: randomColors(transformed.characterAtIndex(8))),
            TeamStatsItemViewModel(title: "TOV", value: teamStats.tov ?? "", colors: randomColors(transformed.characterAtIndex(8))),
            TeamStatsItemViewModel(title: "STL", value: teamStats.stl ?? "", colors: randomColors(transformed.characterAtIndex(8))),
            TeamStatsItemViewModel(title: "BLK", value: teamStats.blk ?? "", colors: randomColors(transformed.characterAtIndex(9))),
            TeamStatsItemViewModel(title: "PF", value: teamStats.pf ?? "", colors: randomColors(transformed.characterAtIndex(9))),
            TeamStatsItemViewModel(title: "+/-", value: teamStats.pm ?? "", colors: randomColors(transformed.characterAtIndex(9))),
            
        ]
    }
    
    private func transformTeamId(_ teamId: String) -> String {
        // teamId의 마지막 숫자를 가져옵니다.
        guard let lastDigit = teamId.last, let lastDigitValue = Int(String(lastDigit)) else {
            // teamId가 비어있거나 마지막 숫자를 가져올 수 없으면 원래의 teamId를 반환합니다.
            return teamId
        }

        // teamId의 각 자리수에 마지막 숫자를 더한 후, 1의 자리 숫자만을 사용합니다.
        let transformedDigits = teamId.map { char -> Character in
            guard let digit = Int(String(char)) else { return char }
            let transformedDigit = (digit + lastDigitValue) % 10
            return Character(String(transformedDigit))
        }

        // 변환된 숫자들을 문자열로 결합하여 반환합니다.
        return String(transformedDigits)
    }

    private func randomColors(_ index: Int) -> [Color] {
        print("randomColors: \(index)")
        guard index >= 0, index < 10 else { return [Color("#EBC67C"), Color("#E4B25A")] }
        return [
            [Color("#EBC67C"), Color("#E4B25A")], //yellow
            [Color("#EC723D"), Color("#E24627")], //orange-red
            [Color("#9CD788"), Color("#75BD67")], //green
            [Color("#EC723D"), Color("#E24627")], //orange-red
            [Color("#93D9F2"), Color("#62C0E2")], //sky
            
            [Color("#A7E3BF"), Color("#74C893")], //green2
            [Color("#4981DE"), Color("#2E479F")], //blue
            [Color("#EF9781"), Color("#ED816F")], //red
            [Color("#F4B474"), Color("#EF974B")], //orange
            [Color("#A79CF6"), Color("#7E6BF3")], //violet
        ][index]
    }
}
