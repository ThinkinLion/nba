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
        
        //admob
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        if Auth.isDeveloper() {
            GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "9c8f15e14cb4f8190750ea6d7b559c4d" ]
        }
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                StandingsView()
            }
        }
    }
}
