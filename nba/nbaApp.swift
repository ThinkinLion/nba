//
//  nbaApp.swift
//  nba
//
//  Created by 1100690 on 2023/11/07.
//

import SwiftUI
import GoogleMobileAds
import Firebase

@main
struct nbaApp: App {
  init() {
    if !Auth.isDeveloper() {
      print("isDeveloper not")
    }
    FirebaseApp.configure()
    
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
      NavigationView {
        PowerRankingView()
      }
    }
  }
}
