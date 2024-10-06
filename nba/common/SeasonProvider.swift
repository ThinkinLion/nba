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

    // 시즌 연도 계산 메서드
    func seasonYear() -> String {
        let currentDate = Date()
        let calendar = Calendar.current

        let currentYear = calendar.component(.year, from: currentDate)
        let seasonStartDateComponents = DateComponents(year: currentYear, month: 10, day: 01)
        let seasonStartDate = calendar.date(from: seasonStartDateComponents)!

      /*
       NBA 시즌이 10월에 시작하므로, 10월 이전이면 이전 년도를 반환일 경우는
       if calendar.component(.month, from: currentDate) < 10 {
       
       현재 날짜가 10월 23일 이전이면 이전 년도를 반환
       */
        if currentDate < seasonStartDate {
            return "\(currentYear - 1)"
        } else {
            return "\(currentYear)"
        }
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
