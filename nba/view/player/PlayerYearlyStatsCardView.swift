//
//  PlayerYearlyStatsCardView.swift
//  nba
//
//

import SwiftUI

struct PlayerYearlyStatsCardView<T: StatsGeneratable & Hashable>: View {
    let title: String
    let stats: [T]
    let teamId: String
    
    // 유효한 스탯(헤더 외에 실제 수치가 1개 이상 존재하는 항목)을 가진 카드 목록만 필터링
    private var validSeasonCards: [(index: Int, items: [PlayerStatsItemViewModel])] {
        stats.enumerated().compactMap { index, stat in
            let items = stat.createStatsItemViewModels(teamId: teamId)
            let validStatRows = items.dropFirst().filter {
                !$0.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && $0.value != "-"
            }
            // 유효한 스탯 수치가 1개 이상 있을 때만 카드 허용
            guard !validStatRows.isEmpty else { return nil }
            return (index, items)
        }
    }
    
    var body: some View {
        // 스마트 숨김: 표시할 유효 카드가 없으면 섹션 타이틀 자체를 렌더링하지 않음
        if !validSeasonCards.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                // Section Title
                HStack {
                    Rectangle()
                        .fill(Color(teamId.light))
                        .frame(width: 4, height: 18)
                    
                    Text(title.uppercased())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.horizontal, 15)
                
                // Horizontal Scroll of Stats Cards
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(validSeasonCards, id: \.index) { item in
                            StatSeasonCard(items: item.items, teamId: teamId)
                        }
                    }
                    .padding(.horizontal, 15)
                }
            }
            .padding(.vertical, 10)
        }
    }
}

struct StatSeasonCard: View {
    let items: [PlayerStatsItemViewModel]
    let teamId: String
    
    // 값이 비어있지 않은 유효한 스탯 항목만 노출 (스마트 숨김)
    private var validStats: [PlayerStatsItemViewModel] {
        items.dropFirst().filter {
            !$0.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && $0.value != "-"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header (Year & Team of that season)
            if let firstItem = items.first {
                let teamTriCode = firstItem.title
                let year = firstItem.value
                let cardTeamId = teamTriCode.triCodeToTeamId
                let headerColor = cardTeamId.isEmpty ? Color(teamId.dark) : Color(cardTeamId.dark)
                
                HStack(spacing: 4) {
                    if teamTriCode == "TOT" {
                        Text("TOTAL")
                            .font(.system(size: 9, weight: .heavy, design: .rounded))
                            .foregroundColor(.white.opacity(0.95))
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Capsule())
                    } else if !teamTriCode.isEmpty {
                        HStack(spacing: 3) {
                            if RemoteConfigManager.shared.shouldUseOfficialTeamData {
                                Image(teamTriCode)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 13, height: 13)
                            }
                            Text(teamTriCode)
                                .font(.system(size: 10, weight: .black, design: .rounded))
                                .foregroundColor(.white.opacity(0.95))
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                        }
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.black.opacity(0.45))
                        .clipShape(Capsule())
                    }
                    
                    Spacer(minLength: 4)
                    
                    Text(year) // Season Year
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 7)
                .background(headerColor.opacity(0.75))
            }
            
            Divider().background(Color.white.opacity(0.1))
            
            // Stats Grid (유효한 스탯만 스마트하게 렌더링 - 빈 타이틀 노출 방지)
            VStack(spacing: 8) {
                ForEach(validStats, id: \.title) { item in
                    HStack {
                        Text(item.title)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Spacer()
                        
                        Text(item.value)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
            }
            .padding(12)
        }
        .frame(width: 146)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}
