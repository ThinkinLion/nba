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
        //260x190: https://cdn.nba.com/headshots/nba/latest/260x190/1631260.png
        "https://cdn.nba.com/headshots/nba/latest/1040x760/{{playerId}}.png".replacingOccurrences(of: "{{playerId}}", with: playerId)
    }
    
    var name: String {
        seasonLeader.name ?? ""
    }
    
    var upperCasedName: String {
        name.uppercased()
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
    
//    var dark: String {
//        teamTriCode.triCodeToNickName.toDarkColor
//    }
//    
//    var light: String {
//        teamTriCode.triCodeToNickName.toLightColor
//    }
}
