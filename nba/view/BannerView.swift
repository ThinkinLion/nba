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
//    case standingsView = "ca-app-pub-3499543148696658/6384435245" //NBA-StandingsView banner
    case powerRanking = "ca-app-pub-3499543148696658/8684442869" //NBA - powerRanking banner
  
  //앱아이디: ca-app-pub-3499543148696658~9532273069
}

struct BannerView: View {
    var adUnitId: BannerUnitID = .powerRanking
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
    var adUnitId: BannerUnitID = .powerRanking
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
