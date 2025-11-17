//
//  PowerRankingDetailView.swift
//  nba
//
//  Created by 1100690 on 12/10/24.
//

import SwiftUI

struct PowerRankingDetailView: View {
    let teamState: PowerRankingViewModel.TeamState
    @State var scrollOffset: CGFloat = CGFloat.zero
    @State var hideNavigationBar: Bool = true
    @StateObject private var playerViewModel = PlayerViewModel()
    @StateObject private var viewModel = PowerRankingViewModel()
    @State private var hasAppeared = false
    
    private var viewState: PowerRankingViewModel.TeamDetailViewState {
        teamState.detailViewState
    }
    
    
    var body: some View {
        ObservableScrollView(scrollOffset: $scrollOffset) {
            // 헤더 섹션
            headerView()
            
            // Overview 섹션
            if let overview = viewState.overview, !overview.isEmpty {
                sectionView(title: "Overview", content: overview)
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
                takeawaysView(takeaways: takeaways)
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
                advancedStatsView(advanced: advanced)
                    .padding(.top, 20)
            }
            
            // Upcoming 섹션
            if let upcoming = viewState.upcoming, !upcoming.isEmpty {
                sectionView(title: "Upcoming", content: upcoming)
                    .padding(.top, 20)
            }
            
            // Recent Games 섹션
            if !viewModel.recentGames.isEmpty {
                recentGamesView(games: viewModel.recentGames)
                    .padding(.top, 20)
            }
            
            BannerView(adUnitId: .teamView, paddingTop: 20, height: 100)
                .padding(.bottom, 30)
        }
        .background(viewState.darkBackgroundColor)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarTitle("", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                if let triCode = viewState.triCode {
                    Image(triCode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .opacity(hideNavigationBar ? 0.0 : 1.0)
                }
            }
        }
        .onChange(of: scrollOffset) { scrollOfset in
            let offset = scrollOfset + (self.hideNavigationBar ? 50 : 0)
            if offset > 60 {
                withAnimation(.easeIn(duration: 0.3)) {
                    self.hideNavigationBar = false
                }
            }
            if offset < 50 {
                withAnimation(.easeIn(duration: 0.3)) {
                    self.hideNavigationBar = true
                }
            }
        }
        .onAppear {
            guard !hasAppeared else { return }
            if !viewState.teamId.isEmpty {
                playerViewModel.fetchRoster(teamId: viewState.teamId)
                viewModel.fetchRecentGames(teamId: viewState.teamId)
            }
            hasAppeared = true
        }
    }
}

// MARK: - Header View
extension PowerRankingDetailView {
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
                
                VStack(alignment: .center, spacing: 6) {
                    Image(triCode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .clipped()
                    
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
                            rankChangeBadge(text: viewState.rankChangeText, style: viewState.rankChangeStyle)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 30)
                .padding(.bottom, 20)
                .zIndex(1)
            }
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
    
    @ViewBuilder
    func rankChangeBadge(text: String, style: PowerRankingViewModel.RankChangeStyle) -> some View {
        Text(text)
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(PowerRankingViewModel.rankChangeColor(for: style))
    }
}

