//
//  TeamDetailViewState.swift
//  nba
//
//  Created by Antigravity on 12/10/24.
//

import SwiftUI

struct TeamDetailViewState {
    let triCode: String?
    let name: String
    let rank: String?
    let record: String?
    let rankChangeText: String
    let rankChangeStyle: RankChangeStyle
    let overview: String?
    let takeaways: [String]?
    let upcoming: String?
    let advanced: PowerRankingAdvancedModel?
    let backgroundColorName: String
    var isFromStandings: Bool = false
    
    var teamId: String {
        guard let triCode = triCode else { return "" }
        return triCode.triCodeToTeamId
    }
  
    var backgroundColor: Color {
        Color(backgroundColorName + ".light")
    }
    
    var darkBackgroundColor: Color {
        Color(backgroundColorName + ".dark")
    }
    
    // 팀 컬러를 기반으로 한 그라디언트 (타이틀용)
    var titleGradientColors: [Color] {
        let base = backgroundColor
        return [
            .white,
            .white,
            base.opacity(0.8)
        ]
    }
    
    // MARK: - Momentum Logic
    enum MomentumState {
        case onFire    // 🔥🔥🔥
        case hot       // 🔥
        case neutral   // 😐
        case cold      // ❄️
        case iceCold   // 🧊
        
        var title: String {
            switch self {
            case .onFire: return "ON FIRE"
            case .hot: return "HEATING UP"
            case .neutral: return "STEADY"
            case .cold: return "COOLING DOWN"
            case .iceCold: return "ICE COLD"
            }
        }
        
        var icon: String {
            switch self {
            case .onFire: return "🔥🔥🔥"
            case .hot: return "🔥"
            case .neutral: return "😐"
            case .cold: return "❄️"
            case .iceCold: return "🧊"
            }
        }
        
        var color: Color {
            switch self {
            case .onFire: return .red
            case .hot: return .orange
            case .neutral: return .gray
            case .cold: return .blue
            case .iceCold: return .cyan
            }
        }
    }
    
    var momentum: MomentumState {
        switch rankChangeStyle {
        case .up:
            // 순위 상승폭이 크면 On Fire (예: +4 이상)
            if let change = Int(rankChangeText.replacingOccurrences(of: "+", with: "")), change >= 4 {
                return .onFire
            }
            return .hot
        case .same:
            return .neutral
        case .down:
            // 순위 하락폭이 크면 Ice Cold (예: -4 이하)
            if let change = Int(rankChangeText.replacingOccurrences(of: "-", with: "")), change >= 4 {
                return .iceCold
            }
            return .cold
        }
    }
    
    var radarChartData: [Double] {
        guard let advanced = advanced else { return [0.1, 0.1, 0.1, 0.1] }
        
        let offRank = Double(advanced.offRtg?.rank ?? "30") ?? 30.0
        let defRank = Double(advanced.defRtg?.rank ?? "30") ?? 30.0
        let netRank = Double(advanced.netRtg?.rank ?? "30") ?? 30.0
        let paceRank = Double(advanced.pace?.rank ?? "30") ?? 30.0
        
        // Normalize: 1st -> 1.0, 30th -> 0.1 (to avoid zero radius)
        let offVal = max(0.1, (31.0 - offRank) / 30.0)
        let defVal = max(0.1, (31.0 - defRank) / 30.0)
        let netVal = max(0.1, (31.0 - netRank) / 30.0)
        let paceVal = max(0.1, (31.0 - paceRank) / 30.0)
        
        return [offVal, defVal, netVal, paceVal]
    }
    
    static func findKeyPlayerId(from players: [PlayerModel]) -> String? {
        return players.map { player -> (id: String?, score: Double) in
            // 1. PIE (Player Impact Estimate) - 가장 정확한 공헌도 지표
            if let pieString = player.pie, let pie = Double(pieString), pie > 0 {
                return (player.id, pie * 100) // PIE는 보통 0.1~0.2 수준이므로 점수화
            }
            
            // 2. Fantasy Points (Traditional Stats에 있는 경우)
            if let traditional = player.traditional?.first,
               let fpString = traditional.fp,
               let fp = Double(fpString), fp > 0 {
                return (player.id, fp)
            }
            
            // 3. Fallback: Composite Score (PPG + RPG + APG)
            let p = Double(player.ppg ?? "0") ?? 0
            let r = Double(player.rpg ?? "0") ?? 0
            let a = Double(player.apg ?? "0") ?? 0
            return (player.id, p + r + a)
        }
        .filter { $0.score >= 10.0 } // 최소 점수 기준 (PIE 10.0은 0.1, FP 10.0, Composite 10.0)
        .max(by: { $0.score < $1.score })?
        .id
    }
}
