//
//  Scoring.swift
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
             
             "percentFga2pt": data_elements[4] if len(data_elements) > 4 else "",
             "percentFga3pt": data_elements[5] if len(data_elements) > 5 else "",

             "percentPts2pt": data_elements[6] if len(data_elements) > 6 else "",
             "percentPts2ptMr": data_elements[7] if len(data_elements) > 7 else "",
             "percentPts3pt": data_elements[8] if len(data_elements) > 8 else "",
             "percentPtsFbps": data_elements[9] if len(data_elements) > 9 else "",
             "percentPtsFt": data_elements[10] if len(data_elements) > 10 else "",
             "percentPtsOffto": data_elements[11] if len(data_elements) > 11 else "",
             "percentPtsPitp": data_elements[12] if len(data_elements) > 12 else "",

             "secondFgmPercentAst": data_elements[13] if len(data_elements) > 13 else "",
             "secondFgmPercentUast": data_elements[14] if len(data_elements) > 14 else "",

             "thirdFgmPercentAst": data_elements[15] if len(data_elements) > 15 else "",
             "thirdFgmPercentUast": data_elements[16] if len(data_elements) > 16 else "",

             "fgmPercentAst": data_elements[17] if len(data_elements) > 17 else "",
             "fgmPercentUast": data_elements[18] if len(data_elements) > 18 else "",
 
              %fga 2pt, %fga 3pt, %pts 2pt, %pts 2pt mr, %pts 3pt, %pts fbps, %pts ft, %pts offto, %pts pitp, 2fgm %ast, 2fgm %uast, 3fgm %ast, 3fgm %uast, fgm %ast, fgm %uast
         }
 */
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

extension Scoring {
    static func ==(lhs: Scoring, rhs: Scoring) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Scoring: StatsGeneratable {
    func createStatsItemViewModels(teamId: String) -> [PlayerStatsItemViewModel] {
        return ModelFactory.createScoringStatsItemViewModels(with: self, teamId: teamId)
    }
}
