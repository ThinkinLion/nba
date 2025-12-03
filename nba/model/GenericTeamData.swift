//
//  GenericTeamData.swift
//  nba
//
//  Created on 12/10/24.
//

import Foundation

struct GenericTeamData {
    struct Info {
        let name: String
        let triCode: String
        let colorName: String // Use existing color names for now as they are just hex codes or semantic names
    }
    
    static let mapping: [String: Info] = [
        "1610612737": Info(name: "Atlanta", triCode: "ATL", colorName: "hawks"),
        "1610612738": Info(name: "Boston", triCode: "BOS", colorName: "celtics"),
        "1610612751": Info(name: "Brooklyn", triCode: "BKN", colorName: "nets"),
        "1610612766": Info(name: "Charlotte", triCode: "CHA", colorName: "hornets"),
        "1610612741": Info(name: "Chicago", triCode: "CHI", colorName: "bulls"),
        "1610612739": Info(name: "Cleveland", triCode: "CLE", colorName: "cavaliers"),
        "1610612742": Info(name: "Dallas", triCode: "DAL", colorName: "mavericks"),
        "1610612743": Info(name: "Denver", triCode: "DEN", colorName: "nuggets"),
        "1610612765": Info(name: "Detroit", triCode: "DET", colorName: "pistons"),
        "1610612744": Info(name: "Golden State", triCode: "GSW", colorName: "warriors"),
        "1610612745": Info(name: "Houston", triCode: "HOU", colorName: "rockets"),
        "1610612754": Info(name: "Indiana", triCode: "IND", colorName: "pacers"),
        "1610612746": Info(name: "LA Clippers", triCode: "LAC", colorName: "clippers"),
        "1610612747": Info(name: "LA Lakers", triCode: "LAL", colorName: "lakers"),
        "1610612763": Info(name: "Memphis", triCode: "MEM", colorName: "grizzlies"),
        "1610612748": Info(name: "Miami", triCode: "MIA", colorName: "heat"),
        "1610612749": Info(name: "Milwaukee", triCode: "MIL", colorName: "bucks"),
        "1610612750": Info(name: "Minnesota", triCode: "MIN", colorName: "timberwolves"),
        "1610612740": Info(name: "New Orleans", triCode: "NOP", colorName: "pelicans"),
        "1610612752": Info(name: "New York", triCode: "NYK", colorName: "knicks"),
        "1610612760": Info(name: "Oklahoma City", triCode: "OKC", colorName: "thunder"),
        "1610612753": Info(name: "Orlando", triCode: "ORL", colorName: "magic"),
        "1610612755": Info(name: "Philadelphia", triCode: "PHI", colorName: "sixers"),
        "1610612756": Info(name: "Phoenix", triCode: "PHX", colorName: "suns"),
        "1610612757": Info(name: "Portland", triCode: "POR", colorName: "blazers"),
        "1610612758": Info(name: "Sacramento", triCode: "SAC", colorName: "kings"),
        "1610612759": Info(name: "San Antonio", triCode: "SAS", colorName: "spurs"),
        "1610612761": Info(name: "Toronto", triCode: "TOR", colorName: "raptors"),
        "1610612762": Info(name: "Utah", triCode: "UTA", colorName: "jazz"),
        "1610612764": Info(name: "Washington", triCode: "WAS", colorName: "wizards")
    ]
    
    static func get(for teamId: String) -> Info? {
        return mapping[teamId]
    }
    
    static func get(byTriCode triCode: String) -> Info? {
        return mapping.values.first { $0.triCode == triCode }
    }
}
