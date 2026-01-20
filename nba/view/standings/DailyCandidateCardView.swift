//
//  DailyCandidateCardView.swift
//  nba
//
//  Created by Antigravity on 1/5/25.
//

import SwiftUI

struct DailyCandidateCardView: View {
    let performer: DailyPerformer
    
    var body: some View {
        ZStack {
            // Background: Team Color
            Color(performer.teamCode.lowercased() + ".dark")
            

            
            VStack(spacing: 0) {
                // Image Area
                ZStack(alignment: .bottom) {
                    if let playerId = performer.player.playerId {
                        AsyncImage(url: URL(string: playerId.smallImageUrl)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.white.opacity(0.1))
                                    .padding(20)
                            }
                        }
                        .mask(LinearGradient(gradient: Gradient(colors: [.black, .black, .clear]), startPoint: .top, endPoint: .bottom))
                    }
                }
                .frame(height: 100)
                
                Spacer()
                
                // Info Area
                VStack(alignment: .center, spacing: 2) {
                    // Name
                    Text(performer.player.lastName?.uppercased() ?? "")
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    // Stats (PTS)
                    Text("\(performer.player.pts ?? "0") PTS")
                        .font(.system(size: 16, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                    
                    // Game Result
                    Text(performer.gameResultText)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 2)
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 16)
            }
        }
        .clipped() // Sharp edges
    }
}
