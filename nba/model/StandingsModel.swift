//
//  StandingsModel.swift
//  nba
//
//  Created by 1100690 on 2023/11/09.
//

import Foundation
import FirebaseFirestoreSwift

struct StandingsModel: Codable {
    @DocumentID var id: String?
    let east: [StandingsTeam]
    let west: [StandingsTeam]
}

struct StandingsTeam: Identifiable, Codable, Hashable {
    var id = UUID()
    let teamId: String
    let teamCode: String
    let teamName: String
    let confRank: String
    let conference: String?
    let win: String
    let loss: String
    let winPct: String
    let gamesBehind: String
}

extension StandingsTeam {
    static func ==(lhs: StandingsTeam, rhs: StandingsTeam) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension StandingsModel {
    static var empty = StandingsModel(east: [
        StandingsTeam(teamId: "", teamCode: "", teamName: "", confRank: "", conference: "", win: "", loss: "", winPct: "", gamesBehind: ""),
                                    ],
                                 west: [
                                    StandingsTeam(teamId: "", teamCode: "", teamName: "", confRank: "", conference: "", win: "", loss: "", winPct: "", gamesBehind: ""),
                                    ])
    static var sample = StandingsModel(east: [
        StandingsTeam(teamId: "1610612755", teamCode: "sixers", teamName: "Philadelphia", confRank: "1", conference: "", win: "7", loss: "1", winPct: ".875", gamesBehind: ""),
        StandingsTeam(teamId: "1610612755", teamCode: "celtics", teamName: "Boston", confRank: "2", conference: "", win: "7", loss: "2", winPct: ".778", gamesBehind: "0.5"),
        StandingsTeam(teamId: "1610612755", teamCode: "pacers", teamName: "Indiana", confRank: "3", conference: "", win: "6", loss: "3", winPct: ".667", gamesBehind: "1.5"),
        StandingsTeam(teamId: "1610612755", teamCode: "heat", teamName: "Miami", confRank: "4", conference: "", win: "5", loss: "4", winPct: ".556", gamesBehind: "2.5"),
        StandingsTeam(teamId: "1610612755", teamCode: "hawks", teamName: "Atlanta", confRank: "5", conference: "", win: "5", loss: "4", winPct: ".556", gamesBehind: "2.5"),
        StandingsTeam(teamId: "1610612755", teamCode: "magic", teamName: "Orlando", confRank: "6", conference: "", win: "5", loss: "4", winPct: ".556", gamesBehind: "2.5"),
                                    
        StandingsTeam(teamId: "1610612755", teamCode: "bucks", teamName: "Milwaukee", confRank: "7", conference: "", win: "5", loss: "4", winPct: ".556", gamesBehind: "2.5"),
        StandingsTeam(teamId: "1610612755", teamCode: "knicks", teamName: "NewYork", confRank: "8", conference: "", win: "4", loss: "4", winPct: ".550", gamesBehind: "3"),
        StandingsTeam(teamId: "1610612755", teamCode: "cavaliers", teamName: "Cleveland", confRank: "9", conference: "", win: "4", loss: "5", winPct: ".444", gamesBehind: "3.5"),
        StandingsTeam(teamId: "1610612755", teamCode: "nets", teamName: "Brooklyn", confRank: "10", conference: "", win: "4", loss: "5", winPct: ".444", gamesBehind: "3.5"),
                                    
        StandingsTeam(teamId: "1610612755", teamCode: "raptors", teamName: "Toronto", confRank: "11", conference: "", win: "4", loss: "5", winPct: ".444", gamesBehind: "3.5"),
        StandingsTeam(teamId: "1610612755", teamCode: "hornets", teamName: "Charlotte", confRank: "12", conference: "", win: "3", loss: "5", winPct: ".375", gamesBehind: "4"),
        StandingsTeam(teamId: "1610612755", teamCode: "bulls", teamName: "Chicago", confRank: "13", conference: "", win: "3", loss: "6", winPct: ".333", gamesBehind: "4.5"),
        StandingsTeam(teamId: "1610612755", teamCode: "wizards", teamName: "Washington", confRank: "14", conference: "", win: "2", loss: "6", winPct: ".250", gamesBehind: "5"),
        StandingsTeam(teamId: "1610612755", teamCode: "pistons", teamName: "Detroit", confRank: "15", conference: "", win: "2", loss: "8", winPct: ".200", gamesBehind: "6"),
                                    ],
                                 west: [
                                    StandingsTeam(teamId: "1610612755", teamCode: "timberwolves", teamName: "Minnesota", confRank: "1", conference: "", win: "9", loss: "3", winPct: ".778", gamesBehind: ""),
                                    StandingsTeam(teamId: "1610612755", teamCode: "nuggets", teamName: "Denver", confRank: "2", conference: "", win: "9", loss: "3", winPct: ".889", gamesBehind: ""),
                                    StandingsTeam(teamId: "1610612755", teamCode: "mavericks", teamName: "Dallas", confRank: "3", conference: "", win: "9", loss: "4", winPct: ".667", gamesBehind: "1.5"),
                                    StandingsTeam(teamId: "1610612755", teamCode: "thunder", teamName: "Oklahoma City", confRank: "4", conference: "", win: "9", loss: "4", winPct: ".556", gamesBehind: "2.5"),
                                    StandingsTeam(teamId: "1610612755", teamCode: "kings", teamName: "Sacramento", confRank: "5", conference: "", win: "7", loss: "4", winPct: ".556", gamesBehind: "2.5"),
                                    StandingsTeam(teamId: "1610612755", teamCode: "rockets", teamName: "Houston", confRank: "6", conference: "", win: "6", loss: "4", winPct: ".556", gamesBehind: "2.5"),
                                    
                                    StandingsTeam(teamId: "1610612755", teamCode: "lakers", teamName: "LA", confRank: "7", conference: "", win: "7", loss: "6", winPct: ".556", gamesBehind: "2.5"),
                                    StandingsTeam(teamId: "1610612755", teamCode: "suns", teamName: "Phoenix", confRank: "8", conference: "", win: "6", loss: "6", winPct: ".550", gamesBehind: "3"),
                                    StandingsTeam(teamId: "1610612755", teamCode: "pelicans", teamName: "New Orleans", confRank: "9", conference: "", win: "6", loss: "7", winPct: ".444", gamesBehind: "3.5"),
                                    StandingsTeam(teamId: "1610612755", teamCode: "warriors", teamName: "Golden State", confRank: "10", conference: "", win: "6", loss: "8", winPct: ".444", gamesBehind: "3.5"),
                                    
                                    StandingsTeam(teamId: "1610612755", teamCode: "clippers", teamName: "LA", confRank: "11", conference: "", win: "4", loss: "7", winPct: ".444", gamesBehind: "3.5"),
                                    StandingsTeam(teamId: "1610612755", teamCode: "jazz", teamName: "Utah", confRank: "12", conference: "", win: "4", loss: "8", winPct: ".375", gamesBehind: "4"),
                                    StandingsTeam(teamId: "1610612755", teamCode: "grizzlies", teamName: "Memphis", confRank: "13", conference: "", win: "3", loss: "9", winPct: ".333", gamesBehind: "4.5"),
                                    StandingsTeam(teamId: "1610612755", teamCode: "blazers", teamName: "Portland", confRank: "14", conference: "", win: "3", loss: "9", winPct: ".250", gamesBehind: "5"),
                                    StandingsTeam(teamId: "1610612755", teamCode: "spurs", teamName: "San Antonio", confRank: "15", conference: "", win: "3", loss: "10", winPct: ".200", gamesBehind: "6"),
                                    ])
}


