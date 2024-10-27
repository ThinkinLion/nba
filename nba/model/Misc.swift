//
//  Misc.swift
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
             
             "ptsOffTo": data_elements[4] if len(data_elements) > 4 else "",
             "secondPts": data_elements[5] if len(data_elements) > 5 else "",
             "fbps": data_elements[6] if len(data_elements) > 6 else "",
             "pitp": data_elements[7] if len(data_elements) > 7 else "",
             
             "oppPtsOffTo": data_elements[8] if len(data_elements) > 8 else "",
             "oppSecondPts": data_elements[9] if len(data_elements) > 9 else "",
             "oppFbps": data_elements[10] if len(data_elements) > 10 else "",
             "oppPitp": data_elements[11] if len(data_elements) > 11 else "",

             "blk": data_elements[12] if len(data_elements) > 12 else "",
             "blka": data_elements[13] if len(data_elements) > 13 else "",
             "pf": data_elements[14] if len(data_elements) > 14 else "",
             "pfd": data_elements[15] if len(data_elements) > 15 else "",
         }
 */
struct Misc: Codable, Hashable {
  let id: String?
  let title: String?
  let teamTriCode: String?
  let gp: String?
  let min: String?
  
  let ptsOffTo: String? //PTS OFF TO (Points Off Turnovers)
  let secondPts: String? //2ND PTS (Second Chance Points)
  let fbps: String? //FBPS (Fast Break Points)
  let pitp: String? //PITP (Points in the Paint)
  
  let oppPtsOffTo: String? //OPP PTS OFF TO (Opponent Points Off Turnovers)
  let oppSecondPts: String? //OPP 2ND PTS (Opponent Second Chance Points)
  let oppFbps: String? //OPP FBPS (Opponent Fast Break Points)
  let oppPitp: String? //OPP PITP (Opponent Points in the Paint)
  
  let blk: String? //BLK (Blocks)
  let blka: String? //BLKA (Blocks Against)
  let pf: String? //PF (Personal Fouls)
  let pfd: String? //PFD (Personal Fouls Drawn)
}

extension Misc {
    static func ==(lhs: Misc, rhs: Misc) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Misc: StatsGeneratable {
    func createStatsItemViewModels(teamId: String) -> [PlayerStatsItemViewModel] {
        return ModelFactory.createMiscStatsItemViewModels(with: self, teamId: teamId)
    }
}
