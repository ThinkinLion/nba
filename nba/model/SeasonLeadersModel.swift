//
//  SeasonLeadersModel.swift
//  nba
//
//  Created by 1100690 on 12/3/23.
//

import Foundation

// statsLeaders.{season} 문서의 카테고리 1개 (Top 5). 문서 전체는 LeadersStore 가 [String: SeasonLeaders] 로 읽음

struct SeasonLeaders: Codable, Hashable {
    let title: String
    let category: String
    let items: [SeasonLeader]
}

extension SeasonLeaders {
    static var empty = SeasonLeaders(title: "", category: "", items: [])
}

extension SeasonLeaders {
    static func ==(lhs: SeasonLeaders, rhs: SeasonLeaders) -> Bool {
        return lhs.title == rhs.title && lhs.category == rhs.category
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}

struct SeasonLeader: Identifiable, Codable, Hashable {
    var id = UUID()
    let playerId: String?
    let name: String?
    let teamTriCode: String?
    let rank: String?
    let points: String?
}

extension SeasonLeader {
    static func ==(lhs: SeasonLeader, rhs: SeasonLeader) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
