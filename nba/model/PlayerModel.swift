//
//  PlayerModel.swift
//  nba
//
//  Created by 1100690 on 12/11/23.
//

import Foundation
import FirebaseFirestoreSwift

/*
 player_info = {
     "id": str(uuid.uuid4()),
     "teamId": team_id,
     "teamName": team_name,
     "teamCode": team_code,
     "firstName": player_firstname,
     "lastName": player_lastname,
     "jersey": jersey,
     "position": position,
     "ppg": ppg,
     "rpg": rpg,
     "apg": apg,
     "pie": pie,
     "height": height,
     "weight": weight,
     "country": country,
     "lastAttended": last_attended,
     "age": age,
     "brithdate": brithdate,
     "draft": draft,
     "experience": experience,
     "retired": False
 }
 */
struct PlayerModel: Codable, Hashable {
    @DocumentID var id: String?
    let playerId: String?
    let teamId: String?
    let teamName: String?
    let teamCode: String?
    let firstName: String?
    let lastName: String?
    let jersey: String?
    let position: String?
    
    let ppg: String?
    let rpg: String?
    let apg: String?
    let pie: String?
    
    let height: String?
    let weight: String?
    let country: String?
    let lastAttended: String?
    let age: String?
    let brithdate: String?
    let draft: String?
    let experience: String?
    let retired: Bool?
    
    let traditional: [Traditional]?
    let advanced: [Advanced]?
}

extension PlayerModel {
    static func ==(lhs: PlayerModel, rhs: PlayerModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension PlayerModel {
  static var empty = PlayerModel(playerId: "", teamId: "", teamName: "", teamCode: "", firstName: "", lastName: "", jersey: "", position: "", ppg: "", rpg: "", apg: "", pie: "", height: "", weight: "", country: "", lastAttended: "", age: "", brithdate: "", draft: "", experience: "", retired: false, traditional: [], advanced: [])
}

/*
 stats_data = {
             "id": str(uuid.uuid4()),
             "title": data_elements[0] if len(data_elements) > 0 else "",
             "teamTriCode": data_elements[1] if len(data_elements) > 1 else "",
             "gp": data_elements[2] if len(data_elements) > 2 else "",
             "min": data_elements[3] if len(data_elements) > 3 else "",
             "pts": data_elements[4] if len(data_elements) > 4 else "",
             "fgm": data_elements[5] if len(data_elements) > 5 else "",
             "fga": data_elements[6] if len(data_elements) > 6 else "",
             "fgp": data_elements[7] if len(data_elements) > 7 else "",
             "tpm": data_elements[8] if len(data_elements) > 8 else "",
             "tpa": data_elements[9] if len(data_elements) > 9 else "",
             "tpp": data_elements[10] if len(data_elements) > 10 else "",
             "ftm": data_elements[11] if len(data_elements) > 11 else "",
             "fta": data_elements[12] if len(data_elements) > 12 else "",
             "ftp": data_elements[13] if len(data_elements) > 13 else "",
             "oreb": data_elements[14] if len(data_elements) > 14 else "",
             "dreb": data_elements[15] if len(data_elements) > 15 else "",
             "reb": data_elements[16] if len(data_elements) > 16 else "",
             "ast": data_elements[17] if len(data_elements) > 17 else "",
             "tov": data_elements[18] if len(data_elements) > 18 else "",
             "stl": data_elements[19] if len(data_elements) > 19 else "",
             "blk": data_elements[20] if len(data_elements) > 20 else "",
             "pf": data_elements[21] if len(data_elements) > 21 else "",
             "fp": data_elements[22] if len(data_elements) > 22 else "",
             "dd2": data_elements[23] if len(data_elements) > 23 else "",
             "td3": data_elements[24] if len(data_elements) > 24 else "",
             "pm": data_elements[25] if len(data_elements) > 25 else "",
         }
 */
struct Traditional: Codable, Hashable {
    let id: String?
    let title: String?
    let teamTriCode: String?
    let gp: String?
    let min: String?
    let pts: String?
    
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
    let tov: String?
    let stl: String?
    
    let blk: String?
    let pf: String?
    let fp: String? //fantasy point
    
    let dd2: String? //double double
    let td3: String? //triple double
    let pm: String?
}

extension Traditional {
    static func ==(lhs: Traditional, rhs: Traditional) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/*
 stats_data = {
             "id": str(uuid.uuid4()),
             "title": data_elements[0] if len(data_elements) > 0 else "",
             "teamTriCode": data_elements[1] if len(data_elements) > 1 else "",
             "gp": data_elements[2] if len(data_elements) > 2 else "",
             "min": data_elements[3] if len(data_elements) > 3 else "",
             
             "offrtg": data_elements[4] if len(data_elements) > 4 else "",
             "defrtg": data_elements[5] if len(data_elements) > 5 else "",
             "netrtg": data_elements[6] if len(data_elements) > 6 else "",

             "astp": data_elements[7] if len(data_elements) > 7 else "",
             "astto": data_elements[8] if len(data_elements) > 8 else "",
             "astratio": data_elements[9] if len(data_elements) > 9 else "",

             "orebp": data_elements[10] if len(data_elements) > 10 else "",
             "drebp": data_elements[11] if len(data_elements) > 11 else "",
             "reb": data_elements[12] if len(data_elements) > 12 else "",

             "toratio": data_elements[13] if len(data_elements) > 13 else "",
             "efgp": data_elements[14] if len(data_elements) > 14 else "",
             "tsp": data_elements[15] if len(data_elements) > 15 else "",

             "usgp": data_elements[16] if len(data_elements) > 16 else "",
             "pace": data_elements[17] if len(data_elements) > 17 else "",
             "pie": data_elements[18] if len(data_elements) > 18 else "",
         }
 */
struct Advanced: Codable, Hashable {
    let id: String?
    let title: String?
    let teamTriCode: String?
    let gp: String?
    let min: String?
    
    let offrtg: String? //OFFRTG, offensive rating is points scored per 100 possesions
    let defrtg: String? //DEFRTG
    let netrtg: String? //NETRTG, The difference between Offensive and Defensive Rating provides the Net Rating that is the difference in score spread over 100 possessions.
    
    let astp: String? //AST%, percent of team's assists
    let astto: String? //AST/TO, assist-to-turnover ratio
    let astratio: String? //AST RATIO, the percentage of a player's possessions that end in an assist.
    
    let orebp: String? //OREB%, percent of team's offensive rebounds
    let drebp: String?
    let reb: String?
    
    let toratio: String? //TO RATIO, turnover ratio, percentage of a player's or team's possessions
    let efgp: String? //EFG%, Effective Field Goal Percentage
    let tsp: String? //TS%, True Shooting Percentage. field goals, 3-point field goals, and free throws.
    
    let usgp: String? //USG%, Usage percentage
    let pace: String? //Pace is measured by counting the number of possessions that happen in a typical 48 minute game
    let pie: String? //Player Impact Estimate, player's overall contribution to the game
}

extension Advanced {
    static func ==(lhs: Advanced, rhs: Advanced) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
