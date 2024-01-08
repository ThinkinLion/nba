//
//  TeamSummaryViewModel.swift
//  nba
//
//  Created by 1100690 on 2023/11/19.
//

import Foundation

struct TeamSummaryViewModel {
    private let team: StandingsTeam
    
    init(team: StandingsTeam) {
        self.team = team
    }
    
    var teamId: String {
        team.teamCode.nickNameToTriCode.triCodeToTeamId
    }
    
    var teamName: String {
        team.teamName
    }
    
    var upperCasedName: String {
        teamName.uppercased() + " " + teamCode.uppercased()
    }
    
    var teamCode: String {
        team.teamCode.lowercased()
    }
    
    var teamTriCode: String {
        team.teamCode.nickNameToTriCode
    }
    
    var win: String {
        team.win
    }
    
    var loss: String {
        team.loss
    }
    
    var winLoss: String {
        team.win + "-" + team.loss
    }
    
    var winPct: String {
        team.winPct
    }
    
    var gamesBehind: String {
        (team.gamesBehind == "0.0") ? "-" : team.gamesBehind
    }
        
    var conferenceRankFullName: String {
        guard !conference.isEmpty else { return "" }
        return conferenceRank.ordinal + " in " + conference
    }
    
    var conferenceRank: String {
        team.confRank
    }
    
    var conference: String {
        team.conference ?? ""
    }

    
//
//    var homeWinLoss: String {
//        return self.homeWin + "-" + self.homeLoss
//    }
//
//    var homeWin: String {
//        return team.homeWin
//    }
//
//    var homeLoss: String {
//        return team.homeLoss
//    }
//
//    var awayWinLoss: String {
//        return self.awayWin + "-" + self.awayLoss
//    }
//
//    var awayWin: String {
//        return team.awayWin
//    }
//
//    var awayLoss: String {
//        return team.awayLoss
//    }
//
//    var lastTenWinLoss: String {
//        return self.lastTenWin + "-" + self.lastTenLoss
//    }
//
//    var lastTenWin: String {
//        return team.lastTenWin
//    }
//
//    var lastTenLoss: String {
//        return team.lastTenLoss
//    }
//
//    var streak: String {
//        return (team.isWinStreak ? "W" : "L") + team.streak
//    }
}
