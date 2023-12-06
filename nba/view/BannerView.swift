//
//  BannerView.swift
//  nba
//
//  Created by 1100690 on 2023/11/20.
//

import SwiftUI
import GoogleMobileAds
import UIKit

/*
 static let brawler1AdUnitID = "ca-app-pub-3499543148696658/1040546944" //브롤러1
 static let brawler2AdUnitID = "ca-app-pub-3499543148696658/4126541875" //브롤러2
 static let brawler3AdUnitID = "ca-app-pub-3499543148696658/8995725174" //브롤러3
 
 static let gamemodeAdUnitID = "ca-app-pub-3499543148696658/3247907886" //게임모드탭
 static let brawltalkAdUnitID = "ca-app-pub-3499543148696658/2137921444" //브롤토크탭
 static let interstitialID = "ca-app-pub-3499543148696658/5091309269" //전면
 static let donateID = "ca-app-pub-3499543148696658/3882681093" //기부
 */

enum BannerUnitID: String {
    case teamView = "ca-app-pub-3499543148696658/6384435245" //NBA-Teamview banner
    case playerView = "ca-app-pub-3499543148696658/9594728923" //NBA-Playerview banner
    case boxscoreView = "ca-app-pub-3499543148696658/9569476486" //NBA-Boxscoreview banner
}

struct BannerView: View {
    var adUnitId: BannerUnitID = .teamView
    var paddingTop: CGFloat = 0
    var paddingHorizontal: CGFloat = 0
    var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    var body: some View{
        HStack{
            Spacer()
//            if idiom == .phone {
                AdView(adUnitId: adUnitId, paddingHorizontal: paddingHorizontal)
                    .frame(width: 320, height: 50, alignment: .center)
//            }
            Spacer()
        }
        .padding(.top, paddingTop)
        .padding(.horizontal, paddingHorizontal)
    }
}

struct AdView : UIViewRepresentable {
    var adUnitId: BannerUnitID = .teamView
    var paddingHorizontal: CGFloat = 15
    
    func makeUIView(context: UIViewRepresentableContext<AdView>) -> GADBannerView {
//        let banner = GADBannerView(adSize: GADAdSizeBanner)
        let banner = GADBannerView(adSize: GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width))
        
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            return banner
        }
        banner.rootViewController = rootViewController

        let frame = { () -> CGRect in
            return banner.rootViewController!.view.frame.inset(by: banner.rootViewController!.view.safeAreaInsets)
        }()
        let viewWidth = frame.size.width - paddingHorizontal * 2
        banner.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        banner.adUnitID = adUnitId.rawValue
        banner.load(GADRequest())
        return banner
    }

    func updateUIView(_ uiView: GADBannerView, context: UIViewRepresentableContext<AdView>) {
    }
}
