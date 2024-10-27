//
//  Traditional.swift
//  nba
//
//  Created by 1100690 on 10/26/24.
//

import Foundation

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

extension Traditional: StatsGeneratable {
    func createStatsItemViewModels(teamId: String) -> [PlayerStatsItemViewModel] {
        return ModelFactory.createTraditionalStatsItemViewModels(with: self, teamId: teamId)
    }
}
