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
    
    var body: some View {
        ScrollView(.vertical) {
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
            
            BannerView(adUnitId: .teamView, paddingTop: 10)
            
            
        }
        .background(Color(summary.teamId.dark))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear() {
            viewModel.fetchTeam(documentId: summary.teamId)
//            viewModel.fetchRoster(teamId: teamId)
        }
        .ignoresSafeArea()
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
    func statsSummaryView(stats: TeamStatsViewModel) -> some View {
        HStack {
            VStack(alignment: .center) {
                Text(stats.ppgTitle)
                    .padding(.horizontal, 5)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .background(Color("#5C5B60"))
                
                Text(stats.ppg)
                    .padding(2)
                    .foregroundColor(.white.opacity(0.9))
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(stats.ppgRank)
                    .padding(2)
                    .foregroundColor(.white.opacity(0.8))
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .padding(.leading, 20)
            Spacer()
            
            VStack(alignment: .center) {
                Text(stats.oppgTitle)
                    .padding(.horizontal, 5)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .background(Color("#5C5B60"))
                
                Text(stats.oppg)
                    .padding(2)
                    .foregroundColor(.white.opacity(0.9))
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(stats.oppgRank)
                    .padding(2)
                    .foregroundColor(.white.opacity(0.8))
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            Spacer()
            
            VStack(alignment: .center) {
                Text(stats.rpgTitle)
                    .padding(.horizontal, 5)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .background(Color("#5C5B60"))
                
                Text(stats.rpg)
                    .padding(2)
                    .foregroundColor(.white.opacity(0.9))
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(stats.rpgRank)
                    .padding(2)
                    .foregroundColor(.white.opacity(0.8))
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            Spacer()
            
            VStack(alignment: .center) {
                Text(stats.apgTitle)
                    .padding(.horizontal, 5)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .background(Color("#5C5B60"))
                
                Text(stats.apg)
                    .padding(2)
                    .foregroundColor(.white.opacity(0.9))
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(stats.apgRank)
                    .padding(2)
                    .foregroundColor(.white.opacity(0.8))
                    .font(.caption)
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
