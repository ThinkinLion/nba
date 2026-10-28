//
//  OnboardingView.swift
//  nba
//
//  첫 실행 1화면 온보딩: 응원 팀 선택 (복수). 선택한 팀은 Today 홈 피드·My Teams 의 기준이 됨.
//

import SwiftUI
import FirebaseAnalytics

struct OnboardingView: View {
    @ObservedObject private var favorites = FavoritesManager.shared
    @State private var selected: Set<String> = []
    
    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(colors: [Color(red: 0.08, green: 0.08, blue: 0.12), .black], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0))
                            Text("PICK YOUR TEAMS")
                                .font(.system(size: 12, weight: .heavy, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                                .tracking(1)
                        }
                        Text("Who do you root for?")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("Your teams' games, rankings and stars come first on Today. Pick as many as you like.")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.top, 36)
                    
                    TeamPickerGridView(selected: $selected)
                    
                    Spacer(minLength: 120)
                }
                .padding(.horizontal, 16)
            }
            
            // 하단 고정 버튼
            VStack(spacing: 10) {
                Button(action: continueTapped) {
                    Text(selected.isEmpty ? "Choose at least one team" : "Continue with \(selected.count) team\(selected.count > 1 ? "s" : "")")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(selected.isEmpty ? .white.opacity(0.4) : .black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(selected.isEmpty ? Color.white.opacity(0.1) : Color(red: 1.0, green: 0.84, blue: 0.0))
                        )
                }
                .disabled(selected.isEmpty)
                
                Button(action: skipTapped) {
                    Text("Skip for now")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.vertical, 6)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            .background(
                LinearGradient(colors: [.black.opacity(0), .black.opacity(0.9), .black], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            )
        }
        .preferredColorScheme(.dark)
        .analyticsScreen(name: "NBA-Onboarding")
    }
    
    private func continueTapped() {
        favorites.setFavoriteTeams(selected)
        favorites.completeOnboarding()
        Analytics.logEvent("onboarding_complete", parameters: ["team_count": selected.count, "teams": selected.sorted().joined(separator: ",")])
    }
    
    private func skipTapped() {
        favorites.completeOnboarding()
        Analytics.logEvent("onboarding_skip", parameters: nil)
    }
}

#Preview {
    OnboardingView()
}
