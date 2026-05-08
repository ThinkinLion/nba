//
//  PlayoffSeries.swift
//  nba
//

import Foundation

enum PlayoffBracketSide: String, Hashable {
    case east
    case west
    case finals
    case undetermined
}

struct PlayoffGame: Identifiable, Hashable {
    var id: String { homeAway.gameId ?? UUID().uuidString }
    let homeAway: HomeAway
    let date: String
}

/// One best-of series row from recap `series` text. Round grouping is derived in `PlayoffViewModel` (bracket counts + seeds), not from this string alone.
struct PlayoffSeries: Identifiable, Hashable {
    var id: String { "\(awayTeamCode)-vs-\(homeTeamCode)" }
    let awayTeamCode: String
    let homeTeamCode: String
    let awayTeamId: String
    let homeTeamId: String
    let awayTeamName: String
    let homeTeamName: String
    /// Raw Firestore / scoreboard copy (e.g. `Games 3: BOS leads 2-1`).
    let status: String
    let latestDate: String
    let conference: String
    var games: [PlayoffGame] = []
    
    var isFinished: Bool {
        Self.statusIndicatesSeriesComplete(status)
    }
    
    static func statusIndicatesSeriesComplete(_ raw: String) -> Bool {
        let s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !s.isEmpty else { return false }
        let u = s.uppercased()
        if s.range(of: #"(?i)\bwins?\b"#, options: .regularExpression) != nil { return true }
        if u.contains("WINS SERIES") || u.contains("CLINCH") || u.contains("ADVANCES") { return true }
        if u.range(of: #"\b4\s*[-–]\s*[0-3]\b"#, options: .regularExpression) != nil { return true }
        if u.range(of: #"\b[0-3]\s*[-–]\s*4\b"#, options: .regularExpression) != nil { return true }
        return false
    }
}
