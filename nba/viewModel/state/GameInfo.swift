//
//  GameInfo.swift
//  nba
//
//  Created by Antigravity on 12/10/24.
//

import Foundation

struct GameInfo {
    let teamScore: String
    let opponentScore: String
    let opponentTriCode: String
    let teamWon: Bool
    
    static func from(game: HomeAway, teamId: String) -> GameInfo {
        let isHome = game.home.teamId == teamId
        let team = isHome ? game.home : game.away
        let opponent = isHome ? game.away : game.home
        
        let opponentTriCode: String = {
            if opponent.teamCode.count == 3 {
                return opponent.teamCode.uppercased()
            } else {
                let triCode = opponent.teamCode.nickNameToTriCode
                return triCode.isEmpty ? opponent.teamCode.uppercased() : triCode
            }
        }()
        
        let teamWon = isHome ?
            (Int(game.home.score ?? "0") ?? 0) > (Int(game.away.score ?? "0") ?? 0) :
            (Int(game.away.score ?? "0") ?? 0) > (Int(game.home.score ?? "0") ?? 0)
        
        return GameInfo(
            teamScore: team.score ?? "-",
            opponentScore: opponent.score ?? "-",
            opponentTriCode: opponentTriCode,
            teamWon: teamWon
        )
    }
}
