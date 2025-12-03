//
//  PowerRankingDetailView.swift
//  nba
//
//  Created by 1100690 on 12/10/24.
//

import SwiftUI

struct PowerRankingDetailView: View {
    let teamState: PowerRankingViewModel.TeamState
    @State var scrollOffset: CGFloat = CGFloat.zero
    @State var hideNavigationBar: Bool = true
    @StateObject private var playerViewModel = PlayerViewModel()
    @StateObject private var viewModel = PowerRankingViewModel()
    @State private var hasAppeared = false
    
    private var viewState: PowerRankingViewModel.TeamDetailViewState {
        teamState.detailViewState
    }
    
    var body: some View {
        Group {
            if viewModel.shouldUseOfficialTeamData {
                OfficialPowerRankingDetailView(
                    teamState: teamState,
                    viewModel: viewModel,
                    playerViewModel: playerViewModel,
                    scrollOffset: $scrollOffset,
                    hideNavigationBar: $hideNavigationBar
                )
            } else {
                SafeModePowerRankingDetailView(
                    teamState: teamState,
                    viewModel: viewModel,
                    playerViewModel: playerViewModel,
                    scrollOffset: $scrollOffset,
                    hideNavigationBar: $hideNavigationBar
                )
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                if viewModel.shouldUseOfficialTeamData, let triCode = viewState.triCode {
                    Image(triCode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .opacity(hideNavigationBar ? 0.0 : 1.0)
                }
            }
        }
        .onChange(of: scrollOffset) { scrollOfset in
            let offset = scrollOfset + (self.hideNavigationBar ? 50 : 0)
            if offset > 60 {
                withAnimation(.easeIn(duration: 0.3)) {
                    self.hideNavigationBar = false
                }
            }
            if offset < 50 {
                withAnimation(.easeIn(duration: 0.3)) {
                    self.hideNavigationBar = true
                }
            }
        }
        .onAppear {
            guard !hasAppeared else { return }
            if !viewState.teamId.isEmpty {
                playerViewModel.fetchRoster(teamId: viewState.teamId)
                viewModel.fetchRecentGames(teamId: viewState.teamId)
            }
            hasAppeared = true
        }
    }
}

struct PowerRankingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PowerRankingDetailView(
                teamState: PowerRankingViewModel.TeamState(
                    id: "1",
                    displayRank: 1,
                    name: "MILWAUKEE BUCKS",
                    record: "30-12",
                    rankChangeText: "↑1",
                    rankChangeStyle: .up,
                    triCode: "MIL",
                    backgroundColorName: "bucks",
                    model: PowerRankingTeamModel(
                        id: "1",
                        rank: "1",
                        record: "30-12",
                        teamName: "Milwaukee Bucks",
                        teamCode: "MIL",
                        lastWeek: "1",
                        advanced: nil,
                        overview: "The Bucks are playing great basketball...",
                        takeaways: ["Takeaway 1", "Takeaway 2"],
                        upcomming: "Next 5 games..."
                    )
                )
            )
        }
        .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
    }
}
