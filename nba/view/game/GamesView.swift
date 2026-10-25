//
//  GamesView.swift
//  nba
//
//  Created by ThinkinLion on 2026/10/25.
//

import SwiftUI
import FirebaseAnalytics

struct GamesView: View {
    @StateObject private var viewModel = StandingsViewModel()
    @State private var selectedDateIndex: Int = 0
    @State private var hasAppeared = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                // 수평 날짜 캘린더 스트립
                if !viewModel.gameRecap.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        DateSelectorView(games: viewModel.gameRecap, selectedIndex: $selectedDateIndex)
                            .padding(.top, 8)
                            .padding(.bottom, 12)
                    }
                    .onChange(of: selectedDateIndex) { newIndex in
                        if viewModel.gameRecap.indices.contains(newIndex) {
                            let selectedGames = viewModel.gameRecap[newIndex]
                            viewModel.updateDailyPerformers(for: selectedGames)
                        }
                    }
                }
                
                if viewModel.gameRecap.isEmpty && viewModel.errorMessage == nil {
                    LogoLoadingView(size: 130)
                        .padding(.top, 80)
                        .frame(maxWidth: .infinity)
                } else if let errorMessage = viewModel.errorMessage, viewModel.gameRecap.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 36))
                            .foregroundColor(.orange)
                        Text("경기를 불러올 수 없습니다")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 60)
                } else {
                    // 1. PERFORMANCE OF THE NIGHT (데일리 MVP)
                    if let bestPlayer = viewModel.dailyPerformer {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeaderView(title: "PERFORMANCE OF THE NIGHT")
                                .padding(.horizontal, 16)
                            
                            NavigationLink(destination: GameRecapView(viewModel: HomeAwayViewModel(homeAway: bestPlayer.game), gameRecap: viewModel.gameRecap)) {
                                dailyPerformerHeroCard(performer: bestPlayer)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, 16)
                        }
                        .padding(.bottom, 24)
                    }
                    
                    // 2. GAMES (경기 스코어보드 목록)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            SectionHeaderView(title: "MATCHES")
                            Spacer()
                            if viewModel.gameRecap.indices.contains(selectedDateIndex),
                               let date = viewModel.gameRecap[selectedDateIndex].date {
                                Text(date)
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        if viewModel.gameRecap.indices.contains(selectedDateIndex) {
                            let dayGames = viewModel.gameRecap[selectedDateIndex]
                            
                            if dayGames.items.isEmpty {
                                emptyGamesView
                                    .padding(.horizontal, 16)
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(dayGames.items, id: \.self) { game in
                                        NavigationLink(destination: GameRecapView(viewModel: HomeAwayViewModel(homeAway: game), gameRecap: viewModel.gameRecap)) {
                                            GameScoreRow(game: game)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarTitle("Games", displayMode: .large)
        .preferredColorScheme(.dark)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .refreshable {
            await viewModel.fetchGameRecap(forceRefresh: true)
        }
        .onAppear {
            if !hasAppeared {
                Task {
                    await viewModel.fetchGameRecap()
                }
                hasAppeared = true
            }
        }
        .analyticsScreen(name: "NBA-GamesView")
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private func dailyPerformerHeroCard(performer: DailyPerformer) -> some View {
        let teamCode = performer.teamCode
        let triCode = teamCode.nickNameToTriCode
        
        ZStack(alignment: .bottomLeading) {
            // 배경 그라디언트
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(teamCode.lowercased() + ".dark").opacity(0.85),
                            Color.black.opacity(0.9)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.25), Color.white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.4), radius: 8, x: 0, y: 4)
            
            // 선수 이미지 (우측 정렬)
            if let playerId = performer.player.playerId {
                HStack {
                    Spacer()
                    AsyncImage(url: URL(string: playerId.imageUrl)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else {
                            Color.clear
                        }
                    }
                    .frame(height: 150)
                    .offset(x: 10, y: 0)
                    .mask(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.8), .clear],
                            startPoint: .trailing,
                            endPoint: .leading
                        )
                    )
                }
            }
            
            // 콘텐츠 정보 (좌측)
            VStack(alignment: .leading, spacing: 6) {
                // 팀 & 경기 결과 뱃지
                HStack(spacing: 6) {
                    if !triCode.isEmpty {
                        Image(triCode)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    }
                    Text(triCode)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("vs \(performer.opponentTriCode)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Spacer()
                    
                    Text(performer.gameResultText)
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.85, blue: 0.45))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Capsule())
                }
                
                // 선수 이름
                VStack(alignment: .leading, spacing: 0) {
                    Text(performer.player.firstName ?? "")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                    Text(performer.player.lastName ?? "")
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                .padding(.top, 2)
                
                // 주요 기록 칩 (PTS / REB / AST)
                HStack(spacing: 8) {
                    statPill(title: "PTS", value: performer.player.pts ?? "0")
                    statPill(title: "REB", value: performer.player.reb ?? "0")
                    statPill(title: "AST", value: performer.player.ast ?? "0")
                    if let stl = performer.player.stl, stl != "0" {
                        statPill(title: "STL", value: stl)
                    }
                    if let blk = performer.player.blk, blk != "0" {
                        statPill(title: "BLK", value: blk)
                    }
                }
                .padding(.top, 4)
            }
            .padding(16)
        }
        .frame(height: 140)
    }
    
    @ViewBuilder
    private func statPill(title: String, value: String) -> some View {
        HStack(spacing: 3) {
            Text(title)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
            Text(value)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(Color.black.opacity(0.35))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.15), lineWidth: 0.8)
        )
    }
    
    @ViewBuilder
    private var emptyGamesView: some View {
        VStack(spacing: 10) {
            Image(systemName: "basketball")
                .font(.system(size: 32))
                .foregroundColor(.white.opacity(0.3))
            Text("해당 날짜에 예정된 경기가 없습니다")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}
