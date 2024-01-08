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
    
    enum Constants {
        static let headerZStackHeight: CGFloat = 250
        static let headerZStackHeightHalf: CGFloat = CGFloat(headerZStackHeight / 2)
        static let screenWidthHalf = UIScreen.main.bounds.width / 2
        static let screenWidthQuarter = screenWidthHalf / 2
    }
    
    var body: some View {
        ScrollView(.vertical) {
            ZStack {
                ZStack {
                    Image(viewModel.awayTeamCode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .opacity(0.1)
                        .scaleEffect(1.5)
                        .clipped()
                        .padding(.trailing, Constants.screenWidthQuarter)
                        .padding(.bottom, Constants.headerZStackHeightHalf)
                        .zIndex(0)
                    
                    NavigationLink(destination: PlayerView(playerId: viewModel.awayLeaderId, teamId: viewModel.awayTeamId)) {
                        AsyncImage(url: URL(string: viewModel.awayLeaderId.imageUrl)) { image in
                            image.resizable()
                        } placeholder: {}
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 160, height: 160) //250 160
                            .padding(.top, 90)
                            .zIndex(1)
                    }
                }
                .frame(width: Constants.screenWidthHalf, height: 250)
                .background(Color(viewModel.awayTeamCode))
                .padding(.trailing, Constants.screenWidthHalf)
                .zIndex(0)
                
                ZStack {
                    Image(viewModel.homeTeamCode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .opacity(0.1)
                        .scaleEffect(1.5)
                        .clipped()
                        .padding(.leading, Constants.screenWidthQuarter)
                        .padding(.bottom, Constants.headerZStackHeightHalf)
                        .zIndex(0)
                    
                    NavigationLink(destination: PlayerView(playerId: viewModel.homeLeaderId, teamId: viewModel.homeTeamId)) {
                        AsyncImage(url: URL(string: viewModel.homeLeaderId.imageUrl)) { image in
                            image.resizable()
                        } placeholder: {}
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 160, height: 160)
                            .padding(.top, 90)
                            .zIndex(1)
                    }
                }
                .frame(width: Constants.screenWidthHalf, height: 250)
                .background(Color(viewModel.homeTeamCode))
                .padding(.leading, Constants.screenWidthHalf)
                .zIndex(0)
            }
            .frame(height:  Constants.headerZStackHeight)
            .frame(maxWidth: .infinity)
            .background(Color(viewModel.awayTeamId.light))
        
            Text("")
                .frame(maxWidth: .infinity)
                .frame(height: 20)
                .background {
                    CustomCorner(corners: [.topLeft, ], radius: 20)
                        .fill(Color(viewModel.awayTeamId.dark))
                        .ignoresSafeArea()
                }
                .padding(.top, -19)
            
            leaderSummaryView(viewModel: viewModel)
                .padding(.top, -15) //default spcing이 있어서
            
            boxScoreView(boxScores: viewModel.awayBoxscore, teamName: viewModel.awayTeamName)
                .padding(.top, 20)
            
            BannerView(adUnitId: .gameView)
            
            boxScoreView(boxScores: viewModel.homeBoxscore, teamName: viewModel.homeTeamName)
                .padding(.top, 20)
            
            //more
//            moreGameRecapView(gameRecap: gameRecap)
//                .padding(.top, 20)
            
        }
        .background(Color(viewModel.awayTeamId.dark))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear() {
            guard !hasAppeared else { return }
            hasAppeared = true
        }
        .navigationBarTitle("", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 2) {
                    Image(viewModel.awayTeamCode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .clipped()
                    Text(viewModel.score)
                    Image(viewModel.homeTeamCode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .clipped()
                }
            }
        }
        .ignoresSafeArea()
    }
}

extension GameRecapView {
    @ViewBuilder
    func moreGameRecapView(gameRecap: [GamesModel]) -> some View {
        VStack {
            ForEach(gameRecap, id: \.self) { game in
//                let viewModel = BoxScoreViewModel(boxScore: boxScore)
//                NavigationLink(destination: PlayerView(playerId: viewModel.playerId, teamId: viewModel.teamId)) {
//                    boxScoreHeaderItemView(viewModel: viewModel)
//                }
                Text(game.date ?? "")
                    .textStyle(color: .white.opacity(0.9), font: .system(size: 20), weight: .bold)
                dividerWithBackground()
            }
        }
    }
}

extension GameRecapView {
    @ViewBuilder
    func boxScoreHeaderTitleView() -> some View {
        HStack(spacing: 0) {
            Text("PLAYER")
                .textStyle(color: .white.opacity(0.6), font: .system(size: 14))
        }
        .frame(height: 20)
    }
    
