//
//  OtherGamesCarouselView.swift
//  nba
//
//

import SwiftUI

struct OtherGamesCarouselView: View {
    let gameRecap: [GamesModel]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("AROUND THE LEAGUE")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
                .tracking(1)
                .padding(.leading, 15)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(gameRecap, id: \.self) { gamesOfDay in
                        ForEach(gamesOfDay.items, id: \.self) { item in
                            let vm = HomeAwayViewModel(homeAway: item)
                            NavigationLink(destination: GameRecapView(viewModel: vm, gameRecap: gameRecap)) {
                                MiniGameCard(viewModel: vm)
                            }
                        }
                    }
                }
                .padding(.horizontal, 15)
            }
        }
    }
}

struct MiniGameCard: View {
    let viewModel: HomeAwayViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            // Away Team
            HStack {
                Image(viewModel.awayTriCode)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                
                Text(viewModel.awayTeamNickName.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text(viewModel.awayScore)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Divider().background(Color.white.opacity(0.1))
            
            // Home Team
            HStack {
                Image(viewModel.homeTriCode)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                
                Text(viewModel.homeTeamNickName.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text(viewModel.homeScore)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Status
            Text(viewModel.final)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
        }
        .padding(12)
        .frame(width: 160)
        .background(Color.black.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}
