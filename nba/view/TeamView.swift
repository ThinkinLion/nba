//
//  TeamView.swift
//  nba
//
//  Created by 1100690 on 12/21/23.
//

import SwiftUI

struct TeamView: View {
    let teamId: String
    @StateObject var viewModel = TeamViewModel()
    @State private var hasAppeared = false
    @State var scrollOffset: CGFloat = CGFloat.zero
    @State var hideNavigationBar: Bool = true
//    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        let statsViewModel = TeamStatsViewModel(team: viewModel.team)
        
        ObservableScrollView(scrollOffset: $scrollOffset) {
            ZStack(alignment: .topLeading) {
                Color.clear
                Image(teamId.teamIdToNickName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(0.1)
                    .frame(width: 250, height: 250)
                    .scaleEffect(1.2)
                    .clipped()
                    .zIndex(0)
                
                VStack(alignment: .center, spacing: 0) {
                    Image(teamId.teamIdToNickName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .clipped()
                    Text(statsViewModel.conferenceRankFullName)
                        .foregroundColor(.white.opacity(0.9))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .minimumScaleFactor(0.5)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 50)
                .zIndex(1)
            }
            .frame(height: 250)
            .frame(maxWidth: .infinity)
            .background(Color(teamId.light))
        
            Text("")
                .frame(maxWidth: .infinity)
                .frame(height: 20)
                .background {
                    CustomCorner(corners: [.topLeft, ], radius: 20)
                        .fill(Color(teamId.dark))
                        .ignoresSafeArea()
                }
                .padding(.top, -19)
            
//            let statsViewModel = TeamStatsViewModel(team: viewModel.team)
            statsSummaryView(stats: statsViewModel)
            
            dividerWithBackground()
            
            //currentSeasonStats
            statsView(stats: statsViewModel.currentSeasonStats)
            
            //roster
            rosterView(roster: viewModel.guardsInRoster, position: "Guards")
                .padding(.top, 20)
            
            rosterView(roster: viewModel.forwardsInRoster, position: "Forwards")
                .padding(.top, 10)
            
            rosterView(roster: viewModel.centersInRoster, position: "Centers")
                .padding(.top, 10)
            
            if !viewModel.roster.isEmpty {
                BannerView(adUnitId: .teamView, paddingTop: 10, height: 100)
                    .padding(.bottom, 30)
            }
        }
        .background(Color(teamId.dark))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear() {
            guard !hasAppeared else { return }
            viewModel.fetchTeam(documentId: teamId)
            viewModel.fetchRoster(teamId: teamId)
            hasAppeared = true
        }
        .navigationBarTitle("", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 2) {
                    Image(teamId.teamIdToTriCode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                }
                .opacity(hideNavigationBar ? 0.0 : 1.0)
            }
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button {
//                    self.presentationMode.wrappedValue.dismiss()
//                } label: {
//                    Image("home")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 25, height: 25)
//                        .scaleEffect(1.2)
//                        .cornerRadius(12.5)
//                }
//                .buttonStyle(PlainButtonStyle())
//                .opacity(hideNavigationBar ? 0.0 : 1.0)
//            }
        }
        .onChange(of: scrollOffset, perform: { scrollOfset in
            let offset = scrollOfset + (self.hideNavigationBar ? 50 : 0) // note 1
            if offset > 60 { // note 2
                withAnimation(.easeIn(duration: 1), {
                    self.hideNavigationBar = false
                })
            }
            if offset < 50 {
                withAnimation(.easeIn(duration: 1), {
                    self.hideNavigationBar = true
                })
            }
        })
        .ignoresSafeArea()
    }
}

///https://stackoverflow.com/questions/62142773/hide-navigation-bar-on-scroll-in-swiftui
///Note 1: Assume that the height of the navigation title is 50. (This will change depending on the style.) When the nav bar dissapears, scroll offset drops by that height instantly. To keep the offset consistant add the height of the nav bar to the offset if it's hidden.
///Note 1: 제목 표시줄의 높이가 50이라고 가정합니다. (이는 스타일에 따라 변경될 수 있습니다.) 네비게이션 바가 사라질 때 스크롤 오프셋은 즉시 해당 높이만큼 감소합니다. 오프셋을 일관되게 유지하려면 네비게이션 바가 숨겨져 있다면 오프셋에 네비게이션 바의 높이를 추가하십시오.

///Note 2: I intentionally let a small difference between two thresholds for hiding and showing instead of using the same value, Because if the user scrolls and keep it in the threshold it won't flicker.
///Note 2: 나는 나타나고 숨기는 두 임계값 간에 작은 차이를 남겨두었는데, 동일한 값을 사용하는 대신 의도적으로 그렇게 했습니다. 사용자가 스크롤하고 그것을 임계값에서 유지하면 깜빡이지 않도록하기 위해서입니다.

extension TeamView {
    @ViewBuilder
    func statsView(stats: [TeamStatsItemViewModel]) -> some View {
        HStack {
            Text("OVERALL")
                .textStyle(color: .white.opacity(0.9), font: .system(size: 20), weight: .bold)
            Spacer()
        }
        .padding(.horizontal, 15)
        
        let layout = [
              GridItem(.flexible(maximum: 80)),
              GridItem(.flexible(maximum: 80)),
              GridItem(.flexible(maximum: 80)),
//              GridItem(.flexible(maximum: 80))
          ]
        
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: layout, spacing: 10) {
                ForEach(stats, id: \.self) { viewModel in
                    ZStack(alignment: .topLeading) {
                        LinearGradient(colors: viewModel.colors, startPoint: .topLeading, endPoint: .bottom)
                            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                        Text(viewModel.value)
                            .textStyle(color: .white.opacity(0.9), font: .system(size: 22, design: .rounded), weight: .semibold)
                            .padding(.top, 5)
                            .padding(.leading, 90)
                        Text(viewModel.title)
                            .textStyle(color: .white.opacity(0.8), font: .system(size: 13))
                            .padding(.leading, 5)
                            .padding(.top, 40)
                    }
                    .frame(width: 150, height: 60)
                }
            }
        }
        .padding(.horizontal, 10)
    }
}

