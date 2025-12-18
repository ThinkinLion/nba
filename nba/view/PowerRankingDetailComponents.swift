//
//  PowerRankingDetailComponents.swift
//  nba
//
//  Created on 12/03/24.
//

import SwiftUI

// MARK: - Safe Mode Placeholder
struct PlayerPlaceholderView: View {
    let jerseyNumber: String
    let color: Color
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.3), color.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(Circle().stroke(color.opacity(0.3), lineWidth: 1))
            
            Text(jerseyNumber)
                .font(.system(size: size * 0.4, weight: .heavy))
                .foregroundColor(.white.opacity(0.8))
                .shadow(color: color.opacity(0.5), radius: 5)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Enums
enum PowerRankingTab: Int, CaseIterable, Identifiable {
    case analysis = 0
    case stats = 1
    case roster = 2
    
    var id: Int { self.rawValue }
    
    var title: String {
        switch self {
        case .analysis: return "WEEKLY INSIGHTS"
        case .stats: return "TEAM STATS"
        case .roster: return "ROSTER"
        }
    }
}

// MARK: - Tab Picker
struct PowerRankingTabPicker: View {
    @Binding var selection: PowerRankingTab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(PowerRankingTab.allCases) { tab in
                VStack(spacing: 8) {
                    Text(tab.title)
                        .font(.system(size: 14, weight: selection == tab ? .bold : .medium))
                        .foregroundColor(selection == tab ? .white : .white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                    
                    // Indicator
                    Rectangle()
                        .fill(selection == tab ? Color.white : Color.clear)
                        .frame(height: 2)
                }
                .contentShape(Rectangle()) // Make clickable area better
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selection = tab
                    }
                }
            }
        }
        .padding(.horizontal, 15)
        .padding(.top, 10)
        .padding(.bottom, 0)
        .background(Color.clear) // Transparent background
    }
}

// MARK: - Shared Components for PowerRankingDetailView

struct PowerRankingDetailSectionView: View {
    let title: String
    let content: String
    
    var body: some View {
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
}

struct PowerRankingDetailTakeawaysView: View {
    let takeaways: [String]
    
    var body: some View {
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
}

struct PowerRankingDetailAdvancedStatsView: View {
    let advanced: PowerRankingAdvancedModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Advanced Stats".uppercased())
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 15)
            
            VStack(spacing: 12) {
                if let offRtg = advanced.offRtg {
                    VisualAdvancedStatRow(title: offRtg.title ?? "Off Rtg", value: offRtg.value ?? "", rank: offRtg.rank ?? "", color: .green)
                }
              
                if let defRtg = advanced.defRtg {
                    VisualAdvancedStatRow(title: defRtg.title ?? "Def Rtg", value: defRtg.value ?? "", rank: defRtg.rank ?? "", color: .red)
                }
                
                if let netRtg = advanced.netRtg {
                    VisualAdvancedStatRow(title: netRtg.title ?? "Net Rtg", value: netRtg.value ?? "", rank: netRtg.rank ?? "", color: .orange)
                }
                
                if let pace = advanced.pace {
                    VisualAdvancedStatRow(title: pace.title ?? "Pace", value: pace.value ?? "", rank: pace.rank ?? "", color: .blue)
                }
            }
            .padding(.horizontal, 15)
        }
    }
}

struct AdvancedStatRow: View {
    let title: String
    let value: String
    let rank: String
    
