//
//  BannerView.swift
//  nba
//
//  Created by 1100690 on 2023/11/20.
//

import SwiftUI
import GoogleMobileAds
import UIKit

enum BannerUnitID: String {
    case standingsView = "ca-app-pub-3499543148696658/6384435245" //NBA-StandingsView banner
    case standingsView2 = "ca-app-pub-3499543148696658/8586673667" //NBA-StandingsView banner2
    case playerView = "ca-app-pub-3499543148696658/9594728923" //NBA-PlayerView banner
    case teamView = "ca-app-pub-3499543148696658/9569476486" //NBA-TeamView banner
    case gameView = "ca-app-pub-3499543148696658/9865882150" //NBA - GameRecap banner
    
}

struct BannerView: View {
    var adUnitId: BannerUnitID = .standingsView
    var paddingTop: CGFloat = 0
    var paddingHorizontal: CGFloat = 0
    var height: CGFloat = 50
    var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    var body: some View{
        HStack{
            Spacer()
//            if idiom == .phone {
                AdView(adUnitId: adUnitId, paddingHorizontal: paddingHorizontal)
                .frame(height: height)
//                    .frame(width: 320, height: 50, alignment: .center)
//            }
            Spacer()
        }
        .padding(.top, paddingTop)
        .padding(.horizontal, paddingHorizontal)
    }
}

struct AdView : UIViewRepresentable {
    var adUnitId: BannerUnitID = .standingsView
    var paddingHorizontal: CGFloat = 15
    
    func makeUIView(context: UIViewRepresentableContext<AdView>) -> GADBannerView {
//        let banner = GADBannerView(adSize: GADAdSizeLargeBanner)
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
