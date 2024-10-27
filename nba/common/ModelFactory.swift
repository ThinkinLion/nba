//
//  ModelFactory.swift
//  nba
//
//  Created by 1100690 on 10/20/24.
//

import Foundation

final class ModelFactory {
    
  // MARK: - Usage Stats
  /*
   struct Usage: Codable, Hashable {
     let usgPercent: String? //USG% (Usage Percentage): 특정 선수가 경기에 참여한 동안 팀의 전체 플레이 중 해당 선수가 사용한 비율. 주로 공격 기여도를 나타냅니다 (Percentage of Team’s Plays used by the Player while on the court).
     let percentFgm: String? //%FGM (Field Goals Made Percentage): 해당 선수가 팀의 전체 필드 골 성공 횟수에서 차지하는 비율 (Percentage of Team’s Total Field Goals Made by the Player).
     let percentFga: String? //%FGA (Field Goals Attempted Percentage): 해당 선수가 팀의 전체 필드 골 시도 횟수에서 차지하는 비율 (Percentage of Team’s Total Field Goals Attempted by the Player).
     
     let percent3pm: String? //%3PM (3-Point Field Goals Made Percentage): 해당 선수가 팀의 전체 3점 필드 골 성공 횟수에서 차지하는 비율 (Percentage of Team’s Total 3-Point Field Goals Made by the Player).
     let percent3pa: String? //%3PA (3-Point Field Goals Attempted Percentage): 해당 선수가 팀의 전체 3점 필드 골 시도 횟수에서 차지하는 비율 (Percentage of Team’s Total 3-Point Field Goals Attempted by the Player).
     
     let percentFtm: String? //%FTM (Free Throws Made Percentage): 해당 선수가 팀의 전체 자유투 성공 횟수에서 차지하는 비율 (Percentage of Team’s Total Free Throws Made by the Player).
     let percentFta: String? //%FTA (Free Throws Attempted Percentage): 해당 선수가 팀의 전체 자유투 시도 횟수에서 차지하는 비율 (Percentage of Team’s Total Free Throws Attempted by the Player).
     
     let percentOreb: String? //%OREB (Offensive Rebounds Percentage): 해당 선수가 팀의 전체 공격 리바운드 중 차지하는 비율 (Percentage of Team’s Total Offensive Rebounds by the Player).
     let percentDreb: String? //%DREB (Defensive Rebounds Percentage): 해당 선수가 팀의 전체 수비 리바운드 중 차지하는 비율 (Percentage of Team’s Total Defensive Rebounds by the Player). Turnovers).
     let percentReb: String? //%REB (Total Rebounds Percentage): 해당 선수가 팀의 전체 리바운드 중 차지하는 비율 (Percentage of Team’s Total Rebounds by the Player).
     
     let percentAst: String? //%AST (Assists Percentage): 해당 선수가 팀의 전체 어시스트 중 차지하는 비율 (Percentage of Team’s Total Assists by the Player).
     let percentTov: String? //%TOV (Turnovers Percentage): 해당 선수가 팀의 전체 턴오버 중 차지하는 비율 (Percentage of Team’s Total Turnovers by the Player).
     let percentStl: String? //%STL (Steals Percentage): 해당 선수가 팀의 전체 스틸 중 차지하는 비율 (Percentage of Team’s Total Steals by the Player).
     
     let percentBlk: String? //%BLK (Blocks Percentage): 해당 선수가 팀의 전체 블록 중 차지하는 비율 (Percentage of Team’s Total Blocks by the Player).
     let percentBlka: String? //%BLKA (Blocks Against Percentage): 해당 선수가 팀의 전체 블락 당한 횟수에서 차지하는 비율 (Percentage of Team’s Total Times Blocked Against by the Player).
     
     let percentPf: String? //%PF (Personal Fouls Percentage): 해당 선수가 팀의 전체 개인 파울 중 차지하는 비율 (Percentage of Team’s Total Personal Fouls by the Player).
     let percentPfd: String? //%PFD (Personal Fouls Drawn Percentage): 해당 선수가 팀의 전체 파울 유도 횟수에서 차지하는 비율 (Percentage of Team’s Total Personal Fouls Drawn by the Player).
     let percentPts: String? //%PTS (Points Percentage): 해당 선수가 팀의 전체 득점 중 차지하는 비율 (Percentage of Team’s Total Points by the Player).
   }
   */
  static func createUsageStatsItemViewModels(with usage: Usage, teamId: String) -> [PlayerStatsItemViewModel] {
    guard teamId.count >= 10 else { return [] }
    let transformed = Transform.transformTeamId(teamId)
    return [
      PlayerStatsItemViewModel(title: usage.teamTriCode ?? "", value: usage.title ?? "", colors: Transform.randomColors(transformed.characterAtIndex(0))),
      PlayerStatsItemViewModel(title: "GP", value: usage.gp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
      PlayerStatsItemViewModel(title: " MIN", value: usage.min ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
      
      PlayerStatsItemViewModel(title: "USG%", value: usage.usgPercent ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
      PlayerStatsItemViewModel(title: "%FGM", value: usage.percentFgm ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
      PlayerStatsItemViewModel(title: "%FGA", value: usage.percentFga ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
      
      PlayerStatsItemViewModel(title: "%3PM", value: usage.percent3pm ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
      PlayerStatsItemViewModel(title: "%3PA", value: usage.percent3pa ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
      
      PlayerStatsItemViewModel(title: "%FTM", value: usage.percentFtm ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
      PlayerStatsItemViewModel(title: "%FTA", value: usage.percentFta ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
      
      PlayerStatsItemViewModel(title: "%OREB", value: usage.percentOreb ?? "", colors: Transform.randomColors(transformed.characterAtIndex(5))),
      PlayerStatsItemViewModel(title: "%DREB", value: usage.percentDreb ?? "", colors: Transform.randomColors(transformed.characterAtIndex(5))),
      PlayerStatsItemViewModel(title: "%REB", value: usage.percentReb ?? "", colors: Transform.randomColors(transformed.characterAtIndex(5))),
      
      PlayerStatsItemViewModel(title: "%AST", value: usage.percentAst ?? "", colors: Transform.randomColors(transformed.characterAtIndex(3))),
      PlayerStatsItemViewModel(title: "%TOV", value: usage.percentTov ?? "", colors: Transform.randomColors(transformed.characterAtIndex(3))),
      PlayerStatsItemViewModel(title: "%STL", value: usage.percentStl ?? "", colors: Transform.randomColors(transformed.characterAtIndex(3))),
      
      PlayerStatsItemViewModel(title: "%BLK", value: usage.percentBlk ?? "", colors: Transform.randomColors(transformed.characterAtIndex(2))),
      PlayerStatsItemViewModel(title: "%BLKA", value: usage.percentBlka ?? "", colors: Transform.randomColors(transformed.characterAtIndex(2))),
      
      PlayerStatsItemViewModel(title: "%PF", value: usage.percentPf ?? "", colors: Transform.randomColors(transformed.characterAtIndex(0))),
      PlayerStatsItemViewModel(title: "%PFD", value: usage.percentPfd ?? "", colors: Transform.randomColors(transformed.characterAtIndex(0))),
      PlayerStatsItemViewModel(title: "%PTS", value: usage.percentPts ?? "", colors: Transform.randomColors(transformed.characterAtIndex(0))),
    ]
  }
  
  // MARK: - Scoring Stats
  /*
   struct Scoring: Codable, Hashable {
     let id: String?
     let title: String?
     let teamTriCode: String?
     let gp: String?
     let min: String?
     
     let percentFga2pt: String? //%FGA 2PT: 2점 필드 골 시도가 전체 필드 골 시도(FGA)에서 차지하는 비율 (Percentage of Field Goal Attempts that are 2-Point Attempts).
     let percentFga3pt: String? //%FGA 3PT: 3점 필드 골 시도가 전체 필드 골 시도(FGA)에서 차지하는 비율 (Percentage of Field Goal Attempts that are 3-Point Attempts).
     
     let percentPts2pt: String? //%PTS 2PT: 전체 득점에서 2점 필드 골이 차지하는 비율 (Percentage of Points that are from 2-Point Field Goals).
     let percentPts2ptMr: String? //%PTS 2PT MR: 전체 득점에서 미드레인지 2점 필드 골이 차지하는 비율 (Percentage of Points that are from 2-Point Mid-Range Field Goals).
     let percentPts3pt: String? //%PTS 3PT: 전체 득점에서 3점 필드 골이 차지하는 비율 (Percentage of Points that are from 3-Point Field Goals).
     let percentPtsFbps: String? //%PTS FBPS: 전체 득점에서 속공 득점(Fast Break Points)이 차지하는 비율 (Percentage of Points that are from Fast Break Points).
     let percentPtsFt: String? //%PTS FT: 전체 득점에서 자유투 득점(Free Throws)이 차지하는 비율 (Percentage of Points that are from Free Throws).
     let percentPtsOffto: String? //%PTS OFFTO: 상대 팀의 턴오버 후 득점(Points Off Turnovers)이 전체 득점에서 차지하는 비율 (Percentage of Points that are from Points Off Turnovers).
     let percentPtsPitp: String? //%PTS PITP: 페인트 존 득점(Points in the Paint)이 전체 득점에서 차지하는 비율 (Percentage of Points that are from Points in the Paint). Turnovers).
     
     let secondFgmPercentAst: String? //2FGM %AST: 2점 필드 골 성공 중 어시스트된 비율 (Percentage of 2-Point Field Goals Made that were Assisted).
     let secondFgmPercentUast: String? //2FGM %UAST: 2점 필드 골 성공 중 어시스트 없이 성공한 비율 (Percentage of 2-Point Field Goals Made that were Unassisted).
     
     let thirdFgmPercentAst: String? //3FGM %AST: 3점 필드 골 성공 중 어시스트된 비율 (Percentage of 3-Point Field Goals Made that were Assisted).
     let thirdFgmPercentUast: String? //3FGM %UAST: 3점 필드 골 성공 중 어시스트 없이 성공한 비율 (Percentage of 3-Point Field Goals Made that were Unassisted).
     
     let fgmPercentAst: String? //FGM %AST: 전체 필드 골 성공 중 어시스트된 비율 (Percentage of Field Goals Made that were Assisted).
     let fgmPercentUast: String? //FGM %UAST: 전체 필드 골 성공 중 어시스트 없이 성공한 비율 (Percentage of Field Goals Made that were Unassisted).
   }
   */
  static func createScoringStatsItemViewModels(with scoring: Scoring, teamId: String) -> [PlayerStatsItemViewModel] {
    guard teamId.count >= 10 else { return [] }
    let transformed = Transform.transformTeamId(teamId)
    return [
      PlayerStatsItemViewModel(title: scoring.teamTriCode ?? "", value: scoring.title ?? "", colors: Transform.randomColors(transformed.characterAtIndex(0))),
      PlayerStatsItemViewModel(title: "GP", value: scoring.gp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
      PlayerStatsItemViewModel(title: " MIN", value: scoring.min ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
      
      PlayerStatsItemViewModel(title: "%FGA 2PT", value: scoring.percentFga2pt ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
      PlayerStatsItemViewModel(title: "%FGA 3PT", value: scoring.percentFga3pt ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
      
      PlayerStatsItemViewModel(title: "%PTS 2PT", value: scoring.percentPts2pt ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
      PlayerStatsItemViewModel(title: "%PTS 2PT MR", value: scoring.percentPts2ptMr ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
      PlayerStatsItemViewModel(title: "%PTS 3PT", value: scoring.percentPts3pt ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
      PlayerStatsItemViewModel(title: "%PTS FBPS", value: scoring.percentPtsFbps ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
      PlayerStatsItemViewModel(title: "%PTS FT", value: scoring.percentPtsFt ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
      PlayerStatsItemViewModel(title: "%PTS OFFTO", value: scoring.percentPtsOffto ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
      PlayerStatsItemViewModel(title: "%PTS PITP", value: scoring.percentPtsPitp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
      
      PlayerStatsItemViewModel(title: "2FGM %AST", value: scoring.secondFgmPercentAst ?? "", colors: Transform.randomColors(transformed.characterAtIndex(5))),
      PlayerStatsItemViewModel(title: "2FGM %UAST", value: scoring.secondFgmPercentUast ?? "", colors: Transform.randomColors(transformed.characterAtIndex(5))),
      
      PlayerStatsItemViewModel(title: "3FGM %AST", value: scoring.thirdFgmPercentAst ?? "", colors: Transform.randomColors(transformed.characterAtIndex(3))),
      PlayerStatsItemViewModel(title: "3FGM %UAST", value: scoring.thirdFgmPercentUast ?? "", colors: Transform.randomColors(transformed.characterAtIndex(3))),
      
      PlayerStatsItemViewModel(title: "FGM %AST", value: scoring.fgmPercentAst ?? "", colors: Transform.randomColors(transformed.characterAtIndex(4))),
      PlayerStatsItemViewModel(title: "FGM %UAST", value: scoring.fgmPercentUast ?? "", colors: Transform.randomColors(transformed.characterAtIndex(4))),
    ]
  }
  
  // MARK: - Misc Stats
  /*
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
   */
  static func createMiscStatsItemViewModels(with misc: Misc, teamId: String) -> [PlayerStatsItemViewModel] {
    guard teamId.count >= 10 else { return [] }
    let transformed = Transform.transformTeamId(teamId)
    return [
      PlayerStatsItemViewModel(title: misc.teamTriCode ?? "", value: misc.title ?? "", colors: Transform.randomColors(transformed.characterAtIndex(0))),
      PlayerStatsItemViewModel(title: "GP", value: misc.gp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
      PlayerStatsItemViewModel(title: " MIN", value: misc.min ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
      
      PlayerStatsItemViewModel(title: "PTS OFF TO", value: misc.ptsOffTo ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
      PlayerStatsItemViewModel(title: "2ND PTS", value: misc.secondPts ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
      PlayerStatsItemViewModel(title: "FBPS", value: misc.fbps ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
      PlayerStatsItemViewModel(title: "PITP", value: misc.pitp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
      
      PlayerStatsItemViewModel(title: "OPP PTS OFF TO", value: misc.oppPtsOffTo ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
      PlayerStatsItemViewModel(title: "OPP 2ND PTS", value: misc.oppSecondPts ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
      PlayerStatsItemViewModel(title: "OPP FBPS", value: misc.oppFbps ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
      PlayerStatsItemViewModel(title: "OPP PITP", value: misc.oppPitp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
      
      PlayerStatsItemViewModel(title: "BLK", value: misc.blk ?? "", colors: Transform.randomColors(transformed.characterAtIndex(5))),
      PlayerStatsItemViewModel(title: "BLKA", value: misc.blka ?? "", colors: Transform.randomColors(transformed.characterAtIndex(5))),
      PlayerStatsItemViewModel(title: "PF", value: misc.pf ?? "", colors: Transform.randomColors(transformed.characterAtIndex(5))),
      PlayerStatsItemViewModel(title: "PFD", value: misc.pfd ?? "", colors: Transform.randomColors(transformed.characterAtIndex(5))),
    ]
  }
  
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