extension TeamView {
    @ViewBuilder
    func rosterView(roster: [PlayerModel], position: String) -> some View {
        VStack(alignment: .leading) {
            Text(position)
                .textStyle(color: .white.opacity(0.9), font: .system(size: 20), weight: .bold)
                .padding(.horizontal, 5)
            
            ForEach(roster, id: \.self) { player in
                let viewModel = PlayerSummaryViewModel(player: player)
                NavigationLink(destination: PlayerView(playerId: viewModel.playerId, teamId: viewModel.teamId)) {
                    rosterItemView(viewModel: viewModel)
                    
//                    dividerWithBackground()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
    }
    
    @ViewBuilder
    func rosterItemView(viewModel: PlayerSummaryViewModel) -> some View {
        HStack(spacing: 0) {
            AsyncImage(url: URL(string: viewModel.smallImageUrl)) { image in
                image.resizable()
            } placeholder: {}
                .aspectRatio(contentMode: .fill)
                .background(Color(viewModel.teamNickName))
                .frame(width: 48, height: 48)
                .cornerRadius(24)
                .padding(5)
            
            VStack(alignment: .leading) {
                Text(viewModel.jerseyAndShortenPosition)
                    .foregroundColor(.white.opacity(0.8))
                    .font(.system(size: 14))
                
                Text(viewModel.fullName)
                    .foregroundColor(.white.opacity(0.9))
                    .font(.system(size: 14, weight: .semibold))
                    .minimumScaleFactor(0.8)
            }
            Spacer()
            
//            Text(viewModel.points)
//                .foregroundColor(.white)
//                .font(.system(size: 18, weight: .semibold))
//                .padding(.trailing, 10)
        }
        .padding(.bottom, 10)
        .padding(.horizontal, 5)
        .frame(height: 50)
        .frame(maxWidth: .infinity)
    }
}

extension TeamView {
    func dividerWithBackground() -> some View {
        Divider()
            .background(Color("#272628"))
            .opacity(0.9)
            .frame(height: 1.5)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 15)
    }
    
    @ViewBuilder
    func statItemView(title: String, value: String, rank: String) -> some View {
        VStack(alignment: .center) {
            Text(title)
                .padding(.horizontal, 5)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .background(Color("#5C5B60"))
            
            Text(value)
                .padding(2)
                .foregroundColor(.white.opacity(0.9))
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(rank)
                .padding(2)
                .foregroundColor(.white.opacity(0.8))
                .font(.caption)
                .fontWeight(.semibold)
        }
    }

    @ViewBuilder
    func statsSummaryView(stats: TeamStatsViewModel) -> some View {
        HStack {
            statItemView(title: stats.ppgTitle, value: stats.ppg, rank: stats.ppgRank)
                .padding(.leading, 20)
            Spacer()
            
            statItemView(title: stats.oppgTitle, value: stats.oppg, rank: stats.oppgRank)
            Spacer()
            
            statItemView(title: stats.rpgTitle, value: stats.rpg, rank: stats.rpgRank)
            Spacer()
            
            statItemView(title: stats.apgTitle, value: stats.apg, rank: stats.apgRank)
                .padding(.trailing, 20)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    StandingsView()
}
