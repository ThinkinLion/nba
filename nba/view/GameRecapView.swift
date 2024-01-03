//
//  GameRecapView.swift
//  nba
//
//  Created by 1100690 on 12/30/23.
//

import SwiftUI

struct GameRecapView: View {
    let viewModel: HomeAwayViewModel
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
                        .opacity(0.8)
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
                    
                    
//                    Text(viewModel.awayRecord)
//                        .foregroundColor(.white.opacity(0.8))
//                        .font(.system(size: 12, weight: .semibold, design: .rounded))
//                        .padding(.trailing, 50)
    //                                .padding(.bottom, 10)
                }
                .frame(width: Constants.screenWidthHalf, height: 250)
                .background(Color(viewModel.awayTeamCode))
                .padding(.trailing, Constants.screenWidthHalf)
                .zIndex(0)
                
//                Text(viewModel.awayScore)
//                    .foregroundColor(.white.opacity(0.9))
//                    .font(.system(size: 20, weight: .semibold, design: .rounded))
//                    .padding(.trailing, 70)
//                    .zIndex(3)
//                
//                Text("vs")
//                    .foregroundColor(.white.opacity(0.7))
//                    .font(.system(size: 18, weight: .light, design: .rounded))
//                    .zIndex(2)
//                
//                Text(viewModel.homeScore)
//                    .foregroundColor(.white.opacity(0.9))
//                    .font(.system(size: 20, weight: .semibold, design: .rounded))
//                    .padding(.leading, 70)
//                    .zIndex(3)
                
                
                ZStack {
                    Image(viewModel.homeTeamCode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .opacity(0.8)
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
                    
//                    Text(viewModel.homeRecord)
//                        .foregroundColor(.white.opacity(0.8))
//                        .font(.system(size: 12, weight: .semibold, design: .rounded))
//                        .padding(.leading, 50)
    //                                .padding(.bottom, 10)
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
            
            boxScoreView(boxScores: viewModel.awayBoxscore)
                .padding(.top, 20)
            
            boxScoreView(boxScores: viewModel.homeBoxscore)
                .padding(.top, 20)
            
//            let statsViewModel = TeamStatsViewModel(team: viewModel.team)
//            statsSummaryView(stats: statsViewModel)
//            
//            dividerWithBackground()
//            
//            rosterView(roster: viewModel.roster)
//                .padding(.top, 20)
//            
//            if !viewModel.roster.isEmpty {
//                BannerView(adUnitId: .teamView, paddingTop: 10, height: 100)
//                    .padding(.bottom, 30)
//            }
        }
        .background(Color(viewModel.awayTeamId.dark))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear() {
            guard !hasAppeared else { return }
//            viewModel.fetchTeam(documentId: summary.teamId)
//            viewModel.fetchRoster(teamId: summary.teamId)
            hasAppeared = true
        }
        .ignoresSafeArea()
    }
}

extension GameRecapView {
    @ViewBuilder
    func boxScoreItemView(viewModel: BoxScoreViewModel) -> some View {
        HStack(spacing: 0) {
//            AsyncImage(url: URL(string: viewModel.smallImageUrl)) { image in
//                image.resizable()
//            } placeholder: {}
//                .aspectRatio(contentMode: .fill)
//                .background(Color(viewModel.teamNickName))
//                .frame(width: 48, height: 48)
//                .cornerRadius(24)
//                .padding(5)
            
            Text(viewModel.fullName)
                .foregroundColor(.white.opacity(0.9))
                .font(.system(size: 14, weight: .semibold))
                .minimumScaleFactor(0.8)
            
            Spacer()
        }
        .padding(.bottom, 10)
        .padding(.horizontal, 5)
        .frame(height: 50)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func boxScoreView(boxScores: [BoxScore]) -> some View {
        HStack {
            Text("DETROIT PISTONS")
                .textStyle(color: .white.opacity(0.9), font: .title2, weight: .bold)
                .padding(.leading, 15)
            Spacer()
        }
        VStack(alignment: .leading) {
            ForEach(boxScores, id: \.self) { boxScore in
                let viewModel = BoxScoreViewModel(boxScore: boxScore)
                NavigationLink(destination: PlayerView(playerId: viewModel.playerId, teamId: viewModel.teamId)) {
                    boxScoreItemView(viewModel: viewModel)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
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
    @ViewBuilder
    func rosterView(roster: [PlayerModel]) -> some View {
        VStack(alignment: .leading) {
            ForEach(roster, id: \.self) { player in
                let viewModel = PlayerSummaryViewModel(player: player)
                NavigationLink(destination: PlayerView(playerId: viewModel.playerId, teamId: viewModel.teamId)) {
                    rosterItemView(viewModel: viewModel)
                    
//                    dividerWithBackground()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
    }
    
    @ViewBuilder
    func rosterItemView(viewModel: PlayerSummaryViewModel) -> some View {
        HStack(spacing: 0) {
            AsyncImage(url: URL(string: viewModel.smallImageUrl)) { image in
                image.resizable()
            } placeholder: {}
                .aspectRatio(contentMode: .fill)
                .background(Color(viewModel.teamNickName))
                .frame(width: 48, height: 48)
                .cornerRadius(24)
                .padding(5)
            
            VStack(alignment: .leading) {
                Text(viewModel.jerseyAndShortenPosition)
                    .foregroundColor(.white.opacity(0.8))
                    .font(.system(size: 14))
                
                Text(viewModel.fullName)
                    .foregroundColor(.white.opacity(0.9))
                    .font(.system(size: 14, weight: .semibold))
                    .minimumScaleFactor(0.8)
            }
            Spacer()
            
//            Text(viewModel.points)
//                .foregroundColor(.white)
//                .font(.system(size: 18, weight: .semibold))
//                .padding(.trailing, 10)
        }
        .padding(.bottom, 10)
        .padding(.horizontal, 5)
        .frame(height: 50)
        .frame(maxWidth: .infinity)
    }
}

extension GameRecapView {
    func dividerWithBackground() -> some View {
        Divider()
            .background(Color("#272628"))
            .opacity(0.9)
            .frame(height: 1.5)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 15)
    }
    
    @ViewBuilder
    func statItemView(title: String, value: String, rank: String) -> some View {
        VStack(alignment: .center) {
            Text(title)
                .padding(.horizontal, 5)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .background(Color("#5C5B60"))
            
            Text(value)
                .padding(2)
                .foregroundColor(.white.opacity(0.9))
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(rank)
                .padding(2)
                .foregroundColor(.white.opacity(0.8))
                .font(.caption)
                .fontWeight(.semibold)
        }
    }

    @ViewBuilder
    func statsSummaryView(stats: TeamStatsViewModel) -> some View {
        HStack {
            statItemView(title: stats.ppgTitle, value: stats.ppg, rank: stats.ppgRank)
                .padding(.leading, 20)
            Spacer()
            
            statItemView(title: stats.oppgTitle, value: stats.oppg, rank: stats.oppgRank)
            Spacer()
            
            statItemView(title: stats.rpgTitle, value: stats.rpg, rank: stats.rpgRank)
            Spacer()
            
            statItemView(title: stats.apgTitle, value: stats.apg, rank: stats.apgRank)
                .padding(.trailing, 20)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    StandingsView()
}
