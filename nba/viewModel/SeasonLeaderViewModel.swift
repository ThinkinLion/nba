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
    
    var smallImageUrl: String {
        playerId.smallImageUrl
    }
    
    var imageUrl: String {
        playerId.imageUrl
    }
    
    var name: String {
        seasonLeader.name ?? ""
    }
    
    var upperCasedName: String {
        name.uppercased()
    }
    
    var teamId: String {
        teamTriCode.triCodeToTeamId
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
