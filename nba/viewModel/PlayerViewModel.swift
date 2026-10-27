//
//  PlayerViewModel.swift
//  nba
//
//  Created by 1100690 on 12/11/23.
//

import Foundation
import FirebaseFirestore
import Firebase

final class PlayerViewModel: ObservableObject {
    @Published var player = PlayerModel.empty
    @Published var roster = [PlayerModel]()
    @Published var lastGameStats: PlayerLastGameStats? = nil
    var errorMessage: String?
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
}

struct PlayerLastGameStats: Equatable {
    let opponentTriCode: String
    let isHome: Bool
    let gameDate: String
    let resultText: String
    let pts: String
    let reb: String
    let ast: String
    let min: String?
    let game: HomeAway
}

extension PlayerViewModel {
    @MainActor
    private func asyncFetch(documentId: String) async {
//        let docRef = db.collection("standings").document(documentId)
//        do {
//            self.standings = try await docRef.getDocument(as: StandingsModel.self)
//        } catch {
//            self.errorMessage = "Error decoding document: \(error.localizedDescription)"
//        }
    }
    
    func fetchPlayer(documentId: String) {
        guard !documentId.isEmpty else { return }
        let seasonYear = SeasonProvider.shared.seasonYear()
        db.collection("players.\(seasonYear)").document(documentId).getDocument(as: PlayerModel.self) { result in
            switch result {
            case .success(let player):
                print("player: \(player)")
                self.player = player
                self.errorMessage = nil
            case .failure(let error):
                self.errorMessage = "Error decoding document: \(error.localizedDescription)"
            }
        }
    }
    
    func fetchRoster(teamId: String) {
        guard !teamId.isEmpty else { return }
        let seasonYear = SeasonProvider.shared.seasonYear()
        db.collection("players.\(seasonYear)").whereField("teamId", isEqualTo: teamId)
//            .whereField("pie", isGreaterThanOrEqualTo: 5)
//            .whereField("position", isEqualTo: "Guard")
            .getDocuments() { (snapshot, error) in
            self.roster = snapshot?.documents.compactMap { documentSnapshot in
                let result = Result { try documentSnapshot.data(as: PlayerModel.self) }
                switch result {
                case .success(let playerModel):
                    self.errorMessage = nil
                    print("roster: \(playerModel.firstName ?? ""), \(playerModel.lastName ?? "")")
                    return playerModel
                case .failure(let error):
                    self.errorMessage = "Error decoding document: \(error.localizedDescription)"
                    return nil
                }
            } ?? []
        }
    }
    
    func fetchLastGame(playerId: String) {
        guard !playerId.isEmpty else { return }
        
        Task {
            // 1. 캐시 우선 확인
            var games: [GamesModel] = NBAFirestoreDayCache.load([GamesModel].self, key: "gameRecap") ?? []
            
            // 2. 비어있으면 저장소에서 fetch
            if games.isEmpty {
                games = (try? await FirestoreStandingsRepository().fetchGameRecap()) ?? []
            }
            
            // 3. 선수가 출전한 가장 최근 경기 및 박스스코어 탐색
            var foundStats: PlayerLastGameStats? = nil
            for day in games {
                for match in day.items {
                    // Check Home Boxscore
                    if let box = match.home.boxscore?.first(where: { $0.playerId == playerId }) {
                        let awayScore = Int(match.away.score ?? "0") ?? 0
                        let homeScore = Int(match.home.score ?? "0") ?? 0
                        let isWin = homeScore > awayScore
                        let scoreText = "\(match.home.score ?? "0") - \(match.away.score ?? "0")"
                        let resultText = (isWin ? "W " : "L ") + scoreText
                        
                        foundStats = PlayerLastGameStats(
                            opponentTriCode: match.away.teamCode.nickNameToTriCode,
                            isHome: true,
                            gameDate: day.date ?? "",
                            resultText: resultText,
                            pts: box.pts ?? "0",
                            reb: box.reb ?? "0",
                            ast: box.ast ?? "0",
                            min: box.min,
                            game: match
                        )
                        break
                    }
                    
                    // Check Away Boxscore
                    if let box = match.away.boxscore?.first(where: { $0.playerId == playerId }) {
                        let awayScore = Int(match.away.score ?? "0") ?? 0
                        let homeScore = Int(match.home.score ?? "0") ?? 0
                        let isWin = awayScore > homeScore
                        let scoreText = "\(match.away.score ?? "0") - \(match.home.score ?? "0")"
                        let resultText = (isWin ? "W " : "L ") + scoreText
                        
                        foundStats = PlayerLastGameStats(
                            opponentTriCode: match.home.teamCode.nickNameToTriCode,
                            isHome: false,
                            gameDate: day.date ?? "",
                            resultText: resultText,
                            pts: box.pts ?? "0",
                            reb: box.reb ?? "0",
                            ast: box.ast ?? "0",
                            min: box.min,
                            game: match
                        )
                        break
                    }
                }
                if foundStats != nil { break }
            }
            
            await MainActor.run {
                self.lastGameStats = foundStats
            }
        }
    }
}

