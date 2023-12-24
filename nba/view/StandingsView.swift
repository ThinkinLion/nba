//
//  StandingsView.swift
//  nba
//
//  Created by 1100690 on 2023/11/13.
//

import SwiftUI

struct StandingsView: View {
    @StateObject var viewModel = StandingsViewModel()
    @State private var bannerVisible = false
    @State private var hasAppeared = false
    
    @State private var isShowingPopover = false
    @State private var selectedPlayer: SeasonLeaderViewModel?
    
    var body: some View {
        ScrollView(.vertical) {
            HStack {
                Image("person")
                    .resizable()
                    .background(.white)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 35, height: 35)
                    .clipShape(Circle())
                Text("The NBA's East & West standings following \(viewModel.todayOfWeek())'s games!")
                    .font(.system(size: 14))
                Spacer()
            }
//            .frame(maxWidth: .infinity)
            .padding(.top, 15)
            .padding(.horizontal, 15)
            
            if viewModel.hasGames {
                gamesView(games: viewModel.games)
                .padding(.horizontal, 15)
            }
            
            conferenceView(playoffs: viewModel.east.0,
                           playInTournament: viewModel.east.1,
                           nonPlayoff: viewModel.east.2,
                           title: "EASTERN CONFERENCE",
                           backgroundColor: Color("#101D46"))
            
            seasonLeadersView(leaders: viewModel.pointsPerGame)
            .padding(.top, 15)
            
            conferenceView(playoffs: viewModel.west.0,
                           playInTournament: viewModel.west.1,
                           nonPlayoff: viewModel.west.2,
                           title: "WESTERN CONFERENCE",
                           backgroundColor: Color("#821E26"))
            .padding(.top, 15)
            
            BannerView(adUnitId: .standingsView, paddingTop: 15, paddingHorizontal: 10)
            
            seasonLeadersView(leaders: viewModel.assistsPerGame)
            .padding(.top, 15)
            
            seasonLeadersView(leaders: viewModel.reboundsPerGame)
            .padding(.top, 15)
            
            seasonLeadersVStackView(leaders: viewModel.blocksPerGame)
            .padding(.top, 15)
            
            seasonLeadersVStackView(leaders: viewModel.stealsPerGame)
            .padding(.top, 15)
            
            seasonLeadersVStackView(leaders: viewModel.fieldGoalPercentage)
            .padding(.top, 15)
            
            //advanced
            horizontalScrollView(leaders: viewModel.advanced)
            .padding(.top, 25)
            
            //miscellaneous
            horizontalScrollView(leaders: viewModel.miscellaneous)
            .padding(.top, 25)
            
            //player tracking passing
            horizontalScrollView(leaders: viewModel.playerTrackingPassing)
            .padding(.top, 25)
            
            BannerView(adUnitId: .standingsView2, paddingTop: 15, paddingHorizontal: 10, height: 100)
            
            //seasonLeaders
            seasonLeadersVStackView(leaders: viewModel.threePointersMade)
            .padding(.top, 15)
            
            seasonLeadersVStackView(leaders: viewModel.threePointPercentage)
            .padding(.top, 15)
            
            seasonLeadersVStackView(leaders: viewModel.fantasyPointsPerGame)
            .padding(.top, 15)
            
            //scoring
            horizontalScrollView(leaders: viewModel.scoring)
            .padding(.top, 25)
            
            //center
            horizontalScrollView(leaders: viewModel.centers)
            .padding(.top, 25)
            
            //forwards
            horizontalScrollView(leaders: viewModel.forwards)
            .padding(.top, 25)
            
            //guards
            horizontalScrollView(leaders: viewModel.guards)
            .padding(.top, 25)
            
            //rookies
            seasonLeadersView(leaders: viewModel.rookiesMinutesPerGame)
            .padding(.top, 15)

            seasonLeadersView(leaders: viewModel.rookiesPointsPerGame)
            .padding(.top, 15)

            seasonLeadersView(leaders: viewModel.rookiesDoubleDoubles)
            .padding(.top, 15)
            
            //seasonLeaders etc
            seasonLeadersVStackView(leaders: viewModel.seasonLeadersMostTotalPoints)
            .padding(.top, 15)
            
            seasonLeadersVStackView(leaders: viewModel.seasonLeadersMostPointsinaGame)
            .padding(.top, 15)
            
            seasonLeadersVStackView(leaders: viewModel.seasonLeadersMostReboundsinaGame)
            .padding(.top, 15)
            
            seasonLeadersVStackView(leaders: viewModel.seasonLeadersMostAssistsinaGame)
            .padding(.top, 15)
            
            BannerView(adUnitId: .standingsView2, paddingTop: 15, paddingHorizontal: 10, height: 100)
            
            //seasonLeaderEtc
            horizontalScrollView(leaders: viewModel.seasonLeaderEtc)
            .padding(.top, 25)
            
            seasonLeadersVStackView(leaders: viewModel.seasonLeadersMostBlocksinaGame)
            .padding(.top, 15)
            
            seasonLeadersVStackView(leaders: viewModel.seasonLeadersMostStealsinaGame)
            .padding(.top, 15)
            
            
            //스텟을 카테고리 별로
            //advanced, miscellaneous, player tracking passing, scoring, centers, forwards, guards, rookies, season leaders etc
//            Button("Crash") {
//              fatalError("Crash was triggered")
//            }
//            Button(action: viewModel.addSampleItem ) {
//                Label("Then add it", systemImage: "plus")
//            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .preferredColorScheme(.dark)
        .onAppear() {
            guard !hasAppeared else { return }
            viewModel.fetchStandings()
            bannerVisible = true
            hasAppeared = true
        }
        .onDisappear() {
        }
    }
}