    @ViewBuilder
    func boxScoreHeaderItemView(viewModel: BoxScoreViewModel) -> some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading) {
                HStack {
                    AsyncImage(url: URL(string: viewModel.smallImageUrl)) { image in
                        image.resizable()
                    } placeholder: {}
                        .aspectRatio(contentMode: .fill)
                        .background(Color(viewModel.teamNickName))
                        .frame(width: 28, height: 28)
                        .cornerRadius(14)
                    
                    Text(viewModel.position)
                        .textStyle(color: .white.opacity(0.9), font: .system(size: 14), weight: .semibold)
                }
                
                Text(viewModel.lastName)
                    .textStyle(color: .white.opacity(0.9), font: .system(size: 13))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(height: 40)
    }
    
    @ViewBuilder
    func boxScoreTitleView() -> some View {
        HStack {
            Text("MIN")
                .textStyle(color: .white.opacity(0.6), font: .system(size: 14))
                .frame(width: 55)
            
            Text("PTS")
                .textStyle(color: .white.opacity(0.6), font: .system(size: 14))
                .frame(width: 30)
            
            //fg
            Text("FG")
                .textStyle(color: .white.opacity(0.6), font: .system(size: 14))
                .frame(width: 50)
            
            Text("FG%")
                .textStyle(color: .white.opacity(0.6), font: .system(size: 14))
                .frame(width: 40)
            
            //tp
            Text("3P")
                .textStyle(color: .white.opacity(0.6), font: .system(size: 14))
                .frame(width: 40)
            
            Text("3P%")
                .textStyle(color: .white.opacity(0.6), font: .system(size: 14))
                .frame(width: 40)
            
            //ft
            Text("FT")
                .textStyle(color: .white.opacity(0.6), font: .system(size: 14))
                .frame(width: 50)
            
            Text("FT%")
                .textStyle(color: .white.opacity(0.6), font: .system(size: 14))
                .frame(width: 40)
            
            //reb
            Text("OREB")
                .textStyle(color: .white.opacity(0.6), font: .system(size: 14))
                .frame(width: 30)
                .minimumScaleFactor(0.5)
            
            Text("DREB")
                .textStyle(color: .white.opacity(0.6), font: .system(size: 14))
                .frame(width: 30)
                .minimumScaleFactor(0.5)
            
            Text("REB")
                .textStyle(color: .white.opacity(0.6), font: .system(size: 14))
                .frame(width: 30)
            
            //ast
            Text("AST")
                .textStyle(color: .white.opacity(0.6), font: .system(size: 14))
                .frame(width: 30)
            
            Text("STL")
                .textStyle(color: .white.opacity(0.6), font: .system(size: 14))
                .frame(width: 30)
            
            Text("BLK")
                .textStyle(color: .white.opacity(0.6), font: .system(size: 14))
                .frame(width: 30)
            
            //to
            Text("TO")
                .textStyle(color: .white.opacity(0.6), font: .system(size: 14))
                .frame(width: 20)
            
            Text("PF")
                .textStyle(color: .white.opacity(0.6), font: .system(size: 14))
                .frame(width: 20)
            
            Text("+/-")
                .textStyle(color: .white.opacity(0.6), font: .system(size: 14))
                .frame(width: 30)
                .padding(.trailing, 10)
        }
        .frame(height: 20)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func boxScoreItemView(viewModel: BoxScoreViewModel) -> some View {
        HStack {
            Text(viewModel.min)
                .textStyle(color: .white.opacity(0.8), font: .system(size: 14), weight: .bold)
                .frame(width: 55)
                .padding(.leading, 5)
            
            Text(viewModel.pts)
                .textStyle(color: .white.opacity(0.8), font: .system(size: 14), weight: .bold)
                .frame(width: 30)
            
            //fg
            Text(viewModel.fg)
                .textStyle(color: .white.opacity(0.8), font: .system(size: 14), weight: .bold)
                .frame(width: 50)
                .minimumScaleFactor(0.5)
            
            Text(viewModel.fgp)
                .textStyle(color: .white.opacity(0.8), font: .system(size: 14), weight: .bold)
                .frame(width: 40)
            
            //tp
            Text(viewModel.tp)
                .textStyle(color: .white.opacity(0.8), font: .system(size: 14), weight: .bold)
                .frame(width: 40)
            
            Text(viewModel.tpp)
                .textStyle(color: .white.opacity(0.8), font: .system(size: 14), weight: .bold)
                .frame(width: 40)
            
            //ft
            Text(viewModel.ft)
                .textStyle(color: .white.opacity(0.8), font: .system(size: 14), weight: .bold)
                .frame(width: 50)
            
            Text(viewModel.ftp)
                .textStyle(color: .white.opacity(0.8), font: .system(size: 14), weight: .bold)
                .frame(width: 40)
            
            //reb
            Text(viewModel.oreb)
                .textStyle(color: .white.opacity(0.8), font: .system(size: 14), weight: .bold)
                .frame(width: 30)
            
            Text(viewModel.dreb)
                .textStyle(color: .white.opacity(0.8), font: .system(size: 14), weight: .bold)
                .frame(width: 30)
            
            Text(viewModel.reb)
                .textStyle(color: .white.opacity(0.8), font: .system(size: 14), weight: .bold)
                .frame(width: 30)
            
            //ast
            Text(viewModel.ast)
                .textStyle(color: .white.opacity(0.8), font: .system(size: 14), weight: .bold)
                .frame(width: 30)
            
            Text(viewModel.stl)
                .textStyle(color: .white.opacity(0.8), font: .system(size: 14), weight: .bold)
                .frame(width: 30)
            
            Text(viewModel.blk)
                .textStyle(color: .white.opacity(0.8), font: .system(size: 14), weight: .bold)
                .frame(width: 30)
            
            //to
            Text(viewModel.to)
                .textStyle(color: .white.opacity(0.8), font: .system(size: 14), weight: .bold)
                .frame(width: 20)
            
            Text(viewModel.pf)
                .textStyle(color: .white.opacity(0.8), font: .system(size: 14), weight: .bold)
                .frame(width: 20)
            
            Text(viewModel.pm)
                .textStyle(color: .white.opacity(0.8), font: .system(size: 14), weight: .bold)
                .frame(width: 30)
                .padding(.trailing, 10)
        }
        .frame(height: 40)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func boxScoreView(boxScores: [BoxScore], teamName: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                //TODO: navi는 teamView refactor 이후로..
                Image(teamName.nickNameToTriCode)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .clipped()
                Text(teamName)
                    .textStyle(color: .white.opacity(0.9), font: .system(size: 20), weight: .bold)
                    .padding(.leading, 2)
                Spacer()
            }
            .padding(.leading, 15)
            
            HStack(spacing: 0) {
                VStack(alignment: .leading) {
                    boxScoreHeaderTitleView()
                    ForEach(boxScores, id: \.self) { boxScore in
                        let viewModel = BoxScoreViewModel(boxScore: boxScore)
                        NavigationLink(destination: PlayerView(playerId: viewModel.playerId, teamId: viewModel.teamId)) {
                            boxScoreHeaderItemView(viewModel: viewModel)
                        }
                        dividerWithBackground()
                    }
                }
                .frame(width: 100)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        VStack(alignment: .leading) {
                            boxScoreTitleView()
                            ForEach(boxScores, id: \.self) { boxScore in
                                let viewModel = BoxScoreViewModel(boxScore: boxScore)
                                boxScoreItemView(viewModel: viewModel)
                                dividerWithBackground()
                            }
                        }
                    }
                }
            }
            .padding([.leading, .top], 15)
        }
    }
}

