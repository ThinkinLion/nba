//
//  SafeModePowerRankingDetailView.swift
//  nba
//
//  Created on 12/03/24.
//

import SwiftUI

struct SafeModePowerRankingDetailView: View {
    let teamState: PowerRankingViewModel.TeamState
    @ObservedObject var viewModel: PowerRankingViewModel
    @ObservedObject var playerViewModel: PlayerViewModel
    @Binding var scrollOffset: CGFloat
    @Binding var hideNavigationBar: Bool
    
    private var viewState: PowerRankingViewModel.TeamDetailViewState {
        teamState.detailViewState
    }
    
    // 팀 컬러 추출 (그라데이션의 중간색 사용)
    private var teamColor: Color {
        if viewState.titleGradientColors.count >= 3 {
            return viewState.titleGradientColors[2] // opacity가 적용된 팀 컬러
        }
        return .blue
    }
    
    var body: some View {
        ObservableScrollView(scrollOffset: $scrollOffset) {
            // 헤더 섹션 (로고 없음, 기하학적 패턴 추가)
            headerView()
            
            // Overview 섹션
            if let overview = viewState.overview, !overview.isEmpty {
                PowerRankingDetailSectionView(title: "Overview", content: overview)
                    .padding(.top, 20)
                
                // Overview에 언급된 선수들 (네비게이션 비활성화)
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
                
                // Takeaways에 언급된 선수들 (네비게이션 비활성화)
                let allTakeaways = takeaways.joined(separator: " ")
                let mentionedPlayers = viewModel.extractMentionedPlayers(from: allTakeaways, roster: playerViewModel.roster)
                if !mentionedPlayers.isEmpty {
                    mentionedPlayersView(players: mentionedPlayers)
                        .padding(.top, 15)
                }
            }
            
            // Advanced Stats 섹션 (Visual)
            if let advanced = viewState.advanced {
                visualAdvancedStatsView(advanced: advanced)
                    .padding(.top, 20)
            }
            
            // Upcoming 섹션
            if let upcoming = viewState.upcoming, !upcoming.isEmpty {
                PowerRankingDetailSectionView(title: "Upcoming", content: upcoming)
                    .padding(.top, 20)
            }
            
            // Recent Games 섹션 (네비게이션 비활성화, Form Guide 추가)
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
    
    // MARK: - Header View (Geometric Pattern)
    @ViewBuilder
    func headerView() -> some View {
        ZStack(alignment: .topLeading) {
            // 배경 패턴
            GeometryReader { geometry in
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 300, height: 300)
                        .offset(x: -100, y: -100)
                    
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 40)
                        .frame(width: 200, height: 200)
                        .offset(x: geometry.size.width - 100, y: 50)
                    
                    Rectangle()
                        .fill(Color.white.opacity(0.03))
                        .rotationEffect(.degrees(45))
                        .frame(width: 200, height: 200)
                        .offset(x: 50, y: 100)
                }
            }
            .clipped()
            
            VStack(alignment: .center, spacing: 6) {
                Text(viewState.name)
                    .foregroundColor(.white)
                    .font(.system(size: 28, weight: .heavy)) // 폰트 크기 및 굵기 증가
                    .padding(.bottom, 2)
                    .padding(.top, 40) // 상단 여백 증가
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                
                HStack(spacing: 28) {
                    if let rank = viewState.rank {
                        VStack(spacing: 4) {
                            Text("RANK")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(4)
                            
                            Text(rank)
                                .font(.system(size: 32, weight: .bold)) // 폰트 크기 증가
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                        }
                    }
                    
                    if let record = viewState.record {
                        VStack(spacing: 4) {
                            Text("RECORD")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(4)
                            
                            Text(record)
                                .font(.system(size: 24, weight: .bold)) // 폰트 크기 증가
                                .foregroundColor(.white)
                                .padding(.top, 4)
                        }
                    }
                    
                    VStack(spacing: 4) {
                        Text("LAST WEEK")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(4)
                        
                        PowerRankingDetailRankChangeBadge(text: viewState.rankChangeText, style: viewState.rankChangeStyle)
                            .scaleEffect(1.2) // 배지 크기 증가
                            .padding(.top, 4)
                    }
                    
                    MomentumView(momentum: viewState.momentum)
                }
                .padding(.top, 10)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 30)
            .padding(.bottom, 30)
            .zIndex(1)
        }
        .frame(height: 260) // 헤더 높이 증가
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
                    color: teamColor
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
    
    // MARK: - Mentioned Players View (No Navigation, No Images)
    @ViewBuilder
    func mentionedPlayersView(players: [PlayerModel]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Players to Watch".uppercased())
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 15)
            
            // Find Key Player
            let keyPlayerId = PowerRankingViewModel.TeamDetailViewState.findKeyPlayerId(from: players)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(players, id: \.id) { player in
                        playerCardView(player: player, isKeyPlayer: player.id == keyPlayerId)
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
                // 선수 정보 (이미지 없음)
                VStack(alignment: .leading, spacing: 12) {
                    Text("\(player.firstName ?? "") \(player.lastName ?? "")")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack(spacing: 12) {
                        if let ppg = player.ppg, !ppg.isEmpty {
                            VStack(spacing: 3) {
                                Text("PPG")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                                Text(ppg)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(isKeyPlayer ? .yellow : .white) // Highlight PPG
                            }
                        }
                        
                        if let rpg = player.rpg, !rpg.isEmpty {
                            VStack(spacing: 3) {
                                Text("RPG")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                                Text(rpg)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        if let apg = player.apg, !apg.isEmpty {
                            VStack(spacing: 3) {
                                Text("APG")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                                Text(apg)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .padding(.top, 16)
                .padding(.horizontal, 10)
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // 포지션 태그 (오른쪽 하단)
            if let position = player.position {
                let abbreviatedPosition = PowerRankingViewModel.abbreviatePosition(position)
                let gradientColors = PowerRankingViewModel.positionGradientColors(for: position)
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .offset(x: -8, y: -8)
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
                    .frame(maxWidth: .infinity, alignment: .topTrailing)
                    .offset(x: -8, y: 8)
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
    
    // MARK: - Recent Games View (No Navigation, Form Guide Added)
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
                        let gameInfo = PowerRankingViewModel.GameInfo.from(game: game, teamId: viewState.teamId)
                        Circle()
                            .fill(gameInfo.teamWon ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .padding(.horizontal, 15)
            
            VStack(spacing: 10) {
                ForEach(games, id: \.gameId) { game in
                    recentGameCardView(game: game)
                }
            }
            .padding(.horizontal, 15)
        }
    }
    
    @ViewBuilder
    func recentGameCardView(game: HomeAway) -> some View {
        let gameInfo = PowerRankingViewModel.GameInfo.from(game: game, teamId: viewState.teamId)
        
        HStack(spacing: 12) {
            if let date = game.date {
                Text(PowerRankingViewModel.formatGameDate(date))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 50, alignment: .leading)
            }
            
            // Safe Mode: 팀 코드만 표시 (로고 없음)
            Text(gameInfo.opponentTriCode)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 40, alignment: .center)
            
            Text("vs")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
            
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
            
            Spacer()
            
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
