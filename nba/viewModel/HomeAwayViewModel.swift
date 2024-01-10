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
    
    var awayTeamCode: String {
        homeAway.away.teamCode.lowercased()
    }
    
    var homeTeamCode: String {
        homeAway.home.teamCode.lowercased()
    }
    
    //tri code
    var awayTriCode: String {
        homeAway.away.teamCode.nickNameToTriCode
    }
    
    var homeTriCode: String {
        homeAway.home.teamCode.nickNameToTriCode
    }
    
    //team name
    var awayTeamNickName: String {
        homeAway.away.teamCode
    }
    
    var homeTeamNickName: String {
        homeAway.home.teamCode
    }
    
    var awayTeamName: String {
        homeAway.away.teamId.teamIdToName
    }
    
    var homeTeamName: String {
        homeAway.home.teamId.teamIdToName
    }
    
    //team full name
    var awayTeamFullName: String {
        awayTeamName + " " + awayTeamNickName
    }
    
    var homeTeamFullName: String {
        homeTeamName + " " + homeTeamNickName
    }
    
    //date
    var dayOfWeek: String {
        homeAway.date?.dayOfWeek ?? ""
    }
    
    var day: String {
        homeAway.date?.day ?? ""
    }
    
    //team id
    var awayTeamId: String {
        homeAway.away.teamCode.nickNameToTriCode.triCodeToTeamId
    }
    
    var homeTeamId: String {
        homeAway.home.teamCode.nickNameToTriCode.triCodeToTeamId
    }
    
    //record
    var awayRecord: String {
        homeAway.away.record ?? ""
    }
    
    var homeRecord: String {
        homeAway.home.record ?? ""
    }
    
    //score
    var awayScore: String {
        homeAway.away.score ?? "0"
    }
    
    var homeScore: String {
        homeAway.home.score ?? "0"
    }
    
    var score: String {
        awayScore + " - " + homeScore
    }
    
    //leader id
    var awayLeaderId: String {
        homeAway.away.leader?.playerId ?? ""
    }
    
    var homeLeaderId: String {
        homeAway.home.leader?.playerId ?? ""
    }
    
    //pts
    var ptsTitie: String {
        "PTS"
    }
    
    var awayLeaderPts: String {
        guard let pts = homeAway.away.leader?.pts else { return ""}
        guard !pts.isEmpty else { return "" }
        return pts
    }
    
    var homeLeaderPts: String {
        guard let pts = homeAway.home.leader?.pts else { return ""}
        guard !pts.isEmpty else { return "" }
        return pts
    }
    
    //reb
    var rebTitie: String {
        "REB"
    }
    
    var awayLeaderReb: String {
        guard let reb = homeAway.away.leader?.reb else { return ""}
        guard !reb.isEmpty else { return "" }
        return reb
    }
    
    var homeLeaderReb: String {
        guard let reb = homeAway.home.leader?.reb else { return ""}
        guard !reb.isEmpty else { return "" }
        return reb
    }
    
    //ast
    var astTitie: String {
        "AST"
    }
    
    var awayLeaderAst: String {
        guard let ast = homeAway.away.leader?.ast else { return ""}
        guard !ast.isEmpty else { return "" }
        return ast
    }
    
    var homeLeaderAst: String {
        guard let ast = homeAway.home.leader?.ast else { return ""}
        guard !ast.isEmpty else { return "" }
        return ast
    }
    
    //boxscore
    var awayBoxscore: [BoxScore] {
        homeAway.away.boxscore ?? []
    }
    
    var hasAwayBoxscore: Bool {
        !awayBoxscore.isEmpty
    }
    
    var homeBoxscore: [BoxScore] {
        homeAway.home.boxscore ?? []
    }
    
    var hasHomeBoxscore: Bool {
        !homeBoxscore.isEmpty
    }
}

extension HomeAwayViewModel {
    func todayOfWeek() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: currentDate)
    }
    
    private func today() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: currentDate)
    }
}
