//
//  SeasonProvider.swift
//  nba
//
//  Created by 1100690 on 10/6/24.
//

import Foundation

final class SeasonProvider {
    static let shared = SeasonProvider()

    private init() {}

    // 시즌 연도 계산 메서드 (시작 연도 기준: Firestore의 players.2026, powerRankings.2026과 일치)
    func seasonYear() -> String {
        let currentDate = Date()
        let calendar = Calendar.current

        let currentYear = calendar.component(.year, from: currentDate)
        let seasonStartDateComponents = DateComponents(year: currentYear, month: 10, day: 01)
        let seasonStartDate = calendar.date(from: seasonStartDateComponents)!

        // 10월 1일 이전이면 이전 시즌(예: 2026년 5월 -> 2025-26 시즌 -> "2025")
        // 10월 1일 이후면 현재 시즌(예: 2026년 10월 -> 2026-27 시즌 -> "2026")
        if currentDate < seasonStartDate {
            return "\(currentYear - 1)"
        } else {
            return "\(currentYear)"
        }
    }
    
    // 시즌 시작 연도(예: "2026")를 표시용 문자열(예: "2026-27")로 변환
    func seasonDisplayString(for season: String? = nil) -> String {
        let targetSeason = season ?? seasonYear()
        if let startYear = Int(targetSeason) {
            let nextYear = startYear + 1
            let endSuffix = String(format: "%02d", nextYear % 100)
            return "\(startYear)-\(endSuffix)"
        }
        return targetSeason
    }
  
    func todayOfWeek() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: currentDate)
    }
  
    private func today() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: currentDate)
    }
}
