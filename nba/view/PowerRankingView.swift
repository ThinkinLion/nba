//
//  PowerRankingView.swift
//  nba
//
//  Created by 1100690 on 12/10/24.
//

import SwiftUI
import FirebaseAnalytics

struct PowerRankingView: View {
    @StateObject var viewModel = PowerRankingViewModel()
    @State private var hasAppeared = false
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    // Week 캐러셀을 위한 공간 (스크롤 시 사라짐)
                    if !viewModel.availableWeeks.isEmpty {
                        weekCarouselView()
                            .padding(.top, 10)
                            .padding(.bottom, 15)
                            .background(
                                GeometryReader { proxy in
                                    Color.clear
                                        .preference(key: ScrollOffsetPreferenceKey.self, value: -proxy.frame(in: .named("scroll")).minY)
                                }
                            )
                    }
                    
                    if viewModel.isLoading {
                        LogoLoadingView(size: 140)
                            .padding(.top, 60)
                            .frame(maxWidth: .infinity)
                    } else if let currentRanking = viewModel.currentViewState {
                        // 헤더 섹션
                        headerView(powerRanking: currentRanking)
                            .padding(.horizontal, 15)
                            .padding(.top, 15)
                        
                        // 랭킹 리스트
                        if !currentRanking.teams.isEmpty {
                            rankingListView(items: currentRanking.teams)
                                .padding(.top, 20)
                        }
                        
                        BannerView(adUnitId: .powerRanking, paddingTop: 15, paddingHorizontal: 10)
                            .padding(.top, 20)
                    } else if let errorMessage = viewModel.errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        Text("No power rankings available")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }
            
            // Sticky Week 캐러셀 (스크롤 시 상단에 고정)
            if !viewModel.availableWeeks.isEmpty && scrollOffset > 0 {
                VStack(spacing: 0) {
                    weekCarouselView()
                        .padding(.top, 10)
                        .padding(.bottom, 15)
                        .background(
                            Color.black
                                .ignoresSafeArea(edges: .top)
                        )
                    Spacer()
                }
            }
        }
        .navigationBarTitle("Power Rankings", displayMode: .large)
        .preferredColorScheme(.dark)
        .onAppear() {
            guard !hasAppeared else { return }
            viewModel.fetchPowerRankings()
            hasAppeared = true
        }
        .analyticsScreen(name: "NBA-PowerRankingView")
    }
}

// MARK: - Week Carousel View
extension PowerRankingView {
    @ViewBuilder
    func weekCarouselView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(viewModel.availableWeeks.enumerated()), id: \.element) { index, week in
                    let weekLabel = viewModel.weekLabels[index]
                    let isSelected = viewModel.selectedWeek == week
                    
                    Button(action: {
                        viewModel.selectWeek(week)
                    }) {
                        Text(weekLabel)
                            .font(.system(size: 15, weight: isSelected ? .bold : .medium))
                            .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(isSelected ? Color.white.opacity(0.2) : Color.white.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(isSelected ? Color.white.opacity(0.4) : Color.clear, lineWidth: 1.5)
                            )
                    }
                }
            }
            .padding(.horizontal, 15)
        }
    }
}

// MARK: - Header View
extension PowerRankingView {
    @ViewBuilder
    func headerView(powerRanking: PowerRankingViewModel.PowerRankingViewState) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if let cleanedTitle = powerRanking.cleanedTitle {
                Text(cleanedTitle)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }
            
            if let subTitle = powerRanking.subTitle {
                Text(subTitle)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            if let imageUrl = powerRanking.imageURL {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(height: 200)
                .cornerRadius(12)
                .padding(.top, 10)
                
                if let imageDesc = powerRanking.imageDesc {
                    Text(imageDesc)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 5)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Ranking List View
extension PowerRankingView {
    @ViewBuilder
    func rankingListView(items: [PowerRankingViewModel.TeamState]) -> some View {
        VStack(spacing: 12) {
            ForEach(items) { team in
                NavigationLink(destination: PowerRankingDetailView(teamState: team)) {
                    rankingCardView(team: team)
                }
            }
        }
        .padding(.horizontal, 15)
    }
    
    @ViewBuilder
    func rankingCardView(team: PowerRankingViewModel.TeamState) -> some View {
        let baseColor = Color(team.backgroundColorName)
        
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            baseColor,
                            baseColor.opacity(0.75),
                            baseColor.opacity(0.55)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: baseColor.opacity(0.28), radius: 10, x: 0, y: 8)
            
            HStack(alignment: .center, spacing: 10) {
                // 순위
                VStack(spacing: 5) {
                    Text("\(team.displayRank)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(team.rankChangeText)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(PowerRankingViewModel.rankChangeColor(for: team.rankChangeStyle))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                        )
                }
                .frame(width: 48)
                
                // 팀 정보
                VStack(alignment: .leading, spacing: 6) {
                    if !team.name.isEmpty {
                        Text(team.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    HStack(spacing: 8) {
                        if let record = team.record {
                            Label {
                                Text(record)
                                    .font(.system(size: 13, weight: .medium))
                            } icon: {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundColor(.white.opacity(0.85))
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.top, 16)
            .padding(.bottom, 14)
            .padding(.leading, 44)
            .padding(.trailing, 16)
        }
        .overlay(alignment: .topLeading) {
            if let triCode = team.triCode {
                Image(triCode)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 62, height: 62)
                    .shadow(color: .black.opacity(0.25), radius: 9, x: 0, y: 6)
                    .offset(x: -20, y: -20)
            }
        }
        .padding(.top, 16)
        .padding(.horizontal, 2)
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
}

// MARK: - Scroll Offset Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct PowerRankingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PowerRankingView()
        }
        .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
    }
}

