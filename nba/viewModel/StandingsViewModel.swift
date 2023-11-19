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
    @Published var east: ([Team], [Team], [Team])?
    @Published var west: ([Team], [Team], [Team])?
    @Published var errorMessage: String?

    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
      
    func fetchStandings() {
//        Task {
//            await asyncFetch(documentId: "4Ly0HefCvRXdNsHPwmvf")
//        }
        fetchStandings(documentId: "M5mVzGMIb4pdj1KtKVQ1")
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
//                self.standings = standings
                print("fetchStandings: \(standings)")
                self.east = self.divideConferenceStandings(conference: standings.east)
                self.west = self.divideConferenceStandings(conference: standings.west)
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
    
    func divideConferenceStandings(conference: [Team]) -> ([Team], [Team], [Team])? {
        guard conference.count == 15 else { return nil }
        
        // 배열을 나누고자 하는 각 섹션의 길이
        let sectionLengths = [6, 4, 5]
        
        // 배열을 나누어서 튜플로 반환
        let dividedSections = sectionLengths.reduce(into: ([Team](), [Team](), [Team]())) { result, length in
            var startIndex = result.0.count
            if !result.0.isEmpty && !result.1.isEmpty {
                startIndex = result.0.count + result.1.count
            }
            
            let endIndex = startIndex + length
            let section = Array(conference[startIndex..<endIndex])
            
            if result.0.isEmpty {
                result.0 = section
            } else if result.1.isEmpty {
                result.1 = section
            } else {
                result.2 = section
            }
        }
        
        return dividedSections
    }
}
