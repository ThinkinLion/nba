//
//  Usage.swift
//  nba
//
//  Created by 1100690 on 10/26/24.
//

import Foundation

/*
 test
 stats_data = {
             "id": str(uuid.uuid4()),
             "title": data_elements[0] if len(data_elements) > 0 else "",
             "teamTriCode": data_elements[1] if len(data_elements) > 1 else "",
             "gp": data_elements[2] if len(data_elements) > 2 else "",
             "min": data_elements[3] if len(data_elements) > 3 else "",
             
             "usgPercent": data_elements[4] if len(data_elements) > 4 else "",
             "percentFgm": data_elements[5] if len(data_elements) > 5 else "",
             "percentFga": data_elements[6] if len(data_elements) > 6 else "",

             "percent3pm": data_elements[7] if len(data_elements) > 7 else "",
             "percent3pa": data_elements[8] if len(data_elements) > 8 else "",

             "percentFtm": data_elements[9] if len(data_elements) > 9 else "",
             "percentFta": data_elements[10] if len(data_elements) > 10 else "",

             "percentOreb": data_elements[11] if len(data_elements) > 11 else "",
             "percentDreb": data_elements[12] if len(data_elements) > 12 else "",
             "percentReb": data_elements[13] if len(data_elements) > 13 else "",

             "percentAst": data_elements[14] if len(data_elements) > 14 else "",
             "percentTov": data_elements[15] if len(data_elements) > 15 else "",
             "percentStl": data_elements[16] if len(data_elements) > 16 else "",

             "percentBlk": data_elements[17] if len(data_elements) > 17 else "",
             "percentBlka": data_elements[18] if len(data_elements) > 18 else "",

             "percentPf": data_elements[19] if len(data_elements) > 19 else "",
             "percentPfd": data_elements[20] if len(data_elements) > 20 else "",
             "percentPts": data_elements[21] if len(data_elements) > 21 else "",
 
            "usg%" "%fgm" "%fga" "%3pm" "%3pa" "%ftm" "%fta" "%oreb" "%dreb" "%reb" "%ast" "%tov" "%stl" "%blk" "%blka" "%pf" "%pfd" "%pts"
 
         }
 */
struct Usage: Codable, Hashable {
  let id: String?
  let title: String?
  let teamTriCode: String?
  let gp: String?
  let min: String?
  
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

extension Usage {
    static func ==(lhs: Usage, rhs: Usage) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Usage: StatsGeneratable {
    func createStatsItemViewModels(teamId: String) -> [PlayerStatsItemViewModel] {
        return ModelFactory.createUsageStatsItemViewModels(with: self, teamId: teamId)
    }
}
