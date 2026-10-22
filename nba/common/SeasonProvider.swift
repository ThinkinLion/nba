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

    // 시즌 연도 계산 메서드 (종료 연도 기준, 예: 2026년 10월 개막 시즌은 "2027")
    func seasonYear() -> String {
        let currentDate = Date()
        let calendar = Calendar.current

        let currentYear = calendar.component(.year, from: currentDate)
        let seasonStartDateComponents = DateComponents(year: currentYear, month: 10, day: 01)
        let seasonStartDate = calendar.date(from: seasonStartDateComponents)!

        if currentDate < seasonStartDate {
            return "\(currentYear)"
        } else {
            return "\(currentYear + 1)"
        }
    }
    
    // 시즌 연도(예: "2027")를 표시용 문자열(예: "2026-27")로 변환
    func seasonDisplayString(for season: String? = nil) -> String {
        let targetSeason = season ?? seasonYear()
        if let endYear = Int(targetSeason) {
            let startYear = endYear - 1
            let endSuffix = String(format: "%02d", endYear % 100)
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
