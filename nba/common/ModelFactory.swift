//
//  ModelFactory.swift
//  nba
//
//  Created by 1100690 on 10/20/24.
//

import Foundation

final class ModelFactory {
    
    // MARK: - Advanced Stats
    
    static func createAdvancedStatsItemViewModels(with advanced: Advanced, teamId: String) -> [PlayerStatsItemViewModel] {
        guard teamId.count >= 10 else { return [] }
        let transformed = Transform.transformTeamId(teamId)
        return [
            PlayerStatsItemViewModel(title: advanced.teamTriCode ?? "", value: advanced.title ?? "", colors: Transform.randomColors(transformed.characterAtIndex(0))),
            PlayerStatsItemViewModel(title: "PIE", value: advanced.pie ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
            PlayerStatsItemViewModel(title: "USG%", value: advanced.usgp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
            PlayerStatsItemViewModel(title: "Pace", value: advanced.pace ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
            
            PlayerStatsItemViewModel(title: "OFFRTG", value: advanced.offrtg ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
            PlayerStatsItemViewModel(title: "DEFRTG", value: advanced.defrtg ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
            PlayerStatsItemViewModel(title: "NETRTG", value: advanced.netrtg ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
            
            PlayerStatsItemViewModel(title: "AST%", value: advanced.astp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(5))),
            PlayerStatsItemViewModel(title: "AST/TO", value: advanced.astto ?? "", colors: Transform.randomColors(transformed.characterAtIndex(5))),
            PlayerStatsItemViewModel(title: "AST RATIO", value: advanced.astratio ?? "", colors: Transform.randomColors(transformed.characterAtIndex(5))),
            
            PlayerStatsItemViewModel(title: "OREB%", value: advanced.orebp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(6))),
            PlayerStatsItemViewModel(title: "DREB%", value: advanced.drebp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(6))),
            PlayerStatsItemViewModel(title: "REB%", value: advanced.reb ?? "", colors: Transform.randomColors(transformed.characterAtIndex(6))),
            
            PlayerStatsItemViewModel(title: "TO RATIO", value: advanced.toratio ?? "", colors: Transform.randomColors(transformed.characterAtIndex(7))),
            PlayerStatsItemViewModel(title: "EFG%", value: advanced.efgp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(7))),
            PlayerStatsItemViewModel(title: "TS%", value: advanced.tsp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(7))),
        ]
    }
    
    // MARK: - Traditional Stats
    
    static func createTraditionalStatsItemViewModels(with traditional: Traditional, teamId: String) -> [PlayerStatsItemViewModel] {
        guard teamId.count >= 10 else { return [] }
        let transformed = Transform.transformTeamId(teamId)
        return [
            PlayerStatsItemViewModel(title: traditional.teamTriCode ?? "", value: traditional.title ?? "", colors: Transform.randomColors(transformed.characterAtIndex(0))),
            PlayerStatsItemViewModel(title: "GP", value: traditional.gp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(0))),
            PlayerStatsItemViewModel(title: " MIN", value: traditional.min ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
            PlayerStatsItemViewModel(title: "PTS", value: traditional.pts ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
            PlayerStatsItemViewModel(title: "FGM", value: traditional.fgm ?? "", colors: Transform.randomColors(transformed.characterAtIndex(4))),
            PlayerStatsItemViewModel(title: "FGA", value: traditional.fga ?? "", colors: Transform.randomColors(transformed.characterAtIndex(4))),
            PlayerStatsItemViewModel(title: "FG%", value: traditional.fgp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(4))),
            PlayerStatsItemViewModel(title: "3PM", value: traditional.tpm ?? "", colors: Transform.randomColors(transformed.characterAtIndex(5))),
            PlayerStatsItemViewModel(title: "3PA", value: traditional.tpa ?? "", colors: Transform.randomColors(transformed.characterAtIndex(5))),
            PlayerStatsItemViewModel(title: "3P%", value: traditional.tpp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(5))),
            
            PlayerStatsItemViewModel(title: "FTM", value: traditional.ftm ?? "", colors: Transform.randomColors(transformed.characterAtIndex(6))),
            PlayerStatsItemViewModel(title: "FTA", value: traditional.fta ?? "", colors: Transform.randomColors(transformed.characterAtIndex(6))),
            PlayerStatsItemViewModel(title: "FT%", value: traditional.ftp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(6))),
            PlayerStatsItemViewModel(title: "OREB", value: traditional.oreb ?? "", colors: Transform.randomColors(transformed.characterAtIndex(7))),
            PlayerStatsItemViewModel(title: "DREB", value: traditional.dreb ?? "", colors: Transform.randomColors(transformed.characterAtIndex(7))),
            PlayerStatsItemViewModel(title: "REB", value: traditional.reb ?? "", colors: Transform.randomColors(transformed.characterAtIndex(7))),
            PlayerStatsItemViewModel(title: "AST", value: traditional.ast ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
            PlayerStatsItemViewModel(title: "TOV", value: traditional.tov ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
            PlayerStatsItemViewModel(title: "STL", value: traditional.stl ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
            PlayerStatsItemViewModel(title: "BLK", value: traditional.blk ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
            PlayerStatsItemViewModel(title: "PF", value: traditional.pf ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
            PlayerStatsItemViewModel(title: "+/-", value: traditional.pm ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
        ]
    }
}
