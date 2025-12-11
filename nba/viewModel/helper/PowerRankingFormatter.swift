//
//  PowerRankingFormatter.swift
//  nba
//
//  Created by Antigravity on 12/10/24.
//

import SwiftUI

class PowerRankingFormatter {
    
    // RankChangeStyle에 따른 색상 반환
    static func rankChangeColor(for style: RankChangeStyle) -> Color {
        switch style {
        case .up:
            return .green
        case .down:
            return .red
        case .same:
            return .white.opacity(0.6)
        }
    }
    
    // 날짜 포맷팅
    static func formatGameDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date).uppercased()
        }
        
        return dateString
    }
    
    // 포지션 축약
    static func abbreviatePosition(_ position: String) -> String {
        let lowercased = position.lowercased()
        
        // 하이픈으로 구분된 포지션 처리
        if lowercased.contains("-") {
            let parts = lowercased.components(separatedBy: "-")
            let abbreviated = parts.map { part in
                switch part.trimmingCharacters(in: .whitespaces) {
                case "point guard", "guard":
                    return "G"
                case "shooting guard":
                    return "SG"
                case "small forward", "forward":
                    return "F"
                case "power forward":
                    return "PF"
                case "center":
                    return "C"
                default:
                    return part.prefix(1).uppercased()
                }
            }
            return abbreviated.joined(separator: "-")
        }
        
        // 단일 포지션 처리
        switch lowercased {
        case "point guard", "guard":
            return "G"
        case "shooting guard":
            return "SG"
        case "small forward", "forward":
            return "F"
        case "power forward":
            return "PF"
        case "center":
            return "C"
        default:
            // 이미 축약된 형태이거나 알 수 없는 경우 원본 반환
            return position.uppercased()
        }
    }
    
    // 포지션별 색상 (멀티 포지션 지원)
    static func positionGradientColors(for position: String) -> (Color, Color) {
        let abbreviated = abbreviatePosition(position)
        let components = abbreviated.components(separatedBy: "-")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        let colors = components.compactMap { baseColor(for: $0) }
        
        if let first = colors.first, let second = colors.dropFirst().first {
            return (first, second)
        } else if let first = colors.first {
            return (first, first)
        } else {
            let fallback = Color.white.opacity(0.3)
            return (fallback, fallback.opacity(0.6))
        }
    }
    
    private static func baseColor(for abbreviation: String) -> Color? {
        switch abbreviation.uppercased() {
        case "PG", "G":
            return Color(red: 0.2, green: 0.6, blue: 1.0) // 파란색
        case "SG":
            return Color(red: 0.0, green: 0.8, blue: 0.4) // 초록색
        case "SF", "F":
            return Color(red: 1.0, green: 0.65, blue: 0.0) // 주황색
        case "PF":
            return Color(red: 1.0, green: 0.3, blue: 0.3) // 빨간색
        case "C":
            return Color(red: 0.7, green: 0.3, blue: 1.0) // 보라색
        default:
            return nil
        }
    }
    
    static func makeWeekLabel(from week: String?) -> String? {
        guard let week = week, !week.isEmpty else { return nil }
        
        // "week-3" 형식인 경우 숫자만 추출
        if week.lowercased().hasPrefix("week-") {
            let weekNumber = String(week.dropFirst(5))
            return "Week \(weekNumber)"
        }
        
        // 이미 "Week"로 시작하는 경우 그대로 반환
        if week.hasPrefix("Week ") {
            return week
        }
        
        // 숫자만 있는 경우 "Week "를 붙여서 반환
        return "Week \(week)"
    }
    
    static func makeTriCode(from teamCode: String?) -> String {
        guard let teamCode = teamCode, !teamCode.isEmpty else { return "" }
        
        let triCode: String
        if teamCode.count == 3 {
            triCode = teamCode.uppercased()
        } else {
            triCode = teamCode.nickNameToTriCode
        }
        
        // Safe Mode Check
        if !RemoteConfigManager.shared.shouldUseOfficialTeamData {
            if let genericInfo = GenericTeamData.get(byTriCode: triCode) {
                return genericInfo.triCode
            }
        }
        
        return triCode
    }
    
    static func makeBackgroundColorName(from teamCode: String?) -> String {
        guard let teamCode = teamCode, !teamCode.isEmpty else { return "#1C1B1D" }
        
        // Safe Mode Check - For now we use the same colors as they are abstract enough,
        // but we ensure we map correctly via GenericTeamData if needed.
        if !RemoteConfigManager.shared.shouldUseOfficialTeamData {
             let triCode = teamCode.count == 3 ? teamCode.uppercased() : teamCode.nickNameToTriCode
             if let genericInfo = GenericTeamData.get(byTriCode: triCode) {
                 return genericInfo.colorName
             }
        }
        
        let nickName = teamCode.triCodeToNickName.isEmpty ? teamCode.lowercased() : teamCode.triCodeToNickName
        return nickName.isEmpty ? "#1C1B1D" : nickName
    }
    
    static func makeRankChange(from lastWeek: String?) -> (text: String, style: RankChangeStyle) {
        guard let raw = lastWeek?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else {
            return ("-", .same)
        }
        
        let upIndicators: [Character] = ["↑", "▲", "△", "↗", "➚", "⬆"]
        let downIndicators: [Character] = ["↓", "▼", "▽", "↘", "➘", "⬇"]
        
        if raw.contains(where: { upIndicators.contains($0) }) {
            return (raw, .up)
        }
        
        if raw.contains(where: { downIndicators.contains($0) }) {
            return (raw, .down)
        }
        
        return ("-", .same)
    }
    
    static func makeDisplayName(from team: PowerRankingTeamModel) -> String {
        // Safe Mode Check
        if !RemoteConfigManager.shared.shouldUseOfficialTeamData {
            // Try to find by ID first
            if let id = team.id, let genericInfo = GenericTeamData.get(for: id) {
                return genericInfo.name.uppercased()
            }
            
            // Fallback: Try to find by TriCode/NickName
            let rawCode = (team.teamCode ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let triCode = rawCode.count == 3 ? rawCode.uppercased() : rawCode.nickNameToTriCode
            if !triCode.isEmpty, let genericInfo = GenericTeamData.get(byTriCode: triCode) {
                return genericInfo.name.uppercased()
            }
        }
        
        let rawCity = (team.teamName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        var rawCode = (team.teamCode ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        if rawCode.count == 3, rawCode.uppercased() == rawCode {
            let nickname = rawCode.triCodeToNickName
            if !nickname.isEmpty {
                rawCode = nickname
            }
        }
        
        let city = rawCity.isEmpty ? nil : rawCity
        let nickname = rawCode.isEmpty ? nil : rawCode
        
        if let city, let nickname {
            return "\(city) \(nickname)".uppercased()
        }
        
        if let city {
            return city.uppercased()
        }
        
        if let nickname {
            return nickname.uppercased()
        }
        
        return rawCode.uppercased()
    }
}
