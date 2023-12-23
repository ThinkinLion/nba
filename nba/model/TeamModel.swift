//
//  TeamModel.swift
//  nba
//
//  Created by 1100690 on 12/23/23.
//

import Foundation

struct TeamModel: Identifiable, Codable, Hashable {
    let id: String?
    let teamId: String
    let teamCode: String
    let teamName: String
    let ppg: String?
    let ppgRank: String?
    let apg: String?
    let apgRank: String?
    let rpg: String?
    let rpgRank: String?
    let oppg: String?
    let oppgRank: String?
}

extension TeamModel {
    static func ==(lhs: TeamModel, rhs: TeamModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension TeamModel {
    static var empty = TeamModel(id: "", teamId: "", teamCode: "", teamName: "", ppg: "", ppgRank: "", apg: "", apgRank: "", rpg: "", rpgRank: "", oppg: "", oppgRank: "")
}
