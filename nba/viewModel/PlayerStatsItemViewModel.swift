//
//  StatsItemViewModel.swift
//  nba
//
//  Created by 1100690 on 1/26/24.
//

import SwiftUI

struct PlayerStatsItemViewModel: Hashable {
    let title: String
    let value: String
    let colors: [Color]
}

extension PlayerStatsItemViewModel {
    static func ==(lhs: PlayerStatsItemViewModel, rhs: PlayerStatsItemViewModel) -> Bool {
        return lhs.title == rhs.title
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}
