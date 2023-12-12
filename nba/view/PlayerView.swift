//
//  PlayerView.swift
//  nba
//
//  Created by 1100690 on 12/5/23.
//

import SwiftUI

struct PlayerView: View {
    @StateObject var playerViewModel = PlayerViewModel()
    //TODO: common한 player viwemodel이 와야
    var viewModel: SeasonLeaderViewModel
    
    var body: some View {
        ScrollView(.vertical) {
            let player = PlayerSummaryViewModel(player: playerViewModel.player)
            ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center)) {
                AsyncImage(url: URL(string: viewModel.imageUrl)) { image in
                    image.resizable()
                } placeholder: {}
                .aspectRatio(contentMode: .fill)
                .frame(width: 180, height: 180, alignment: .bottom)
                .padding(.leading, 180)
                .padding(.bottom, -55)
                .zIndex(0)
                
                VStack(alignment: .leading) {
                    Image(viewModel.teamTriCode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .scaleEffect(1.2)
                        .clipped()
                    
                    Text(viewModel.upperCasedName)
                    .foregroundColor(.white)
                    .font(.title)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                    
                    Text(player.jerseyAndPosition)
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                .frame(width: 160)
                .padding(.trailing, 200)
                .zIndex(1)
            }
            .frame(height: 250)
            .frame(maxWidth: .infinity)
            .padding(.top, 15)
            .padding(.horizontal, 15)
            .background(Color(viewModel.light))
        
            Text("")
                .frame(maxWidth: .infinity)
                .frame(height: 20)
                .background {
                    CustomCorner(corners: [.topLeft, ], radius: 20)
                        .fill(Color(viewModel.dark))
                        .ignoresSafeArea()
                }
                .padding(.top, -19)
            
            summaryView(player: player)
        }
        .background(Color(viewModel.dark))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear() {
            playerViewModel.fetchPlayer(documentId: viewModel.playerId)
        }
        .ignoresSafeArea()
    }
}

extension PlayerView {
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
                .font(.callout)
                .foregroundColor(.white.opacity(0.9))
                .padding(.leading, 20)
            Spacer()
            Text(value)
                .foregroundColor(.white)
                .font(.callout)
                .fontWeight(.semibold)
                .padding(.trailing, 20)
        }
        .frame(height: 35)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func statsSummaryView(player: PlayerSummaryViewModel) -> some View {
        HStack {
            VStack(alignment: .center) {
                Text(player.pieTitle)
                    .padding(.horizontal, 5)
                    .font(.callout)
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
                    .font(.callout)
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
                    .font(.callout)
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
                    .font(.callout)
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
