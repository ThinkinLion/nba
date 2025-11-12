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
            } else if let currentRanking = viewModel.currentPowerRanking {
                // 헤더 섹션
                headerView(powerRanking: currentRanking)
                    .padding(.horizontal, 15)
                    .padding(.top, 15)
                
                // 랭킹 리스트
                if let items = currentRanking.items, !items.isEmpty {
                    rankingListView(items: items)
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
    func headerView(powerRanking: PowerRankingModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if let week = powerRanking.week {
                Text("Week \(week)")
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
            
            if let imageUrl = powerRanking.image, !imageUrl.isEmpty {
                AsyncImage(url: URL(string: imageUrl)) { image in
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
    func rankingListView(items: [PowerRankingTeamModel]) -> some View {
        VStack(spacing: 12) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, team in
                NavigationLink(destination: PowerRankingDetailView(team: team)) {
                    rankingCardView(team: team, rank: index + 1)
                }
            }
        }
        .padding(.horizontal, 15)
    }
    
    @ViewBuilder
    func rankingCardView(team: PowerRankingTeamModel, rank: Int) -> some View {
        HStack(spacing: 12) {
            // 순위
            Text("\(rank)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 40)
            
            // 팀 로고
            if let teamCode = team.teamCode {
                let triCode = teamCode.count == 3 ? teamCode.uppercased() : teamCode.nickNameToTriCode
                if !triCode.isEmpty {
                    Image(triCode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            
            // 팀 정보
            VStack(alignment: .leading, spacing: 4) {
                if let teamName = team.teamName {
                    Text(teamName.uppercased())
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                HStack(spacing: 8) {
                    if let record = team.record {
                        Text(record)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // 전주 대비 순위 변화
                    if let lastWeek = team.lastWeek, !lastWeek.isEmpty {
                        rankChangeView(change: lastWeek)
                    }
                }
            }
            
            Spacer()
        }
        .padding(15)
        .background(
            Group {
                if let teamCode = team.teamCode {
                    // teamCode가 triCode일 수 있으므로 nickName으로 변환
                    let nickName = teamCode.triCodeToNickName.isEmpty ? teamCode.lowercased() : teamCode.triCodeToNickName
                    Color(nickName)
                } else {
                    Color("#1C1B1D")
                }
            }
        )
        .cornerRadius(12)
    }
    
    @ViewBuilder
    func rankChangeView(change: String) -> some View {
        let changeValue = Int(change) ?? 0
        
        if changeValue > 0 {
            HStack(spacing: 2) {
                Image(systemName: "arrow.up")
                Text("\(changeValue)")
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.green)
        } else if changeValue < 0 {
            HStack(spacing: 2) {
                Image(systemName: "arrow.down")
                Text("\(abs(changeValue))")
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.red)
        } else {
            HStack(spacing: 2) {
                Image(systemName: "minus")
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white.opacity(0.6))
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

