//
//  nbaApp.swift
//  nba
//
//  Created by 1100690 on 2023/11/07.
//

import SwiftUI
import GoogleMobileAds
import Firebase
import FirebaseAnalytics

@main
struct nbaApp: App {
  @ObservedObject var remoteConfig: RemoteConfigManager
  @ObservedObject private var favorites = FavoritesManager.shared
  
  init() {
    if !Auth.isDeveloper() {
      print("isDeveloper not")
    }
    FirebaseApp.configure()
    
    // Disable Firebase Analytics when testing on a developer device
    if Auth.isDeveloper() {
        Analytics.setAnalyticsCollectionEnabled(false)
    }
    
    self._remoteConfig = ObservedObject(wrappedValue: RemoteConfigManager.shared)
    
    // Remote Config Fetch
    RemoteConfigManager.shared.fetchConfig { _ in }
    
    //admob
    GADMobileAds.sharedInstance().start(completionHandler: nil)
    if Auth.isDeveloper() {
      GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "838570ef2bf4d08fc725db87ed957edf" ]
    }
  }
  
  @State private var selectedTab: Int = {
    let args = ProcessInfo.processInfo.arguments
    if args.contains("-screenshot-standings") {
      return 2
    } else if args.contains("-screenshot-powerranking") {
      return 1
    } else if args.contains("-screenshot-games") {
      return 0
    }
    return 0
  }()
  private var isTeamScreenshot: Bool = ProcessInfo.processInfo.arguments.contains("-screenshot-team")
  // 선수 상세 화면 바로 진입 (레이아웃 검증/스크린샷용): -screenshot-player [playerId] [teamId]
  private var isPlayerScreenshot: Bool = ProcessInfo.processInfo.arguments.contains("-screenshot-player")
  private var screenshotPlayerId: String {
    let args = ProcessInfo.processInfo.arguments
    guard let idx = args.firstIndex(of: "-screenshot-player"), args.count > idx + 1 else { return "1641705" }
    return args[idx + 1]
  }
  private var screenshotTeamId: String {
    let args = ProcessInfo.processInfo.arguments
    guard let idx = args.firstIndex(of: "-screenshot-player"), args.count > idx + 2 else { return "1610612759" }
    return args[idx + 2]
  }
  
  var body: some Scene {
    WindowGroup {
      if isTeamScreenshot {
        NavigationView {
          TeamView(teamId: "1610612759")
        }
        .navigationViewStyle(.stack)
        .accentColor(.white)
      } else if isPlayerScreenshot {
        NavigationView {
          PlayerView(playerId: screenshotPlayerId, teamId: screenshotTeamId)
        }
        .navigationViewStyle(.stack)
        .accentColor(.white)
      } else {
        TabView(selection: $selectedTab) {
          // Tab 0: Today (개인화 홈 피드: My Teams, 경기, POTN, Movers, League Leaders)
          NavigationView {
            TodayView()
          }
          .navigationViewStyle(.stack)
          .tabItem {
              Image(systemName: "basketball.fill")
              Text("Today")
          }
          .tag(0)
          
          // Tab 1: Power Ranking (주간 공식 파워랭킹, 마이팀 핀, 분석글)
          NavigationView {
            PowerRankingView()
          }
          .navigationViewStyle(.stack)
          .tabItem {
              Image(systemName: "bolt.fill")
              Text("Power Ranking")
          }
          .tag(1)
          
          // Tab 2: Standings (컨퍼런스 순위표, 승률, 플레이오프 시드)
          NavigationView {
            StandingsView()
          }
          .navigationViewStyle(.stack)
          .tabItem {
              Image(systemName: "list.number")
              Text("Standings")
          }
          .tag(2)
        }
        .accentColor(.white)
        // 첫 실행 온보딩: 응원 팀 선택 (스크린샷 모드에서는 생략)
        .fullScreenCover(isPresented: Binding(
          get: { !favorites.hasCompletedOnboarding && !isScreenshotMode },
          set: { _ in }
        )) {
          OnboardingView()
        }
      }
    }
  }
  
  private var isScreenshotMode: Bool {
    ProcessInfo.processInfo.arguments.contains { $0.hasPrefix("-screenshot") }
  }
}
