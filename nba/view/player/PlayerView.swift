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
                    
                    // 2. Season Summary (Snapshot)
                    PlayerSeasonSummaryView(player: player)
                        .padding(.top, 10)
                    
                    // 3. Bio Grid
                    PlayerBioGridView(player: player)
                        .padding(.top, 10)
                    
                    // 4. Yearly Stats Sections
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
                    
                    // 5. Ad Banner
                    BannerView(adUnitId: .playerView, paddingTop: 10)
                        .padding(.bottom, 30)
                }
            }
            .background(Color.clear)
        }
        .onAppear() {
            guard !hasAppeared else { return }
            viewModel.fetchPlayer(documentId: self.playerId)
            viewModel.fetchRoster(teamId: self.teamId)
            hasAppeared = true
        }
        .navigationBarTitle("", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 4) {
                    Image(self.teamId.teamIdToTriCode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                    
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
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PlayerView(playerId: "1629029", teamId: "1610612742") // Luka Doncic, Dallas Mavericks
        }
    }
}

