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
        FirebaseApp.configure()
        
        //admob
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    
    var body: some Scene {
        WindowGroup {
            StandingsView()
        }
    }
}
