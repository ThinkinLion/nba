//
//  NBAStaticConference.swift
//  nba
//
//  Fallback when Firestore standings keys don’t match game team codes.
//

import Foundation

enum NBAStaticConference {
    static let easternTriCodes: Set<String> = [
        "ATL", "BOS", "BKN", "CHA", "CHO", "CHI", "CLE", "DET", "IND", "MIA", "MIL",
        "NYK", "ORL", "PHI", "TOR", "WAS",
    ]
    
    static let westernTriCodes: Set<String> = [
        "DAL", "DEN", "GSW", "HOU", "LAC", "LAL", "MEM", "MIN", "NOP", "OKC", "PHX",
        "POR", "SAC", "SAS", "UTA",
    ]
    
    /// Returns `"East"` / `"West"` for known NBA tri codes (after alias normalization).
    static func leagueConference(forTriCode tri: String) -> String? {
        let u = normalizeTriAlias(tri.uppercased())
        if easternTriCodes.contains(u) { return "East" }
        if westernTriCodes.contains(u) { return "West" }
        return nil
    }
    
    /// Normalize alternate feeds (PHO/PHX, CHO/CHA, NOL/NOP, etc.)
    static func normalizeTriAlias(_ u: String) -> String {
        switch u {
        case "PHO": return "PHX"
        case "CHO": return "CHA"
        case "NOL", "NO": return "NOP"
        default: return u
        }
    }
    
    /// Box score `teamCode` may be tri (`BOS`) or nickname (`celtics`).
    static func normalizedTriCode(fromTeamCode raw: String) -> String? {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return nil }
        if t.count == 3 {
            return normalizeTriAlias(t.uppercased())
        }
        let tri = t.nickNameToTriCode
        guard !tri.isEmpty else { return nil }
        return normalizeTriAlias(tri.uppercased())
    }
}
