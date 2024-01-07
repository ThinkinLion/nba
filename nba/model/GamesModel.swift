//
//  GamesModel.swift
//  nba
//
//  Created by 1100690 on 11/29/23.
//

import Foundation
import FirebaseFirestoreSwift

struct GamesModel: Codable {
    @DocumentID var id: String?
    let items: [HomeAway]
    let date: String? //firestore oder by
}

struct HomeAway: Codable, Hashable {
    let home: Game
    let away: Game
    let date: String? //cardview 날짜 노출
    let leaders: [BoxScore]? //여기에도 모아봤음, 어떤게 쓰일지 몰라서
}

extension HomeAway {
    static func ==(lhs: HomeAway, rhs: HomeAway) -> Bool {
        return lhs.home.id == rhs.home.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(home.id)
    }
}

struct Game: Identifiable, Codable, Hashable {
    var id = UUID()
    let teamId: String
    let teamCode: String
    let record: String?
    let score: String?
    let leader: BoxScore?
    let boxscore: [BoxScore]?
}

extension Game {
    static func ==(lhs: Game, rhs: Game) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct BoxScore: Codable, Hashable {
    var id = UUID()
    let playerId: String?
    let teamId: String?
    let firstName: String?
    let lastName: String?
    let teamTriCode: String?
    let jersey: String?
    let position: String?
    let pts: String?
    let reb: String?
    let ast: String? //여기까지 leader에만 있는 정보
    
    /*
     파이썬
     player_data = {
                     "id": str(uuid.uuid4()),
                     "playerId": player_id,
                     "title": title,
                     "firstName": player_firstName,
                     "lastName": player_lastName,
                     "positon": position,
                     "min": min,
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
                     "to": to,
                     "pf": pf,
                     "pts": pts,
                     "pm": pm,
                 }
     */
    let title: String? //TOTALS용
    let min: String?
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
    
    let stl: String?
    let blk: String?
    
    let to: String?
    let pf: String?
    let pm: String?
}

extension BoxScore {
    static func ==(lhs: BoxScore, rhs: BoxScore) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
