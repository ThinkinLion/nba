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
    @ObservedObject private var favoritesManager = FavoritesManager.shared
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
                        
                        // Teams of the Week Section
                        if let teamsOfTheWeek = currentRanking.teamsOfTheWeek, !teamsOfTheWeek.isEmpty {
                          TeamsOfTheWeekView(teams: teamsOfTheWeek, viewModel: viewModel)
                                .padding(.top, 20)
                        }
                        
                        // Movement Section
                        if let movement = currentRanking.movement {
                            MovementView(movement: movement, viewModel: viewModel)
                                .padding(.top, 20)
                        }
                        

                        
                        // 컨퍼런스 탭
                        conferenceTabView()
                            .padding(.top, 40)
                        
                        // 랭킹 리스트
                        if !currentRanking.teams.isEmpty {
                            rankingListView(items: viewModel.filteredTeams(currentRanking.teams))
                                .padding(.top, 20)
                        }
                        

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
        .refreshable {
            await viewModel.fetchPowerRankings(forceRefresh: true)
        }
        .onAppear() {
            guard !hasAppeared else { return }
            Task {
                await viewModel.fetchPowerRankings()
            }
            hasAppeared = true
        }
        .analyticsScreen(name: "NBA-PowerRankingView")
    }
}

// MARK: - Week Carousel View
extension PowerRankingView {
    @ViewBuilder
    func weekCarouselView() -> some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(viewModel.availableWeeks.enumerated()), id: \.element) { index, week in
                        let weekLabel = viewModel.weekLabels[index]
                        let isSelected = viewModel.selectedWeek == week
                        
                        Button(action: {
                            viewModel.selectWeek(week)
                            withAnimation {
                                proxy.scrollTo(week, anchor: .center)
                            }
                        }) {
                            Text(weekLabel)
                                .font(.system(size: 15, weight: isSelected ? .bold : .semibold))
                                .foregroundColor(isSelected ? .white : .weekCarouselBlueLight)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(
                                            isSelected ?
                                            LinearGradient(
                                                colors: [
                                                    .weekCarouselBlue,
                                                    .weekCarouselBlueDark
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ) :
                                            LinearGradient(
                                                colors: [
                                                    .weekCarouselBlue.opacity(0.15),
                                                    .weekCarouselBlueDark.opacity(0.1)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .stroke(
                                            isSelected ?
                                            Color.white.opacity(0.5) :
                                            .weekCarouselBlue.opacity(0.4),
                                            lineWidth: 1.5
                                        )
                                )
                                .shadow(
                                    color: isSelected ?
                                    .weekCarouselBlue.opacity(0.4) :
                                    .weekCarouselBlue.opacity(0.2),
                                    radius: isSelected ? 8 : 4,
                                    x: 0,
                                    y: isSelected ? 4 : 2
                                )
                        }
                        .id(week)
                    }
                }
                .padding(.horizontal, 15)
            }
            .onAppear {
                // 초기 로드 시 선택된 week로 스크롤 (최신이 맨 앞이므로 leading으로 스크롤)
                if let selectedWeek = viewModel.selectedWeek {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            proxy.scrollTo(selectedWeek, anchor: .leading)
                        }
                    }
                }
            }
            .onChange(of: viewModel.selectedWeek) { newWeek in
                // selectedWeek가 변경될 때 스크롤 (외부에서 변경된 경우)
                if let newWeek = newWeek {
                    withAnimation {
                        proxy.scrollTo(newWeek, anchor: .center)
                    }
                }
            }
        }
    }
}

