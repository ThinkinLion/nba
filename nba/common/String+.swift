//
//  String+.swift
//  nba
//
//  Created by 1100690 on 12/1/23.
//

import Foundation

extension String {
    var imageUrl: String {
        //260x190: https://cdn.nba.com/headshots/nba/latest/260x190/1631260.png
        let imageUrl = "https://cdn.nba.com/headshots/nba/latest/1040x760/{{playerId}}.png".replacingOccurrences(of: "{{playerId}}", with: self)
        print("\(self)'s imageUrl: \(imageUrl)")
        return imageUrl
    }
    
    var dark: String {
        self.teamIdToNickName.toDarkColor
    }
    
    var light: String {
        self.teamIdToNickName.toLightColor
    }
    
    var toLightColor: String {
        self.lowercased() + ".light"
    }
    
    var toDarkColor: String {
        self.lowercased() + ".dark"
    }
    
    var ordinal: String {
        guard let number = Int(self) else { return self }
        switch number % 100 {
        case 11, 12, 13:
            return "\(number)th"
        default:
            switch number % 10 {
            case 1:
                return "\(number)st"
            case 2:
                return "\(number)nd"
            case 3:
                return "\(number)rd"
            default:
                return "\(number)th"
            }
        }
    }
    
    var abbreviation: String {
        var abbreviation = self.lowercased()
        if abbreviation.contains("guard") {
            abbreviation = abbreviation.replacingOccurrences(of: "guard", with: "G")
        }
        if abbreviation.contains("forward") {
            abbreviation = abbreviation.replacingOccurrences(of: "forward", with: "F")
        }
        if abbreviation.contains("center") {
            abbreviation = abbreviation.replacingOccurrences(of: "center", with: "C")
        }
        return abbreviation
    }
}

extension String {
    var nickNameToTriCode: String {
        switch self.lowercased() {
        case "76ers", "sixers": return "PHI"
        case "blazers", "trail blazers": return "POR"
        case "bucks": return "MIL"
        case "bulls": return "CHI"
        case "cavaliers": return "CLE"
        case "celtics": return "BOS"
        case "clippers": return "LAC"
        case "grizzlies": return "MEM"
        case "hawks": return "ATL"
        case "heat": return "MIA"
        case "hornets": return "CHA"
        case "jazz": return "UTA"
        case "kings": return "SAC"
        case "knicks": return "NYK"
        case "lakers": return "LAL"
        case "magic": return "ORL"
        case "mavericks": return "DAL"
        case "nets": return "BKN"
        case "nuggets": return "DEN"
        case "pacers": return "IND"
        case "pelicans": return "NOP"
        case "pistons": return "DET"
        case "raptors": return "TOR"
        case "rockets": return "HOU"
        case "spurs": return "SAS"
        case "suns": return "PHX"
        case "thunder": return "OKC"
        case "timberwolves": return "MIN"
        case "warriors": return "GSW"
        case "wizards": return "WAS"
        default: return ""
        }
    }

    var triCodeToNickName: String {
        switch self {
        case "PHI": return "76ers"
        case "POR": return "trail blazers"
        case "MIL": return "bucks"
        case "CHI": return "bulls"
        case "CLE": return "cavaliers"
        case "BOS": return "celtics"
        case "LAC": return "clippers"
        case "MEM": return "grizzlies"
        case "ATL": return "hawks"
        case "MIA": return "heat"
        case "CHA": return "hornets"
        case "UTA": return "jazz"
        case "SAC": return "kings"
        case "NYK": return "knicks"
        case "LAL": return "lakers"
        case "ORL": return "magic"
        case "DAL": return "mavericks"
        case "BKN": return "nets"
        case "DEN": return "nuggets"
        case "IND": return "pacers"
        case "NOP": return "pelicans"
        case "DET": return "pistons"
        case "TOR": return "raptors"
        case "HOU": return "rockets"
        case "SAS": return "spurs"
        case "PHX": return "suns"
        case "OKC": return "thunder"
        case "MIN": return "timberwolves"
        case "GSW": return "warriors"
        case "WAS": return "wizards"
        default: return ""
        }
    }

