//
//  TeamView.swift
//  nba
//
//  Created by 1100690 on 12/21/23.
//

import SwiftUI

struct TeamView: View {
    let summary: TeamSummaryViewModel
    @StateObject var viewModel = TeamViewModel()
    @State private var hasAppeared = false
    @State var scrollOffset: CGFloat = CGFloat.zero
    @State var hideNavigationBar: Bool = true
    
    var body: some View {
        ObservableScrollView(scrollOffset: $scrollOffset) {
            ZStack(alignment: .topLeading) {
                Color.clear
                Image(summary.teamCode)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(0.1)
                    .frame(width: 250, height: 250)
                    .scaleEffect(1.2)
                    .clipped()
                    .zIndex(0)
                
                VStack(alignment: .center, spacing: 0) {
                    Image(summary.teamCode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .clipped()
                    Text(summary.conferenceRankFullName)
                        .foregroundColor(.white.opacity(0.9))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .minimumScaleFactor(0.5)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 50)
                .zIndex(1)
            }
            .frame(height: 250)
            .frame(maxWidth: .infinity)
            .background(Color(summary.teamId.light))
        
            Text("")
                .frame(maxWidth: .infinity)
                .frame(height: 20)
                .background {
                    CustomCorner(corners: [.topLeft, ], radius: 20)
                        .fill(Color(summary.teamId.dark))
                        .ignoresSafeArea()
                }
                .padding(.top, -19)
            
            let statsViewModel = TeamStatsViewModel(team: viewModel.team)
            statsSummaryView(stats: statsViewModel)
            
            dividerWithBackground()
            
            rosterView(roster: viewModel.roster)
                .padding(.top, 20)
            
            if !viewModel.roster.isEmpty {
                BannerView(adUnitId: .teamView, paddingTop: 10, height: 100)
                    .padding(.bottom, 30)
            }
        }
        .background(Color(summary.teamId.dark))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear() {
            guard !hasAppeared else { return }
            viewModel.fetchTeam(documentId: summary.teamId)
            viewModel.fetchRoster(teamId: summary.teamId)
            hasAppeared = true
        }
        .navigationBarTitle("", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 2) {
                    Image(summary.teamTriCode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                }
                .opacity(hideNavigationBar ? 0.0 : 1.0)
            }
        }
        .onChange(of: scrollOffset, perform: { scrollOfset in
            let offset = scrollOfset + (self.hideNavigationBar ? 50 : 0) // note 1
            if offset > 60 { // note 2
                withAnimation(.easeIn(duration: 1), {
                    self.hideNavigationBar = false
                })
            }
            if offset < 50 {
                withAnimation(.easeIn(duration: 1), {
                    self.hideNavigationBar = true
                })
            }
        })
        .ignoresSafeArea()
    }
}

extension TeamView {
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

extension TeamView {
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
