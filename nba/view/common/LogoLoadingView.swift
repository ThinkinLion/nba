//
//  LogoLoadingView.swift
//  nba
//
//  Created by ChatGPT on 11/17/25.
//

import SwiftUI

struct LogoLoadingView: View {
    private static let defaultLogos = [
        "BOS", "DEN", "GSW", "LAL", "MIA", "MIL", "NYK", "PHX"
    ]
    
    let size: CGFloat
    let showBackground: Bool
    let logos: [String]
    
    @State private var rotation: Double = 0
    
    init(
        size: CGFloat = 120,
        showBackground: Bool = true,
        logos: [String] = LogoLoadingView.defaultLogos
    ) {
        self.size = size
        self.showBackground = showBackground
        self.logos = logos
    }
    
    var body: some View {
        ZStack {
            if showBackground {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
            }
            
            let logosToUse = logos.isEmpty ? LogoLoadingView.defaultLogos : logos
            ForEach(Array(logosToUse.enumerated()), id: \.offset) { index, logo in
                Image(logo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size * 0.22, height: size * 0.22)
                    .offset(y: -size * 0.38)
                    .rotationEffect(
                        .degrees(rotation + (Double(index) / Double(logosToUse.count)) * 360)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 4)
            }
            
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.0)]),
                        center: .center,
                        startRadius: 0,
                        endRadius: size / 2
                    )
                )
                .frame(width: size * 0.45, height: size * 0.45)
                .blur(radius: 4)
        }
        .frame(width: size, height: size)
        .onAppear(perform: startRotation)
    }
    
    private func startRotation() {
        withAnimation(Animation.linear(duration: 5).repeatForever(autoreverses: false)) {
            rotation = 360
        }
    }
}

