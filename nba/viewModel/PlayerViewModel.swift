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
        db.collection("players").document(documentId).getDocument(as: PlayerModel.self) { result in
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
    
    var imageUrl: String {
        //260x190: https://cdn.nba.com/headshots/nba/latest/260x190/1631260.png
        "https://cdn.nba.com/headshots/nba/latest/1040x760/{{playerId}}.png".replacingOccurrences(of: "{{playerId}}", with: playerId)
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
    
    var pie: String {
        player.pie ?? ""
    }
    
    var ppg: String {
        player.ppg ?? ""
    }
    
    var rpg: String {
        player.rpg ?? ""
    }
    
    var apg: String {
        player.apg ?? ""
    }
    
}
