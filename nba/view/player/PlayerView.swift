//
//  PlayerView.swift
//  nba
//
//  Created by 1100690 on 12/5/23.
//
//

import SwiftUI

struct PlayerView: View {
    @StateObject var viewModel = PlayerViewModel()
    @State private var hasAppeared = false
    let playerId: String
    let teamId: String
    @State var scrollOffset: CGFloat = CGFloat.zero
    @State var hideNavigationBar: Bool = true
    
    var body: some View {
        let player = PlayerSummaryViewModel(player: viewModel.player)
        
        ZStack(alignment: .top) {
            Color(UIColor.systemBackground).ignoresSafeArea() // Fallback background
            
            // Dynamic Background based on Team Color
            LinearGradient(
                colors: [Color(self.teamId.dark), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ObservableScrollView(scrollOffset: $scrollOffset) {
                VStack(spacing: 0) {
                    // 1. Header Section
                    PlayerHeaderView(player: player)
                    
                    // 2. Season Summary (Snapshot: 2026-27 PPG, RPG, APG, PIE)
                    PlayerSeasonSummaryView(player: player)
                        .padding(.top, 16)
                    
                    // 3. LAST 3 GAMES Section
                    if !viewModel.recentGames.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            // 섹션 헤더
                            HStack(spacing: 6) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.orange)
                                Text("LAST \(viewModel.recentGames.count) GAMES")
                                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white.opacity(0.75))
                                    .tracking(0.6)
                                Spacer()
                            }
                            
                            // 가장 최근 경기 히어로 카드 (탭 → GameRecap)
                            if let lastGame = viewModel.recentGames.first {
                                NavigationLink(destination: GameRecapView(viewModel: HomeAwayViewModel(homeAway: lastGame.game), gameRecap: [])) {
                                    lastGameCard(stats: lastGame)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            // 최근 3경기 미니 요약 로우 (2번째부터)
                            if viewModel.recentGames.count > 1 {
                                HStack(spacing: 8) {
                                    ForEach(viewModel.recentGames.dropFirst().prefix(2), id: \.gameDate) { game in
                                        NavigationLink(destination: GameRecapView(viewModel: HomeAwayViewModel(homeAway: game.game), gameRecap: [])) {
                                            miniGameRow(stats: game)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }

                    
                    // 4. Bio Grid
                    PlayerBioGridView(player: player)
                        .padding(.top, 16)

                    // In-Feed Banner
                    StyledBannerContainer(adUnitId: .powerRanking, paddingHorizontal: 15)
                        .padding(.top, 20)
                    
                    // 5. Yearly Stats Sections
                    VStack(spacing: 20) {
                        if player.hasTraditional {
                            PlayerYearlyStatsCardView(title: "Traditional Stats", stats: player.traditional, teamId: teamId)
                        }
                        
                        if player.hasAdvanced {
                            PlayerYearlyStatsCardView(title: "Advanced Stats", stats: player.advanced, teamId: teamId)
                        }
                        
                        if player.hasScoring {
                            PlayerYearlyStatsCardView(title: "Scoring Stats", stats: player.scoring, teamId: teamId)
                        }
                        
                        if player.hasUsage {
                            PlayerYearlyStatsCardView(title: "Usage Stats", stats: player.usage, teamId: teamId)
                        }
                        
                        if player.hasMisc {
                            PlayerYearlyStatsCardView(title: "Misc Stats", stats: player.misc, teamId: teamId)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .background(Color.clear)
        }
        .onAppear() {
            guard !hasAppeared else { return }
            viewModel.fetchPlayer(documentId: self.playerId)
            viewModel.fetchRoster(teamId: self.teamId)
            viewModel.fetchLastGame(playerId: self.playerId)
            hasAppeared = true
        }
        .navigationBarTitle("", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 4) {
                    if RemoteConfigManager.shared.shouldUseOfficialTeamData {
                        Image(self.teamId.teamIdToTriCode)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                    }
                    
                    Text(player.fullName.uppercased())
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                .opacity(hideNavigationBar ? 0.0 : 1.0)
                .animation(.easeInOut, value: hideNavigationBar)
            }
        }
        .onChange(of: scrollOffset) { scrollOfset in
            let offset = scrollOfset + (self.hideNavigationBar ? 50 : 0)
            if offset > 150 { // Show Nav Bar after scrolling past header
                withAnimation(.easeIn(duration: 0.3)) {
                    self.hideNavigationBar = false
                }
            }
            if offset < 140 {
                withAnimation(.easeOut(duration: 0.3)) {
                    self.hideNavigationBar = true
                }
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .analyticsScreen(name: "NBA-PlayerView")
    }
    
    // MARK: - Last Game Snapshot Card (Scaled-Up Premium Boxscore)
    @ViewBuilder
    private func lastGameCard(stats: PlayerLastGameStats) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // 섹션 헤더
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.orange)
                Text("LATEST PERFORMANCE")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundColor(.white.opacity(0.75))
                    .tracking(0.6)
                
                Spacer()
                
                if !stats.gameDate.isEmpty {
                    Text(stats.gameDate)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.45))
                }
            }
            
            // 프리미엄 네온 글래스 카드
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(self.teamId.dark).opacity(0.45),
                                Color.white.opacity(0.06),
                                Color.black.opacity(0.65)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.orange.opacity(0.55),
                                        Color.white.opacity(0.12)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.35), radius: 6, x: 0, y: 3)
                
                VStack(spacing: 12) {
                    // 상단 행: 상대팀 정보 & 스코어 & 리캡 인디케이터
                    HStack(spacing: 8) {
                        HStack(spacing: 6) {
                            if RemoteConfigManager.shared.shouldUseOfficialTeamData, !stats.opponentTriCode.isEmpty {
                                Image(stats.opponentTriCode)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 22, height: 22)
                            }
                            Text("\(stats.isHome ? "vs" : "@") \(stats.opponentTriCode)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        Text(stats.resultText)
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundColor(stats.resultText.hasPrefix("W") ? Color(red: 0.2, green: 0.85, blue: 0.45) : Color.red.opacity(0.85))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.black.opacity(0.35))
                            .clipShape(Capsule())
                        
                        Spacer()
                        
                        HStack(spacing: 3) {
                            Text("RECAP")
                                .font(.system(size: 10, weight: .heavy, design: .rounded))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 9, weight: .bold))
                        }
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Capsule())
                    }
                    
                    // 하단 행: 스탯 그리드 (PTS 크게, REB, AST, MIN 미니 필)
                    HStack(spacing: 10) {
                        HStack(alignment: .firstTextBaseline, spacing: 3) {
                            Text(stats.pts)
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            Text("PTS")
                                .font(.system(size: 10, weight: .heavy))
                                .foregroundColor(.orange)
                        }
                        .padding(.trailing, 4)
                        
                        statPill(label: "REB", value: stats.reb)
                        statPill(label: "AST", value: stats.ast)
                        if let min = stats.min, !min.isEmpty && min != "0" {
                            statPill(label: "MIN", value: min)
                        }
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
        }
    }
    
