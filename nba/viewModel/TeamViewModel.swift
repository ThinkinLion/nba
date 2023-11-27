//
//  TeamViewModel.swift
//  nba
//
//  Created by 1100690 on 2023/11/19.
//

import Foundation

struct TeamViewModel {
    private let team: Team
    
    init(team: Team) {
        self.team = team
    }
    
    var teamName: String {
        return team.teamName
    }
    
//    var teamNickname: String {
//        return team.teamSitesOnly.teamNickname
//    }
    
    var teamCode: String {
        return team.teamCode.lowercased()
    }
    
    var win: String {
        return team.win
    }
    
    var loss: String {
        return team.loss
    }
    
    var winLoss: String {
        return team.win + "-" + team.loss
    }
    
//    var winLossInConference: String {
//        return team.confWin + " - " + team.confLoss
//    }
//
//    var winLossInDivision: String {
//        return team.divWin + " - " + team.divLoss
//    }
    
    var winPct: String {
        return team.winPct
    }
    
    var gamesBehind: String {
        return (team.gamesBehind == "0.0") ? "-" : team.gamesBehind
    }
        
//    var conferenceRankFullName: String {
//        return self.conferenceRank + self.conferenceRankSuffix
//    }
//
    var conferenceRank: String {
        return team.confRank
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
