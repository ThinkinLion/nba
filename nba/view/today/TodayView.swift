//
//  TodayView.swift
//  nba
//
//  홈 탭 "Today": 개인화의 거점. (기존 Games 탭을 큐레이션 + 개인화 피드로 재편, 탭 추가 없음)
//  모듈 순서: 날짜 스트립 → MY TEAMS → GAMES(내 팀 우선) → POTN → 배너 → MOVERS → LEAGUE LEADERS
//

import SwiftUI
import FirebaseAnalytics

struct TodayView: View {
    @StateObject private var viewModel = StandingsViewModel()
    @StateObject private var powerRankingViewModel = PowerRankingViewModel() // 팀 상세(PowerRankingDetailView) 진입용
    @ObservedObject private var favorites = FavoritesManager.shared
    @ObservedObject private var leaders = LeadersStore.shared
    @State private var selectedDateIndex: Int = 0
    @State private var hasAppeared = false
    @State private var showProfile = false

    /// 레이아웃 검증/스크린샷용: -screenshot-today <myteams|games|potn|movers|leaders> 전달 시 해당 모듈로 자동 스크롤
    private var screenshotAnchor: String? {
        let args = ProcessInfo.processInfo.arguments
        guard let idx = args.firstIndex(of: "-screenshot-today"), args.count > idx + 1 else { return nil }
        return args[idx + 1]
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // 수평 날짜 캘린더 스트립
                    if !viewModel.gameRecap.isEmpty {
                        DateSelectorView(games: viewModel.gameRecap, selectedIndex: $selectedDateIndex)
                            .padding(.top, 8)
                            .padding(.bottom, 12)
                            .onChange(of: selectedDateIndex) { newIndex in
                                if viewModel.gameRecap.indices.contains(newIndex) {
                                    viewModel.updateDailyPerformers(for: viewModel.gameRecap[newIndex])
                                }
                            }
                    }

                    if viewModel.gameRecap.isEmpty && viewModel.errorMessage == nil {
                        LogoLoadingView(size: 130)
                            .padding(.top, 80)
                            .frame(maxWidth: .infinity)
                    } else if let errorMessage = viewModel.errorMessage, viewModel.gameRecap.isEmpty {
                        errorView(errorMessage)
                    } else {
                        // 1. MY TEAMS
                        MyTeamsModuleView(
                            games: viewModel.gameRecap,
                            standings: viewModel.standings,
                            powerRanking: viewModel.powerRankings.first,
                            teamLink: teamLink,
                            onManage: { showProfile = true }
                        )
                        .padding(.bottom, 22)
                        .id("myteams")

                        // 2. GAMES (내 팀 경기 우선)
                        gamesModule
                            .padding(.bottom, 24)
                            .id("games")

                        // 3. PERFORMANCE OF THE NIGHT
                        if let best = viewModel.dailyPerformer {
                            PerformanceOfTheNightModuleView(performer: best, candidates: viewModel.dailyCandidates)
                                .padding(.bottom, 24)
                                .id("potn")
                        }

                        // 광고 슬롯
                        StyledBannerContainer(adUnitId: .powerRanking, paddingHorizontal: 16)
                            .padding(.bottom, 24)

                        // 4. MOVERS (주간 파워랭킹 상승/하락)
                        if let pr = viewModel.powerRankings.first {
                            MoversModuleView(powerRanking: pr, teamLink: teamLink)
                                .padding(.bottom, 24)
                                .id("movers")
                        }

                        // 5. LEAGUE LEADERS (일별 로테이션)
                        LeadersModuleView()
                            .padding(.bottom, 40)
                            .id("leaders")
                    }
                }
            }
            .onChange(of: leaders.isLoaded) { loaded in
                guard loaded, let anchor = screenshotAnchor else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation { proxy.scrollTo(anchor, anchor: .top) }
                }
            }
        }
        .navigationBarTitle("Today", displayMode: .large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showProfile = true
                    Analytics.logEvent("profile_open", parameters: ["source": "today"])
                }) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.white.opacity(0.9))
                        if favorites.hasFavorites {
                            Circle()
                                .fill(Color(red: 1.0, green: 0.84, blue: 0.0))
                                .frame(width: 9, height: 9)
                                .overlay(Circle().stroke(Color.black, lineWidth: 1.5))
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showProfile) {
            ProfileSheetView()
        }
        .preferredColorScheme(.dark)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .refreshable {
            await viewModel.fetchStandingsAsync(forceRefresh: true)
            await powerRankingViewModel.fetchPowerRankings(forceRefresh: true)
            await leaders.loadIfNeeded(forceRefresh: true)
        }
        .onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            Task {
                await viewModel.fetchStandingsAsync()
                await powerRankingViewModel.fetchPowerRankings()
                await leaders.loadIfNeeded()
            }
        }
        .analyticsScreen(name: "NBA-TodayView")
    }

    // MARK: - Team link (파워랭킹 탭과 동일한 팀 상세로 진입)
    
    /// 팀 상세 진입 정보. 파워랭킹 상태에서 먼저 찾고, 없으면 순위표 행으로 TeamState 를 구성
    private var teamLink: TodayTeamLink {
        TodayTeamLink(viewModel: powerRankingViewModel) { team in
            if let ts = powerRankingViewModel.getTeamState(for: team.triCode) { return ts }
            if let row = (viewModel.standings.east + viewModel.standings.west).first(where: { $0.teamId == team.teamId }) {
                return viewModel.createTeamState(from: row, powerRankings: powerRankingViewModel.currentPowerRanking?.items)
            }
            return nil
        }
    }
    
    // MARK: - Games module

    @ViewBuilder
    private var gamesModule: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SectionHeaderView(title: "GAMES")
                Spacer()
                if viewModel.gameRecap.indices.contains(selectedDateIndex),
                   let date = viewModel.gameRecap[selectedDateIndex].date {
                    Text(date)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.trailing, 16)
                }
            }

            if viewModel.gameRecap.indices.contains(selectedDateIndex) {
                let dayGames = viewModel.gameRecap[selectedDateIndex]
                if dayGames.items.isEmpty {
                    emptyGamesView
                        .padding(.horizontal, 16)
                } else {
                    let ordered = orderedGames(dayGames.items)
                    LazyVStack(spacing: 12) {
                        ForEach(ordered, id: \.self) { game in
                            NavigationLink(destination: GameRecapView(viewModel: HomeAwayViewModel(homeAway: game), gameRecap: viewModel.gameRecap)) {
                                GameScoreRow(game: game)
                                    .overlay(alignment: .topLeading) {
                                        if isMyGame(game) {
                                            myTeamTag
                                                .offset(x: 10, y: -7)
                                        }
                                    }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }

    /// 내 팀 경기를 앞으로 (원래 순서는 유지)
    private func orderedGames(_ items: [HomeAway]) -> [HomeAway] {
        let mine = items.filter(isMyGame)
        let rest = items.filter { !isMyGame($0) }
        return mine + rest
    }

    private func isMyGame(_ game: HomeAway) -> Bool {
        let ids = favorites.favoriteTeamIds
        return ids.contains(game.home.teamId) || ids.contains(game.away.teamId)
    }

    private var myTeamTag: some View {
        HStack(spacing: 3) {
            Image(systemName: "star.fill").font(.system(size: 7, weight: .bold))
            Text("MY TEAM").font(.system(size: 8, weight: .heavy, design: .rounded))
        }
        .foregroundColor(.black)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Color(red: 1.0, green: 0.84, blue: 0.0))
        .clipShape(Capsule())
    }

    // MARK: - States

    @ViewBuilder
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36))
                .foregroundColor(.orange)
            Text("경기를 불러올 수 없습니다")
                .font(.headline)
                .foregroundColor(.white)
            Text(message)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.top, 60)
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
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
        )
    }
}
