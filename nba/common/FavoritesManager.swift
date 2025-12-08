//
//  FavoritesManager.swift
//  nba
//
//  Created by Antigravity on 12/07/24.
//

import Foundation
import Combine

/// Manages user's favorite NBA teams with persistent storage
final class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    @Published private(set) var favoriteTeamCodes: Set<String> = []
    
    private let favoritesKey = "com.nba.powerranking.favorites"
    private let userDefaults = UserDefaults.standard
    
    private init() {
        loadFavorites()
    }
    
    // MARK: - Public Methods
    
    /// Add a team to favorites
    func addFavorite(_ teamCode: String) {
        favoriteTeamCodes.insert(teamCode)
        saveFavorites()
    }
    
    /// Remove a team from favorites
    func removeFavorite(_ teamCode: String) {
        favoriteTeamCodes.remove(teamCode)
        saveFavorites()
    }
    
    /// Toggle favorite status for a team
    func toggleFavorite(_ teamCode: String) {
        if isFavorite(teamCode) {
            removeFavorite(teamCode)
        } else {
            addFavorite(teamCode)
        }
    }
    
    /// Check if a team is favorited
    func isFavorite(_ teamCode: String) -> Bool {
        return favoriteTeamCodes.contains(teamCode)
    }
    
    /// Get all favorite team codes
    func getFavorites() -> Set<String> {
        return favoriteTeamCodes
    }
    
    /// Check if user has any favorites
    var hasFavorites: Bool {
        return !favoriteTeamCodes.isEmpty
    }
    
    /// Get count of favorite teams
    var favoritesCount: Int {
        return favoriteTeamCodes.count
    }
    
    // MARK: - Private Methods
    
    private func loadFavorites() {
        if let savedFavorites = userDefaults.array(forKey: favoritesKey) as? [String] {
            favoriteTeamCodes = Set(savedFavorites)
        }
    }
    
    private func saveFavorites() {
        let favoritesArray = Array(favoriteTeamCodes)
        userDefaults.set(favoritesArray, forKey: favoritesKey)
    }
}