    @ViewBuilder
    private func statPill(label: String, value: String) -> some View {
        HStack(spacing: 4) {
            Text(value)
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.08))
        .clipShape(Capsule())
    }
    
    // MARK: - Mini Game Row (2번째, 3번째 최근 경기 요약 카드)
    @ViewBuilder
    private func miniGameRow(stats: PlayerLastGameStats) -> some View {
        HStack(spacing: 10) {
            // 상대팀 로고 + 홈/어웨이
            HStack(spacing: 5) {
                if RemoteConfigManager.shared.shouldUseOfficialTeamData, !stats.opponentTriCode.isEmpty {
                    Image(stats.opponentTriCode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                }
                Text("\(stats.isHome ? "vs" : "@") \(stats.opponentTriCode)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
            }
            
            // 승패 뱃지
            Text(String(stats.resultText.prefix(1))) // "W" or "L"
                .font(.system(size: 9, weight: .black))
                .foregroundColor(.white)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(stats.resultText.hasPrefix("W") ? Color(red: 0.2, green: 0.8, blue: 0.4) : Color.red.opacity(0.8))
                .clipShape(Capsule())
            
            Spacer()
            
            // 핵심 스탯 (PTS · REB · AST)
            Text("\(stats.pts) · \(stats.reb) · \(stats.ast)")
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.white.opacity(0.35))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .frame(maxWidth: .infinity)
    }
}


struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PlayerView(playerId: "1629029", teamId: "1610612742") // Luka Doncic, Dallas Mavericks
        }
    }
}