    var body: some View {
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

struct VisualAdvancedStatRow: View {
    let title: String
    let value: String
    let rank: String
    let color: Color
    
    private var progress: Double {
        // Rank 1 = 1.0 (Full), Rank 30 = 0.0 (Empty)
        // Formula: (31 - rank) / 30
        guard let rankInt = Int(rank) else { return 0.5 }
        return max(0.1, Double(31 - rankInt) / 30.0)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text(value)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    if !rank.isEmpty {
                        Text("#\(rank)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(color.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 6)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.7), color],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct PowerRankingDetailRankChangeBadge: View {
    let text: String
    let style: RankChangeStyle
    
    var body: some View {
        Text(text)
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(PowerRankingFormatter.rankChangeColor(for: style))
    }
}

struct MomentumView: View {
    let momentum: TeamDetailViewState.MomentumState
    
    var body: some View {
        VStack(spacing: 6) {
            Text("MOMENTUM")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
            
            HStack(spacing: 8) {
                Text(momentum.icon)
                    .font(.system(size: 16))
                
                Text(momentum.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(momentum.color)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(momentum.color.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct RadarChartView: View {
    let data: [Double] // 0.0 ~ 1.0 (Normalized Rank: 1st=1.0, 30th=0.0)
    let labels: [String]
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: size / 2, y: size / 2)
            let radius = size / 2 * 0.8 // 80% of available space
            
            ZStack {
                // Background Grid
                RadarChartGrid(count: data.count, radius: radius, center: center)
                
                // Axes & Labels
                RadarChartAxes(count: data.count, radius: radius, center: center, labels: labels)
                
                // Data
                RadarChartData(data: data, radius: radius, center: center, color: color)
            }
        }
        .frame(height: 200)
    }
}

struct RadarChartGrid: View {
    let count: Int
    let radius: CGFloat
    let center: CGPoint
    
    var body: some View {
        ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { scale in
            RadarPolygon(count: count, radius: radius * scale, center: center)
                .stroke(Color.white.opacity(0.3), lineWidth: 1) // Increased opacity
        }
    }
}

struct RadarChartAxes: View {
    let count: Int
    let radius: CGFloat
    let center: CGPoint
    let labels: [String]
    
    var body: some View {
        ForEach(0..<count, id: \.self) { index in
            RadarAxis(index: index, count: count, radius: radius, center: center)
                .stroke(Color.white.opacity(0.3), lineWidth: 1) // Increased opacity
            
            RadarLabel(text: labels[index], index: index, count: count, radius: radius, center: center)
        }
    }
}

struct RadarLabel: View {
    let text: String
    let index: Int
    let count: Int
    let radius: CGFloat
    let center: CGPoint
    
    var body: some View {
        let angle = (Double(index) / Double(count)) * 2 * .pi - .pi / 2
        let labelRadius = radius * 1.15
        let x = center.x + CGFloat(cos(angle)) * labelRadius
        let y = center.y + CGFloat(sin(angle)) * labelRadius
        
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(.white) // Full white
            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1) // Add shadow for contrast
            .position(x: x, y: y)
    }
}

struct RadarChartData: View {
    let data: [Double]
    let radius: CGFloat
    let center: CGPoint
    let color: Color
    
    var body: some View {
        ZStack {
            RadarDataPolygon(data: data, radius: radius, center: center)
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.9), color.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            RadarDataPolygon(data: data, radius: radius, center: center)
                .stroke(color, lineWidth: 3) // Thicker stroke
                .shadow(color: color, radius: 10, x: 0, y: 0) // Stronger glow
            
            ForEach(0..<data.count, id: \.self) { index in
                RadarDataPoint(value: data[index], index: index, count: data.count, radius: radius, center: center, color: color)
            }
        }
    }
}

struct RadarDataPoint: View {
    let value: Double
    let index: Int
    let count: Int
    let radius: CGFloat
    let center: CGPoint
    let color: Color
    
    var body: some View {
        let angle = (Double(index) / Double(count)) * 2 * .pi - .pi / 2
        let valueRadius = radius * value
        let x = center.x + CGFloat(cos(angle)) * valueRadius
        let y = center.y + CGFloat(sin(angle)) * valueRadius
        
        Circle()
            .fill(color)
            .frame(width: 6, height: 6)
            .position(x: x, y: y)
    }
}

struct RadarPolygon: Shape {
    let count: Int
    let radius: CGFloat
    let center: CGPoint
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        for i in 0..<count {
            let angle = (Double(i) / Double(count)) * 2 * .pi - .pi / 2
            let x = center.x + CGFloat(cos(angle)) * radius
            let y = center.y + CGFloat(sin(angle)) * radius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}

struct RadarAxis: Shape {
    let index: Int
    let count: Int
    let radius: CGFloat
    let center: CGPoint
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let angle = (Double(index) / Double(count)) * 2 * .pi - .pi / 2
        let x = center.x + CGFloat(cos(angle)) * radius
        let y = center.y + CGFloat(sin(angle)) * radius
        
        path.move(to: center)
        path.addLine(to: CGPoint(x: x, y: y))
        
        return path
    }
}

struct RadarDataPolygon: Shape {
    let data: [Double]
    let radius: CGFloat
    let center: CGPoint
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        for i in 0..<data.count {
            let angle = (Double(i) / Double(data.count)) * 2 * .pi - .pi / 2
            let valueRadius = radius * data[i]
            let x = center.x + CGFloat(cos(angle)) * valueRadius
            let y = center.y + CGFloat(sin(angle)) * valueRadius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}
// MARK: - Team Stats View


struct TeamStatsView: View {
    let viewState: TeamDetailViewState
    let advanced: PowerRankingAdvancedModel?
    let roster: [PlayerModel]
    let teamColor: Color
    let teamModel: TeamModel? // Restored

    // Helper to get stats
    private var currentSeasonStats: [TeamStats] {
        guard let teamModel = teamModel else { return [] }
        let targetSeason = "2025-26"
        
        if let seasonalStats = teamModel.seasonalStats,
           let currentSeason = seasonalStats.first(where: { $0.season == targetSeason }) {
            return currentSeason.stats
        } else if let legacyStats = teamModel.stats {
            return legacyStats
        }
        return []
    }
    
    var body: some View {
        VStack(spacing: 30) {
            
            // 1. Detailed Season Stats (Categorized)
            let stats = currentSeasonStats
            if !stats.isEmpty {
                CategorizedTeamStatsView(stats: stats, teamColor: teamColor)
            }
            
            // 2. Stat Kings (Leaders)
            if !roster.isEmpty {
                TeamLeadersView(roster: roster, teamColor: teamColor)
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 40)
    }
}

struct TeamLeadersView: View {
    let roster: [PlayerModel]
    let teamColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text("STAT LEADERS")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 15)
            
            LeaderRow(title: "POINTS", roster: roster, type: .points, color: .green)
            LeaderRow(title: "REBOUNDS", roster: roster, type: .rebounds, color: .blue)
            LeaderRow(title: "ASSISTS", roster: roster, type: .assists, color: .orange)
        }
    }
}

struct LeaderRow: View {
    let title: String
    let roster: [PlayerModel]
    let type: LeaderType
    let color: Color
    
    enum LeaderType {
        case points, rebounds, assists
    }
    
    var leaders: [PlayerModel] {
        let sorted: [PlayerModel]
        switch type {
        case .points:
            sorted = roster.sorted { ($0.ppg?.doubleValue ?? 0) > ($1.ppg?.doubleValue ?? 0) }
        case .rebounds:
            sorted = roster.sorted { ($0.rpg?.doubleValue ?? 0) > ($1.rpg?.doubleValue ?? 0) }
        case .assists:
            sorted = roster.sorted { ($0.apg?.doubleValue ?? 0) > ($1.apg?.doubleValue ?? 0) }
        }
        return Array(sorted.prefix(5))
    }
    
    func getValue(for player: PlayerModel) -> String {
        switch type {
        case .points: return player.ppg ?? "0.0"
        case .rebounds: return player.rpg ?? "0.0"
        case .assists: return player.apg ?? "0.0"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Circle().fill(color).frame(width: 6, height: 6)
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 15)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(leaders.enumerated()), id: \.element.id) { index, player in
                        LeaderCard(
                            rank: index + 1,
                            player: player,
                            value: getValue(for: player),
                            color: color
                        )
                    }
                }
                .padding(.horizontal, 15)
            }
        }
    }
}

struct LeaderCard: View {
    let rank: Int
    let player: PlayerModel
    let value: String
    let color: Color
    
