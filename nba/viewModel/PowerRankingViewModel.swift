//
//  PowerRankingViewModel.swift
//  nba
//
//  Created by 1100690 on 12/10/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import Firebase
import Combine

// MARK: - Conference Enum
enum Conference: String, CaseIterable {
    case league = "LEAGUE"
    case eastern = "EASTERN"
    case western = "WESTERN"
    case favorites = "FAVORITES"
}

final class PowerRankingViewModel: ObservableObject {
    @Published var powerRankings: [PowerRankingModel] = []
    @Published var currentPowerRanking: PowerRankingModel?
    @Published var selectedWeek: String?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var recentGames: [HomeAway] = []
    @Published var isLoadingGames: Bool = false
    @Published var shouldUseOfficialTeamData: Bool = false
    @Published var selectedConference: Conference = .league
    @Published var showOnlyFavorites: Bool = false
    
    private let repository: PowerRankingRepository
    private var cancellables = Set<AnyCancellable>()
    let favoritesManager = FavoritesManager.shared
    
    init(repository: PowerRankingRepository = FirestorePowerRankingRepository()) {
        self.repository = repository
        
        // Remote Config 변경 감지하여 뷰 갱신 트리거
        RemoteConfigManager.shared.$shouldUseOfficialTeamData
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
                self?.updateViewState()
            }
            .store(in: &cancellables)
        
