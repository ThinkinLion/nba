//
//  StatsGeneratable.swift
//  nba
//
//  Created by 1100690 on 10/22/24.
//

import Foundation

protocol StatsGeneratable {
  func createStatsItemViewModels(teamId: String) -> [PlayerStatsItemViewModel]
}