    var teamIdToNickName: String {
        switch self {
        case "1610612752": return "knicks" // east
        case "1610612741": return "bulls"
        case "1610612764": return "wizards"
        case "1610612748": return "heat"
        case "1610612766": return "hornets"
        case "1610612755": return "sixers"
        case "1610612761": return "raptors"
        case "1610612749": return "bucks"
        case "1610612751": return "nets"
        case "1610612737": return "hawks"
        case "1610612739": return "cavaliers"
        case "1610612738": return "celtics"
        case "1610612765": return "pistons"
        case "1610612753": return "magic"
        case "1610612754": return "pacers" // west
        case "1610612744": return "warriors"
        case "1610612762": return "jazz"
        case "1610612743": return "nuggets"
        case "1610612742": return "mavericks"
        case "1610612758": return "kings"
        case "1610612757": return "blazers"
        case "1610612750": return "timberwolves"
        case "1610612747": return "lakers"
        case "1610612763": return "grizzlies"
        case "1610612756": return "suns"
        case "1610612759": return "spurs"
        case "1610612746": return "clippers"
        case "1610612745": return "rockets"
        case "1610612760": return "thunder"
        case "1610612740": return "pelicans"
        default: return ""
        }
    }
    
    var teamIdToTriCode: String {
        switch self {
        case "1610612752": return "NYK" // east
        case "1610612741": return "CHI"
        case "1610612764": return "WAS"
        case "1610612748": return "MIA"
        case "1610612766": return "CHA"
        case "1610612755": return "PHI"
        case "1610612761": return "TOR"
        case "1610612749": return "MIL"
        case "1610612751": return "BKN"
        case "1610612737": return "ATL"
        case "1610612739": return "CLE"
        case "1610612738": return "BOS"
        case "1610612765": return "DET"
        case "1610612753": return "ORL"
        case "1610612754": return "IND"
        case "1610612744": return "GSW" // west
        case "1610612762": return "UTA"
        case "1610612743": return "DEN"
        case "1610612742": return "DAL"
        case "1610612758": return "SAC"
        case "1610612757": return "POR"
        case "1610612750": return "MIN"
        case "1610612747": return "LAL"
        case "1610612763": return "MEM"
        case "1610612756": return "PHX"
        case "1610612759": return "SAS"
        case "1610612746": return "LAC"
        case "1610612745": return "HOU"
        case "1610612760": return "OKC"
        case "1610612740": return "NOP"
        default: return ""
        }
    }
    
    var triCodeToTeamId: String {
            switch self {
            case "NYK": return "1610612752" // east
            case "CHI": return "1610612741"
            case "WAS": return "1610612764"
            case "MIA": return "1610612748"
            case "CHA": return "1610612766"
            case "PHI": return "1610612755"
            case "TOR": return "1610612761"
            case "MIL": return "1610612749"
            case "BKN": return "1610612751"
            case "ATL": return "1610612737"
            case "CLE": return "1610612739"
            case "BOS": return "1610612738"
            case "DET": return "1610612765"
            case "ORL": return "1610612753"
            case "IND": return "1610612754"
            case "GSW": return "1610612744" // west
            case "UTA": return "1610612762"
            case "DEN": return "1610612743"
            case "DAL": return "1610612742"
            case "SAC": return "1610612758"
            case "POR": return "1610612757"
            case "MIN": return "1610612750"
            case "LAL": return "1610612747"
            case "MEM": return "1610612763"
            case "PHX": return "1610612756"
            case "SAS": return "1610612759"
            case "LAC": return "1610612746"
            case "HOU": return "1610612745"
            case "OKC": return "1610612760"
            case "NOP": return "1610612740"
            default: return ""
            }
        }
}
