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

final class PowerRankingViewModel: ObservableObject {
    @Published var powerRankings: [PowerRankingModel] = []
    @Published var currentPowerRanking: PowerRankingModel?
    @Published var selectedWeek: String?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var recentGames: [HomeAway] = []
    @Published var isLoadingGames: Bool = false
    @Published var shouldUseOfficialTeamData: Bool = false
    
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchRemoteConfig()
        
        // Remote Config 변경 감지하여 뷰 갱신 트리거
        RemoteConfigManager.shared.$shouldUseOfficialTeamData
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    private func fetchRemoteConfig() {
        RemoteConfigManager.shared.fetchConfig { [weak self] success in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.shouldUseOfficialTeamData = RemoteConfigManager.shared.shouldUseOfficialTeamData
            }
        }
    }
    
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
        powerRankings.compactMap { $0.week }
    }
    
    var weekLabels: [String] {
        availableWeeks.compactMap { Self.makeWeekLabel(from: $0) }
    }
    
    func fetchRecentGames(teamId: String) {
        guard !teamId.isEmpty else { return }
        isLoadingGames = true
        
        db.collection("games")
            .order(by: "date", descending: true)
            .limit(to: 10)
            .getDocuments() { [weak self] (snapshot, error) in
                guard let self = self else { return }
                guard let documents = snapshot?.documents else {
                    self.isLoadingGames = false
                    return
                }
                
                var allGames: [HomeAway] = []
                
                for document in documents {
                    let result = Result { try document.data(as: GamesModel.self) }
                    switch result {
                    case .success(let gamesModel):
                        // 해당 팀이 참여한 경기만 필터링
                        let teamGames = gamesModel.items.filter { game in
                            game.home.teamId == teamId || game.away.teamId == teamId
                        }
                        allGames.append(contentsOf: teamGames)
                    case .failure:
                        continue
                    }
                }
                
                // 최근 5경기만
                self.recentGames = Array(allGames.prefix(5))
                self.isLoadingGames = false
            }
    }
    
    func extractMentionedPlayers(from text: String, roster: [PlayerModel]) -> [PlayerModel] {
        guard !roster.isEmpty else { return [] }
        
        var mentionedPlayers: [PlayerModel] = []
        
        for player in roster {
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
    
    // 경기 정보 구조체
    struct GameInfo {
        let teamScore: String
        let opponentScore: String
        let opponentTriCode: String
        let teamWon: Bool
        
        static func from(game: HomeAway, teamId: String) -> GameInfo {
            let isHome = game.home.teamId == teamId
            let team = isHome ? game.home : game.away
            let opponent = isHome ? game.away : game.home
            
            let opponentTriCode: String = {
                if opponent.teamCode.count == 3 {
                    return opponent.teamCode.uppercased()
                } else {
                    let triCode = opponent.teamCode.nickNameToTriCode
                    return triCode.isEmpty ? opponent.teamCode.uppercased() : triCode
                }
            }()
            
            let teamWon = isHome ?
                (Int(game.home.score ?? "0") ?? 0) > (Int(game.away.score ?? "0") ?? 0) :
                (Int(game.away.score ?? "0") ?? 0) > (Int(game.home.score ?? "0") ?? 0)
            
            return GameInfo(
                teamScore: team.score ?? "-",
                opponentScore: opponent.score ?? "-",
                opponentTriCode: opponentTriCode,
                teamWon: teamWon
            )
        }
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
}


extension PowerRankingViewModel {
    struct PowerRankingViewState {
        let weekLabel: String?
        let title: String?
        let subTitle: String?
        let imageURL: URL?
        let imageDesc: String?
        let teams: [TeamState]
        
        // "Power Rankings, WeekX:" 접두어를 제거한 title
        var cleanedTitle: String? {
            guard let title = title else { return nil }
            // "Power Rankings, WeekX:" 또는 "Power Rankings, Week X:" 패턴 제거
            let pattern = "^Power Rankings,\\s*Week\\s*\\d+:\\s*"
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
                    
                    return [
                        .white,
                        teamColor,
                        teamColor.opacity(0.7)
                    ]
                }
            }
            
            // 팀 이름을 찾지 못한 경우 기본 그라디언트
            return [.white, .weekCarouselBlue, .weekCarouselBlueDark]
        }
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
        
        var teamId: String {
            guard let triCode = triCode else { return "" }
            return triCode.triCodeToTeamId
        }
        
        var backgroundColor: Color {
            return Color(backgroundColorName + ".light")
        }
        
        var darkBackgroundColor: Color {
            return Color(backgroundColorName + ".dark")
        }
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
    
    private static func makeBackgroundColorName(from teamCode: String?) -> String {
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
        
        return "UNKNOWN TEAM"
    }
}

