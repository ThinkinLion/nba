//
//  ProfileSheetView.swift
//  nba
//
//  Today 우상단 프로필 버튼 → 관심 팀·선수 관리 시트 (별도 탭/사이드메뉴 없이 개인화 설정을 한 곳에)
//

import SwiftUI
import FirebaseAnalytics

struct ProfileSheetView: View {
    @ObservedObject private var favorites = FavoritesManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTeams: Set<String> = []
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    // MY PLAYERS
                    VStack(alignment: .leading, spacing: 10) {
                        sectionHeader(icon: "person.fill", title: "MY PLAYERS", count: favorites.favoritePlayers.count)
                        if favorites.favoritePlayers.isEmpty {
                            hintRow(icon: "star", text: "Tap ☆ on any player page to follow them. Their games and league ranks show up on Today.")
                        } else {
                            VStack(spacing: 8) {
                                ForEach(favorites.favoritePlayers) { player in
                                    playerRow(player)
                                }
                            }
                        }
                    }
                    
                    // MY TEAMS
                    VStack(alignment: .leading, spacing: 10) {
                        sectionHeader(icon: "star.fill", title: "MY TEAMS", count: selectedTeams.count)
                        TeamPickerGridView(selected: $selectedTeams)
                    }
                    
                    Spacer(minLength: 30)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationBarTitle("My Hoop", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0))
                }
            }
        }
        .navigationViewStyle(.stack)
        .preferredColorScheme(.dark)
        .onAppear { selectedTeams = favorites.favoriteTeamCodes }
        .onChange(of: selectedTeams) { newValue in
            favorites.setFavoriteTeams(newValue)
            Analytics.logEvent("favorite_teams_update", parameters: ["team_count": newValue.count])
        }
        .analyticsScreen(name: "NBA-ProfileSheet")
    }
    
    @ViewBuilder
    private func sectionHeader(icon: String, title: String, count: Int) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0))
            Text(title)
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
                .tracking(0.8)
            if count > 0 {
                Text("\(count)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 1)
                    .background(Color(red: 1.0, green: 0.84, blue: 0.0))
                    .clipShape(Capsule())
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    private func hintRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.yellow.opacity(0.8))
                .frame(width: 32, height: 32)
                .background(Circle().fill(Color.white.opacity(0.08)))
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.white.opacity(0.1), lineWidth: 1))
        )
    }
    
    @ViewBuilder
    private func playerRow(_ player: FavoritePlayer) -> some View {
        HStack(spacing: 10) {
            if RemoteConfigManager.shared.shouldUseOfficialTeamData {
                Image(player.teamTriCode)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(player.name)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(player.teamTriCode)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
            }
            Spacer()
            Button(action: {
                favorites.removeFavoritePlayer(id: player.id)
                Analytics.logEvent("favorite_player_remove", parameters: ["player_id": player.id])
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(Color.white.opacity(0.08)))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(player.teamId.dark).opacity(0.35))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.white.opacity(0.1), lineWidth: 1))
        )
    }
}
