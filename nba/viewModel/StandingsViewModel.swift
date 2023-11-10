//
//  StandingsViewModel.swift
//  nba
//
//  Created by 1100690 on 2023/11/09.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase

class StandingsViewModel: ObservableObject {
    @Published var colorEntries = [Standings]()
    @Published var newColor = Standings.empty
    @Published var errorMessage: String?

    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
  
    func unsubscribe() {
        if listenerRegistration != nil {
            listenerRegistration?.remove()
            listenerRegistration = nil
        }
    }
    
    func subscribe() {
        if listenerRegistration == nil {
            listenerRegistration = db.collection("standings")
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    self?.errorMessage = "No documents in 'colors' collection"
                    return
                }
          
                self?.colorEntries = documents.compactMap { queryDocumentSnapshot in
                    let result = Result { try queryDocumentSnapshot.data(as: Standings.self) }
                    switch result {
                    case .success(let colorEntry):
                        // A ColorEntry value was successfully initialized from the DocumentSnapshot.
                        self?.errorMessage = nil
                        print("colorEntry:\(colorEntry)")
                        return colorEntry
                    case .failure(let error):
                        // A ColorEntry value could not be initialized from the DocumentSnapshot.
                        switch error {
                        case DecodingError.typeMismatch(_, let context):
                            self?.errorMessage = "\(error.localizedDescription): \(context.debugDescription)"
                        case DecodingError.valueNotFound(_, let context):
                            self?.errorMessage = "\(error.localizedDescription): \(context.debugDescription)"
                        case DecodingError.keyNotFound(_, let context):
                            self?.errorMessage = "\(error.localizedDescription): \(context.debugDescription)"
                        case DecodingError.dataCorrupted(let key):
                            self?.errorMessage = "\(error.localizedDescription): \(key)"
                        default:
                            self?.errorMessage = "Error decoding document: \(error.localizedDescription)"
                        }
                        return nil
                    }
                }
            }
        }
    }
  
    func addColorEntry() {
        let collectionRef = db.collection("standings")
        do {
            let newDocReference = try collectionRef.addDocument(from: newColor)
            print("ColorEntry stored with new document reference: \(newDocReference)")
        } catch {
            print(error)
        }
    }
}
