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
    
    private var viewState: PowerRankingViewModel.TeamDetailViewState {
        teamState.detailViewState
    }
    
    var body: some View {
        ObservableScrollView(scrollOffset: $scrollOffset) {
            // 헤더 섹션
            headerView()
            
            // Overview 섹션
            if let overview = viewState.overview, !overview.isEmpty {
                sectionView(title: "Overview", content: overview)
                    .padding(.top, 20)
            }
            
            // Takeaways 섹션
            if let takeaways = viewState.takeaways, !takeaways.isEmpty {
                takeawaysView(takeaways: takeaways)
                    .padding(.top, 20)
            }
            
            // Advanced Stats 섹션
            if let advanced = viewState.advanced {
                advancedStatsView(advanced: advanced)
                    .padding(.top, 20)
            }
            
            // Upcoming 섹션
            if let upcoming = viewState.upcoming, !upcoming.isEmpty {
                sectionView(title: "Upcoming", content: upcoming)
                    .padding(.top, 20)
            }
            
            BannerView(adUnitId: .teamView, paddingTop: 20, height: 100)
                .padding(.bottom, 30)
        }
        .background(backgroundColor)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarTitle("", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                if let triCode = viewState.triCode {
                    HStack(spacing: 2) {
                        Image(triCode)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                        Text(viewState.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
    
    private var backgroundColor: Color {
        Color(viewState.backgroundColorName)
    }
}

// MARK: - Header View
extension PowerRankingDetailView {
    @ViewBuilder
    func headerView() -> some View {
        ZStack(alignment: .topLeading) {
            Color.clear
            
            // 배경 로고
            if let triCode = viewState.triCode {
                Image(triCode)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(0.1)
                    .frame(width: 250, height: 250)
                    .scaleEffect(1.2)
                    .clipped()
                    .zIndex(0)
                
                VStack(alignment: .center, spacing: 12) {
                    Image(triCode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .clipped()
                    
                    Text(viewState.name)
                        .foregroundColor(.white)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 16) {
                        if let rank = viewState.rank {
                            VStack {
                                Text("RANK")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                                Text(rank)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        if let record = viewState.record {
                            VStack {
                                Text("RECORD")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                                Text(record)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        if let lastWeek = viewState.lastWeek, !lastWeek.isEmpty {
                            VStack {
                                Text("CHANGE")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                                rankChangeBadge(change: lastWeek)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 50)
                .zIndex(1)
            }
        }
        .frame(height: 280)
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        
        // 커스텀 코너로 다음 섹션과 연결
        Text("")
            .frame(maxWidth: .infinity)
            .frame(height: 20)
            .background {
                CustomCorner(corners: [.topLeft], radius: 20)
                    .fill(darkBackgroundColor)
                    .ignoresSafeArea()
            }
            .padding(.top, -19)
    }
    
    private var darkBackgroundColor: Color {
        let nickName = viewState.backgroundColorName
        return Color(nickName + ".dark")
    }
    
    @ViewBuilder
    func rankChangeBadge(change: String) -> some View {
        let changeValue = Int(change) ?? 0
        
        if changeValue > 0 {
            HStack(spacing: 4) {
                Image(systemName: "arrow.up")
                Text("\(changeValue)")
            }
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.green)
        } else if changeValue < 0 {
            HStack(spacing: 4) {
                Image(systemName: "arrow.down")
                Text("\(abs(changeValue))")
            }
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.red)
        } else {
            Image(systemName: "minus")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

// MARK: - Section Views
extension PowerRankingDetailView {
    @ViewBuilder
    func sectionView(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 15)
            
            Text(content)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .lineSpacing(4)
                .padding(.horizontal, 15)
        }
    }
    
    @ViewBuilder
    func takeawaysView(takeaways: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Takeaways".uppercased())
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 15)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(takeaways.enumerated()), id: \.offset) { index, takeaway in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.top, 2)
                        
                        Text(takeaway)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 15)
                }
            }
        }
    }
    
    @ViewBuilder
    func advancedStatsView(advanced: PowerRankingAdvancedModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Advanced Stats".uppercased())
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 15)
            
            VStack(spacing: 12) {
                if let defRtg = advanced.defRtg {
                    advancedStatRow(title: defRtg.title ?? "Def Rtg", value: defRtg.value ?? "", rank: defRtg.rank ?? "")
                }
                
                if let offRtg = advanced.offfRtg {
                    advancedStatRow(title: offRtg.title ?? "Off Rtg", value: offRtg.value ?? "", rank: offRtg.rank ?? "")
                }
                
                if let netRtg = advanced.netRtg {
                    advancedStatRow(title: netRtg.title ?? "Net Rtg", value: netRtg.value ?? "", rank: netRtg.rank ?? "")
                }
                
                if let pace = advanced.pace {
                    advancedStatRow(title: pace.title ?? "Pace", value: pace.value ?? "", rank: pace.rank ?? "")
                }
            }
            .padding(.horizontal, 15)
        }
    }
    
    @ViewBuilder
    func advancedStatRow(title: String, value: String, rank: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            HStack(spacing: 8) {
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                if !rank.isEmpty {
                    Text("(Rank: \(rank))")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(8)
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

