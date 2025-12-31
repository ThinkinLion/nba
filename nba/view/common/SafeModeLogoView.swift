//
//  SafeModeLogoView.swift
//  nba
//
//  Created by Antigravity on 12/31/24.
//

import SwiftUI

struct SafeModeLogoView: View {
    let originalCode: String
    let triCode: String // Accept triCode explicitly as it might be computed earlier
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 1. Background: Team Color (using nickname for Asset lookup)
                // User Pattern: "nickname.dark" for deeper color
                Color(originalCode.lowercased() + ".dark")
                
                // 2. Edgy Watermark
                // Large Uppercase Letter (First char of TriCode)
                if !triCode.isEmpty {
                    Text(String(triCode.prefix(1)))
                        .font(.system(size: geo.size.width * 0.9, weight: .black, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.3)) // Subtle lighter watermark
                        .rotationEffect(.degrees(-15))
                        .offset(x: 2, y: 2)
                        .clipped()
                }
            }
        }
    }
}