        // Auto-disable favorites filter when no favorites remain
        favoritesManager.$favoriteTeamCodes
            .receive(on: RunLoop.main)
            .sink { [weak self] favorites in
                if favorites.isEmpty && self?.showOnlyFavorites == true {
                    self?.showOnlyFavorites = false
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateViewState() {
        self.shouldUseOfficialTeamData = RemoteConfigManager.shared.shouldUseOfficialTeamData
        // 필요한 경우, 현재 선택된 주차의 랭킹을 다시 로드하거나 뷰를 갱신
        if let currentWeek = selectedWeek {
            fetchPowerRankingByWeek(currentWeek)
        }
    }
    
    func fetchPowerRankings(forceRefresh: Bool = false) async {
        errorMessage = nil
        
        if !forceRefresh, let cached = NBAFirestoreDayCache.load([PowerRankingModel].self, key: Self.powerRankingsCacheKey) {
            await MainActor.run {
                self.applyProcessedPowerRankings(from: cached)
                self.isLoading = false
                self.errorMessage = nil
            }
            return
        }
        
        isLoading = true
        do {
            let rankings = try await repository.fetchPowerRankings()
            NBAFirestoreDayCache.save(rankings, key: Self.powerRankingsCacheKey)
            await MainActor.run {
                self.applyProcessedPowerRankings(from: rankings)
                self.isLoading = false
                self.errorMessage = nil
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Error fetching power rankings: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    private static let powerRankingsCacheKey = "powerRankings.list"
    
    /// Shared cache payload with `StandingsViewModel` — filter/sort for UI only.
    private func applyProcessedPowerRankings(from rankings: [PowerRankingModel]) {
        powerRankings = rankings
            .filter { ($0.items?.count ?? 0) > 0 }
            .sorted { lhs, rhs in
                let lhsNum = Int(lhs.week?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined() ?? "") ?? 0
                let rhsNum = Int(rhs.week?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined() ?? "") ?? 0
                return lhsNum > rhsNum
            }
        if selectedWeek == nil, let firstRanking = powerRankings.first {
            currentPowerRanking = firstRanking
            selectedWeek = firstRanking.week
        } else if let currentWeek = selectedWeek,
                  let existingRanking = powerRankings.first(where: { $0.week == currentWeek }) {
            currentPowerRanking = existingRanking
        } else if let firstRanking = powerRankings.first {
            currentPowerRanking = firstRanking
            selectedWeek = firstRanking.week
        }
    }
    
    func fetchPowerRankingByWeek(_ week: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                if let ranking = try await repository.fetchPowerRanking(week: week) {
                    await MainActor.run {
                        self.currentPowerRanking = ranking
                        self.selectedWeek = ranking.week
                        self.isLoading = false
                    }
                } else {
                    await MainActor.run {
                        self.errorMessage = "No ranking found for week \(week)"
                        self.isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Error fetching power ranking: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func selectPowerRanking(_ powerRanking: PowerRankingModel) {
        currentPowerRanking = powerRanking
        selectedWeek = powerRanking.week
    }
    
    func selectWeek(_ week: String) {
        if let ranking = powerRankings.first(where: { $0.week == week }) {
            selectPowerRanking(ranking)
        }
    }
    
    // MARK: - Ranking History Logic
    @Published var rankingHistory: [(week: String, rank: Int)] = []
    
    func updateRankingHistory(teamId: String, teamCode: String? = nil) {
        guard !teamId.isEmpty else {
            rankingHistory = []
            return
        }
        
        var history: [(week: String, rank: Int)] = []
        
        // 모든 주차의 랭킹을 순회하며 해당 팀의 순위를 찾음
        for ranking in powerRankings {
            guard let week = ranking.week,
                  let items = ranking.items else { continue }
            
            // 1. teamCode로 매칭 (가장 정확)
            if let teamCode = teamCode, !teamCode.isEmpty,
               let teamIndex = items.firstIndex(where: { $0.teamCode == teamCode || $0.teamCode?.nickNameToTriCode == teamCode || $0.teamCode?.triCodeToNickName == teamCode }) {
                let rank = teamIndex + 1
                history.append((week: week, rank: rank))
                continue
            }
            
            // 2. id로 매칭 (fallback)
            if let teamIndex = items.firstIndex(where: { $0.id == teamId || $0.teamCode?.triCodeToTeamId == teamId }) {
                let rank = teamIndex + 1
                history.append((week: week, rank: rank))
            }
        }
        
        // 주차 순으로 정렬 (Week 1, Week 2, ...)
        // "Week X" 형식에서 숫자만 추출하여 정렬
        rankingHistory = history.sorted { (lhs, rhs) -> Bool in
            let lhsNum = Int(lhs.week.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 0
            let rhsNum = Int(rhs.week.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 0
            return lhsNum < rhsNum
        }
    }
    
    var availableWeeks: [String] {
        powerRankings.compactMap { $0.week }
    }
    
    var weekLabels: [String] {
        availableWeeks.compactMap { PowerRankingFormatter.makeWeekLabel(from: $0) }
    }
    
    func fetchRecentGames(teamId: String) {
        guard !teamId.isEmpty else { return }
        isLoadingGames = true
        
        Task {
            do {
                let games = try await repository.fetchRecentGames(teamId: teamId)
                await MainActor.run {
                    self.recentGames = games
                    self.isLoadingGames = false
                }
            } catch {
                await MainActor.run {
                    print("Error fetching recent games: \(error.localizedDescription)")
                    self.isLoadingGames = false
                }
            }
        }
    }
    
    func extractMentionedPlayers(from text: String, roster: [PlayerModel]) -> [PlayerModel] {
        guard !roster.isEmpty else { return [] }
        
        var mentionedPlayers: [PlayerModel] = []
        
        for player in roster {
            // PPG가 없거나 너무 낮은 선수(예: 1.0 미만)는 제외하여 동명이인(예: 타나시스 아데토쿤보) 문제 방지
            // "--"와 같이 숫자가 아닌 경우도 0으로 취급하여 제외
            let ppgString = player.ppg ?? "0"
            let ppg = Double(ppgString) ?? 0.0
            
            if ppg < 1.0 {
                continue
            }
            
            guard let firstName = player.firstName,
                  let lastName = player.lastName else { continue }
            
            let fullName = "\(firstName) \(lastName)"
            let lastNameOnly = lastName
            
            // 전체 이름 매칭 (우선순위 1)
            if text.localizedCaseInsensitiveContains(fullName) {
                if !mentionedPlayers.contains(where: { $0.id == player.id }) {
                    mentionedPlayers.append(player)
                }
                continue
            }
            
            // 성만으로 매칭할 때는 단어 경계를 확인하여 더 정확하게 매칭
            // "야니스" 같은 이름이 다른 선수의 이름과 겹치는 것을 방지
            let wordBoundaryPattern = "\\b\(NSRegularExpression.escapedPattern(for: lastNameOnly))\\b"
            if let regex = try? NSRegularExpression(pattern: wordBoundaryPattern, options: [.caseInsensitive]),
               regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil {
                // 성만으로 매칭되더라도, 같은 성을 가진 다른 선수가 이미 매칭되지 않았는지 확인
                // 단, 전체 이름이 명시적으로 언급된 경우는 제외 (이미 위에서 처리됨)
                let hasOtherPlayerWithSameLastName = roster.contains { otherPlayer in
                    otherPlayer.id != player.id &&
                    otherPlayer.lastName?.localizedCaseInsensitiveCompare(lastNameOnly) == .orderedSame &&
                    text.localizedCaseInsensitiveContains("\(otherPlayer.firstName ?? "") \(otherPlayer.lastName ?? "")")
                }
                
                // 같은 성을 가진 다른 선수가 전체 이름으로 명시적으로 언급되지 않은 경우만 추가
                if !hasOtherPlayerWithSameLastName {
                    if !mentionedPlayers.contains(where: { $0.id == player.id }) {
                        mentionedPlayers.append(player)
                    }
                }
            }
        }
        
        return mentionedPlayers
    }
    




}

extension PowerRankingViewModel {
    var currentViewState: PowerRankingViewState? {
        guard let powerRanking = currentPowerRanking else { return nil }
        
        let teams: [TeamState] = (powerRanking.items ?? [])
            .enumerated()
            .map { index, team in
                let triCode = PowerRankingFormatter.makeTriCode(from: team.teamCode)
                let backgroundColorName = PowerRankingFormatter.makeBackgroundColorName(from: team.teamCode)
                let rankChange = PowerRankingFormatter.makeRankChange(from: team.lastWeek)
                
                return TeamState(
                    id: team.id?.isEmpty == false ? team.id! : "\(index)",
                    displayRank: index + 1,
                    name: PowerRankingFormatter.makeDisplayName(from: team),
                    record: team.record?.isEmpty == false ? team.record : nil,
                    rankChangeText: rankChange.text,
                    rankChangeStyle: rankChange.style,
                    triCode: triCode.isEmpty ? nil : triCode,
                    backgroundColorName: backgroundColorName,
                    model: team
                )
            }
        
        return PowerRankingViewState(
            weekLabel: PowerRankingFormatter.makeWeekLabel(from: powerRanking.week),
            title: powerRanking.title?.isEmpty == false ? powerRanking.title : nil,
            subTitle: powerRanking.subTitle?.isEmpty == false ? powerRanking.subTitle : nil,
            imageURL: powerRanking.image?.isEmpty == false ? URL(string: powerRanking.image!) : nil,
            imageDesc: powerRanking.imageDesc?.isEmpty == false ? powerRanking.imageDesc : nil,
            teams: teams,
            movement: powerRanking.movement,
            teamsOfTheWeek: powerRanking.teamsOfTheWeek
        )
    }
    
    // MARK: - Conference Filtering
    
    /// Filter teams based on selected conference and favorites
    func filteredTeams(_ teams: [TeamState]) -> [TeamState] {
        var result = teams
        
        // Apply conference filter
        switch selectedConference {
        case .league:
            break // Show all
        case .eastern:
            result = result.filter { isEasternConference($0.triCode ?? "") }
        case .western:
            result = result.filter { !isEasternConference($0.triCode ?? "") }
        case .favorites:
            // Show only favorites (all conferences)
            result = result.filter { team in
                guard let triCode = team.triCode else { return false }
                return favoritesManager.isFavorite(triCode)
            }
        }
        
        return result
    }
    
    /// Determine if team is in Eastern Conference
    private func isEasternConference(_ teamCode: String) -> Bool {
        let easternTeams = ["ATL", "BOS", "BKN", "CHA", "CHI", "CLE", "DET", "IND", "MIA", "MIL", "NYK", "ORL", "PHI", "TOR", "WAS"]
        return easternTeams.contains(teamCode)
    }
    
    /// Check if user has any favorites
    var hasFavorites: Bool {
        return favoritesManager.hasFavorites
    }
    
    /// Get count of favorite teams
    var favoritesCount: Int {
        return favoritesManager.favoritesCount
    }
    
    // MARK: - Weekly Highlights
    

    
    // MARK: - Helper for Navigation
    func getTeamState(for teamNameOrCode: String) -> TeamState? {
        guard let currentViewState = currentViewState else { return nil }
        
        // 1. Try matching by TriCode (exact match)
        if let match = currentViewState.teams.first(where: { $0.triCode == teamNameOrCode }) {
            return match
        }
        
        // 2. Try matching by Name (case insensitive)
        if let match = currentViewState.teams.first(where: { $0.name.lowercased() == teamNameOrCode.lowercased() }) {
            return match
        }
        
        // 3. Try matching by Nickname -> TriCode
        let triCode = teamNameOrCode.nickNameToTriCode
        if !triCode.isEmpty {
             if let match = currentViewState.teams.first(where: { $0.triCode == triCode }) {
                return match
            }
        }
        
        return nil
    }
}

