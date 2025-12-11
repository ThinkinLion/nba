//
//  PowerRankingViewState.swift
//  nba
//
//  Created by Antigravity on 12/10/24.
//

import SwiftUI

struct PowerRankingViewState {
    let weekLabel: String?
    let title: String?
    let subTitle: String?
    let imageURL: URL?
    let imageDesc: String?
    let teams: [TeamState]
    let movement: PowerRankingMovementModel?
    let teamsOfTheWeek: [PowerRankingTeamOfTheWeekModel]?
    
    // "Power Rankings, WeekX:" 접두어를 제거한 title
    var cleanedTitle: String? {
        guard let title = title else { return nil }
        // "Power Rankings, WeekX:" 또는 "Power Rankings Week X:" 패턴 제거 (쉼표 유무 상관없이)
        let pattern = "^Power Rankings,?\\s*Week\\s*\\d+:\\s*"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            let range = NSRange(location: 0, length: title.utf16.count)
            let cleaned = regex.stringByReplacingMatches(in: title, options: [], range: range, withTemplate: "")
            return cleaned.isEmpty ? nil : cleaned
        }
        return title
    }
    
    // cleanedTitle에서 첫 번째 팀 이름을 추출하여 그라디언트 컬러 생성
    var titleGradientColors: [Color] {
        guard let cleanedTitle = cleanedTitle else {
            return [.white, .weekCarouselBlue, .weekCarouselBlueDark]
        }
        
        // 쉼표로 먼저 분리하여 첫 번째 부분 추출 (예: "Pistons, Warriors..." -> "Pistons")
        let firstPart = cleanedTitle.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespaces) ?? cleanedTitle
        
        // 첫 번째 부분을 공백으로 분리하여 단어들 추출
        let words = firstPart.components(separatedBy: .whitespaces)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        // 첫 번째 단어부터 시작하여 최대 3단어까지 조합하여 팀 이름 매칭 시도
        // (예: "Trail Blazers" 같은 2단어 팀 이름 처리)
        for i in 0..<min(words.count, 3) {
            let candidate = words[0...i].joined(separator: " ").lowercased()
            let triCode = candidate.nickNameToTriCode
            
            if !triCode.isEmpty {
                // 팀 이름을 찾았으면 해당 팀의 컬러 사용
                let nickName = triCode.triCodeToNickName
                let backgroundColorName = nickName.isEmpty ? triCode.lowercased() : nickName
                let teamColor = Color(backgroundColorName)
                
                // 가독성을 위해 White 비중을 높이고, 팀 컬러는 끝부분에 은은하게 적용
                // 배경색과 텍스트 색상이 비슷해도(예: 토론토) 가독성이 유지됨
                return [
                    .white,
                    .white,
                    teamColor.opacity(0.6)
                ]
            }
        }
        
        // 팀 이름을 찾지 못한 경우 기본 그라디언트
        return [.white, .weekCarouselBlue, .weekCarouselBlueDark]
    }
}
