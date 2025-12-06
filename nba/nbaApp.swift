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
//      GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "fa144699d13077c7e0b5d8c2d008e311" ]
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
