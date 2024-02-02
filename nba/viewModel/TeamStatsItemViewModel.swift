//
//  TeamStatsItemViewModel.swift
//  nba
//
//  Created by 1100690 on 1/26/24.
//

import SwiftUI

struct TeamStatsItemViewModel: Hashable {
    let title: String
    let value: String
    let colors: [Color]
}

extension TeamStatsItemViewModel {
    static func ==(lhs: TeamStatsItemViewModel, rhs: TeamStatsItemViewModel) -> Bool {
        return lhs.title == rhs.title
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}