//MARK: leadersScrollView
extension StandingsView {
    @ViewBuilder
    func horizontalItemView(viewModel: SeasonLeaderViewModel) -> some View {
        HStack(spacing: 0) {
            AsyncImage(url: URL(string: viewModel.smallImageUrl)) { image in
                image.resizable()
            } placeholder: {}
                .aspectRatio(contentMode: .fill)
                .background(Color(viewModel.teamTriCode.triCodeToNickName))
                .frame(width: 36, height: 36)
                .cornerRadius(18)
                .padding(5)
            
            VStack(alignment: .leading) {
                Text(viewModel.teamTriCode)
                    .font(.system(size: 14))
                    .foregroundColor(Color("#5C5B60"))
                
                Text(viewModel.name)
                    .foregroundColor(.white.opacity(0.9))
                    .font(.system(size: 14, weight: .semibold))
                    .minimumScaleFactor(0.8)
            }
            Spacer()
            Text(viewModel.points)
                .foregroundColor(.white.opacity(0.9))
                .font(.system(size: 16, weight: .semibold))
                .padding(.trailing, 10)
        }
        .padding([.bottom, .horizontal], 5)
        .frame(height: 42)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func horizontalScrollView(leaders: [SeasonLeaders]) -> some View {
        let item = leaders.first
        VStack(alignment: .leading, spacing: 0) {
            Text(item?.category.uppercased() ?? "")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding([.leading, .bottom], 10)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(leaders, id: \.self) { item in
                        VStack(alignment: .leading) {
                            Text(item.title)
                                .foregroundColor(.white.opacity(0.8))
                                .font(.system(size: 14, weight: .bold))
                            
                            ForEach(item.items, id: \.self) { item in
                                let viewModel = SeasonLeaderViewModel(seasonLeader: item)
                                NavigationLink(destination: PlayerView(playerId: viewModel.playerId, teamId: viewModel.teamTriCode.triCodeToTeamId)) {
                                    horizontalItemView(viewModel: viewModel)
                                }
                            }
                        }
                    }
                }
                .padding(.leading, 10)
            }
        }
    }
}

//MARK: seasonLeadersVStackView
extension StandingsView {
    @ViewBuilder
    func seasonLeadersVStackView(leaders: SeasonLeaders) -> some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text(leaders.category.uppercased())
                    .font(.caption)
                    .foregroundColor(Color("#5C5B60"))
                    .padding(.leading, 10)
                Text(leaders.title)
                    .font(.system(size: 20, weight: .bold))
                    .padding(.leading, 10)
            }
            .padding(.top, 7)
            
            ForEach(leaders.items, id: \.self) { item in
                let viewModel = SeasonLeaderViewModel(seasonLeader: item)
                NavigationLink(destination: PlayerView(playerId: viewModel.playerId, teamId: viewModel.teamId)) {
                    playerStackItemView(viewModel: viewModel)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color("#1C1B1D"))
        .cornerRadius(10)
        .padding(.horizontal, 10)
    }
    
    @ViewBuilder
    func playerStackItemView(viewModel: SeasonLeaderViewModel) -> some View {
        HStack(spacing: 0) {
            AsyncImage(url: URL(string: viewModel.smallImageUrl)) { image in
                image.resizable()
            } placeholder: {}
                .aspectRatio(contentMode: .fill)
                .background(Color(viewModel.teamTriCode.triCodeToNickName))
                .frame(width: 48, height: 48)
                .cornerRadius(24)
                .padding(5)
            
            VStack(alignment: .leading) {
                Text(viewModel.teamTriCode)
                    .font(.system(size: 14))
                    .foregroundColor(Color("#5C5B60"))
                
                Text(viewModel.name)
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .semibold))
                    .minimumScaleFactor(0.8)
            }
            Spacer()
            Text(viewModel.points)
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .semibold))
                .padding(.trailing, 10)
        }
        .padding(.bottom, 5)
        .padding(.horizontal, 5)
        .frame(height: 50)
        .frame(maxWidth: .infinity)
    }
}

