//
//  MovementView.swift
//  nba
//
//  Created by Antigravity on 12/09/24.
//

import SwiftUI

struct MovementView: View {
    let movement: PowerRankingMovementModel
    @ObservedObject var viewModel: PowerRankingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("MOVEMENT IN THE RANKINGS")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 15)
            
            HStack(alignment: .top, spacing: 15) {
                // High Jumps
                if let jumps = movement.highJumps, !jumps.isEmpty {
                    movementColumn(title: "HIGH JUMPS", items: jumps, color: .green, icon: "arrow.up")
                }
                
                // Free Falls
                if let falls = movement.freeFalls, !falls.isEmpty {
                    movementColumn(title: "FREE FALLS", items: falls, color: .red, icon: "arrow.down")
                }
            }
            .padding(.horizontal, 15)
        }
    }
    
    @ViewBuilder
    private func movementColumn(title: String, items: [PowerRankingMovementItemModel], color: Color, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                Text(title)
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundColor(color)
            
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element) { index, item in
                    if let teamName = item.team,
                       let teamState = viewModel.getTeamState(for: teamName) {
                        NavigationLink(destination: PowerRankingDetailView(teamState: teamState, viewModel: viewModel)) {
                            movementItemRow(item: item, color: color, isLast: index == items.count - 1)
                        }
                    } else {
                        movementItemRow(item: item, color: color, isLast: index == items.count - 1)
                    }
                }
            }
            .background(Color.fromHex("1C1C1E"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
    

    
    @ViewBuilder
    private func movementItemRow(item: PowerRankingMovementItemModel, color: Color, isLast: Bool) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(item.team?.uppercased() ?? "")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Spacer()
                
                Text(item.change ?? "")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
            }
            .padding(12)
            
            if !isLast {
                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.horizontal, 12)
            }
        }
    }
}

#Preview {
    let sampleMovement = PowerRankingMovementModel(
        highJumps: [
            PowerRankingMovementItemModel(team: "Boston", change: "+7"),
            PowerRankingMovementItemModel(team: "Brooklyn", change: "+4")
        ],
        freeFalls: [
            PowerRankingMovementItemModel(team: "Chicago", change: "-5"),
            PowerRankingMovementItemModel(team: "Milwaukee", change: "-3")
        ]
    )
    
    return NavigationView {
        ZStack {
            Color.black.ignoresSafeArea()
            MovementView(movement: sampleMovement, viewModel: PowerRankingViewModel())
        }
    }
}
