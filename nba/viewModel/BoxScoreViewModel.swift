//
//  BoxScoreViewModel.swift
//  nba
//
//  Created by 1100690 on 1/3/24.
//

import Foundation

struct BoxScoreViewModel {
    private let boxScore: BoxScore
    
    init(boxScore: BoxScore) {
        self.boxScore = boxScore
    }
    
    var playerId: String {
        boxScore.playerId ?? ""
    }
    
    var teamId: String {
        boxScore.teamId ?? ""
    }
    
    var fullName: String {
        firstName + " " + lastName
    }
    
    var firstName: String {
        boxScore.firstName ?? ""
    }
    
    var lastName: String {
        boxScore.lastName ?? ""
    }

}
