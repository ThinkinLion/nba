//
//  SeasonLeadersModel.swift
//  nba
//
//  Created by 1100690 on 12/3/23.
//

import Foundation
import FirebaseFirestoreSwift

struct SeasonLeadersModel: Codable {
    @DocumentID var id: String?
    let pointsPerGame: SeasonLeaders?
    let reboundsPerGame: SeasonLeaders?
    let assistsPerGame: SeasonLeaders?
    let blocksPerGame: SeasonLeaders?
    let stealsPerGame: SeasonLeaders?
    let fieldGoalPercentage: SeasonLeaders?
    let threePointersMade: SeasonLeaders?
    let threePointPercentage: SeasonLeaders?
    let fantasyPointsPerGame: SeasonLeaders?
    
    enum CodingKeys: String, CodingKey {
        case pointsPerGame = "PointsPerGame"
        case reboundsPerGame = "ReboundsPerGame"
        case assistsPerGame = "AssistsPerGame"
        case blocksPerGame = "BlocksPerGame"
        case stealsPerGame = "StealsPerGame"
        case fieldGoalPercentage = "FieldGoalPercentage"
        case threePointersMade = "ThreePointersMade"
        case threePointPercentage = "ThreePointPercentage"
        case fantasyPointsPerGame = "FantasyPointsPerGame"
    }
}

struct SeasonLeaders: Codable {
    let title: String
    let items: [SeasonLeader]
}

extension SeasonLeaders {
    static var empty = SeasonLeaders(title: "", items: [])
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