    var body: some View {
        NavigationLink(destination: PlayerView(playerId: player.playerId ?? "", teamId: player.teamId ?? "")) {
            ZStack(alignment: .bottomLeading) {
                // Background
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.05))
                
                // Image (Enlarged & Background)
                GeometryReader { geo in
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            if RemoteConfigManager.shared.shouldUseOfficialTeamData, let playerId = player.playerId {
                                AsyncImage(url: URL(string: playerId.smallImageUrl)) { image in
                                    image.resizable().aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    Color.clear
                                }
                                .frame(height: 90) // Slightly smaller than RosterCard (100)
                                .offset(x: 10, y: 15)
                            } else {
                                PlayerPlaceholderView(jerseyNumber: player.jersey ?? "00", color: color, size: 70)
                                    .offset(x: 15, y: 15)
                            }
                        }
                    }
                }
                
                // Content
                VStack(alignment: .leading, spacing: 0) {
                    // Header (Rank & Value)
                    HStack(alignment: .top) {
                        Text("#\(rank)")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(color.opacity(0.8))
                        
                        Spacer()
                        
                        Text(value)
                            .font(.system(size: 18, weight: .bold)) // Slightly smaller to fit
                            .foregroundColor(.white)
                    }
                    .padding(10)
                    
                    Spacer()
                    
                    // Name Info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(player.firstName?.uppercased() ?? "")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        Text(player.lastName?.uppercased() ?? "")
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        CustomCorner(corners: [.bottomLeft, .bottomRight], radius: 12)
                            .fill(LinearGradient(colors: [.black.opacity(0.8), .clear], startPoint: .bottom, endPoint: .top))
                    )
                }
            }
            .frame(width: 130, height: 110)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(LinearGradient(colors: [color.opacity(0.5), color.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
            )
        }
    }
}

