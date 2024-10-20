//
//  ModelFactory.swift
//  nba
//
//  Created by 1100690 on 10/20/24.
//

import Foundation

final class ModelFactory {
    
    // MARK: - Advanced Stats
    
    static func createAdvancedStatsViewModels(with advanced: Advanced, teamId: String) -> [StatsItemViewModel] {
        guard teamId.count >= 10 else { return [] }
        let transformed = Transform.transformTeamId(teamId)
        return [
            StatsItemViewModel(title: "SEASON", value: advanced.title ?? "", colors: Transform.randomColors(transformed.characterAtIndex(0))),
            StatsItemViewModel(title: "PIE", value: advanced.pie ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
            StatsItemViewModel(title: "USG%", value: advanced.usgp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
            StatsItemViewModel(title: "Pace", value: advanced.pace ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
            
            StatsItemViewModel(title: "OFFRTG", value: advanced.offrtg ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
            StatsItemViewModel(title: "DEFRTG", value: advanced.defrtg ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
            StatsItemViewModel(title: "NETRTG", value: advanced.netrtg ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
            
            StatsItemViewModel(title: "AST%", value: advanced.astp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(5))),
            StatsItemViewModel(title: "AST/TO", value: advanced.astto ?? "", colors: Transform.randomColors(transformed.characterAtIndex(5))),
            StatsItemViewModel(title: "AST RATIO", value: advanced.astratio ?? "", colors: Transform.randomColors(transformed.characterAtIndex(5))),
            
            StatsItemViewModel(title: "OREB%", value: advanced.orebp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(6))),
            StatsItemViewModel(title: "DREB%", value: advanced.drebp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(6))),
            StatsItemViewModel(title: "REB%", value: advanced.reb ?? "", colors: Transform.randomColors(transformed.characterAtIndex(6))),
            
            StatsItemViewModel(title: "TO RATIO", value: advanced.toratio ?? "", colors: Transform.randomColors(transformed.characterAtIndex(7))),
            StatsItemViewModel(title: "EFG%", value: advanced.efgp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(7))),
            StatsItemViewModel(title: "TS%", value: advanced.tsp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(7))),
        ]
    }
    
    // MARK: - Traditional Stats
    
    static func createTraditionalStatsItemViewModels(with traditional: Traditional, teamId: String) -> [StatsItemViewModel] {
        guard teamId.count >= 10 else { return [] }
        let transformed = Transform.transformTeamId(teamId)
        return [
            StatsItemViewModel(title: "SEASON", value: traditional.title ?? "", colors: Transform.randomColors(transformed.characterAtIndex(0))),
            StatsItemViewModel(title: "GP", value: traditional.gp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(0))),
            StatsItemViewModel(title: "MIN", value: traditional.min ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
            StatsItemViewModel(title: "PTS", value: traditional.pts ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
            StatsItemViewModel(title: "FGM", value: traditional.fgm ?? "", colors: Transform.randomColors(transformed.characterAtIndex(4))),
            StatsItemViewModel(title: "FGA", value: traditional.fga ?? "", colors: Transform.randomColors(transformed.characterAtIndex(4))),
            StatsItemViewModel(title: "FG%", value: traditional.fgp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(4))),
            StatsItemViewModel(title: "3PM", value: traditional.tpm ?? "", colors: Transform.randomColors(transformed.characterAtIndex(5))),
            StatsItemViewModel(title: "3PA", value: traditional.tpa ?? "", colors: Transform.randomColors(transformed.characterAtIndex(5))),
            StatsItemViewModel(title: "3P%", value: traditional.tpp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(5))),
            
            StatsItemViewModel(title: "FTM", value: traditional.ftm ?? "", colors: Transform.randomColors(transformed.characterAtIndex(6))),
            StatsItemViewModel(title: "FTA", value: traditional.fta ?? "", colors: Transform.randomColors(transformed.characterAtIndex(6))),
            StatsItemViewModel(title: "FT%", value: traditional.ftp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(6))),
            StatsItemViewModel(title: "OREB", value: traditional.oreb ?? "", colors: Transform.randomColors(transformed.characterAtIndex(7))),
            StatsItemViewModel(title: "DREB", value: traditional.dreb ?? "", colors: Transform.randomColors(transformed.characterAtIndex(7))),
            StatsItemViewModel(title: "REB", value: traditional.reb ?? "", colors: Transform.randomColors(transformed.characterAtIndex(7))),
            StatsItemViewModel(title: "AST", value: traditional.ast ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
            StatsItemViewModel(title: "TOV", value: traditional.tov ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
            StatsItemViewModel(title: "STL", value: traditional.stl ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
            StatsItemViewModel(title: "BLK", value: traditional.blk ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
            StatsItemViewModel(title: "PF", value: traditional.pf ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
            StatsItemViewModel(title: "+/-", value: traditional.pm ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
        ]
    }
}
