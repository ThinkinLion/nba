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

struct PowerRankingDetailRankChangeBadge: View {
    let text: String
    let style: PowerRankingViewModel.RankChangeStyle
    
    var body: some View {
        Text(text)
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(PowerRankingViewModel.rankChangeColor(for: style))
    }
}
