//
//  PlayoffMainView.swift
//  nba
//

import SwiftUI

struct PlayoffMainView: View {
    @StateObject private var viewModel = PlayoffViewModel()
    @StateObject private var standingsViewModel = StandingsViewModel()
    @StateObject private var powerRankingViewModel = PowerRankingViewModel()
    @State private var selectedGameDateIndex = 0
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                playoffHeader
                
                StyledBannerContainer(adUnitId: .powerRanking)
                
                if viewModel.isLoading && viewModel.activeSeries.isEmpty {
                    loadingPlaceholder
                } else if viewModel.activeSeries.isEmpty {
                    emptyPlaceholder
                } else {
                    ForEach(viewModel.roundSections) { section in
                        PlayoffRoundSectionView(section: section, powerRankingViewModel: powerRankingViewModel)
                    }
                }
                
                if !standingsViewModel.gameRecap.isEmpty {
                    recentGamesBlock
                }
            }
            .padding(.bottom, 48)
        }
        .navigationBarHidden(true)
        .background(playoffBackground)
        .refreshable {
            await standingsViewModel.fetchStandingsAsync(forceRefresh: true)
            await powerRankingViewModel.fetchPowerRankings(forceRefresh: true)
            await viewModel.fetchAndBacktrackPlayoffs(
                standings: standingsViewModel.standings,
                precachedRecap: standingsViewModel.gameRecap,
                forceRefresh: true
            )
        }
        .onAppear {
            Task {
                await standingsViewModel.fetchStandingsAsync()
                await powerRankingViewModel.fetchPowerRankings()
                await viewModel.fetchAndBacktrackPlayoffs(
                    standings: standingsViewModel.standings,
                    precachedRecap: standingsViewModel.gameRecap
                )
            }
        }
    }
    
    private var playoffBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 0.06, green: 0.06, blue: 0.09),
                Color(red: 0.03, green: 0.03, blue: 0.05)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var playoffHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("NBA PLAYOFFS")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(.yellow.opacity(0.9))
                .tracking(4)
            
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(viewModel.currentYear)
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text("BRACKET")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.35))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 36)
    }
    
    private var loadingPlaceholder: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.yellow)
                .scaleEffect(1.2)
            Text("Loading series…")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }
    
    private var emptyPlaceholder: some View {
        VStack(spacing: 14) {
            Image(systemName: "sportscourt")
                .font(.system(size: 48))
                .foregroundStyle(.white.opacity(0.15))
            Text("No playoff series to show.")
                .font(.subheadline)
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 72)
    }
    
    private var recentGamesBlock: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 10) {
                Capsule()
                    .fill(Color.white.opacity(0.85))
                    .frame(width: 4, height: 22)
                Text("RECENT GAMES")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 20)
            
            GameScoresView(games: standingsViewModel.gameRecap, selectedIndex: $selectedGameDateIndex)
        }
    }
}

// MARK: - Round section

