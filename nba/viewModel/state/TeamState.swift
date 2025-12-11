//
//  TeamState.swift
//  nba
//
//  Created by Antigravity on 12/10/24.
//

import Foundation

struct TeamState: Identifiable {
    let id: String
    let displayRank: Int
    let name: String
    let record: String?
    let rankChangeText: String
    let rankChangeStyle: RankChangeStyle
    let triCode: String?
    let backgroundColorName: String
    let model: PowerRankingTeamModel
    
    var rankChange: Int? {
        guard let lastWeek = model.lastWeek, !lastWeek.isEmpty else { return nil }
        
        // Remove arrows and other non-numeric characters
        let numericString = lastWeek.filter { $0.isNumber }
        
        if let lastRank = Int(numericString) {
            return lastRank - displayRank // Positive = moved up, Negative = moved down
        }
        return nil
    }
    
    var detailViewState: TeamDetailViewState {
        let rankChange = PowerRankingFormatter.makeRankChange(from: model.lastWeek)
        return TeamDetailViewState(
            triCode: triCode,
            name: name,
            rank: model.rank,
            record: record,
            rankChangeText: rankChange.text,
            rankChangeStyle: rankChange.style,
            overview: model.overview,
            takeaways: model.takeaways,
            upcoming: model.upcomming,
            advanced: model.advanced,
            backgroundColorName: backgroundColorName
        )
    }
}
