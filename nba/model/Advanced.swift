//
//  Advanced.swift
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

extension Advanced: StatsGeneratable {
    func createStatsItemViewModels(teamId: String) -> [PlayerStatsItemViewModel] {
        return ModelFactory.createAdvancedStatsItemViewModels(with: self, teamId: teamId)
    }
}
