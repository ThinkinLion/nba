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
            if Auth.UUID() == "F527E50F-C470-4C48-B72A-FF632C1995BA" {
                GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "c6280a9bf7bdadc3cfa7b8067bd4446c" ]
            } else {
                GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "9c8f15e14cb4f8190750ea6d7b559c4d" ]
            }
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
