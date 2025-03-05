//
//  PowerRankingModel.swift
//  nba
//
//  Created by 1100690 on 12/10/24.
//

/*
 newdata["title"] = article_title
 newdata["subTitle"] = article_subtitle
 newdata["image"] = img_src
 newdata["imageDesc"] = img_desc
 newdata["week"] = week
 newdata["items"] = items
 
 items = {
     "id": str(uuid.uuid4()),
     "rank": rank_text,
     "record": record,
     "teamName": team_name,
     "teamCode": team_code,
     "lastWeek": rank_change,
     "advanced": advanced,
     "overview": overview,
     "takeaways": takeaways,
     "upcomming": upcoming,
 }
 */
struct PowerRankingModel: Codable, Hashable {
    let id: String?
    let week: String?
    let title: String?
    let subTitle: String?
    let image: String?
    let imageDesc: String?
    
    let items: [PowerRankingTeamModel]?
}

extension PowerRankingModel {
    static func ==(lhs: PowerRankingModel, rhs: PowerRankingModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension PowerRankingModel {
  static var empty = PowerRankingModel(id: "", week: "", title: "", subTitle: "", image: "", imageDesc: "", items: [])
}

struct PowerRankingTeamModel: Codable, Hashable {
  let id: String?
  let rank: String?
  let record: String?
  let teamName: String?
  let teamCode: String?
  let lastWeek: String?
  let advanced: PowerRankingAdvancedModel?
  let overview: String?
  let takeaways: [String]?
  let upcomming: String?
}

extension PowerRankingTeamModel {
  static func ==(lhs: PowerRankingTeamModel, rhs: PowerRankingTeamModel) -> Bool {
    lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

struct PowerRankingAdvancedModel: Codable {
  let defRtg: PowerRankingAdvancedItemModel?
  let offfRtg: PowerRankingAdvancedItemModel?
  let netRtg: PowerRankingAdvancedItemModel?
  let pace: PowerRankingAdvancedItemModel?
}

struct PowerRankingAdvancedItemModel: Codable {
  let title: String?
  let value: String?
  let rank: String?
}
