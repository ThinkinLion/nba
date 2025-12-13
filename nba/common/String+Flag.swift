//
//  String+Flag.swift
//  nba
//
//  Created by Antigravity on 12/13/23.
//

import Foundation

extension String {
    var flagEmoji: String {
        switch self.lowercased() {
        case "usa", "us", "united states", "united states of america": return "🇺🇸"
        case "france": return "🇫🇷"
        case "germany": return "🇩🇪"
        case "canada": return "🇨🇦"
        case "australia": return "🇦🇺"
        case "serbia": return "🇷🇸"
        case "slovenia": return "🇸🇮"
        case "greece": return "🇬🇷"
        case "spain": return "🇪🇸"
        case "italy": return "🇮🇹"
        case "croatia": return "🇭🇷"
        case "lithuania": return "🇱🇹"
        case "turkey": return "🇹🇷"
        case "brazil": return "🇧🇷"
        case "argentina": return "🇦🇷"
        case "nigeria": return "🇳🇬"
        case "cameroon": return "🇨🇲"
        case "japan": return "🇯🇵"
        case "china": return "🇨🇳"
        case "latvia": return "🇱🇻"
        case "montenegro": return "🇲🇪"
        case "finland": return "🇫🇮"
        case "ukraine": return "🇺🇦"
        case "georgia": return "🇬🇪"
        case "poland": return "🇵🇱"
        case "czech republic", "czechia": return "🇨🇿"
        case "bosnia", "bosnia & herzegovina", "bosnia and herzegovina": return "🇧🇦"
        case "democratic republic of the congo", "drc": return "🇨🇩"
        case "dominican republic": return "🇩🇴"
        case "bahamas": return "🇧🇸"
        case "uk", "united kingdom", "great britain": return "🇬🇧"
        case "israel": return "🇮🇱"
        case "new zealand": return "🇳🇿"
        case "senegal": return "🇸🇳"
        case "switzerland": return "🇨🇭"
        case "south sudan": return "🇸🇸"
        case "sudan": return "🇸🇩"
        case "jamaica": return "🇯🇲"
        case "saint lucia": return "🇱🇨"
        default: return ""
        }
    }
}
