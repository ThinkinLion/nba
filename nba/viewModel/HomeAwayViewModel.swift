//
//  HomeAwayViewModel.swift
//  nba
//
//  Created by 1100690 on 12/1/23.
//

import Foundation

struct HomeAwayViewModel {
    private let homeAway: HomeAway
    
    init(homeAway: HomeAway) {
        self.homeAway = homeAway
    }
    
    var homeTeamCode: String {
        homeAway.home.teamCode.lowercased()
    }
    
    var awayTeamCode: String {
        homeAway.away.teamCode.lowercased()
    }
    
    var homeScore: String {
        homeAway.home.score ?? "0"
    }
    
    var awayScore: String {
        homeAway.away.score ?? "0"
    }
}
