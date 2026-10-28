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
                    // 1. PERFORMANCE OF THE NIGHT (데일리 MVP & 후보군)
                    if let bestPlayer = viewModel.dailyPerformer {
                        VStack(alignment: .leading, spacing: 14) {
                            SectionHeaderView(title: "PERFORMANCE OF THE NIGHT")
                                .padding(.horizontal, 16)
                            
                            // 1위 히어로 카드 (승리팀 MVP) → PlayerView로 직접 연결
                            NavigationLink(
                                destination: PlayerView(
                                    playerId: bestPlayer.player.playerId ?? "",
                                    teamId: bestPlayer.player.teamId ?? ""
                                )
                            ) {
                                dailyPerformerHeroCard(performer: bestPlayer)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, 16)
                            
                            // 2~4위 후보군 (Honorable Mentions) 가로 스크롤 카드
                            if !viewModel.dailyCandidates.isEmpty {
                                honorableMentionsSection(candidates: viewModel.dailyCandidates)
                            }
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
                            Color.black.opacity(0.92)
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
            
            // 선수 이미지 (우측 정렬 - 높이 165, 얼굴이 절대 텍스트에 가려지지 않음)
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
                    .frame(height: 165)
                    .offset(x: 5, y: 0)
                    .mask(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.9), .clear],
                            startPoint: .trailing,
                            endPoint: .leading
                        )
                    )
                }
            }
            
            // 콘텐츠 정보 (좌측에만 정렬 - 우측 120pt는 선수 얼굴 공간으로 클리어하게 비워둠)
            VStack(alignment: .leading, spacing: 6) {
                // 1행: 팀 정보 & 경기 결과 뱃지 (좌측 정렬!)
                HStack(spacing: 8) {
                    if !triCode.isEmpty {
                        Image(triCode)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22)
                    }
                    Text(triCode)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("vs \(performer.opponentTriCode)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.65))
                    
                    Text(performer.gameResultText)
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.85, blue: 0.45))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                // 2행: 선수 이름 (좌측에 굵게)
                VStack(alignment: .leading, spacing: 0) {
                    Text(performer.player.firstName ?? "")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white.opacity(0.75))
                    Text(performer.player.lastName ?? "")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                
                // 3행: 주요 기록 칩 (PTS / REB / AST)
                HStack(spacing: 6) {
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
                .padding(.top, 2)
            }
            .padding(14)
            .padding(.trailing, 120) // 선수 얼굴 영역과 절대 겹치지 않도록 우측 여백 확보!
        }
        .frame(height: 155)
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
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color.black.opacity(0.45))
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
    
    // MARK: - Honorable Mentions (Top Candidates) Section
    
    @ViewBuilder
    private func honorableMentionsSection(candidates: [DailyPerformer]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.yellow)
                Text("HONORABLE MENTIONS")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .tracking(0.6)
            }
            .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(candidates) { candidate in
                        // HONORABLE MENTIONS 카드 → PlayerView로 직접 연결
                        NavigationLink(
                            destination: PlayerView(
                                playerId: candidate.player.playerId ?? "",
                                teamId: candidate.player.teamId ?? ""
                            )
                        ) {
                            candidateMiniCard(performer: candidate)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            }
        }
    }
    
    // MARK: - Candidate Mini Card (Honorable Mentions: 상단 여백 없이 테두리를 꽉 채우는 구조)
    @ViewBuilder
    private func candidateMiniCard(performer: DailyPerformer) -> some View {
        let teamCode = performer.teamCode
        let triCode = teamCode.nickNameToTriCode
        
        ZStack(alignment: .bottom) {
            // 1. 카드 전체 배경 (테두리를 빈틈없이 100% 꽉 채우는 그라디언트)
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(teamCode.lowercased() + ".dark").opacity(0.9),
                            Color.black.opacity(0.92)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // 2. 선수 이미지 (상단 영역에 시원하게 배치되어 머리가 잘리거나 붕 뜨지 않음)
            if let playerId = performer.player.playerId {
                VStack(spacing: 0) {
                    AsyncImage(url: URL(string: playerId.imageUrl)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else {
                            Color.clear
                        }
                    }
                    .frame(height: 112)
                    .offset(y: 4)
                    
                    Spacer(minLength: 0)
                }
            }
            
            // 3. 상단 뱃지 오버레이 (팀 TriCode & W/L 승패)
            VStack {
                HStack {
                    Text(triCode)
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                    
                    Text(performer.isWin ? "W" : "L")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(performer.isWin ? Color(red: 0.2, green: 0.8, blue: 0.4) : Color.red.opacity(0.85))
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 10)
                .padding(.top, 8)
                
                Spacer()
            }
            
            // 4. 하단 정보 패널 (카드 밑바닥에 딱 밀착되어 얼굴을 전혀 가리지 않음)
            VStack(alignment: .leading, spacing: 3) {
                Text(performer.player.lastName?.uppercased() ?? "")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Text("\(performer.player.pts ?? "0") PTS")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                    
                    if let reb = performer.player.reb, reb != "0" {
                        Text("· \(reb)R")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.65))
                    }
                    
                    if let ast = performer.player.ast, ast != "0" {
                        Text("· \(ast)A")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.65))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                Rectangle()
                    .fill(Color.black.opacity(0.88))
                    .overlay(
                        Rectangle()
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 0.5),
                        alignment: .top
                    )
            )
        }
        .frame(width: 130, height: 165)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.25), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 3)
    }
}
