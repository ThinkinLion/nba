//
//  TeamsOfTheWeekView.swift
//  nba
//
//  Created by Antigravity on 12/09/24.
//

import SwiftUI

struct TeamsOfTheWeekView: View {
    let teams: [PowerRankingTeamOfTheWeekModel]
    @ObservedObject var viewModel: PowerRankingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("TEAMS OF THE WEEK")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 15)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 15) {
                    ForEach(teams, id: \.self) { team in
                        if let teamName = team.team,
                           let teamState = viewModel.getTeamState(for: teamName) {
                            NavigationLink(destination: PowerRankingDetailView(teamState: teamState, viewModel: viewModel)) {
                                teamCard(team)
                            }
                        } else {
                            teamCard(team)
                        }
                    }
                }
                .padding(.horizontal, 15)
            }
        }
    }
    
    @ViewBuilder
    private func teamCard(_ team: PowerRankingTeamOfTheWeekModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category Badge
            Text(team.category?.uppercased() ?? "")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(categoryColor(for: team.category))
                .cornerRadius(4)
            
            // Team & Record
            HStack {
                Text(team.team?.uppercased() ?? "")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(team.record ?? "")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // Description
            Text(team.description ?? "")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(4)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(width: 280)
        .background(
            LinearGradient(
              colors: [Color.fromHex("1C1C1E"), Color.fromHex("2C2C2E")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    private func categoryColor(for category: String?) -> Color {
        guard let category = category else { return .white }
        
        // Specific category colors
        let lowercasedCategory = category.lowercased()
        if lowercasedCategory.contains("make it last") {
            return .green // or colorFromHex("2ECC71")
        } else if lowercasedCategory.contains("something just") && lowercasedCategory.contains("right") {
            return .red // or colorFromHex("FF3B30")
        }
        
        // Simple hash-based color generation or predefined mapping
        let colors: [Color] = [
            Color.fromHex("FFD700"), // Gold
            Color.fromHex("00FFFF"), // Cyan
            Color.fromHex("FF69B4"), // Hot Pink
            Color.fromHex("7FFF00"), // Chartreuse
            Color.fromHex("FF4500"), // Orange Red
            Color.fromHex("1E90FF")  // Dodger Blue
        ]
        
        // Use the sum of character ascii values to pick a color
        let sum = category.utf8.reduce(0) { $0 + Int($1) }
        return colors[sum % colors.count]
    }
    

}

#Preview {
    let sampleTeams = [
        PowerRankingTeamOfTheWeekModel(
            category: "Make It Last Forever",
            team: "Boston",
            record: "4-0",
            description: "The Celtics occupy this space for the second straight week, because they keep beating good teams."
        ),
        PowerRankingTeamOfTheWeekModel(
            category: "Something Just Ain't Right",
            team: "Chicago",
            record: "0-4",
            description: "The Bulls occupy this space for the second straight week, because they keep losing to bad ones."
        )
    ]
    
    return NavigationView {
        ZStack {
            Color.black.ignoresSafeArea()
            TeamsOfTheWeekView(teams: sampleTeams, viewModel: PowerRankingViewModel())
        }
    }
}
