//
//  PlayoffMainView.swift
//  nba
//

import SwiftUI

struct PlayoffMainView: View {
    @StateObject private var viewModel = PlayoffViewModel()
    @StateObject private var standingsViewModel = StandingsViewModel()
    @State private var selectedGameDateIndex = 0
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                playoffHeader
                
                if viewModel.isLoading && viewModel.activeSeries.isEmpty {
                    loadingPlaceholder
                } else if viewModel.activeSeries.isEmpty {
                    emptyPlaceholder
                } else {
                    ForEach(viewModel.roundSections) { section in
                        PlayoffRoundSectionView(section: section)
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
            await viewModel.fetchAndBacktrackPlayoffs(
                standings: standingsViewModel.standings,
                precachedRecap: standingsViewModel.gameRecap,
                forceRefresh: true
            )
        }
        .onAppear {
            Task {
                await standingsViewModel.fetchStandingsAsync()
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(section.sectionTitle)
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(.white)
                    .tracking(0.8)
                Spacer()
                Text("\(section.matchups.count)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.35))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.white.opacity(0.08)))
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                ForEach(section.matchups) { series in
                    PlayoffMatchupCard(series: series)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Card

private struct PlayoffMatchupCard: View {
    let series: PlayoffSeries
    
    private var bracketSide: PlayoffBracketSide {
        switch series.conference {
        case "East": return .east
        case "West": return .west
        case "Finals": return .finals
        default: return .undetermined
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            sideAccent
                .frame(width: 5)
            
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center, spacing: 10) {
                    teamBlock(code: series.awayTeamCode, label: series.awayTeamName, alignTrailing: false)
                    Text("@")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(.white.opacity(0.25))
                    teamBlock(code: series.homeTeamCode, label: series.homeTeamName, alignTrailing: true)
                }
                
                Text(series.status)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.92))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
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
            }
            .padding(14)
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
    
    private func teamBlock(code: String, label: String, alignTrailing: Bool) -> some View {
        VStack(spacing: 8) {
            Image(code.nickNameToTriCode)
                .resizable()
                .scaledToFit()
                .frame(width: 46, height: 46)
                .shadow(color: .black.opacity(0.4), radius: 6, y: 2)
            Text(label)
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(.white)
                .multilineTextAlignment(alignTrailing ? .trailing : .leading)
                .frame(maxWidth: .infinity, alignment: alignTrailing ? .trailing : .leading)
        }
        .frame(maxWidth: .infinity, alignment: alignTrailing ? .trailing : .leading)
    }
}
