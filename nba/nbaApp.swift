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
  
  var body: some Scene {
    WindowGroup {
      if remoteConfig.shouldUseOfficialTeamData {
          // Multi-tab Mode
          TabView {
            NavigationView {
              PlayoffMainView()
            }
            .tabItem {
                Image(systemName: "trophy.fill")
                Text("Playoffs")
            }
            
            NavigationView {
              PowerRankingView()
            }
            .tabItem {
                Image(systemName: "bolt.fill")
                Text("Power Ranking")
            }
            
            NavigationView {
              StandingsView()
            }
            .tabItem {
                Image(systemName: "list.number")
                Text("Standings")
            }
          }
          .accentColor(.white)
      } else {
          // Single-view Mode (Legacy)
          NavigationView {
              PowerRankingView()
          }
      }
    }
  }
}
