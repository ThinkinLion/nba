//
//  Standings.swift
//  nba
//
//  Created by 1100690 on 2023/11/09.
//

import Foundation
import FirebaseFirestoreSwift

struct Standings: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
    let position: Int
}

extension Standings {
    static var empty = Standings(name: "Boston", position: 0)
    static var sample = [
        Standings(id: "red", name: "Boston", position: 1),
        Standings(id: "cerise", name: "Cerise", position: 2)
    ]
}
