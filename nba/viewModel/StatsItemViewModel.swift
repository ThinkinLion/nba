//
//  StatsItemViewModel.swift
//  nba
//
//  Created by 1100690 on 1/26/24.
//

import SwiftUI

struct StatsItemViewModel: Hashable {
    let title: String
    let value: String
    let colors: [Color]
}

extension StatsItemViewModel {
    static func ==(lhs: StatsItemViewModel, rhs: StatsItemViewModel) -> Bool {
        return lhs.title == rhs.title
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}
