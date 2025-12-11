//
//  OfficialPowerRankingDetailView.swift
//  nba
//
//  Created on 12/03/24.
//

import SwiftUI

struct OfficialPowerRankingDetailView: View {
    let teamState: TeamState
    @ObservedObject var viewModel: PowerRankingViewModel
    @ObservedObject var playerViewModel: PlayerViewModel
    @Binding var scrollOffset: CGFloat
    @Binding var hideNavigationBar: Bool
    
    private var viewState: TeamDetailViewState {
        teamState.detailViewState
    }
    
    var body: some View {
        ObservableScrollView(scrollOffset: $scrollOffset) {
            // 헤더 섹션
            headerView()
            
            // Overview 섹션
            if let overview = viewState.overview, !overview.isEmpty {
                PowerRankingDetailSectionView(title: "Overview", content: overview)
                    .padding(.top, 20)
                
                // Overview에 언급된 선수들
                let mentionedPlayers = viewModel.extractMentionedPlayers(from: overview, roster: playerViewModel.roster)
                if !mentionedPlayers.isEmpty {
                    mentionedPlayersView(players: mentionedPlayers)
                        .padding(.top, 15)
                }
            }
            
            // Takeaways 섹션
            if let takeaways = viewState.takeaways, !takeaways.isEmpty {
                PowerRankingDetailTakeawaysView(takeaways: takeaways)
                    .padding(.top, 20)
                
                // Takeaways에 언급된 선수들
                let allTakeaways = takeaways.joined(separator: " ")
                let mentionedPlayers = viewModel.extractMentionedPlayers(from: allTakeaways, roster: playerViewModel.roster)
                if !mentionedPlayers.isEmpty {
                    mentionedPlayersView(players: mentionedPlayers)
                        .padding(.top, 15)
                }
            }
            
            // Advanced Stats 섹션
            if let advanced = viewState.advanced {
                visualAdvancedStatsView(advanced: advanced)
                    .padding(.top, 20)
            }
            
            // Ranking History 섹션
            if !viewModel.rankingHistory.isEmpty {
                RankingHistoryView(history: viewModel.rankingHistory, teamColor: viewState.backgroundColor)
                    .padding(.top, 20)
            }
            
            // Upcoming 섹션
            if let upcoming = viewState.upcoming, !upcoming.isEmpty {
                PowerRankingDetailSectionView(title: "Upcoming", content: upcoming)
                    .padding(.top, 20)
            }
            
            // Recent Games 섹션
            if !viewModel.recentGames.isEmpty {
                recentGamesView(games: viewModel.recentGames)
                    .padding(.top, 20)
            }
            
            BannerView(adUnitId: .powerRanking, paddingTop: 20, height: 100)
                .padding(.bottom, 30)
        }
        .background(viewState.darkBackgroundColor)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Header View
    @ViewBuilder
    func headerView() -> some View {
        ZStack(alignment: .topLeading) {
            Color.clear
            
            // 배경 로고
            if let triCode = viewState.triCode {
                Image(triCode)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(0.1)
                    .frame(width: 167, height: 167)
                    .scaleEffect(1.2)
                    .clipped()
                    .zIndex(0)
            }
            
            VStack(alignment: .center, spacing: 6) {
                // 메인 로고
                if let triCode = viewState.triCode {
                    Image(triCode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .clipped()
                }
                
                Text(viewState.name)
                    .foregroundColor(.white)
                    .font(.system(size: 22, weight: .bold))
                    .padding(.bottom, 2)
                
                HStack(spacing: 28) {
                    if let rank = viewState.rank {
                        VStack(spacing: 4) {
                            Text("RANK")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                            Text(rank)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    
                    if let record = viewState.record {
                        VStack(spacing: 4) {
                            Text("RECORD")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                            Text(record)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    
                    VStack(spacing: 4) {
                        Text("LAST WEEK")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                        PowerRankingDetailRankChangeBadge(text: viewState.rankChangeText, style: viewState.rankChangeStyle)
                    }
                    

                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 30)
            .padding(.bottom, 20)
            .zIndex(1)
        }
        .frame(height: 220)
        .frame(maxWidth: .infinity)
        .background(viewState.backgroundColor)
        
        // 커스텀 코너로 다음 섹션과 연결
        Text("")
            .frame(maxWidth: .infinity)
            .frame(height: 20)
            .background {
                CustomCorner(corners: [.topLeft], radius: 20)
                    .fill(viewState.darkBackgroundColor)
                    .ignoresSafeArea()
            }
            .padding(.top, -19)
    }
    
    // MARK: - Visual Advanced Stats View
    @ViewBuilder
    func visualAdvancedStatsView(advanced: PowerRankingAdvancedModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Advanced Stats".uppercased())
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 15)
            
            // Radar Chart
            HStack {
                Spacer()
                RadarChartView(
                    data: viewState.radarChartData,
                    labels: ["OFF", "DEF", "NET", "PACE"],
                    color: viewState.backgroundColor
                )
                .frame(width: 200, height: 200)
                Spacer()
            }
            .padding(.bottom, 10)
            
            VStack(spacing: 12) {
                if let offRtg = advanced.offRtg {
                    VisualAdvancedStatRow(title: offRtg.title ?? "Off Rtg", value: offRtg.value ?? "", rank: offRtg.rank ?? "", color: .green)
                }
              
                if let defRtg = advanced.defRtg {
                    VisualAdvancedStatRow(title: defRtg.title ?? "Def Rtg", value: defRtg.value ?? "", rank: defRtg.rank ?? "", color: .red)
                }
                
                if let netRtg = advanced.netRtg {
                    VisualAdvancedStatRow(title: netRtg.title ?? "Net Rtg", value: netRtg.value ?? "", rank: netRtg.rank ?? "", color: .orange)
                }
                
                if let pace = advanced.pace {
                    VisualAdvancedStatRow(title: pace.title ?? "Pace", value: pace.value ?? "", rank: pace.rank ?? "", color: .blue)
                }
            }
            .padding(.horizontal, 15)
        }
    }
    
    // MARK: - Mentioned Players View
    @ViewBuilder
    func mentionedPlayersView(players: [PlayerModel]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Players to Watch".uppercased())
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 15)
            
            // Find Key Player
            let keyPlayerId = TeamDetailViewState.findKeyPlayerId(from: players)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(players, id: \.id) { player in
                        NavigationLink(destination: PlayerView(
                            playerId: player.playerId ?? "",
                            teamId: player.teamId ?? ""
                        )) {
                            playerCardView(player: player, isKeyPlayer: player.id == keyPlayerId)
                        }
                    }
                }
                .padding(.horizontal, 15)
            }
        }
    }
    
    @ViewBuilder
    func playerCardView(player: PlayerModel, isKeyPlayer: Bool = false) -> some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 0) {
                // 선수 이미지
                if let playerId = player.playerId, !playerId.isEmpty {
                    AsyncImage(url: URL(string: playerId.smallImageUrl)) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.15),
                                            Color.white.opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    LogoLoadingView(size: 48, showBackground: false)
                                )
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.15),
                                            Color.white.opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.white.opacity(0.5))
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 140, height: 100)
                    .clipped()
                } else {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.15),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 100)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white.opacity(0.5))
                        )
                }
                
                // 선수 정보
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(player.firstName ?? "") \(player.lastName ?? "")")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack(spacing: 8) {
                        if let ppg = player.ppg, !ppg.isEmpty {
                            VStack(spacing: 3) {
                                Text("PPG")
                                    .font(.system(size: 8, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                                Text(ppg)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(isKeyPlayer ? .yellow : .white) // Highlight PPG
                            }
                        }
                        
                        if let rpg = player.rpg, !rpg.isEmpty {
                            VStack(spacing: 3) {
                                Text("RPG")
                                    .font(.system(size: 8, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                                Text(rpg)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        if let apg = player.apg, !apg.isEmpty {
                            VStack(spacing: 3) {
                                Text("APG")
                                    .font(.system(size: 8, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                                Text(apg)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .padding(.top, 10)
                .padding(.horizontal, 10)
                .padding(.bottom, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // 포지션 태그
            if let position = player.position {
                let abbreviatedPosition = PowerRankingFormatter.abbreviatePosition(position)
                let gradientColors = PowerRankingFormatter.positionGradientColors(for: position)
                let startColor = gradientColors.0
                let endColor = gradientColors.1
                
                Text(abbreviatedPosition)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        startColor.opacity(0.9),
                                        endColor.opacity(0.7)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        Capsule()
                            .stroke(startColor.opacity(0.95), lineWidth: 1)
                    )
                    .shadow(color: startColor.opacity(0.4), radius: 4, x: 0, y: 2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .offset(x: 8, y: 8)
            }
            
            // Key Player Badge
            if isKeyPlayer {
                Text("KEY PLAYER")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.yellow)
                    .cornerRadius(4)
                    .offset(x: 8, y: 80) // Position above info
            }
        }
        .frame(width: 140)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            isKeyPlayer ? Color.yellow.opacity(0.15) : Color.white.opacity(0.12),
                            isKeyPlayer ? Color.yellow.opacity(0.05) : Color.white.opacity(0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            isKeyPlayer ? Color.yellow.opacity(0.8) : Color.white.opacity(0.2),
                            isKeyPlayer ? Color.yellow.opacity(0.3) : Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: isKeyPlayer ? 2 : 1
                )
        )
        .shadow(color: isKeyPlayer ? Color.yellow.opacity(0.2) : .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Recent Games View
    @ViewBuilder
    func recentGamesView(games: [HomeAway]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Games".uppercased())
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                // Form Guide (Last 5)
                HStack(spacing: 4) {
                    ForEach(games.prefix(5), id: \.gameId) { game in
                        let gameInfo = GameInfo.from(game: game, teamId: viewState.teamId)
                        Circle()
                            .fill(gameInfo.teamWon ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .padding(.horizontal, 15)
            
            VStack(spacing: 10) {
                ForEach(games, id: \.gameId) { game in
                    NavigationLink(destination: GameRecapView(
                        viewModel: HomeAwayViewModel(homeAway: game),
                        gameRecap: []
                    )) {
                        recentGameCardView(game: game)
                    }
                }
            }
            .padding(.horizontal, 15)
        }
    }
    
    @ViewBuilder
    func recentGameCardView(game: HomeAway) -> some View {
        let gameInfo = GameInfo.from(game: game, teamId: viewState.teamId)
        
        HStack(spacing: 12) {
            if let date = game.date {
                Text(PowerRankingFormatter.formatGameDate(date))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 50, alignment: .leading)
            }
            
            Image(gameInfo.opponentTriCode)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
            
            Text(gameInfo.opponentTriCode)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 4) {
                Text(gameInfo.teamScore)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Text("-")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
                
                Text(gameInfo.opponentScore)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Text(gameInfo.teamWon ? "W" : "L")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(gameInfo.teamWon ? .green : .red)
                .frame(width: 24, height: 24)
                .background(
                    Circle()
                        .fill((gameInfo.teamWon ? Color.green : Color.red).opacity(0.2))
                )
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
}