// Float conversion helper
extension String {
    var doubleValue: Double {
        Double(self) ?? 0.0
    }
}
// MARK: - Team Roster View


struct TeamRosterView: View {
    let roster: [PlayerModel]
    
    // Sort Roster: Key Players first (if any logic), then by PPG descending
    var sortedRoster: [PlayerModel] {
        roster.sorted { ($0.ppg?.doubleValue ?? 0) > ($1.ppg?.doubleValue ?? 0) }
    }
    
    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 15)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Full Roster".uppercased())
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 15)
            
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(sortedRoster, id: \.id) { player in
                    NavigationLink(destination: PlayerView(playerId: player.playerId ?? "", teamId: player.teamId ?? "")) {
                        RosterPlayerCard(player: player)
                    }
                }
            }
            .padding(.horizontal, 15)
            .padding(.bottom, 40)
        }
        .padding(.top, 20)
    }
}

struct RosterPlayerCard: View {
    let player: PlayerModel
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.05))
            
            // Image (Positioned absolutely in ZStack to allow overlap and larger size)
            GeometryReader { geo in
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        if RemoteConfigManager.shared.shouldUseOfficialTeamData, let playerId = player.playerId {
                            AsyncImage(url: URL(string: playerId.smallImageUrl)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                Color.clear
                            }
                            .frame(height: 100) // Enlarged Image
                            .offset(x: 10, y: 10) // Push slightly right/down
                        } else {
                            PlayerPlaceholderView(jerseyNumber: player.jersey ?? "00", color: .white.opacity(0.3), size: 80)
                                 .offset(x: 20, y: 20)
                        }
                    }
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 0) {
                // Header (Number & Pos)
                HStack {
                    Text(player.jersey ?? "#")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                    Text(player.position ?? "")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(4)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(10)
                
                Spacer()
                
                // Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(player.firstName ?? "")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    Text(player.lastName ?? "")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    // Key Stats
                    HStack(spacing: 4) {
                        Text("P: \(player.ppg ?? "-")")
                        Text("•")
                            .opacity(0.3)
                        Text("R: \(player.rpg ?? "-")")
                        Text("•")
                            .opacity(0.3)
                        Text("A: \(player.apg ?? "-")")
                    }
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.top, 2)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    CustomCorner(corners: [.bottomLeft, .bottomRight], radius: 12)
                        .fill(LinearGradient(colors: [.black.opacity(0.8), .clear], startPoint: .bottom, endPoint: .top))
                )
            }
        }
        .frame(height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}
