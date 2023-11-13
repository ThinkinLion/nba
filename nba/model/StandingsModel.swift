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
    let east: [Team]
    let west: [Team]
}

struct Team: Identifiable, Codable, Hashable {
    var id = UUID()
    let teamId: String
    let teamCode: String
    let teamName: String
    let confRank: String
    let win: String
    let loss: String
    let winPct: String
    let gamesBehind: String
}

extension Team {
    static func ==(lhs: Team, rhs: Team) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension StandingsModel {
    static var empty = StandingsModel(east: [
                                    Team(teamId: "", teamCode: "", teamName: "", confRank: "", win: "", loss: "", winPct: "", gamesBehind: ""),
                                    ],
                                 west: [
                                    Team(teamId: "", teamCode: "", teamName: "", confRank: "", win: "", loss: "", winPct: "", gamesBehind: ""),
                                    ])
    static var sample = StandingsModel(east: [
                                    Team(teamId: "1610612755", teamCode: "celtics", teamName: "Boston", confRank: "1", win: "7", loss: "1", winPct: ".875", gamesBehind: ""),
                                    Team(teamId: "1610612755", teamCode: "pacers", teamName: "Indiana", confRank: "2", win: "7", loss: "2", winPct: ".778", gamesBehind: "0.5")
                                    ],
                                 west: [
                                    Team(teamId: "1610612755", teamCode: "nuggets", teamName: "Denver", confRank: "1", win: "8", loss: "1", winPct: ".889", gamesBehind: "")
                                    ])
}


