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
                    .font(.callout)
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
            
            BannerView(paddingTop: 15)
            
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
            
//            seasonLeadersView(leaders: viewModel.threePointersMade)
//            .padding(.top, 15)
//            
//            seasonLeadersView(leaders: viewModel.threePointPercentage)
//            .padding(.top, 15)
//            
//            seasonLeadersView(leaders: viewModel.fantasyPointsPerGame)
//            .padding(.top, 15)
            
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

extension StandingsView {
    @ViewBuilder
    func seasonLeadersVStackView(leaders: SeasonLeaders) -> some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("SEASON LEADERS")
                    .font(.caption)
                    .foregroundColor(Color("#5C5B60"))
                    .padding(.leading, 10)
                Text(leaders.title)
                    .font(.system(size: 20, weight: .bold))
                    .padding(.leading, 10)
            }
            
            ForEach(leaders.items, id: \.self) { item in
                let viewModel = SeasonLeaderViewModel(seasonLeader: item)
                NavigationLink(destination: PlayerView(viewModel: viewModel)) {
                    playerStackItemView(viewModel: viewModel)
                }
            }
            
        }
//        .frame(height: 360)
        .frame(maxWidth: .infinity)
        .padding(7)
        .background(Color("#1C1B1D"))
        .cornerRadius(10)
        .padding(.horizontal, 10)
    }
    
    @ViewBuilder
    func playerStackItemView(viewModel: SeasonLeaderViewModel) -> some View {
        HStack(spacing: 0) {
            AsyncImage(url: URL(string: viewModel.imageUrl)) { image in
                image.resizable()
            } placeholder: {}
                .aspectRatio(contentMode: .fill)
                .background(Color(viewModel.teamTriCode.triCodeToNickName))
                .frame(width: 50, height: 50)
                .cornerRadius(25)
                .padding(5)
            
            VStack(alignment: .leading) {
                Text(viewModel.teamTriCode)
                    .font(.callout)
                    .foregroundColor(Color("#5C5B60"))
                
                Text(viewModel.name)
                    .foregroundColor(.white)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .minimumScaleFactor(0.8)
            }
            Spacer()
            Text(viewModel.points)
                .foregroundColor(.white)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.trailing, 10)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func seasonLeadersView(leaders: SeasonLeaders) -> some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("SEASON LEADERS")
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
                        NavigationLink(destination: PlayerView(viewModel: viewModel)) {
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
            //                .background(Color(viewModel.teamTriCode.triCodeToNickName))
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
            
            Text(viewModel.name)
                .frame(width: 120)
                .padding(.trailing, 160)
                .foregroundColor(.white)
                .font(.callout)
                .fontWeight(.bold)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .zIndex(2)
        }
        .frame(width: 300)
    }
}

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

extension StandingsView {
    @ViewBuilder
    func conferenceView(playoffs: [Team],
                        playInTournament: [Team],
                        nonPlayoff: [Team],
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
    func standingRowView(items: [Team]) -> some View {

        //.font(.system(size: 25, weight: .bold, design: .serif))
        //.font(.system(size: 25, weight: .bold, design: .rounded))
        //.font(.system(size: 25, weight: .bold, design: .monospaced))
        VStack {
            ForEach(Array(items.enumerated()), id: \.element) { index, model in
                let viewModel = TeamViewModel(team: model)
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
                    
                    Text(" ")
                    
                    Text(viewModel.winLoss)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .frame(width: 50, height: 25)
                        .frame(alignment: .leading)
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.5)
                }
                .background(Color(viewModel.teamCode).opacity(0.9))
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
