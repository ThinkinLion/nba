//
//  GameHeaderView.swift
//  nba
//
//

import SwiftUI

struct GameHeaderView: View {
    let viewModel: HomeAwayViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Dynamic Diagonal Background
            GeometryReader { geometry in
                ZStack {
                    // Away Side (Top Left)
                    Path { path in
                        path.move(to: .zero)
                        path.addLine(to: CGPoint(x: geometry.size.width * 0.65, y: 0))
                        path.addLine(to: CGPoint(x: geometry.size.width * 0.35, y: geometry.size.height))
                        path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                        path.closeSubpath()
                    }
                    .fill(LinearGradient(
                        colors: [Color(viewModel.awayTeamId.dark), Color(viewModel.awayTeamId.light)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    
                    // Home Side (Bottom Right)
                    Path { path in
                        path.move(to: CGPoint(x: geometry.size.width * 0.65, y: 0))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: 0))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                        path.addLine(to: CGPoint(x: geometry.size.width * 0.35, y: geometry.size.height))
                        path.closeSubpath()
                    }
                    .fill(LinearGradient(
                        colors: [Color(viewModel.homeTeamId.light), Color(viewModel.homeTeamId.dark)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    
                    // Neon Divider
                    Path { path in
                        path.move(to: CGPoint(x: geometry.size.width * 0.65, y: 0))
                        path.addLine(to: CGPoint(x: geometry.size.width * 0.35, y: geometry.size.height))
                    }
                    .stroke(
                        LinearGradient(colors: [.white.opacity(0), .white, .white.opacity(0)], startPoint: .top, endPoint: .bottom),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .blur(radius: 2)
                }
                    // Watermarks (Top Corners)
                    Image(viewModel.awayTriCode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .opacity(0.3)
                        .shadow(color: .black.opacity(0.6), radius: 5, x: 0, y: 0)
                        .position(x: 40 + 20, y: 60) // Top Left with padding

                    Image(viewModel.homeTriCode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .opacity(0.3)
                        .shadow(color: .black.opacity(0.6), radius: 5, x: 0, y: 0)
                        .position(x: geometry.size.width - 40 - 20, y: 60) // Top Right with padding
            }
            .ignoresSafeArea()
            
            // Content
            GeometryReader { contentGeo in
                VStack(spacing: 0) {
                    // 1. Score Center (Top)
                    VStack(spacing: 0) {
                        // Team Names
                        HStack(spacing: 12) {
                            Text(viewModel.awayTriCode)
                                .font(.system(size: 16, weight: .heavy, design: .monospaced))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text("vs")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text(viewModel.homeTriCode)
                                .font(.system(size: 16, weight: .heavy, design: .monospaced))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.top, 10)
                        
                        Text("FINAL")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1))
                            .padding(.top, 4)
                        
                        ZStack {
                            Text(viewModel.score)
                                .font(.system(size: 38, weight: .heavy)) // Slightly reduced to fit names
                                .foregroundColor(.white)
                                .italic()
                            
                            Text(viewModel.score)
                                .font(.system(size: 38, weight: .heavy))
                                .foregroundColor(.white.opacity(0.5))
                                .italic()
                                .blur(radius: 10)
                        }
                        .padding(.top, -4)
                        
                        Text(viewModel.series.uppercased())
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                            .tracking(1)
                    }
                    .frame(width: 200)
                    .zIndex(2)
                    .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
                    
                    Spacer(minLength: 0)
                    
                    // 2. Face-off Layout (Bottom)
                    HStack(alignment: .bottom, spacing: -20) { // Slight overlap between L/R containers allowed
                        // Away Container (Left)
                        // Layout: Text (Left) <-> Image (Right/Center)
                        ZStack(alignment: .bottomTrailing) {
                            // Image Layer (Masked)
                            ZStack(alignment: .bottom) {
                                // REMOVED Watermark from here

                                NavigationLink(destination: PlayerView(playerId: viewModel.awayLeaderId, teamId: viewModel.awayTeamId)) {
                                    AsyncImage(url: URL(string: viewModel.awayLeaderId.imageUrl)) { image in
                                        image.resizable()
                                    } placeholder: {
                                        Color.clear
                                    }
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 220)
                                    .mask(LinearGradient(colors: [.black, .black, .clear], startPoint: .top, endPoint: .bottom))
                                }
                            }
                            .offset(x: 20) // Push Image slightly RIGHT (towards center)
                            .frame(width: contentGeo.size.width / 2) 
                            .mask(
                                GeometryReader { geo in
                                    Path { path in
                                        path.move(to: .zero)
                                        path.addLine(to: CGPoint(x: geo.size.width, y: 0))
                                        path.addLine(to: CGPoint(x: geo.size.width * 0.85, y: geo.size.height)) // Cut right edge inward
                                        path.addLine(to: CGPoint(x: 0, y: geo.size.height))
                                        path.closeSubpath()
                                    }
                                }
                            )
                            
                            // Text Layer (Floating on Left)
                            VStack(alignment: .trailing, spacing: 0) {
                                Text(viewModel.awayLeaderFirstName.uppercased())
                                    .font(.system(size: 14, weight: .bold, design: .monospaced)) // Smaller First Name
                                    .foregroundColor(.white.opacity(0.8))
                                    .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)
                                
                                Text(viewModel.awayLeaderName.uppercased())
                                    .font(.system(size: 20, weight: .black, design: .monospaced)) // Larger Last Name
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)
                                    .lineLimit(3)
                                    .minimumScaleFactor(0.5)
                                    .multilineTextAlignment(.trailing)
                                
                                Text("\(viewModel.awayLeaderJersey) • \(viewModel.awayLeaderPosition)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(.top, 4)
                            }
                            .padding(.bottom, 60)
                            .padding(.trailing, 120) // Increased from 100 to 120
                            .frame(width: contentGeo.size.width / 2, alignment: .trailing)
                        }
                        .zIndex(1)
                        
                        // Home Container (Right)
                        // Layout: Image (Left/Center) <-> Text (Right)
                        ZStack(alignment: .bottomLeading) {
                            // Image Layer (Masked)
                            ZStack(alignment: .bottom) {
                                // REMOVED Watermark from here
                                    
                                NavigationLink(destination: PlayerView(playerId: viewModel.homeLeaderId, teamId: viewModel.homeTeamId)) {
                                    AsyncImage(url: URL(string: viewModel.homeLeaderId.imageUrl)) { image in
                                        image.resizable()
                                    } placeholder: {
                                        Color.clear
                                    }
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 220)
                                    .mask(LinearGradient(colors: [.black, .black, .clear], startPoint: .top, endPoint: .bottom))
                                }
                            }
                            .offset(x: -20) // Push Image slightly LEFT (towards center)
                            .frame(width: contentGeo.size.width / 2)
                            .mask(
                                GeometryReader { geo in
                                    Path { path in
                                        path.move(to: CGPoint(x: 0, y: 0))
                                        path.addLine(to: CGPoint(x: geo.size.width, y: 0))
                                        path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
                                        path.addLine(to: CGPoint(x: geo.size.width * 0.15, y: geo.size.height)) // Cut left edge inward
                                        path.closeSubpath()
                                    }
                                }
                            )

                            // Text Layer (Floating on Right)
                            VStack(alignment: .leading, spacing: 0) {
                                Text(viewModel.homeLeaderFirstName.uppercased())
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.8))
                                    .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)

                                Text(viewModel.homeLeaderName.uppercased())
                                    .font(.system(size: 20, weight: .black, design: .monospaced))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)
                                    .lineLimit(3)
                                    .minimumScaleFactor(0.5)
                                    .multilineTextAlignment(.leading)
                                
                                Text("\(viewModel.homeLeaderJersey) • \(viewModel.homeLeaderPosition)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(.top, 4)
                            }
                            .padding(.bottom, 60)
                            .padding(.leading, 120) // Increased from 100 to 120
                            .frame(width: contentGeo.size.width / 2, alignment: .leading)
                        }
                        .zIndex(1)
                    }
                }
            }
        }
        .frame(height: 280)
        .clipped()
    }
}
