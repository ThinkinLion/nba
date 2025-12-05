//
//  PowerRankingDetailComponents.swift
//  nba
//
//  Created on 12/03/24.
//

import SwiftUI

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
                    AdvancedStatRow(title: offRtg.title ?? "Off Rtg", value: offRtg.value ?? "", rank: offRtg.rank ?? "")
                }
              
                if let defRtg = advanced.defRtg {
                    AdvancedStatRow(title: defRtg.title ?? "Def Rtg", value: defRtg.value ?? "", rank: defRtg.rank ?? "")
                }
                
                if let netRtg = advanced.netRtg {
                    AdvancedStatRow(title: netRtg.title ?? "Net Rtg", value: netRtg.value ?? "", rank: netRtg.rank ?? "")
                }
                
                if let pace = advanced.pace {
                    AdvancedStatRow(title: pace.title ?? "Pace", value: pace.value ?? "", rank: pace.rank ?? "")
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
    let style: PowerRankingViewModel.RankChangeStyle
    
    var body: some View {
        Text(text)
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(PowerRankingViewModel.rankChangeColor(for: style))
    }
}

struct MomentumView: View {
    let momentum: PowerRankingViewModel.TeamDetailViewState.MomentumState
    
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