extension GameRecapView {
    @ViewBuilder
    func leaderSummaryView(viewModel: HomeAwayViewModel) -> some View {
        HStack {
            //away
            HStack {
                VStack(alignment: .center, spacing: 0) {
                    Text(viewModel.awayLeaderPts)
                        .textStyle(color: .white, font: .title, weight: .bold)
                        .padding(2)
                    
                    Text(viewModel.ptsTitie)
                        .textStyle(color: .white.opacity(0.7), font: .system(size: 14))
                }
                Divider()
                    .background(.white.opacity(0.5))
                    .padding(.vertical, 5)
                
                VStack(alignment: .center, spacing: 0) {
                    Text(viewModel.awayLeaderReb)
                        .textStyle(color: .white, font: .title, weight: .bold)
                        .padding(2)
                    
                    Text(viewModel.rebTitie)
                        .textStyle(color: .white.opacity(0.7), font: .system(size: 14))
                }
                Divider()
                    .background(.white.opacity(0.5))
                    .padding(.vertical, 5)
                
                VStack(alignment: .center, spacing: 0) {
                    Text(viewModel.awayLeaderAst)
                        .textStyle(color: .white, font: .title, weight: .bold)
                        .padding(2)
                    
                    Text(viewModel.astTitie)
                        .textStyle(color: .white.opacity(0.7), font: .system(size: 14))
                }
            }
            .frame(width: Constants.screenWidthHalf)
            
            //home
            HStack {
                VStack(alignment: .center, spacing: 0) {
                    Text(viewModel.homeLeaderPts)
                        .textStyle(color: .white, font: .title, weight: .bold)
                        .padding(2)
                    
                    Text(viewModel.ptsTitie)
                        .textStyle(color: .white.opacity(0.7), font: .system(size: 14))
                }
                Divider()
                    .background(.white.opacity(0.5))
                    .padding(.vertical, 5)
                
                VStack(alignment: .center, spacing: 0) {
                    Text(viewModel.homeLeaderReb)
                        .textStyle(color: .white, font: .title, weight: .bold)
                        .padding(2)
                    
                    Text(viewModel.rebTitie)
                        .textStyle(color: .white.opacity(0.7), font: .system(size: 14))
                }
                Divider()
                    .background(.white.opacity(0.5))
                    .padding(.vertical, 5)
                
                VStack(alignment: .center, spacing: 0) {
                    Text(viewModel.homeLeaderAst)
                        .textStyle(color: .white, font: .title, weight: .bold)
                        .padding(2)
                    
                    Text(viewModel.astTitie)
                        .textStyle(color: .white.opacity(0.7), font: .system(size: 14))
                }
            }
            .frame(width: Constants.screenWidthHalf)
        }
    }
}

extension GameRecapView {
    func dividerWithBackground() -> some View {
        Divider()
            .background(Color("#272628"))
            .opacity(0.9)
            .frame(height: 1.5)
//            .frame(maxWidth: .infinity)
    }
}

#Preview {
    StandingsView()
}
