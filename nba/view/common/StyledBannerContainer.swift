//
//  StyledBannerContainer.swift
//  nba
//
//  Created by AntiGravity on 2024/12/24.
//

import SwiftUI

struct StyledBannerContainer: View {
    var adUnitId: BannerUnitID
    var paddingHorizontal: CGFloat = 15
    
    var body: some View {
        VStack(spacing: 8) {
            // "SPONSORED" Label
            Text("SPONSORED")
                .font(.system(size: 10, weight: .bold))
                .tracking(1.0)
                .foregroundColor(.white.opacity(0.4))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.top, 10)
            
            // Banner Content
            // We use paddingHorizontal: 0 for the inner BannerView because 
            // the container itself handles the horizontal padding/margins via the card layout.
            BannerView(adUnitId: adUnitId, paddingHorizontal: 0)
                .frame(minHeight: 50) // Minimum height for banner area
                .padding(.bottom, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(white: 0.12)) // Dark card background
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        // Apply outer padding to position the card itself
        .padding(.horizontal, paddingHorizontal)
    }
}
