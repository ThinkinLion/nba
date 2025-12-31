//
//  StandingsView.swift
//  nba
//
//  Created by 1100690 on 2023/11/13.
//

import SwiftUI
import FirebaseAnalytics

struct StandingsView: View {
    @StateObject var viewModel = StandingsViewModel()
    @StateObject var powerRankingViewModel = PowerRankingViewModel()
    @State private var selectedConference: Conference = .east
    @State private var displayMode: StandingsDisplayMode = .list
    @State private var hasAppeared = false
    
    enum Conference: String, CaseIterable {
        case east = "Eastern"
        case west = "Western"
        
        var color: Color {
            switch self {
            case .east: return Color(red: 0.0, green: 0.4, blue: 0.8) // Blue-ish
            case .west: return Color(red: 0.8, green: 0.1, blue: 0.1) // Red-ish
            }
        }
    }
    
    enum StandingsDisplayMode: String, CaseIterable {
        case list = "List"
        case playoff = "Playoff Picture"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header Timestamp
                if !viewModel.lastUpdated.isEmpty {
                    HStack {
                        Spacer()
                        Text("Updated: \(viewModel.lastUpdated)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                
                // Conference Toggle
                HStack(spacing: 0) {
                    ForEach(Conference.allCases, id: \.self) { conference in
                        Button(action: {
                            withAnimation(.spring()) {
                                selectedConference = conference
                            }
                        }) {
                            VStack(spacing: 10) {
                                Text(conference.rawValue)
                                    .font(.system(size: 16, weight: selectedConference == conference ? .bold : .semibold, design: .rounded))
                                    .foregroundColor(selectedConference == conference ? .white : .white.opacity(0.5))
                                
                                Rectangle()
                                    .fill(selectedConference == conference ? conference.color : Color.clear)
                                    .frame(height: 3)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 10)
                .background(Color.black.opacity(0.85))
                
                // Display Mode Picker REMOVED - Moved to Toolbar
                
                if displayMode == .list {
                    // List View Content
                    VStack(spacing: 0) {
                        // Table Header
                        HStack(spacing: 0) {
                            Text("")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.gray)
                                .frame(width: 30, alignment: .center)
                            
                            // Logo Space
                            Color.clear
                                .frame(width: 40, height: 1)
                            
                            Text("TEAM")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 8)
                            
                            Group {
                                Text("W")
                                    .frame(width: 35, alignment: .center)
                                Text("L")
                                    .frame(width: 35, alignment: .center)
                                Text("WIN%")
                                    .frame(width: 45, alignment: .center)
                                Text("GB")
                                    .frame(width: 40, alignment: .center)
                            }
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.gray)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color(white: 0.1))
                        
                        // Table List
                        LazyVStack(spacing: 0) {
                            let teams = selectedConference == .east ? (viewModel.east.0 + viewModel.east.1 + viewModel.east.2) : (viewModel.west.0 + viewModel.west.1 + viewModel.west.2)
                            
                            if teams.isEmpty {
                                if viewModel.errorMessage != nil {
                                    Text("Error loading data")
                                            .foregroundColor(.red)
                                            .padding(.top, 50)
                                    } else {
                                        ProgressView()
                                            .scaleEffect(1.5)
                                            .padding(.top, 50)
                                    }
                            } else {
                                ForEach(teams, id: \.self) { team in
                                    NavigationLink(destination: PowerRankingDetailView(teamState: createTeamState(from: team), viewModel: powerRankingViewModel)) {
                                        ratingsRow(team: team)
                                    }
                                    Divider().background(Color.white.opacity(0.1))
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                        
                        // Recent Games Section
                        if displayMode == .list && !viewModel.gameRecap.isEmpty {
                            VStack(spacing: 0) {
                                HStack {
                                    Text("Recent Games")
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 12)
                                
                                GameScoresView(games: viewModel.gameRecap)
                            }
                            .padding(.top, 20)
                            .padding(.bottom, 40)
                        }
                    }
                } else {
                    // Playoff Picture View
                    PlayoffPictureView(
                        eastTeams: (viewModel.east.0 + viewModel.east.1 + viewModel.east.2),
                        westTeams: (viewModel.west.0 + viewModel.west.1 + viewModel.west.2),
                        selectedConference: $selectedConference
                    )
                }
            }
        }
        .navigationBarTitle("Standings", displayMode: .large)
        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button(action: {
//                    withAnimation {
//                        displayMode = (displayMode == .list) ? .playoff : .list
//                    }
//                }) {
//                    Image(systemName: displayMode == .list ? "trophy.fill" : "list.bullet")
//                        .foregroundColor(.white)
//                }
//            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            if !hasAppeared {
                viewModel.fetchStandings()
                powerRankingViewModel.fetchPowerRankings() // Fetch latest rankings for detail view
                hasAppeared = true
            }
        }
        .analyticsScreen(name: "NBA-StandingsView")
    }
    
    @ViewBuilder
    func ratingsRow(team: StandingsTeam) -> some View {
        HStack(spacing: 0) {
            // Rank Indicator (Vertical Bar)
            if let rankInt = Int(team.confRank), rankInt <= 10 {
                Capsule()
                    .fill(rankIndicatorColor(rank: team.confRank))
                    .frame(width: 4, height: 24)
                    .padding(.trailing, 8)
            } else {
                Color.clear
                    .frame(width: 4, height: 24)
                    .padding(.trailing, 8)
            }
            
            // Rank (App Store Style: Large # on left)
            Text(team.confRank)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(rankColor(rank: team.confRank))
                .frame(width: 30, alignment: .center)
            
            // Team Logo (Rounded Square App Icon Style)
            let triCode = team.teamCode.nickNameToTriCode
            if RemoteConfigManager.shared.shouldUseOfficialTeamData, !triCode.isEmpty {
                Image(triCode)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 34, height: 34)
                    .background(Color(white: 0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .frame(width: 40, alignment: .center)
            } else {
                // Safe Mode: Edgy Watermark
                SafeModeLogoView(originalCode: team.teamCode, triCode: triCode)
                    .frame(width: 34, height: 34)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .frame(width: 40, alignment: .center)
            }
            
            // Team Name
            Text(team.teamName)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
                .padding(.leading, 8)
            
            // Stats Columns (Get Button Area equivalent)
            Group {
                Text(team.win)
                    .frame(width: 35, alignment: .center)
                    .foregroundColor(.white)
                
                Text(team.loss)
                    .frame(width: 35, alignment: .center)
                    .foregroundColor(.gray)
                
                Text(team.winPct)
                    .frame(width: 45, alignment: .center)
                    .foregroundColor(.gray)
                
                Text(team.gamesBehind)
                    .frame(width: 40, alignment: .center)
                    .foregroundColor(.gray)
            }
            .font(.system(size: 14, weight: .medium, design: .rounded))
        }
        .padding(.vertical, 12)
        // No background, just clean Row
    }
    
    func rankColor(rank: String) -> Color {
        guard let rankInt = Int(rank) else { return .white }
        if rankInt <= 10 { return .white } // Playoff & Play-in (Active)
        return .gray.opacity(0.5) // Lottery (Faded)
    }
    
    func rankIndicatorColor(rank: String) -> Color {
        guard let rankInt = Int(rank) else { return .clear }
        if rankInt <= 6 { return .green } // Guaranteed Playoff
        if rankInt <= 10 { return .yellow } // Play-in Tournament
        return .clear
    }
    
    // Helper to create TeamState from StandingsTeam
    func createTeamState(from team: StandingsTeam) -> TeamState {
        let triCode = team.teamCode.nickNameToTriCode
        let backgroundColorName = PowerRankingFormatter.makeBackgroundColorName(from: team.teamCode)
        
        // 1. Try to find the actual PowerRanking model for this team
        var realModel: PowerRankingTeamModel? = nil
        
        if let currentItems = powerRankingViewModel.currentPowerRanking?.items {
            // Match by ID
            if let match = currentItems.first(where: { $0.id == team.teamId }) {
                realModel = match
            }
            // Match by TriCode
            else if !triCode.isEmpty, let match = currentItems.first(where: { $0.teamCode == triCode || $0.teamCode?.nickNameToTriCode == triCode }) {
                realModel = match
            }
        }
        
        // 2. Use real model if found, otherwise fallback to dummy
        if let model = realModel {
            // Apply real data
             let rankChange = PowerRankingFormatter.makeRankChange(from: model.lastWeek)
             
             return TeamState(
                 id: model.id ?? team.teamId,
                 displayRank: Int(model.rank ?? "") ?? Int(team.confRank) ?? 0,
                 name: PowerRankingFormatter.makeDisplayName(from: model), // Use formatted name
                 record: model.record, // Use record from power ranking (might differ slightly if PR is older) OR override with live standings? Let's use live standings record for consistency with the list.
                 rankChangeText: rankChange.text,
                 rankChangeStyle: rankChange.style,
                 triCode: triCode.isEmpty ? nil : triCode,
                 backgroundColorName: backgroundColorName,
                 model: model
             )
        } else {
            // Fallback Dummy
            let dummyModel = PowerRankingTeamModel(
                id: team.teamId,
                rank: team.confRank,
                record: "\(team.win)-\(team.loss)",
                teamName: team.teamName,
                teamCode: team.teamCode,
                lastWeek: nil,
                advanced: nil,
                overview: nil,
                takeaways: nil,
                upcomming: nil
            )
            
            return TeamState(
                id: team.teamId,
                displayRank: Int(team.confRank) ?? 0,
                name: team.teamName,
                record: "\(team.win)-\(team.loss)",
                rankChangeText: "-",
                rankChangeStyle: .same,
                triCode: triCode.isEmpty ? nil : triCode,
                backgroundColorName: backgroundColorName,
                model: dummyModel
            )
        }
    }
}

// Preview
struct StandingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StandingsView()
        }
        .preferredColorScheme(.dark)
    }
}
