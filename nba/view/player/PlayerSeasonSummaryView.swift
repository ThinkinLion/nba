//
//  PlayerSeasonSummaryView.swift
//  nba
//
//  Created by ThinkinLion on 2026/10/27.
//

import SwiftUI

struct PlayerSeasonSummaryView: View {
    let player: PlayerSummaryViewModel
    
    private var currentSeasonTitle: String {
        "\(SeasonProvider.shared.seasonDisplayString()) SEASON AVERAGES"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 1. 헤더: 시즌 누적 명시 및 루키 뱃지
            HStack(spacing: 8) {
                Text(currentSeasonTitle)
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                    .tracking(0.6)
                
                if player.isRookie {
                    Text("ROOKIE")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(.black)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(red: 1.0, green: 0.84, blue: 0.0))
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                Text("공식 집계")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.45))
            }
            .padding(.horizontal, 16)
            
            // 2. 스탯 카드 그리드 (PPG, RPG, APG, PIE)
            HStack(spacing: 10) {
                SeasonStatCard(title: player.ppgTitle, value: player.ppg, color: .green)
                SeasonStatCard(title: player.rpgTitle, value: player.rpg, color: .blue)
                SeasonStatCard(title: player.apgTitle, value: player.apg, color: .orange)
                if !player.pie.isEmpty {
                    SeasonStatCard(title: player.pieTitle, value: player.pie, color: .purple)
                }
            }
            .padding(.horizontal, 16)
            
            // 3. 만약 시즌 공식 스탯이 아직 집계 전인 경우 친절한 안내 캡션
            if !player.hasSeasonStats {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                    Text("새 시즌 공식 경기 출전 후 누적 기록이 집계되어 업데이트됩니다.")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.horizontal, 16)
                .padding(.top, 2)
            }
        }
    }
}

struct SeasonStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    private var isDash: Bool {
        value == "-" || value.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
            
            Text(value)
                .font(.system(size: isDash ? 18 : 20, weight: .heavy, design: .rounded))
                .foregroundColor(isDash ? .white.opacity(0.5) : .white)
                .shadow(color: isDash ? Color.clear : color.opacity(0.4), radius: 5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.08), Color.white.opacity(0.02)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [color.opacity(0.7), color.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: color.opacity(0.15), radius: 4, x: 0, y: 2)
    }
}