// MARK: - Header View
extension PowerRankingView {
    @ViewBuilder
    func headerView(powerRanking: PowerRankingViewState) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if let cleanedTitle = powerRanking.cleanedTitle {
                Text(cleanedTitle)
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundStyle(
                        LinearGradient(
                            colors: powerRanking.titleGradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            if let subTitle = powerRanking.subTitle {
                Text(subTitle)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // Remote Config로 이미지 표시 제어
            if viewModel.shouldUseOfficialTeamData, let imageUrl = powerRanking.imageURL {
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

// MARK: - Conference Tab View
extension PowerRankingView {
    @ViewBuilder
    func conferenceTabView() -> some View {
        HStack(spacing: 0) {
            ForEach(Conference.allCases, id: \.self) { conference in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.selectedConference = conference
                    }
                }) {
                    VStack(spacing: 8) {
                        Text(conference.rawValue)
                            .font(.system(size: 13, weight: viewModel.selectedConference == conference ? .bold : .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .overlay(
                                // Badge with count for FAVORITES (top-right corner)
                                Group {
                                    if conference == .favorites && viewModel.hasFavorites {
                                        Text("\(viewModel.favoritesCount)")
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 5)
                                            .padding(.vertical, 3)
                                            .background(
                                                LinearGradient(
                                                    colors: [
                                                        Color(red: 1.0, green: 0.84, blue: 0.0), // NBA Gold
                                                        Color(red: 1.0, green: 0.6, blue: 0.0)   // Orange
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .clipShape(Circle())
                                            .shadow(color: Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.5), radius: 4, x: 0, y: 2)
                                            .offset(x: 8, y: -8)
                                    }
                                },
                                alignment: .topTrailing
                            )
                        
                        // Underline indicator
                        Rectangle()
                            .fill(viewModel.selectedConference == conference ? Color.white : Color.clear)
                            .frame(height: 2)
                    }
                    .padding(.bottom, 6)
                    .foregroundColor(viewModel.selectedConference == conference ? .white : .white.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
                .disabled(conference == .favorites && !viewModel.hasFavorites)
                .opacity(conference == .favorites && !viewModel.hasFavorites ? 0.3 : 1.0)
            }
        }
        .padding(.horizontal, 15)
    }
}

// Helper extension for conditional modifiers
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Ranking List View
extension PowerRankingView {
    @ViewBuilder
    func rankingListView(items: [TeamState]) -> some View {
        LazyVStack(spacing: 16) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, team in
                NavigationLink(destination: PowerRankingDetailView(teamState: team, viewModel: viewModel)) {
                    rankingCardView(team: team)
                }
                
                // Banner after Top 4 (Index 3)
                if index == 3 {
                    StyledBannerContainer(adUnitId: .powerRanking, paddingHorizontal: 0)
                }
            }
        }
        .padding(.horizontal, 15)
    }
    
    
    @ViewBuilder
    func rankingCardView(team: TeamState) -> some View {
        let baseColor = Color(team.backgroundColorName)
        
        ZStack(alignment: .leading) {
            // 1. Background with Gradient & Watermark
            ZStack(alignment: .trailing) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                baseColor,
                                baseColor.opacity(0.8),
                                Color.black.opacity(0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Watermark Logo
                if viewModel.shouldUseOfficialTeamData, let triCode = team.triCode {
                    Image(triCode)
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 90, height: 90)
                        .foregroundColor(.white.opacity(0.05))
                        .rotationEffect(.degrees(-15))
                        .offset(x: 40, y: 10)
                        .clipped()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.3), .white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: baseColor.opacity(0.3), radius: 8, x: 0, y: 4)
            
            // Content
            HStack(spacing: 0) {
                // Rank Section
                ZStack {
                    // Shadow Text
                    Text("\(team.displayRank)")
                        .font(.system(size: team.displayRank <= 3 ? 52 : (team.displayRank <= 9 ? 44 : 38), weight: .black, design: .rounded))
                        .italic()
                        .foregroundColor(.black.opacity(0.2))
                        .offset(x: 3, y: 3)
                    
                    // Main Text
                    Text("\(team.displayRank)")
                        .font(.system(size: team.displayRank <= 3 ? 52 : (team.displayRank <= 9 ? 44 : 38), weight: .black, design: .rounded))
                        .italic()
                        .foregroundStyle(
                            rankGradient(for: team.displayRank)
                        )
                        .shadow(color: rankShadowColor(for: team.displayRank), radius: 10, x: 0, y: 0)
                }
                .frame(width: 70)
                .padding(.leading, 5)
                
                // Team Info Section
                VStack(alignment: .leading, spacing: 4) {
                    // Team Name (left-aligned)
                    Text(team.name.uppercased())
                        .font(.system(size: 16, weight: .heavy, design: .default))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Record and Rank Change Badge Row
                    HStack(spacing: 8) {
                        if let record = team.record {
                            HStack(spacing: 4) {
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white.opacity(0.6))
                                
                                Text(record)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        
                        // Rank Change Badge
                        HStack(spacing: 2) {
                            Text(team.rankChangeText)
                                .font(.system(size: 11, weight: .bold))
                            
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
                                .fill(Color.black.opacity(0.3))
                                .overlay(
                                    Capsule()
                                        .stroke(PowerRankingFormatter.rankChangeColor(for: team.rankChangeStyle).opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
                .padding(.leading, 10)
                .padding(.trailing, 8)
                
                // Official Logo (Right side)
                if viewModel.shouldUseOfficialTeamData, let triCode = team.triCode {
                    Image(triCode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                        .padding(.trailing, 12)
                }
            }
            .padding(.vertical, 16)
        }
        .frame(height: 95)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 2)
    }
    
    // 랭크별 그라디언트
    func rankGradient(for rank: Int) -> LinearGradient {
        switch rank {
        case 1: // Gold
            return LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.95, blue: 0.6), // Light Gold
                    Color(red: 1.0, green: 0.84, blue: 0.0), // Gold
                    Color(red: 0.8, green: 0.6, blue: 0.0)   // Dark Gold
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 2: // Silver
            return LinearGradient(
                colors: [
                    Color(white: 0.95),
                    Color(white: 0.8),
                    Color(white: 0.6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 3: // Bronze
            return LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.8, blue: 0.6),
                    Color(red: 0.8, green: 0.5, blue: 0.3),
                    Color(red: 0.6, green: 0.3, blue: 0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default: // White/Blueish
            return LinearGradient(
                colors: [
                    .white,
                    .white.opacity(0.7)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    // 랭크별 그림자 색상 (Glow 효과)
    func rankShadowColor(for rank: Int) -> Color {
        switch rank {
        case 1: return Color.yellow.opacity(0.6)
        case 2: return Color.white.opacity(0.5)
        case 3: return Color.orange.opacity(0.5)
        default: return Color.clear
        }
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

