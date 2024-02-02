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
    let conference: String?
    let confRank: String?
    let ppg: String?
    let ppgRank: String?
    let apg: String?
    let apgRank: String?
    let rpg: String?
    let rpgRank: String?
    let oppg: String?
    let oppgRank: String?
    let stats: [TeamStats]?
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
    static var empty = TeamModel(id: "", teamId: "", teamCode: "", teamName: "", conference: "", confRank: "", ppg: "", ppgRank: "", apg: "", apgRank: "", rpg: "", rpgRank: "", oppg: "", oppgRank: "", stats: [])
}

struct TeamStats: Codable, Hashable {
    /*
     파이썬
     team_data = {
                     "id": str(uuid.uuid4()),
                     "title": title,
                     "gp": gp,
                     "min": min,
                     "pts": pts,
                     "win": win,
                     "loss": loss,
                     "wp": wp,
                     "fgm": fgm,
                     "fga": fga,
                     "fgp": fgp,
                     "tpm": tpm,
                     "tpa": tpa,
                     "tpp": tpp,
                     "ftm": ftm,
                     "fta": fta,
                     "ftp": ftp,
                     "oreb": oreb,
                     "dreb": dreb,
                     "reb": reb,
                     "ast": ast,
                     "stl": stl,
                     "blk": blk,
                     "tov": tov,
                     "pf": pf,
                     "pm": pm,
                 }
     */
    let id: String?
    let title: String?
    
    let gp: String?
    let min: String?
    let pts: String?
    
    let win: String?
    let loss: String?
    let wp: String?
    
    let fgm: String?
    let fga: String?
    let fgp: String?
    
    let tpm: String?
    let tpa: String?
    let tpp: String?
    
    let ftm: String?
    let fta: String?
    let ftp: String?
    
    let oreb: String?
    let dreb: String?
    let reb: String?
    
    let ast: String?
    let stl: String?
    let blk: String?
    
    let tov: String?
    let pf: String?
    let pm: String?
}

extension TeamStats {
    static var empty = TeamStats(id: "", title: "", gp: "", min: "", pts: "", win: "", loss: "", wp: "", fgm: "", fga: "", fgp: "", tpm: "", tpa: "", tpp: "", ftm: "", fta: "", ftp: "", oreb: "", dreb: "", reb: "", ast: "", stl: "", blk: "", tov: "", pf: "", pm: "")
}

extension TeamStats {
    static func ==(lhs: TeamStats, rhs: TeamStats) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
