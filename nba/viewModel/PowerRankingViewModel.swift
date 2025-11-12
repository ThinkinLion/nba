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
                self.currentPowerRanking = self.powerRankings.first
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
    }
}


