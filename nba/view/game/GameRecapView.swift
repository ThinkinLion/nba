//
//  GameRecapView.swift
//  nba
//
//  Created by 1100690 on 12/30/23.
//

import SwiftUI

struct GameRecapView: View {
    let viewModel: HomeAwayViewModel
    let gameRecap: [GamesModel]
    @State private var hasAppeared = false
    @State var scrollOffset: CGFloat = CGFloat.zero
    @State var hideNavigationBar: Bool = true
    
    var body: some View {
        ZStack(alignment: .top) {
            // Dynamic Background Gradient
            GeometryReader { geo in
                ZStack {
                    // Angular Gradient Background
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color(viewModel.awayTeamId.dark),
                            Color.black,
                            Color(viewModel.homeTeamId.dark),
                            Color.black,
                            Color(viewModel.awayTeamId.dark)
                        ]),
                        center: .center,
                        angle: .degrees(45)
                    )
                    .blur(radius: 60)
                    .opacity(0.4)
                    .scaleEffect(1.5)
                }
            }
            .ignoresSafeArea()
            
            ObservableScrollView(scrollOffset: $scrollOffset) {
                VStack(spacing: 0) {
                    // 1. Header (VS Screen)
                    GameHeaderView(viewModel: viewModel)
                    
                    VStack(spacing: 40) {
                        // 2. Head to Head (Leader Comparison)
                        HeadToHeadView(viewModel: viewModel)
                            //.padding(.horizontal, 15) // Removed to span full width
                        
                        // 3. Ad Banner
                        BannerView(adUnitId: .gameView, paddingTop: 0)
                        
                        // 4. Away Box Score
                        if viewModel.hasAwayBoxscore {
                            BoxScoreTableView(boxScores: viewModel.awayBoxscore, teamName: viewModel.awayTeamNickName)
                        }
                        
                        // 5. Home Box Score
                        if viewModel.hasHomeBoxscore {
                            BoxScoreTableView(boxScores: viewModel.homeBoxscore, teamName: viewModel.homeTeamNickName)
                        }
                        
                        // 6. Other Games
//                        OtherGamesCarouselView(gameRecap: gameRecap)
//                            .padding(.bottom, 60)
                    }
                    .padding(.top, 0) // Removed spacing (was 20)
                }
            }
            
            // Floating Back Button (Custom Nav) placeholder
            VStack {
                Spacer()
            }
        }
        .onAppear() {
            guard !hasAppeared else { return }
            hasAppeared = true
        }
        .navigationBarTitle("", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    Image(viewModel.awayTriCode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                    
                    Text(viewModel.score)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    
                    Image(viewModel.homeTriCode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
                .opacity(hideNavigationBar ? 0.0 : 1.0)
                .animation(.easeInOut, value: hideNavigationBar)
            }
        }
        .onChange(of: scrollOffset) { scrollOfset in
            let offset = scrollOfset + (self.hideNavigationBar ? 50 : 0)
            if offset > 280 {
                withAnimation(.easeIn(duration: 0.3)) {
                    self.hideNavigationBar = false
                }
            }
            if offset < 270 {
                withAnimation(.easeOut(duration: 0.3)) {
                    self.hideNavigationBar = true
                }
            }
        }
        .analyticsScreen(name: "NBA-GameRecapView")
    }
}

