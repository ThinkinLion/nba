//
//  FavoriteTeamsBarView.swift
//  nba
//
//  Created by ThinkinLion on 2026/10/25.
//

import SwiftUI

struct FavoriteTeamsBarView: View {
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    @ObservedObject var viewModel: PowerRankingViewModel
    
    var body: some View {
        let favoriteTeams = getFavoriteTeams()
        
        VStack(alignment: .leading, spacing: 8) {
            // 헤더: 타이틀 & 즐겨찾기 개수
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.84, blue: 0.0), Color(red: 1.0, green: 0.55, blue: 0.0)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("MY TEAMS")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                    .tracking(0.8)
                
                if !favoriteTeams.isEmpty {
                    Text("\(favoriteTeams.count)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(Color(red: 1.0, green: 0.84, blue: 0.0))
                        .clipShape(Capsule())
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            
            if favoriteTeams.isEmpty {
                // 즐겨찾기 팀이 없을 때 유도 배너
                emptyFavoritesBanner
                    .padding(.horizontal, 16)
            } else {
                // 즐겨찾기 팀 가로 스크롤 카드 리스트
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(favoriteTeams, id: \.id) { team in
                            NavigationLink(destination: PowerRankingDetailView(teamState: team, viewModel: viewModel)) {
                                favoriteTeamCard(team: team)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(.vertical, 6)
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var emptyFavoritesBanner: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 32, height: 32)
                Image(systemName: "star.dashed")
                    .font(.system(size: 14))
                    .foregroundColor(.yellow.opacity(0.8))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("나만의 관심 팀을 등록해보세요")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                Text("순위 리스트에서 팀을 탭해 즐겨찾기(⭐)하면 여기에 모아볼 수 있습니다.")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.55))
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    @ViewBuilder
    private func favoriteTeamCard(team: TeamState) -> some View {
        let baseColor = Color(team.backgroundColorName)
        
        ZStack(alignment: .leading) {
            // 글래스모피즘 배경
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            baseColor.opacity(0.85),
                            Color.black.opacity(0.65)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.35), Color.white.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: baseColor.opacity(0.3), radius: 6, x: 0, y: 3)
            
            // 워터마크 로고
            if let triCode = team.triCode {
                HStack {
                    Spacer()
                    Image(triCode)
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48, height: 48)
                        .foregroundColor(.white.opacity(0.07))
                        .offset(x: 10, y: 10)
                }
                .clipped()
            }
            
            // 콘텐츠
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .center, spacing: 8) {
                    // 팀 로고
                    if let triCode = team.triCode {
                        Image(triCode)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                            .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 1)
                    }
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text(team.triCode ?? team.name)
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        
                        if let record = team.record {
                            Text(record)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    Spacer(minLength: 4)
                }
                
                HStack(alignment: .bottom, spacing: 6) {
                    // 순위 표시
                    HStack(alignment: .firstTextBaseline, spacing: 1) {
                        Text("#")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.yellow)
                        Text("\(team.displayRank)")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // 등락 뱃지
                    HStack(spacing: 2) {
                        Text(team.rankChangeText)
                            .font(.system(size: 10, weight: .bold))
                        
                        if team.rankChangeStyle != .same {
                            Image(systemName: team.rankChangeStyle == .up ? "arrow.up" : "arrow.down")
                                .font(.system(size: 7, weight: .bold))
                        }
                    }
                    .foregroundColor(PowerRankingFormatter.rankChangeColor(for: team.rankChangeStyle))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(PowerRankingFormatter.rankChangeColor(for: team.rankChangeStyle).opacity(0.18))
                            .overlay(
                                Capsule()
                                    .stroke(PowerRankingFormatter.rankChangeColor(for: team.rankChangeStyle).opacity(0.35), lineWidth: 0.8)
                            )
                    )
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .frame(width: 140, height: 78)
    }
    
    // MARK: - Helpers
    
    private func getFavoriteTeams() -> [TeamState] {
        guard let currentTeams = viewModel.currentViewState?.teams else { return [] }
        return currentTeams.filter { team in
            guard let triCode = team.triCode else { return false }
            return favoritesManager.isFavorite(triCode)
        }
    }
}
