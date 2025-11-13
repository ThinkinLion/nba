//
//  PowerRankingView.swift
//  nba
//
//  Created by 1100690 on 12/10/24.
//

import SwiftUI
import FirebaseAnalytics

struct PowerRankingView: View {
    @StateObject var viewModel = PowerRankingViewModel()
    @State private var hasAppeared = false
    
    var body: some View {
        ScrollView(.vertical) {
            if viewModel.isLoading {
                ProgressView()
                    .padding(.top, 50)
            } else if let currentRanking = viewModel.currentViewState {
                // 헤더 섹션
                headerView(powerRanking: currentRanking)
                    .padding(.horizontal, 15)
                    .padding(.top, 15)
                
                // 랭킹 리스트
                if !currentRanking.teams.isEmpty {
                    rankingListView(items: currentRanking.teams)
                        .padding(.top, 20)
                }
                
                BannerView(adUnitId: .standingsView, paddingTop: 15, paddingHorizontal: 10)
                    .padding(.top, 20)
            } else if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                Text("No power rankings available")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .navigationBarTitle("Power Rankings", displayMode: .large)
        .preferredColorScheme(.dark)
        .onAppear() {
            guard !hasAppeared else { return }
            viewModel.fetchPowerRankings()
            hasAppeared = true
        }
        .analyticsScreen(name: "NBA-PowerRankingView")
    }
}

// MARK: - Header View
extension PowerRankingView {
    @ViewBuilder
    func headerView(powerRanking: PowerRankingViewModel.PowerRankingViewState) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if let week = powerRanking.weekLabel {
                Text(week)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            if let title = powerRanking.title {
                Text(title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }
            
            if let subTitle = powerRanking.subTitle {
                Text(subTitle)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            if let imageUrl = powerRanking.imageURL {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(height: 200)
                .cornerRadius(12)
                .padding(.top, 10)
                
                if let imageDesc = powerRanking.imageDesc {
                    Text(imageDesc)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 5)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Ranking List View
extension PowerRankingView {
    @ViewBuilder
    func rankingListView(items: [PowerRankingViewModel.TeamState]) -> some View {
        VStack(spacing: 12) {
            ForEach(items) { team in
                NavigationLink(destination: PowerRankingDetailView(team: team.model)) {
                    rankingCardView(team: team)
                }
            }
        }
        .padding(.horizontal, 15)
    }
    
    @ViewBuilder
    func rankingCardView(team: PowerRankingViewModel.TeamState) -> some View {
        HStack(spacing: 12) {
            // 순위
            VStack(spacing: 4) {
                Text("\(team.displayRank)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(team.rankChangeText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(rankChangeColor(for: team.rankChangeStyle))
            }
            .frame(width: 50)
            
            // 팀 로고
            if let triCode = team.triCode {
                Image(triCode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
            }
            
            // 팀 정보
            VStack(alignment: .leading, spacing: 4) {
                if !team.name.isEmpty {
                    Text(team.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                HStack(spacing: 8) {
                    if let record = team.record {
                        Text(record)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            
            Spacer()
        }
        .padding(15)
        .background(
            Color(team.backgroundColorName)
        )
        .cornerRadius(12)
    }
    
    private func rankChangeColor(for style: PowerRankingViewModel.RankChangeStyle) -> Color {
        switch style {
        case .up:
            return .green
        case .down:
            return .red
        case .same:
            return .white.opacity(0.6)
        }
    }
}

struct PowerRankingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PowerRankingView()
        }
        .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
    }
}

