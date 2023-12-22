//
//  TeamSummaryViewModel.swift
//  nba
//
//  Created by 1100690 on 2023/11/19.
//

import Foundation

struct TeamSummaryViewModel {
    private let team: Team
    
    init(team: Team) {
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
        
//    var conferenceRankFullName: String {
//        return self.conferenceRank + self.conferenceRankSuffix
//    }
//
    var conferenceRank: String {
        team.confRank
    }
//
//    var conferenceRankSuffix: String {
//        var suffix = "th"
//        if team.confRank == "1" {
//            suffix = "st"
//        } else if team.confRank == "2" {
//            suffix = "nd"
//        } else if team.confRank == "3" {
//            suffix = "rd"
//        }
//        return suffix
//    }
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