/*
 player_info = {
     "id": str(uuid.uuid4()),
     "teamId": team_id,
     "teamName": team_name,
     "teamCode": team_code,
     "firstName": player_firstname,
     "lastName": player_lastname,
     "jersey": jersey,
     "position": position,
     "ppg": ppg,
     "rpg": rpg,
     "apg": apg,
     "pie": pie,
     "height": height,
     "weight": weight,
     "country": country,
     "lastAttended": last_attended,
     "age": age,
     "brithdate": brithdate,
     "draft": draft,
     "experience": experience,
     "retired": False
 }
 */
struct PlayerSummaryViewModel {
    private let player: PlayerModel
    
    init(player: PlayerModel) {
        self.player = player
    }
    
    var playerId: String {
        player.playerId ?? ""
    }
    
    var smallImageUrl: String {
        playerId.smallImageUrl
    }
    
    var imageUrl: String {
        playerId.imageUrl
    }
    
    var teamTriCode: String {
        player.teamId?.teamIdToTriCode ?? ""
    }
    
    var teamId: String {
        teamTriCode.triCodeToTeamId
    }
    
    var teamNickName: String {
        teamTriCode.triCodeToNickName
    }
    
    var firstName: String {
        player.firstName ?? ""
    }
    
    var lastName: String {
        player.lastName ?? ""
    }
    
    var fullName: String {
        firstName + " " + lastName
    }
    
    var upperCasedName: String {
        fullName.uppercased()
    }
    
    var jersey: String {
        player.jersey ?? ""
    }
    
    var position: String {
        player.position ?? ""
    }
    
    var jerseyAndPosition: String {
        guard !jersey.isEmpty && !position.isEmpty else { return "" }
        return jersey + " • " + position
    }
    
    var jerseyAndShortenPosition: String {
        guard !jersey.isEmpty && !position.isEmpty else { return "" }
        return jersey + " • " + position.abbreviation
    }
    
    private func sanitizeStat(_ value: String?) -> String {
        guard let v = value?.trimmingCharacters(in: .whitespacesAndNewlines), !v.isEmpty else {
            return "-"
        }
        if v == "0" || v == "0.0" || v == "--" {
            return "-"
        }
        return v
    }
    
    var isRookie: Bool {
        let exp = player.experience?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        return exp == "r" || exp == "rookie" || exp == "0"
    }
    
    var hasSeasonStats: Bool {
        return ppg != "-" || rpg != "-" || apg != "-"
    }
    
    var pieTitle: String {
        "PIE"
    }
    
    var pie: String {
        sanitizeStat(player.pie)
    }
    
    var ppgTitle: String {
        "PPG"
    }
    
    var ppg: String {
        sanitizeStat(player.ppg)
    }
    
    var rpgTitle: String {
        "RPG"
    }
    
    var rpg: String {
        sanitizeStat(player.rpg)
    }
    
    var apgTitle: String {
        "APG"
    }
    
    var apg: String {
        sanitizeStat(player.apg)
    }
    
    var heightTitle: String {
        "HEIGHT"
    }
    
    var height: String {
        player.height ?? ""
    }
    
    var weightTitle: String {
        "WEIGHT"
    }
    
    var weight: String {
        player.weight ?? ""
    }
    
    var ageTitle: String {
        "AGE"
    }
    
    var age: String {
        player.age ?? ""
    }
    
    var birthdateTitle: String {
        "BIRTHDATE"
    }
    
    var birthdate: String {
        player.brithdate ?? ""
    }
    
    var experienceTitle: String {
        "EXPERIENCE"
    }
    
    var experience: String {
        player.experience ?? ""
    }
    
    var draftTitle: String {
        "DRAFT"
    }
    
    var draft: String {
        player.draft ?? ""
    }
    
    var countryTitle: String {
        "COUNTRY"
    }
    
    var country: String {
        player.country ?? ""
    }
    
    var countryWithFlag: String {
        let name = country
        let flag = name.flagEmoji
        return flag.isEmpty ? name : "\(flag) \(name)"
    }
    
    var lastAttendedTitle: String {
        "LAST ATTENDED"
    }
    
    var lastAttended: String {
        player.lastAttended ?? ""
    }
  
}

extension PlayerSummaryViewModel {
  var traditional: [Traditional] {
    self.player.traditional ?? []
  }
  
  var hasTraditional: Bool {
    !self.traditional.isEmpty
  }
  
  var currentSeasonTraditional: [PlayerStatsItemViewModel] {
    self.traditional.first {
      $0.title == "2023-24"
    }
    .map {
      ModelFactory.createTraditionalStatsItemViewModels(with: $0, teamId: self.teamId)
    } ?? []
  }
  
  var advanced: [Advanced] {
    self.player.advanced ?? []
  }
  
  var hasAdvanced: Bool {
    !self.advanced.isEmpty
  }
  
  var currentSeasonAdvanced: [PlayerStatsItemViewModel] {
    self.advanced.first {
      $0.title == "2023-24"
    }
    .map {
      ModelFactory.createAdvancedStatsItemViewModels(with: $0, teamId: self.teamId)
    } ?? []
  }
  
  var misc: [Misc] {
    self.player.misc ?? []
  }
  
  var hasMisc: Bool {
    !self.misc.isEmpty
  }
  
  var scoring: [Scoring] {
    self.player.scoring ?? []
  }
  
  var hasScoring: Bool {
    !self.scoring.isEmpty
  }
  
  var usage: [Usage] {
    self.player.usage ?? []
  }
  
  var hasUsage: Bool {
    !self.usage.isEmpty
  }
}
