//
//  PlayerHeaderView.swift
//  nba
//
//

import SwiftUI

struct PlayerHeaderView: View {
    let player: PlayerSummaryViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background Mesh Gradient
            LinearGradient(
                colors: [
                    Color(player.teamId.dark),
                    Color(player.teamId.light),
                    Color(player.teamId.dark)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Texture overlay (Dots/Mesh)
            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 400, height: 400)
                .offset(y: -100)
                .blur(radius: 50)
            
            VStack {
                Spacer()
                
                // Player Image & Info
                HStack(alignment: .bottom, spacing: -20) {
                    // Left Side: Name and Team Info
                    VStack(alignment: .leading, spacing: 4) {
                        
                        // Team Logo and TriCode
                        HStack(spacing: 8) {
                            if RemoteConfigManager.shared.shouldUseOfficialTeamData {
                                Image(player.teamTriCode)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                            }
                            
                            Text(player.teamNickName.uppercased())
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white.opacity(0.8))
                                .tracking(1)
                        }
                        .padding(.bottom, 8)

                        Text(player.firstName.uppercased())
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text(player.lastName.uppercased())
                            .font(.system(size: 40, weight: .black))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        
                        HStack(spacing: 8) {
                            Text(player.jersey)
                                .font(.system(size: 24, weight: .heavy))
                                .foregroundColor(Color(player.teamId.light).opacity(0.8)) // Team Accent
                                .overlay(
                                    Text(player.jersey)
                                        .font(.system(size: 24, weight: .heavy))
                                        .foregroundColor(.white)
                                        .offset(x: -1, y: -1)
                                        .blendMode(.overlay)
                                )
                            
                            Text("•")
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text(player.position)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.top, 4)
                    }
                    .padding(.leading, 20)
                    .padding(.bottom, 30)
                    .zIndex(1)
                    
                    Spacer()
                    
                    if RemoteConfigManager.shared.shouldUseOfficialTeamData {
                        // Right Side: Player Cutout Image
                        AsyncImage(url: URL(string: player.playerId.imageUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Image(systemName: "person.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .frame(height: 280)
                        .mask(
                            LinearGradient(
                                colors: [.black, .black, .black.opacity(0)],
                                startPoint: .center,
                                endPoint: .bottom
                            )
                        )
                        .padding(.trailing, -20) // Push to edge
                        .padding(.bottom, 0)
                        .zIndex(0)
                    }
                }
            }
        }
        .frame(height: 320)
    }
}
