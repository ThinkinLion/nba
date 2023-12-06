//
//  GamesModel.swift
//  nba
//
//  Created by 1100690 on 11/29/23.
//

import Foundation
import FirebaseFirestoreSwift

struct GamesModel: Codable {
    @DocumentID var id: String?
    let items: [HomeAway]
}

struct HomeAway: Codable, Hashable {
    let home: Game
    let away: Game
}

extension HomeAway {
    static func ==(lhs: HomeAway, rhs: HomeAway) -> Bool {
        return lhs.home.id == rhs.home.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(home.id)
    }
}

struct Game: Identifiable, Codable, Hashable {
    var id = UUID()
    let teamId: String
    let teamCode: String
    let record: String
    let score: String?
}

extension Game {
    static func ==(lhs: Game, rhs: Game) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
