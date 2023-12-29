//
//  HomeAwayViewModel.swift
//  nba
//
//  Created by 1100690 on 12/1/23.
//

import Foundation

struct HomeAwayViewModel {
    private let homeAway: HomeAway
    
    init(homeAway: HomeAway) {
        self.homeAway = homeAway
    }
    
    var homeTeamCode: String {
        homeAway.home.teamCode.lowercased()
    }
    
    var awayTeamCode: String {
        homeAway.away.teamCode.lowercased()
    }
    
    var homeRecord: String {
        homeAway.home.record ?? ""
    }
    
    var awayRecord: String {
        homeAway.away.record ?? ""
    }
    
    var homeScore: String {
        homeAway.home.score ?? "0"
    }
    
    var awayScore: String {
        homeAway.away.score ?? "0"
    }
    
    var awayLeaderId: String {
        homeAway.away.leader?.playerId ?? ""
    }
    
    var homeLeaderId: String {
        homeAway.home.leader?.playerId ?? ""
    }
    
    //pts
    var awayLeaderPts: String {
        guard let pts = homeAway.away.leader?.pts else { return ""}
        guard !pts.isEmpty else { return "" }
        return pts + "PTS"
    }
    
    var homeLeaderPts: String {
        guard let pts = homeAway.home.leader?.pts else { return ""}
        guard !pts.isEmpty else { return "" }
        return pts + "PTS"
    }
    
    //reb
    var awayLeaderReb: String {
        guard let reb = homeAway.away.leader?.reb else { return ""}
        guard !reb.isEmpty else { return "" }
        return reb + "REB"
    }
    
    var homeLeaderReb: String {
        guard let reb = homeAway.home.leader?.reb else { return ""}
        guard !reb.isEmpty else { return "" }
        return reb + "REB"
    }
    
    //ast
    var awayLeaderAst: String {
        guard let ast = homeAway.away.leader?.ast else { return ""}
        guard !ast.isEmpty else { return "" }
        return ast + "AST"
    }
    
    var homeLeaderAst: String {
        guard let ast = homeAway.home.leader?.ast else { return ""}
        guard !ast.isEmpty else { return "" }
        return ast + "AST"
    }
}
