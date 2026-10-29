//
//  TeamPickerGridView.swift
//  nba
//
//  온보딩과 프로필 시트가 공유하는 30개 구단 선택 그리드
//

import SwiftUI

struct TeamPickerGridView: View {
    @Binding var selected: Set<String> // triCode
    var columns: Int = 4
    
    private var gridItems: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: columns)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            conferenceSection(title: "EASTERN CONFERENCE", teams: NBATeamCatalog.east)
            conferenceSection(title: "WESTERN CONFERENCE", teams: NBATeamCatalog.west)
        }
    }
    
    @ViewBuilder
    private func conferenceSection(title: String, teams: [NBATeamCatalogItem]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
                .tracking(0.8)
            
            LazyVGrid(columns: gridItems, spacing: 8) {
                ForEach(teams) { team in
                    TeamPickerTile(team: team, isSelected: selected.contains(team.triCode)) {
                        if selected.contains(team.triCode) {
                            selected.remove(team.triCode)
                        } else {
                            selected.insert(team.triCode)
                        }
                    }
                }
            }
        }
    }
}

struct TeamPickerTile: View {
    let team: NBATeamCatalogItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) { action() }
        }) {
            VStack(spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    teamLogo
                        .frame(width: 36, height: 36)
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .background(Circle().fill(Color(red: 1.0, green: 0.55, blue: 0.0)).padding(1))
                            .offset(x: 8, y: -6)
                    }
                }
                
                Text(team.triCode)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        isSelected
                        ? LinearGradient(colors: [Color(team.darkColorName).opacity(0.9), Color.black.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [Color.white.opacity(0.06), Color.white.opacity(0.03)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? Color.white.opacity(0.5) : Color.white.opacity(0.1), lineWidth: isSelected ? 1.5 : 1)
            )
            .scaleEffect(isSelected ? 1.0 : 0.97)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private var teamLogo: some View {
        if RemoteConfigManager.shared.shouldUseOfficialTeamData {
            Image(team.triCode)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            SafeModeLogoView(originalCode: team.nickname, triCode: team.triCode)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }
}
