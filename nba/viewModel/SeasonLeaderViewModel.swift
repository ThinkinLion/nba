//
//  SeasonLeaderViewModel.swift
//  nba
//
//  Created by 1100690 on 12/3/23.
//

import Foundation

struct SeasonLeaderViewModel {
    private let seasonLeader: SeasonLeader
    
    init(seasonLeader: SeasonLeader) {
        self.seasonLeader = seasonLeader
    }
    
    var playerId: String {
        seasonLeader.playerId ?? ""
    }
    
    var imageUrl: String {
        "https://cdn.nba.com/headshots/nba/latest/1040x760/{{playerId}}.png".replacingOccurrences(of: "{{playerId}}", with: playerId)
    }
    
    var name: String {
        seasonLeader.name ?? ""
    }
    
    var teamTriCode: String {
        seasonLeader.teamTriCode ?? ""
    }
    
    var rank: String {
        seasonLeader.rank ?? ""
    }
    
    var points: String {
        seasonLeader.points ?? ""
    }
}
