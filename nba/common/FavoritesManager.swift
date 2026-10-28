//
//  FavoritesManager.swift
//  nba
//
//  Created by Antigravity on 12/07/24.
//

import Foundation
import Combine

/// 즐겨찾기 선수 (UserDefaults JSON 저장)
struct FavoritePlayer: Codable, Hashable, Identifiable {
    let id: String        // playerId
    let name: String      // "Alperen Sengun"
    let teamId: String    // "1610612745"
    let teamTriCode: String // "HOU"
}

/// 사용자의 관심 팀·선수와 온보딩 완료 여부를 로컬(UserDefaults)에 보관합니다. 로그인 없음.
final class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    @Published private(set) var favoriteTeamCodes: Set<String> = []
    @Published private(set) var favoritePlayers: [FavoritePlayer] = []
    @Published private(set) var hasCompletedOnboarding: Bool = false
    
    private let favoritesKey = "com.nba.powerranking.favorites"
    private let playersKey = "com.nba.powerranking.favoritePlayers"
    private let onboardingKey = "com.nba.powerranking.onboardingCompleted"
    private let userDefaults = UserDefaults.standard
    
    private init() {
        loadFavorites()
    }
    
    // MARK: - Teams (triCode 기준, 예: "HOU")
    
    func addFavorite(_ teamCode: String) {
        favoriteTeamCodes.insert(teamCode)
        saveFavorites()
    }
    
    func removeFavorite(_ teamCode: String) {
        favoriteTeamCodes.remove(teamCode)
        saveFavorites()
    }
    
    func toggleFavorite(_ teamCode: String) {
        if isFavorite(teamCode) {
            removeFavorite(teamCode)
        } else {
            addFavorite(teamCode)
        }
    }
    
    func isFavorite(_ teamCode: String) -> Bool {
        return favoriteTeamCodes.contains(teamCode)
    }
    
    /// 온보딩 등에서 여러 팀을 한 번에 설정
    func setFavoriteTeams(_ codes: Set<String>) {
        favoriteTeamCodes = codes
        saveFavorites()
    }
    
    func getFavorites() -> Set<String> {
        return favoriteTeamCodes
    }
    
    var hasFavorites: Bool {
        return !favoriteTeamCodes.isEmpty
    }
    
    var favoritesCount: Int {
        return favoriteTeamCodes.count
    }
    
    /// 즐겨찾기 팀의 teamId 집합 (경기·순위 데이터는 teamId 로 매칭)
    var favoriteTeamIds: Set<String> {
        Set(favoriteTeamCodes.map { $0.triCodeToTeamId }.filter { !$0.isEmpty })
    }
    
    // MARK: - Players (playerId 기준)
    
    var favoritePlayerIds: Set<String> {
        Set(favoritePlayers.map { $0.id })
    }
    
    func isFavoritePlayer(_ playerId: String) -> Bool {
        favoritePlayers.contains { $0.id == playerId }
    }
    
    func addFavoritePlayer(_ player: FavoritePlayer) {
        guard !isFavoritePlayer(player.id) else { return }
        favoritePlayers.append(player)
        savePlayers()
    }
    
    func removeFavoritePlayer(id: String) {
        favoritePlayers.removeAll { $0.id == id }
        savePlayers()
    }
    
    func toggleFavoritePlayer(_ player: FavoritePlayer) {
        if isFavoritePlayer(player.id) {
            removeFavoritePlayer(id: player.id)
        } else {
            addFavoritePlayer(player)
        }
    }
    
    // MARK: - Onboarding
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        userDefaults.set(true, forKey: onboardingKey)
    }
    
    // MARK: - Private
    
    private func loadFavorites() {
        if let savedFavorites = userDefaults.array(forKey: favoritesKey) as? [String] {
            favoriteTeamCodes = Set(savedFavorites)
        }
        if let data = userDefaults.data(forKey: playersKey),
           let players = try? JSONDecoder().decode([FavoritePlayer].self, from: data) {
            favoritePlayers = players
        }
        // 이미 팀을 등록해 둔 기존 사용자는 온보딩을 다시 보여주지 않음
        hasCompletedOnboarding = userDefaults.bool(forKey: onboardingKey) || !favoriteTeamCodes.isEmpty
    }
    
    private func saveFavorites() {
        userDefaults.set(Array(favoriteTeamCodes), forKey: favoritesKey)
    }
    
    private func savePlayers() {
        if let data = try? JSONEncoder().encode(favoritePlayers) {
            userDefaults.set(data, forKey: playersKey)
        }
    }
}