// MARK: - Mentioned Players View
extension PowerRankingDetailView {
    @ViewBuilder
    func mentionedPlayersView(players: [PlayerModel]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Players to Watch".uppercased())
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 15)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(players, id: \.id) { player in
                        NavigationLink(destination: PlayerView(
                            playerId: player.playerId ?? "",
                            teamId: player.teamId ?? ""
                        )) {
                            playerCardView(player: player)
                        }
                    }
                }
                .padding(.horizontal, 15)
            }
        }
    }
    
    @ViewBuilder
    func playerCardView(player: PlayerModel) -> some View {
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
                                    ProgressView()
                                        .tint(.white.opacity(0.7))
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
                    // 선수 이름
                    Text("\(player.firstName ?? "") \(player.lastName ?? "")")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // 주요 스탯
                    HStack(spacing: 8) {
                        if let ppg = player.ppg, !ppg.isEmpty {
                            VStack(spacing: 2) {
                                Text("PPG")
                                    .font(.system(size: 8, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                                Text(ppg)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        if let rpg = player.rpg, !rpg.isEmpty {
                            VStack(spacing: 2) {
                                Text("RPG")
                                    .font(.system(size: 8, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                                Text(rpg)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        if let apg = player.apg, !apg.isEmpty {
                            VStack(spacing: 2) {
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
            
            // 포지션 태그 (왼쪽 상단 모서리)
            if let position = player.position {
                let abbreviatedPosition = PowerRankingViewModel.abbreviatePosition(position)
                let positionColor = PowerRankingViewModel.positionColor(for: position)
                
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
                                        positionColor.opacity(0.8),
                                        positionColor.opacity(0.6)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        Capsule()
                            .stroke(positionColor.opacity(0.9), lineWidth: 1)
                    )
                    .shadow(color: positionColor.opacity(0.4), radius: 4, x: 0, y: 2)
                    .offset(x: 8, y: 8)
            }
        }
        .frame(width: 140)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.12),
                            Color.white.opacity(0.06)
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
                            Color.white.opacity(0.2),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Recent Games View
extension PowerRankingDetailView {
    @ViewBuilder
    func recentGamesView(games: [HomeAway]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Games".uppercased())
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
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
        let gameInfo = PowerRankingViewModel.GameInfo.from(game: game, teamId: viewState.teamId)
        
        HStack(spacing: 12) {
            // 날짜
            if let date = game.date {
                Text(PowerRankingViewModel.formatGameDate(date))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 50, alignment: .leading)
            }
            
            // 상대팀 로고
            Image(gameInfo.opponentTriCode)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
            
            // 상대팀 이름
            Text(gameInfo.opponentTriCode)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // 점수
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
            
            // 승/패 표시
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

// MARK: - Section Views
extension PowerRankingDetailView {
    @ViewBuilder
    func sectionView(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 15)
            
            Text(content)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .lineSpacing(4)
                .padding(.horizontal, 15)
        }
    }
    
    @ViewBuilder
    func takeawaysView(takeaways: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Takeaways".uppercased())
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 15)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(takeaways.enumerated()), id: \.offset) { index, takeaway in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.top, 2)
                        
                        Text(takeaway)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 15)
                }
            }
        }
    }
    
    @ViewBuilder
    func advancedStatsView(advanced: PowerRankingAdvancedModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Advanced Stats".uppercased())
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 15)
            
            VStack(spacing: 12) {
                if let offRtg = advanced.offRtg {
                  advancedStatRow(title: offRtg.title ?? "Off Rtg", value: offRtg.value ?? "", rank: offRtg.rank ?? "")
                }
              
                if let defRtg = advanced.defRtg {
                    advancedStatRow(title: defRtg.title ?? "Def Rtg", value: defRtg.value ?? "", rank: defRtg.rank ?? "")
                }
                
                if let netRtg = advanced.netRtg {
                    advancedStatRow(title: netRtg.title ?? "Net Rtg", value: netRtg.value ?? "", rank: netRtg.rank ?? "")
                }
                
                if let pace = advanced.pace {
                    advancedStatRow(title: pace.title ?? "Pace", value: pace.value ?? "", rank: pace.rank ?? "")
                }
            }
            .padding(.horizontal, 15)
        }
    }
    
    @ViewBuilder
    func advancedStatRow(title: String, value: String, rank: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            HStack(spacing: 8) {
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                if !rank.isEmpty {
                    Text("(Rank: \(rank))")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(8)
    }
}

struct PowerRankingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PowerRankingDetailView(
                teamState: PowerRankingViewModel.TeamState(
                    id: "1",
                    displayRank: 1,
                    name: "MILWAUKEE BUCKS",
                    record: "30-12",
                    rankChangeText: "↑1",
                    rankChangeStyle: .up,
                    triCode: "MIL",
                    backgroundColorName: "bucks",
                    model: PowerRankingTeamModel(
                        id: "1",
                        rank: "1",
                        record: "30-12",
                        teamName: "Milwaukee Bucks",
                        teamCode: "MIL",
                        lastWeek: "1",
                        advanced: nil,
                        overview: "The Bucks are playing great basketball...",
                        takeaways: ["Takeaway 1", "Takeaway 2"],
                        upcomming: "Next 5 games..."
                    )
                )
            )
        }
        .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
    }
}

