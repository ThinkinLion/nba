//
//  PowerRankingViewModel.swift
//  nba
//
//  Created by 1100690 on 12/10/24.
//

import Foundation
import FirebaseFirestore
import Firebase

final class PowerRankingViewModel: ObservableObject {
    @Published var powerRankings: [PowerRankingModel] = []
    @Published var currentPowerRanking: PowerRankingModel?
    @Published var selectedWeek: String?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    
    func fetchPowerRankings() {
        isLoading = true
        errorMessage = nil
        
        db.collection("powerRankings.2025")
            .order(by: "week", descending: true)
            .limit(to: 10)
            .getDocuments() { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = "Error fetching power rankings: \(error.localizedDescription)"
                    self.isLoading = false
                    return
                }
                
                self.powerRankings = snapshot?.documents.compactMap { documentSnapshot in
                    let result = Result { try documentSnapshot.data(as: PowerRankingModel.self) }
                    switch result {
                    case .success(let powerRanking):
                        // items가 있고 비어있지 않은 경우만 반환
                        return (powerRanking.items?.count ?? 0) > 0 ? powerRanking : nil
                    case .failure(let error):
                        self.errorMessage = "Error decoding document: \(error.localizedDescription)"
                        return nil
                    }
                } ?? []
                
                // 가장 최신 랭킹을 currentPowerRanking으로 설정
                if let firstRanking = self.powerRankings.first {
                    self.currentPowerRanking = firstRanking
                    self.selectedWeek = firstRanking.week
                }
                self.isLoading = false
            }
    }
    
    func fetchPowerRankingByWeek(_ week: String) {
        isLoading = true
        errorMessage = nil
        
        db.collection("powerRankings.2024")
            .whereField("week", isEqualTo: week)
            .limit(to: 1)
            .getDocuments() { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = "Error fetching power ranking: \(error.localizedDescription)"
                    self.isLoading = false
                    return
                }
                
                if let document = snapshot?.documents.first {
                    let result = Result { try document.data(as: PowerRankingModel.self) }
                    switch result {
                    case .success(let powerRanking):
                        self.currentPowerRanking = powerRanking
                        self.errorMessage = nil
                    case .failure(let error):
                        self.errorMessage = "Error decoding document: \(error.localizedDescription)"
                    }
                }
                
                self.isLoading = false
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
    
    var availableWeeks: [String] {
        powerRankings.compactMap { $0.week }.reversed()
    }
    
    var weekLabels: [String] {
        availableWeeks.compactMap { Self.makeWeekLabel(from: $0) }
    }
}


extension PowerRankingViewModel {
    struct PowerRankingViewState {
        let weekLabel: String?
        let title: String?
        let subTitle: String?
        let imageURL: URL?
        let imageDesc: String?
        let teams: [TeamState]
    }
    
    struct TeamState: Identifiable {
        let id: String
        let displayRank: Int
        let name: String
        let record: String?
        let rankChangeText: String
        let rankChangeStyle: RankChangeStyle
        let triCode: String?
        let backgroundColorName: String
        let model: PowerRankingTeamModel
        
        var detailViewState: TeamDetailViewState {
            let rankChange = PowerRankingViewModel.makeRankChange(from: model.lastWeek)
            return TeamDetailViewState(
                triCode: triCode,
                name: name,
                rank: model.rank,
                record: record,
                rankChangeText: rankChange.text,
                rankChangeStyle: rankChange.style,
                overview: model.overview,
                takeaways: model.takeaways,
                advanced: model.advanced,
                upcoming: model.upcomming,
                backgroundColorName: backgroundColorName
            )
        }
    }
    
    struct TeamDetailViewState {
        let triCode: String?
        let name: String
        let rank: String?
        let record: String?
        let rankChangeText: String
        let rankChangeStyle: RankChangeStyle
        let overview: String?
        let takeaways: [String]?
        let advanced: PowerRankingAdvancedModel?
        let upcoming: String?
        let backgroundColorName: String
    }
    
    enum RankChangeStyle {
        case up
        case down
        case same
    }
    
    var currentViewState: PowerRankingViewState? {
        guard let powerRanking = currentPowerRanking else { return nil }
        
        let teams: [TeamState] = (powerRanking.items ?? [])
            .enumerated()
            .map { index, team in
                let triCode = Self.makeTriCode(from: team.teamCode)
                let backgroundColorName = Self.makeBackgroundColorName(from: team.teamCode)
                let rankChange = Self.makeRankChange(from: team.lastWeek)
                
                return TeamState(
                    id: team.id?.isEmpty == false ? team.id! : "\(index)",
                    displayRank: index + 1,
                    name: Self.makeDisplayName(from: team),
                    record: team.record?.isEmpty == false ? team.record : nil,
                    rankChangeText: rankChange.text,
                    rankChangeStyle: rankChange.style,
                    triCode: triCode.isEmpty ? nil : triCode,
                    backgroundColorName: backgroundColorName,
                    model: team
                )
            }
        
        return PowerRankingViewState(
            weekLabel: Self.makeWeekLabel(from: powerRanking.week),
            title: powerRanking.title?.isEmpty == false ? powerRanking.title : nil,
            subTitle: powerRanking.subTitle?.isEmpty == false ? powerRanking.subTitle : nil,
            imageURL: powerRanking.image?.isEmpty == false ? URL(string: powerRanking.image!) : nil,
            imageDesc: powerRanking.imageDesc?.isEmpty == false ? powerRanking.imageDesc : nil,
            teams: teams
        )
    }
    
    private static func makeWeekLabel(from week: String?) -> String? {
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
    
    private static func makeTriCode(from teamCode: String?) -> String {
        guard let teamCode = teamCode, !teamCode.isEmpty else { return "" }
        if teamCode.count == 3 {
            return teamCode.uppercased()
        } else {
            return teamCode.nickNameToTriCode
        }
    }
    
    private static func makeBackgroundColorName(from teamCode: String?) -> String {
        guard let teamCode = teamCode, !teamCode.isEmpty else { return "#1C1B1D" }
        let nickName = teamCode.triCodeToNickName.isEmpty ? teamCode.lowercased() : teamCode.triCodeToNickName
        return nickName.isEmpty ? "#1C1B1D" : nickName
    }
    
    private static func makeRankChange(from lastWeek: String?) -> (text: String, style: RankChangeStyle) {
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
    
    private static func makeDisplayName(from team: PowerRankingTeamModel) -> String {
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
        
        return "UNKNOWN TEAM"
    }
}

