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
struct PlayerModel: Codable {
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
}

extension PlayerModel {
    static var empty = PlayerModel(playerId: "", teamId: "", teamName: "", teamCode: "", firstName: "", lastName: "", jersey: "", position: "", ppg: "", rpg: "", apg: "", pie: "", height: "", weight: "", country: "", lastAttended: "", age: "", brithdate: "", draft: "", experience: "", retired: false)
}
