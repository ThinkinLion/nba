
import SwiftUI

// MARK: - Categorized Team Stats View
struct CategorizedTeamStatsView: View {
    let stats: [TeamStats]
    let teamColor: Color
    
    // Categorized Stats
    var overallStats: [TeamStats] {
        stats.filter { $0.title?.contains("202") == true || $0.title?.lowercased().contains("overall") == true }
    }
    
    var locationStats: [TeamStats] {
        stats.filter { ["home", "road", "away"].contains($0.title?.lowercased() ?? "") }
    }
    
    var outcomeStats: [TeamStats] {
        stats.filter { ["wins", "losses", "won", "lost"].contains($0.title?.lowercased() ?? "") }
    }
    
    var monthStats: [TeamStats] {
        let months = ["oct", "nov", "dec", "jan", "feb", "mar", "apr", "may", "jun"]
        return stats.filter { stat in
            months.contains(where: { stat.title?.lowercased().hasPrefix($0) == true })
        }
    }
    
    var restStats: [TeamStats] {
        stats.filter { $0.title?.lowercased().contains("days rest") == true }
    }
    
    var allStarStats: [TeamStats] {
        stats.filter { $0.title?.lowercased().contains("all-star") == true }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            // 1. Overall Season
            if !overallStats.isEmpty {
                StatsSectionView(title: "SEASON SUMMARY", stats: overallStats, color: teamColor)
            }
            
            // 2. Location (Home/Away)
            if !locationStats.isEmpty {
                StatsSectionView(title: "BY LOCATION", stats: locationStats, color: teamColor)
            }
            
            // 3. Outcome (Wins/Losses)
            if !outcomeStats.isEmpty {
                StatsSectionView(title: "BY OUTCOME", stats: outcomeStats, color: teamColor)
            }
            
            // 4. Monthly Breakdown
            if !monthStats.isEmpty {
                StatsSectionView(title: "MONTHLY BREAKDOWN", stats: monthStats, color: teamColor)
            }
            
            // 5. Rest Days
            if !restStats.isEmpty {
                StatsSectionView(title: "BY DAYS REST", stats: restStats, color: teamColor)
            }
            
             // 6. Pre/Post All-Star
            if !allStarStats.isEmpty {
                StatsSectionView(title: "ALL-STAR BREAK", stats: allStarStats, color: teamColor)
            }
        }
    }
}

// MARK: - Components

struct StatsSectionView: View {
    let title: String
    let stats: [TeamStats]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 14, weight: .bold)) // Section Header
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 15)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(stats, id: \.id) { stat in
                        DetailedStatCard(stat: stat, color: color)
                    }
                }
                .padding(.horizontal, 15)
            }
        }
    }
}

struct DetailedStatCard: View {
    let stat: TeamStats
    let color: Color
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(stat.title?.uppercased() ?? "STATS")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(.white)
                Spacer()
                if let gp = stat.gp, gp != "0", !gp.isEmpty {
                     Text("\(gp) GP")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            .padding(12)
            .background(color.opacity(0.8)) // Header Background
            
            // Stats Content
            VStack(spacing: 12) {
                
                // Row 1: Record & Key
                HStack(spacing: 0) {
                    StatVerticalBox(label: "W-L", value: "\(stat.win ?? "0")-\(stat.loss ?? "0")", isBold: true)
                    Divider().background(Color.white.opacity(0.1))
                    StatVerticalBox(label: "WIN%", value: stat.wp ?? "-", isBold: true)
                    Divider().background(Color.white.opacity(0.1))
                    StatVerticalBox(label: "+/-", value: stat.pm ?? "-", isBold: true)
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                // Row 2: Scoring & Shooting
                 HStack(spacing: 0) {
                    StatVerticalBox(label: "PTS", value: stat.pts ?? "-", highlight: true)
                    StatVerticalBox(label: "FG%", value: stat.fgp ?? "-")
                    StatVerticalBox(label: "3P%", value: stat.tpp ?? "-")
                    StatVerticalBox(label: "FT%", value: stat.ftp ?? "-")
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                // Row 3: Rebounding
                HStack(spacing: 0) {
                    StatVerticalBox(label: "REB", value: stat.reb ?? "-", highlight: true)
                    StatVerticalBox(label: "OREB", value: stat.oreb ?? "-")
                    StatVerticalBox(label: "DREB", value: stat.dreb ?? "-")
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                // Row 4: Playmaking & Defense
                 HStack(spacing: 0) {
                    StatVerticalBox(label: "AST", value: stat.ast ?? "-", highlight: true)
                    StatVerticalBox(label: "TOV", value: stat.tov ?? "-")
                    StatVerticalBox(label: "STL", value: stat.stl ?? "-")
                    StatVerticalBox(label: "BLK", value: stat.blk ?? "-")
                }
            }
            .padding(12)
            .background(Color.black.opacity(0.2)) // Slightly darker content background
        }
        .frame(width: 280) // Wider card for detailed info
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(LinearGradient(colors: [color.opacity(0.5), color.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct StatVerticalBox: View {
    let label: String
    let value: String
    var isBold: Bool = false
    var highlight: Bool = false
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
            
            Text(value)
                .font(.system(size: 13, weight: isBold || highlight ? .heavy : .medium))
                .foregroundColor(highlight ? .yellow : .white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
}
