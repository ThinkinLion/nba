//
//  StandingsViewModel.swift
//  nba
//
//  Created by 1100690 on 2023/11/09.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase

final class StandingsViewModel: ObservableObject {
    @Published var standings = StandingsModel.empty
    @Published var newItem = StandingsModel.sample
    @Published var errorMessage: String?

    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
      
    func fetchStandings() {
        Task {
            await asyncFetch(documentId: "5OlFabQXrrz129xunRbm")
        }
//        fetchStandings(documentId: "5OlFabQXrrz129xunRbm")
    }

    @MainActor
    private func asyncFetch(documentId: String) async {
        let docRef = db.collection("nba").document(documentId)
        do {
            self.standings = try await docRef.getDocument(as: StandingsModel.self)
        } catch {
            switch error {
            case DecodingError.typeMismatch(_, let context):
                self.errorMessage = "\(error.localizedDescription): \(context.debugDescription)"
            case DecodingError.valueNotFound(_, let context):
                self.errorMessage = "\(error.localizedDescription): \(context.debugDescription)"
            case DecodingError.keyNotFound(_, let context):
                self.errorMessage = "\(error.localizedDescription): \(context.debugDescription)"
            case DecodingError.dataCorrupted(let key):
                self.errorMessage = "\(error.localizedDescription): \(key)"
            default:
                self.errorMessage = "Error decoding document: \(error.localizedDescription)"
            }
        }
    }
    
    private func fetchStandings(documentId: String) {
        db.collection("nba").document(documentId).getDocument(as: StandingsModel.self) { result in
            switch result {
            case .success(let standings):
                self.standings = standings
                self.errorMessage = nil
            case .failure(let error):
                switch error {
                case DecodingError.typeMismatch(_, let context):
                    self.errorMessage = "\(error.localizedDescription): \(context.debugDescription)"
                case DecodingError.valueNotFound(_, let context):
                    self.errorMessage = "\(error.localizedDescription): \(context.debugDescription)"
                case DecodingError.keyNotFound(_, let context):
                    self.errorMessage = "\(error.localizedDescription): \(context.debugDescription)"
                case DecodingError.dataCorrupted(let key):
                    self.errorMessage = "\(error.localizedDescription): \(key)"
                default:
                    self.errorMessage = "Error decoding document: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func addSampleItem() {
        let collectionRef = db.collection("nba")
        do {
            let newDocReference = try collectionRef.addDocument(from: newItem)
            
            print("nba stored with new document reference: \(newDocReference)")
        } catch {
            print(error)
        }
    }
    
    func updateStandings() {
        if let id = standings.id {
            let docRef = db.collection("nba").document(id)
            do {
                try docRef.setData(from: standings)
            } catch {
                print(error)
            }
        }
    }
}

struct TeamViewModel {
    private let team: Team
    
    init(team: Team) {
        self.team = team
    }
    
    var teamName: String {
        return team.teamName
    }
    
//    var teamNickname: String {
//        return team.teamSitesOnly.teamNickname
//    }
    
    var teamCode: String {
        return team.teamCode
    }
    
    var win: String {
        return team.win
    }
    
    var loss: String {
        return team.loss
    }
    
    var winLoss: String {
        return team.win + " - " + team.loss
    }
    
//    var winLossInConference: String {
//        return team.confWin + " - " + team.confLoss
//    }
//
//    var winLossInDivision: String {
//        return team.divWin + " - " + team.divLoss
//    }
    
    var winPct: String {
        return team.winPct
    }
    
    var gamesBehind: String {
        return (team.gamesBehind == "0.0") ? "-" : team.gamesBehind
    }
        
//    var conferenceRankFullName: String {
//        return self.conferenceRank + self.conferenceRankSuffix
//    }
//
    var conferenceRank: String {
        return team.confRank
    }
//
//    var conferenceRankSuffix: String {
//        var suffix = "th"
//        if team.confRank == "1" {
//            suffix = "st"
//        } else if team.confRank == "2" {
//            suffix = "nd"
//        } else if team.confRank == "3" {
//            suffix = "rd"
//        }
//        return suffix
//    }
//
//    var homeWinLoss: String {
//        return self.homeWin + "-" + self.homeLoss
//    }
//
//    var homeWin: String {
//        return team.homeWin
//    }
//
//    var homeLoss: String {
//        return team.homeLoss
//    }
//
//    var awayWinLoss: String {
//        return self.awayWin + "-" + self.awayLoss
//    }
//
//    var awayWin: String {
//        return team.awayWin
//    }
//
//    var awayLoss: String {
//        return team.awayLoss
//    }
//
//    var lastTenWinLoss: String {
//        return self.lastTenWin + "-" + self.lastTenLoss
//    }
//
//    var lastTenWin: String {
//        return team.lastTenWin
//    }
//
//    var lastTenLoss: String {
//        return team.lastTenLoss
//    }
//
//    var streak: String {
//        return (team.isWinStreak ? "W" : "L") + team.streak
//    }
}