//MARK: seasonLeadersView
extension StandingsView {
    @ViewBuilder
    func seasonLeadersView(leaders: SeasonLeaders) -> some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text(leaders.category.uppercased())
                    .font(.caption)
                    .foregroundColor(Color("#5C5B60"))
                    .padding(.leading, 10)
                Text(leaders.title)
                    .font(.system(size: 20, weight: .bold))
                    .padding(.leading, 10)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(leaders.items, id: \.self) { item in
                        let viewModel = SeasonLeaderViewModel(seasonLeader: item)
                        NavigationLink(destination: PlayerView(playerId: viewModel.playerId, teamId: viewModel.teamTriCode.triCodeToTeamId)) {
                            playerCardView(viewModel: viewModel)
                        }
                    }
                }
                .frame(height: 150)
                .padding(.leading, 10)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(7)
    }
    
    @ViewBuilder
    func playerCardView(viewModel: SeasonLeaderViewModel) -> some View {
        ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center)) {
            LinearGradient(colors: [.black, .gray, .black], startPoint: .topLeading, endPoint: .bottomTrailing)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            
            AsyncImage(url: URL(string: viewModel.imageUrl)) { image in
                image.resizable()
            } placeholder: {}
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 150, alignment: .bottom)
                .padding(.trailing, 20)
                .zIndex(0)
            
            Text(viewModel.points)
                .frame(width: 120)
                .padding(.trailing, 160)
                .padding(.bottom, 90)
                .foregroundColor(.white)
                .font(.title)
                .fontWeight(.bold)
                .zIndex(1)
            
            Text(viewModel.upperCasedName)
                .frame(width: 120)
                .padding(.trailing, 160)
                .foregroundColor(.white)
                .font(.callout)
                .fontWeight(.bold)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
                .zIndex(2)
        }
        .frame(width: 300)
    }
}

//MARK: gamesView
extension StandingsView {
    @ViewBuilder
    func gamesView(games: [HomeAway]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(games, id: \.self) { item in
                    let viewModel = HomeAwayViewModel(homeAway: item)
                    HStack {
                        Image(viewModel.homeTeamCode.nickNameToTriCode)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .clipped()
                        Text(viewModel.homeScore)
                            .font(.caption)
                        Text(" - ")
                        Text(viewModel.awayScore)
                            .font(.caption)
                        Image(viewModel.awayTeamCode.nickNameToTriCode)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .clipped()
                    }
                    .padding(3)
                    .frame(width: 160, height: 50)
                    .background(Color("#202123"))
                    .cornerRadius(5)
                }
            }
            .frame(height: 50)
            .padding(.top, 10)
        }
    }
}

//MARK: conferenceView
extension StandingsView {
    @ViewBuilder
    func conferenceView(playoffs: [StandingsTeam],
                        playInTournament: [StandingsTeam],
                        nonPlayoff: [StandingsTeam],
                        title: String,
                        backgroundColor: Color) -> some View {
        VStack {
            Text(title)
                .padding(.top, 10)
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
            
            HStack(alignment: .top) {
                standingRowView(items: playoffs)
                
                VerticalLineView()
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 1, dash: [5]))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
                    .opacity(bannerVisible ? 1 : 0)
                
                standingRowView(items: playInTournament)
                
                VerticalLineView()
                    .stroke(Color.white)
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
                    .opacity(bannerVisible ? 1 : 0)
                
                standingRowView(items: nonPlayoff)
            }
        }
        .frame(height: 360)
        .frame(maxWidth: .infinity)
        .padding(7)
        .background(backgroundColor)
        .cornerRadius(10)
        .padding(.horizontal, 10)
    }
    
    @ViewBuilder
    func standingRowView(items: [StandingsTeam]) -> some View {

        //.font(.system(size: 25, weight: .bold, design: .serif))
        //.font(.system(size: 25, weight: .bold, design: .rounded))
        //.font(.system(size: 25, weight: .bold, design: .monospaced))
        VStack {
            ForEach(Array(items.enumerated()), id: \.element) { index, model in
                let viewModel = TeamSummaryViewModel(team: model)
                NavigationLink(destination: TeamView(summary: viewModel)) {
                    HStack(spacing: 0) {
                        Text(viewModel.conferenceRank)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .frame(width: 25, height: 40)
                            .foregroundColor(.white)
                            .background(.black)
                        
                        Image(viewModel.teamCode.nickNameToTriCode)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .scaleEffect(1.5)
                            .clipped()
                        
                        Text(viewModel.winLoss)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .frame(width: 50, height: 25)
                            .frame(alignment: .leading)
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.5)
                            .padding(.horizontal, 2)
                    }
                    .background(Color(viewModel.teamCode).opacity(0.9))
                }
            }
        }
    }
}

struct StandingsView_Previews: PreviewProvider {
    static var previews: some View {
        StandingsView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 14 pro"))
    }
}
