//
//  PlayerView.swift
//  nba
//
//  Created by 1100690 on 12/5/23.
//

import SwiftUI

struct PlayerView: View {
    @StateObject var viewModel = PlayerViewModel()
    let playerId: String
    let teamId: String
    
    var body: some View {
        let player = PlayerSummaryViewModel(player: viewModel.player)
        
        ScrollView(.vertical) {
            ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center)) {
                AsyncImage(url: URL(string: playerId.imageUrl)) { image in
                    image.resizable()
                } placeholder: {}
                .aspectRatio(contentMode: .fill)
                .frame(width: 180, height: 180, alignment: .bottom)
                .padding(.leading, 200)
                .padding(.bottom, -55)
                .zIndex(0)
                
                VStack(alignment: .leading) {
                    Image(teamId.teamIdToTriCode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .scaleEffect(1.2)
                        .clipped()
                    
                    Text(player.upperCasedName)
                    .foregroundColor(.white)
                    .font(.title)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                    
                    Text(player.jerseyAndPosition)
                        .foregroundColor(.white.opacity(0.8))
                        .font(.system(size: 14))
                }
                .frame(width: 160)
                .padding(.trailing, 200)
                .zIndex(1)
            }
            .frame(height: 250)
            .frame(maxWidth: .infinity)
            .padding(.top, 15)
            .padding(.horizontal, 15)
            .background(Color(teamId.light))
        
            Text("")
                .frame(maxWidth: .infinity)
                .frame(height: 20)
                .background {
                    CustomCorner(corners: [.topLeft, ], radius: 20)
                        .fill(Color(teamId.dark))
                        .ignoresSafeArea()
                }
                .padding(.top, -19)
            
            summaryView(player: player)
            
            BannerView(adUnitId: .playerView, paddingTop: 10)
            
            rosterView(roster: viewModel.roster)
        }
        .background(Color(teamId.dark))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear() {
            viewModel.fetchPlayer(documentId: playerId)
            viewModel.fetchRoster(teamId: teamId)
        }
        .ignoresSafeArea()
    }
}

extension PlayerView {
    @ViewBuilder
    func rosterItemView(viewModel: PlayerSummaryViewModel) -> some View {
        VStack {
            ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center)) {
                AsyncImage(url: URL(string: viewModel.imageUrl)) { image in
                    image.resizable()
                } placeholder: {}
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80, alignment: .bottom)
                    .padding(.trailing, 20)
                    .zIndex(1)
                
                Text(viewModel.jersey)
                    .frame(width: 30)
                    .padding(.trailing, 90)
                    .padding(.bottom, 30)
                    .foregroundColor(.white.opacity(0.8))
                    .font(.system(size: 14))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .zIndex(0)
            }
            
            Text(viewModel.lastName)
                .foregroundColor(.white.opacity(0.8))
                .font(.system(size: 14))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(width: 120)
    }
    
    @ViewBuilder
    func rosterView(roster: [PlayerModel]) -> some View {
        VStack(alignment: .leading) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(roster, id: \.self) { player in
                        let viewModel = PlayerSummaryViewModel(player: player)
                        NavigationLink(destination: PlayerView(playerId: viewModel.playerId, teamId: viewModel.teamId)) {
                            rosterItemView(viewModel: viewModel)
                        }
                    }
                }
                .frame(height: 120)
                .padding(.leading, 10)
            }
            
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
        .padding(7)
        .padding(.bottom, 30)
    }
    
    @ViewBuilder
    func summaryView(player: PlayerSummaryViewModel) -> some View {
        statsSummaryView(player: player)
        
        dividerWithBackground()
        
        bioSummaryView(title: player.heightTitle, value: player.height)
        
        dividerWithBackground()
        
        bioSummaryView(title: player.weightTitle, value: player.weight)
        
        dividerWithBackground()
        
        bioSummaryView(title: player.ageTitle, value: player.age)
        
        dividerWithBackground()
        
        bioSummaryView(title: player.birthdateTitle, value: player.birthdate)
        
        dividerWithBackground()
        
        bioSummaryView(title: player.experienceTitle, value: player.experience)
        
        dividerWithBackground()
        
        bioSummaryView(title: player.draftTitle, value: player.draft)
        
        dividerWithBackground()
        
        bioSummaryView(title: player.countryTitle, value: player.country)
        
        dividerWithBackground()
        
        bioSummaryView(title: player.lastAttendedTitle, value: player.lastAttended)
    }
    
    func dividerWithBackground() -> some View {
        Divider()
            .background(Color("#272628"))
            .opacity(0.9)
            .frame(height: 1.5)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 15)
    }
    
    @ViewBuilder
    func bioSummaryView(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.9))
                .padding(.leading, 20)
            Spacer()
            Text(value)
                .foregroundColor(.white.opacity(0.9))
                .font(.system(size: 14, weight: .semibold))
                .padding(.trailing, 20)
        }
        .frame(height: 30)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func statsSummaryView(player: PlayerSummaryViewModel) -> some View {
        HStack {
            VStack(alignment: .center) {
                Text(player.pieTitle)
                    .padding(.horizontal, 5)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .background(Color("#5C5B60"))
                
                Text(player.pie)
                    .padding(2)
                    .foregroundColor(Color("#db4c30"))
                    .font(.title)
                    .fontWeight(.bold)
            }
            .padding(.leading, 20)
            Spacer()
            
            VStack(alignment: .center) {
                Text(player.ppgTitle)
                    .padding(.horizontal, 5)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .background(Color("#5C5B60"))
                
                Text(player.ppg)
                    .padding(2)
                    .foregroundColor(.white)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            Spacer()
            
            VStack(alignment: .center) {
                Text(player.rpgTitle)
                    .padding(.horizontal, 5)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .background(Color("#5C5B60"))
                
                Text(player.rpg)
                    .padding(2)
                    .foregroundColor(.white)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            Spacer()
            
            VStack(alignment: .center) {
                Text(player.apgTitle)
                    .padding(.horizontal, 5)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .background(Color("#5C5B60"))
                
                Text(player.apg)
                    .padding(2)
                    .foregroundColor(.white)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .padding(.trailing, 20)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    StandingsView()
}
