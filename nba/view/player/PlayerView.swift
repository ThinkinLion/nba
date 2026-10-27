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
                    
                    // 2. LAST GAME (Most Recent Game Boxscore Snapshot)
                    if let lastGame = viewModel.lastGameStats {
                        NavigationLink(destination: GameRecapView(viewModel: HomeAwayViewModel(homeAway: lastGame.game), gameRecap: [])) {
                            lastGameCard(stats: lastGame)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                    }
                    
                    // 3. Season Summary (Snapshot)
                    PlayerSeasonSummaryView(player: player)
                        .padding(.top, 12)
                    
                    // 4. Bio Grid
                    PlayerBioGridView(player: player)
                        .padding(.top, 12)

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
    
    // MARK: - Last Game Snapshot Card
    @ViewBuilder
    private func lastGameCard(stats: PlayerLastGameStats) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.1), Color.white.opacity(0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.5), Color.white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 3)
            
            VStack(spacing: 8) {
                // Top Header Row: LAST GAME Badge & Opponent / Result
                HStack(spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.orange)
                        Text("LAST GAME")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(0.25))
                    .clipShape(Capsule())
                    
                    Text("\(stats.isHome ? "vs" : "@") \(stats.opponentTriCode)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                    
                    Text(stats.resultText)
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundColor(stats.resultText.hasPrefix("W") ? Color(red: 0.2, green: 0.85, blue: 0.45) : Color.red.opacity(0.85))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Capsule())
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                }
                
                // Stat Numbers Row: 32 PTS · 8 REB · 6 AST
                HStack(spacing: 14) {
                    statSnapshotItem(label: "PTS", value: stats.pts)
                    statSnapshotItem(label: "REB", value: stats.reb)
                    statSnapshotItem(label: "AST", value: stats.ast)
                    if let min = stats.min, !min.isEmpty && min != "0" {
                        statSnapshotItem(label: "MIN", value: min)
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
    }
    
    @ViewBuilder
    private func statSnapshotItem(label: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 3) {
            Text(value)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PlayerView(playerId: "1629029", teamId: "1610612742") // Luka Doncic, Dallas Mavericks
        }
    }
}