private struct PlayoffRoundSectionView: View {
    let section: PlayoffRoundSection
    @ObservedObject var powerRankingViewModel: PowerRankingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(section.sectionTitle)
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(.white)
                    .tracking(0.8)
                Spacer()
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                ForEach(section.matchups) { series in
                    PlayoffMatchupCard(series: series, stage: section.stage, powerRankingViewModel: powerRankingViewModel)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Card

private struct PlayoffMatchupCard: View {
    let series: PlayoffSeries
    let stage: PlayoffRoundStage
    @ObservedObject var powerRankingViewModel: PowerRankingViewModel
    
    private enum TeamSide {
        case away
        case home
    }
    
    private enum TeamOutcome {
        case winner
        case loser
        case undecided
    }
    
    private struct StageMetrics {
        let logoSize: CGFloat
        let teamFont: CGFloat
        let statusFont: CGFloat
        let vPadding: CGFloat
        let badge: String
    }
    
    private var bracketSide: PlayoffBracketSide {
        switch series.conference {
        case "East": return .east
        case "West": return .west
        case "Finals": return .finals
        default: return .undetermined
        }
    }
    
    private var metrics: StageMetrics {
        switch stage {
        case .finals:
            return StageMetrics(logoSize: 72, teamFont: 16, statusFont: 14, vPadding: 24, badge: "🏆 FINALS")
        case .conferenceFinals:
            return StageMetrics(logoSize: 52, teamFont: 14, statusFont: 12, vPadding: 16, badge: "CONF. FINALS")
        case .semifinals:
            return StageMetrics(logoSize: 44, teamFont: 12, statusFont: 11, vPadding: 12, badge: "ROUND 2")
        case .firstRound:
            return StageMetrics(logoSize: 38, teamFont: 11, statusFont: 10, vPadding: 10, badge: "ROUND 1")
        }
    }
    
    private var winnerTri: String? {
        guard series.isFinished else { return nil }
        let u = series.status.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if let r = u.range(of: #"^[A-Z]{2,3}(?=\s+WINS)"#, options: .regularExpression) {
            return String(u[r])
        }
        let away = normalizedTri(fromTeamCode: series.awayTeamCode)
        let home = normalizedTri(fromTeamCode: series.homeTeamCode)
        if u.contains("\(away) WINS") { return away }
        if u.contains("\(home) WINS") { return home }
        return nil
    }
    
    private func normalizedTri(fromTeamCode raw: String) -> String {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.count == 3 { return t.uppercased() }
        let tri = t.nickNameToTriCode
        return tri.isEmpty ? t.uppercased() : tri.uppercased()
    }
    
    private func outcome(for side: TeamSide) -> TeamOutcome {
        guard let winnerTri else { return .undecided }
        let away = normalizedTri(fromTeamCode: series.awayTeamCode)
        let home = normalizedTri(fromTeamCode: series.homeTeamCode)
        switch side {
        case .away: return winnerTri == away ? .winner : .loser
        case .home: return winnerTri == home ? .winner : .loser
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            sideAccent
                .frame(width: 5)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Spacer()
                    Text(metrics.badge)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.65))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.white.opacity(0.08)))
                }
                
                HStack(alignment: .center, spacing: 10) {
                    teamBlock(
                        teamId: series.awayTeamId,
                        code: series.awayTeamCode,
                        label: series.awayTeamName,
                        alignTrailing: false,
                        outcome: outcome(for: .away)
                    )
                    Text("@")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(.white.opacity(0.25))
                    teamBlock(
                        teamId: series.homeTeamId,
                        code: series.homeTeamCode,
                        label: series.homeTeamName,
                        alignTrailing: true,
                        outcome: outcome(for: .home)
                    )
                }
                
                Text(series.status)
                    .font(.system(size: metrics.statusFont, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.92))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 11, style: .continuous)
                            .fill(Color.black.opacity(0.42))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 11, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                
                if series.isFinished {
                    Text("SERIES COMPLETE")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(.white.opacity(0.35))
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                if !series.games.isEmpty {
                    gameResultsSection
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, metrics.vPadding)
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(cardStroke, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.35), radius: 10, y: 4)
    }
    
    private var gameResultsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider().background(Color.white.opacity(0.1))
                .padding(.vertical, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(series.games) { game in
                        NavigationLink(destination: GameRecapView(viewModel: HomeAwayViewModel(homeAway: game.homeAway), gameRecap: [])) {
                            gameResultChip(game: game)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
    
    private func gameResultChip(game: PlayoffGame) -> some View {
        let awayScore = Int(game.homeAway.away.score ?? "0") ?? 0
        let homeScore = Int(game.homeAway.home.score ?? "0") ?? 0
        let awayWon = awayScore > homeScore
        let homeWon = homeScore > awayScore
        
        let gameLabel: String = {
            if let text = game.homeAway.series, let range = text.range(of: #"^Games?\s*\d+"#, options: .regularExpression) {
                return String(text[range])
                    .replacingOccurrences(of: "Games", with: "G")
                    .replacingOccurrences(of: "Game", with: "G")
                    .replacingOccurrences(of: " ", with: "")
            }
            return "G"
        }()
        
        return HStack(spacing: 6) {
            Text(gameLabel)
                .font(.system(size: 9, weight: .black))
                .foregroundStyle(.white.opacity(0.4))
            
            HStack(spacing: 3) {
                Text("\(awayScore)")
                    .foregroundStyle(awayWon ? .yellow : .white.opacity(0.6))
                Text("-")
                    .foregroundStyle(.white.opacity(0.2))
                Text("\(homeScore)")
                    .foregroundStyle(homeWon ? .yellow : .white.opacity(0.6))
            }
            .font(.system(size: 10, weight: .bold, design: .monospaced))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.3))
        )
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    private var sideAccent: some View {
        RoundedRectangle(cornerRadius: 2, style: .continuous)
            .fill(accentColor)
    }
    
    private var accentColor: LinearGradient {
        switch bracketSide {
        case .east:
            return LinearGradient(colors: [.blue.opacity(0.95), .cyan.opacity(0.45)], startPoint: .top, endPoint: .bottom)
        case .west:
            return LinearGradient(colors: [.red.opacity(0.95), .orange.opacity(0.45)], startPoint: .top, endPoint: .bottom)
        case .finals:
            return LinearGradient(colors: [.yellow.opacity(0.95), .orange.opacity(0.55)], startPoint: .top, endPoint: .bottom)
        case .undetermined:
            return LinearGradient(colors: [Color.white.opacity(0.45), Color.white.opacity(0.15)], startPoint: .top, endPoint: .bottom)
        }
    }
    
    private var cardFill: LinearGradient {
        switch bracketSide {
        case .east:
            return LinearGradient(colors: [Color.blue.opacity(0.14), Color.black.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .west:
            return LinearGradient(colors: [Color.red.opacity(0.14), Color.black.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .finals:
            return LinearGradient(colors: [Color.yellow.opacity(0.12), Color.black.opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .undetermined:
            return LinearGradient(colors: [Color(white: 0.16), Color(white: 0.08)], startPoint: .top, endPoint: .bottom)
        }
    }
    
    private var cardStroke: Color {
        bracketSide == .finals ? .yellow.opacity(0.35) : .white.opacity(0.1)
    }
    
    @ViewBuilder
    private func teamBlock(teamId: String, code: String, label: String, alignTrailing: Bool, outcome: TeamOutcome) -> some View {
        let activeOpacity: Double = {
            switch outcome {
            case .winner, .undecided: return 1.0
            case .loser: return 0.45
            }
        }()
        let textColor: Color = {
            switch outcome {
            case .winner: return .white
            case .loser: return .gray
            case .undecided: return .white
            }
        }()
        
        let content = VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                Image(code.nickNameToTriCode)
                    .resizable()
                    .scaledToFit()
                    .frame(width: metrics.logoSize, height: metrics.logoSize)
                    .shadow(color: outcome == .winner ? .yellow.opacity(0.4) : .black.opacity(0.4), radius: 6, y: 2)
                
                if outcome == .winner {
                    Text("WINNER")
                        .font(.system(size: 8, weight: .black))
                        .foregroundColor(.black)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.yellow)
                        .cornerRadius(4)
                        .offset(x: 10, y: -5)
                }
            }
            
            HStack(spacing: 4) {
                if outcome == .winner {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.yellow)
                }
                
                Text(label)
                    .font(.system(size: metrics.teamFont, weight: .heavy))
                    .foregroundStyle(textColor)
            }
            .frame(maxWidth: .infinity, alignment: alignTrailing ? .trailing : .leading)
        }
        .opacity(activeOpacity)
        .frame(maxWidth: .infinity, alignment: alignTrailing ? .trailing : .leading)
        
        if !teamId.isEmpty {
            NavigationLink(destination: teamDestinationView(teamId: teamId, code: code)) {
                content
            }
            .buttonStyle(.plain)
        } else {
            content
        }
    }
    
    @ViewBuilder
    private func teamDestinationView(teamId: String, code: String) -> some View {
        let tri = normalizedTri(fromTeamCode: code)
        if let teamState = powerRankingViewModel.getTeamState(for: tri) {
            PowerRankingDetailView(teamState: teamState, viewModel: powerRankingViewModel)
        } else {
            TeamView(teamId: teamId)
        }
    }
}
