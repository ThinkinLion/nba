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
    case powerRanking = "ca-app-pub-3499543148696658/8684442869" //NBA - powerRanking banner
  
  //앱아이디: ca-app-pub-3499543148696658~9532273069
}

struct BannerView: View {
    var adUnitId: BannerUnitID = .powerRanking
    var paddingTop: CGFloat = 0
    var paddingHorizontal: CGFloat = 0
    var height: CGFloat = 50
    var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    @State private var isAdLoaded: Bool = false // Default to hidden/false until loaded
    
    var body: some View {
        HStack {
            Spacer()
            if isAdLoaded {
                AdView(adUnitId: adUnitId, paddingHorizontal: paddingHorizontal, isAdLoaded: $isAdLoaded)
                    .frame(height: height)
            } else {
                // Load in background/overlay with minimal size to prompt request
                Color.clear
                    .frame(height: 0)
                    .overlay(
                        AdView(adUnitId: adUnitId, paddingHorizontal: paddingHorizontal, isAdLoaded: $isAdLoaded)
                            .frame(height: 1) // 1px height to satisfy AdMob
                            .opacity(0)
                    )
            }
            Spacer()
        }
        .padding(.top, isAdLoaded ? paddingTop : 0)
        .padding(.horizontal, paddingHorizontal)
    }
}

struct AdView : UIViewRepresentable {
    var adUnitId: BannerUnitID = .powerRanking
    var paddingHorizontal: CGFloat = 15
    @Binding var isAdLoaded: Bool
    
    func makeUIView(context: UIViewRepresentableContext<AdView>) -> GADBannerView {
        let banner = GADBannerView(adSize: GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width))
        
        banner.delegate = context.coordinator // Set delegate
        
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
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, GADBannerViewDelegate {
        let parent: AdView
        
        init(parent: AdView) {
            self.parent = parent
        }
        
        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            print("Banner loaded")
            withAnimation {
                parent.isAdLoaded = true
            }
        }
        
        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            print("Banner failed: \(error)")
            withAnimation {
                parent.isAdLoaded = false
            }
        }
    }
}
