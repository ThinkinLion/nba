//
//  PlayerViewModel.swift
//  nba
//
//  Created by 1100690 on 12/11/23.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase

final class PlayerViewModel: ObservableObject {
    @Published var player = PlayerModel.empty
    @Published var roster = [PlayerModel]()
    var errorMessage: String?
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
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
    
    var pieTitle: String {
        "PIE"
    }
    
    var pie: String {
        player.pie ?? ""
    }
    
    var ppgTitle: String {
        "PPG"
    }
    
    var ppg: String {
        player.ppg ?? ""
    }
    
    var rpgTitle: String {
        "RPG"
    }
    
    var rpg: String {
        player.rpg ?? ""
    }
    
    var apgTitle: String {
        "APG"
    }
    
    var apg: String {
        player.apg ?? ""
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
    !self.currentSeasonTraditional.isEmpty
  }
  
  var currentSeasonTraditional: [StatsItemViewModel] {
    self.traditional.first {
      $0.title == "2023-24"
    }
    .map {
      self.makeTraditionalStatsItemViewModels(with: $0)
    } ?? []
  }
  
  var advanced: [Advanced] {
    self.player.advanced ?? []
  }
  
  var hasAdvanced: Bool {
    !self.currentSeasonAdvanced.isEmpty
  }
  
  var currentSeasonAdvanced: [StatsItemViewModel] {
    self.advanced.first {
      $0.title == "2023-24"
    }
    .map {
      self.makeAdvancedStatsItemViewModels(with: $0)
    } ?? []
  }

  private func makeAdvancedStatsItemViewModels(with advanced: Advanced) -> [StatsItemViewModel] {
    guard self.teamId.count >= 10 else { return [] }
    let transformed = Transform.transformTeamId(self.teamId)
      return [
        StatsItemViewModel(title: "PIE", value: advanced.pie ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
        StatsItemViewModel(title: "USG%", value: advanced.usgp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
        StatsItemViewModel(title: "Pace", value: advanced.pace ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
        
        StatsItemViewModel(title: "OFFRTG", value: advanced.offrtg ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
        StatsItemViewModel(title: "DEFRTG", value: advanced.defrtg ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
        StatsItemViewModel(title: "NETRTG", value: advanced.netrtg ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
        
        StatsItemViewModel(title: "AST%", value: advanced.astp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(5))),
        StatsItemViewModel(title: "AST/TO", value: advanced.astto ?? "", colors: Transform.randomColors(transformed.characterAtIndex(5))),
        StatsItemViewModel(title: "AST RATIO", value: advanced.astratio ?? "", colors: Transform.randomColors(transformed.characterAtIndex(5))),
          
        StatsItemViewModel(title: "OREB%", value: advanced.orebp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(6))),
        StatsItemViewModel(title: "DREB%", value: advanced.drebp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(6))),
        StatsItemViewModel(title: "REB%", value: advanced.reb ?? "", colors: Transform.randomColors(transformed.characterAtIndex(6))),
        
        StatsItemViewModel(title: "TO RATIO", value: advanced.toratio ?? "", colors: Transform.randomColors(transformed.characterAtIndex(7))),
        StatsItemViewModel(title: "EFG%", value: advanced.efgp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(7))),
        StatsItemViewModel(title: "TS%", value: advanced.tsp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(7))),
          
      ]
  }
  
  private func makeTraditionalStatsItemViewModels(with traditional: Traditional) -> [StatsItemViewModel] {
    guard self.teamId.count >= 10 else { return [] }
    let transformed = Transform.transformTeamId(self.teamId)
//        print("transformed: \(transformed)")
      return [
        StatsItemViewModel(title: "GP", value: traditional.gp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(0))),
        StatsItemViewModel(title: "MIN", value: traditional.min ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
        StatsItemViewModel(title: "PTS", value: traditional.pts ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
        StatsItemViewModel(title: "FGM", value: traditional.fgm ?? "", colors: Transform.randomColors(transformed.characterAtIndex(4))),
        StatsItemViewModel(title: "FGA", value: traditional.fga ?? "", colors: Transform.randomColors(transformed.characterAtIndex(4))),
        StatsItemViewModel(title: "FG%", value: traditional.fgp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(4))),
        StatsItemViewModel(title: "3PM", value: traditional.tpm ?? "", colors: Transform.randomColors(transformed.characterAtIndex(5))),
        StatsItemViewModel(title: "3PA", value: traditional.tpa ?? "", colors: Transform.randomColors(transformed.characterAtIndex(5))),
        StatsItemViewModel(title: "3P%", value: traditional.tpp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(5))),
          
        StatsItemViewModel(title: "FTM", value: traditional.ftm ?? "", colors: Transform.randomColors(transformed.characterAtIndex(6))),
        StatsItemViewModel(title: "FTA", value: traditional.fta ?? "", colors: Transform.randomColors(transformed.characterAtIndex(6))),
        StatsItemViewModel(title: "FT%", value: traditional.ftp ?? "", colors: Transform.randomColors(transformed.characterAtIndex(6))),
        StatsItemViewModel(title: "OREB", value: traditional.oreb ?? "", colors: Transform.randomColors(transformed.characterAtIndex(7))),
        StatsItemViewModel(title: "DREB", value: traditional.dreb ?? "", colors: Transform.randomColors(transformed.characterAtIndex(7))),
        StatsItemViewModel(title: "REB", value: traditional.reb ?? "", colors: Transform.randomColors(transformed.characterAtIndex(7))),
        StatsItemViewModel(title: "AST", value: traditional.ast ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
        StatsItemViewModel(title: "TOV", value: traditional.tov ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
        StatsItemViewModel(title: "STL", value: traditional.stl ?? "", colors: Transform.randomColors(transformed.characterAtIndex(8))),
        StatsItemViewModel(title: "BLK", value: traditional.blk ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
        StatsItemViewModel(title: "PF", value: traditional.pf ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
        StatsItemViewModel(title: "+/-", value: traditional.pm ?? "", colors: Transform.randomColors(transformed.characterAtIndex(9))),
          
      ]
  }
}
