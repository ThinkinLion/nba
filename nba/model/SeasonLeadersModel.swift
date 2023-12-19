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
    let seasonLeadersPointsPerGame: SeasonLeaders?
    let seasonLeadersReboundsPerGame: SeasonLeaders?
    let seasonLeadersAssistsPerGame: SeasonLeaders?
    let seasonLeadersBlocksPerGame: SeasonLeaders?
    let seasonLeadersStealsPerGame: SeasonLeaders?
    let seasonLeadersFieldGoalPercentage: SeasonLeaders?
    let seasonLeadersThreePointersMade: SeasonLeaders?
    let seasonLeadersThreePointPercentage: SeasonLeaders?
    let seasonLeadersFantasyPointsPerGame: SeasonLeaders?
    
    //advanced
    let advancedTrueShootingPercentage: SeasonLeaders?
    let advancedUsagePercentage: SeasonLeaders?
    let advancedOffensiveReboundPercentage: SeasonLeaders?
    
    //miscellaneous
    let miscellaneousFastBreakPointsPerGame: SeasonLeaders?
    let miscellaneous2ndChancePointsPerGame: SeasonLeaders?
    let miscellaneousPointsInThePaintPerGame: SeasonLeaders?
    
    //playerTrackingPassing
    let playerTrackingPassingPassesPerGame: SeasonLeaders?
    let playerTrackingPassingPointsFromAssistsPerGame: SeasonLeaders?
    let playerTrackingPassingPotentialAssistsPerGame: SeasonLeaders?
    
    //scoring
    let scoringPercentageofPoints3PT: SeasonLeaders?
    let scoringPercentageofPointsinthePaint: SeasonLeaders?
    let scoringPercentageofPointsMidRange: SeasonLeaders?
    
    //centers
    let centersPointsPerGame: SeasonLeaders?
    let centersReboundsPerGame: SeasonLeaders?
    let centersAssistsPerGame: SeasonLeaders?
    
    //forwards
    let forwardsPointsPerGame: SeasonLeaders?
    let forwardsReboundsPerGame: SeasonLeaders?
    let forwardsAssistsPerGame: SeasonLeaders?
    
    //guards
    let guardsPointsPerGame: SeasonLeaders?
    let guardsReboundsPerGame: SeasonLeaders?
    let guardsAssistsPerGame: SeasonLeaders?
    
    //rookies
    let rookiesMinutesPerGame: SeasonLeaders?
    let rookiesPointsPerGame: SeasonLeaders?
    let rookiesDoubleDoubles: SeasonLeaders?
    
    //seasonLeaders more
    let seasonLeadersMostTotalPoints: SeasonLeaders?
    let seasonLeadersMostPointsinaGame: SeasonLeaders?
    let seasonLeadersMostReboundsinaGame: SeasonLeaders?
    let seasonLeadersMostAssistsinaGame: SeasonLeaders?
    let seasonLeadersMostStealsinaGame: SeasonLeaders?
    let seasonLeadersMostBlocksinaGame: SeasonLeaders?
    let seasonLeadersHighestPercentageofPTS3PT: SeasonLeaders?
    let seasonLeadersHighestPercentageofPTS2PT: SeasonLeaders?
    let seasonLeadersHighestPercentageofPTSMidRange: SeasonLeaders?
}

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
