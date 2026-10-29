//
//  ReviewPromptManager.swift
//  nba
//
//  별점/리뷰 요청 타이밍 관리. 시스템 다이얼로그(requestReview)는 애플이 연 3회로 제한하므로
//  "긍정 순간"에만, 그리고 로컬에서 최소 간격을 두고 요청합니다.
//

import Foundation

final class ReviewPromptManager {
    static let shared = ReviewPromptManager()
    
    static let appStoreId = "6755461492"
    static var writeReviewURL: URL { URL(string: "https://apps.apple.com/app/id\(appStoreId)?action=write-review")! }
    
    enum Trigger {
        case sessionMilestone                        // 5·20·50번째 실행
        case favoritesSet                            // 온보딩/프로필에서 팀을 고른 직후
    }
    
    private let sessionKey = "com.nba.powerranking.review.sessionCount"
    private let lastPromptKey = "com.nba.powerranking.review.lastPromptedAt"
    private let defaults = UserDefaults.standard
    private var countedThisLaunch = false
    
    private let minDaysBetweenPrompts = 90.0
    private let minSessions = 3
    
    private init() {}
    
    /// 앱 실행당 1회 세션 카운트
    func registerSession() {
        guard !countedThisLaunch else { return }
        countedThisLaunch = true
        defaults.set(sessionCount + 1, forKey: sessionKey)
    }
    
    var sessionCount: Int { defaults.integer(forKey: sessionKey) }
    
    private var daysSinceLastPrompt: Double {
        guard let last = defaults.object(forKey: lastPromptKey) as? Date else { return .infinity }
        return Date().timeIntervalSince(last) / 86400
    }
    
    /// 지금 요청해도 되는지. true 를 돌려주면 호출 측이 requestReview() 를 띄우고 markPrompted() 를 호출
    func shouldPrompt(_ trigger: Trigger) -> Bool {
        guard sessionCount >= minSessions, daysSinceLastPrompt >= minDaysBetweenPrompts else { return false }
        switch trigger {
        case .sessionMilestone:
            return [5, 20, 50].contains(sessionCount)
        case .favoritesSet:
            return FavoritesManager.shared.favoritesCount >= 1
        }
    }
    
    func markPrompted() {
        defaults.set(Date(), forKey: lastPromptKey)
    }
}
