//
//  DailyPerformerCardView.swift
//  nba
//
//  Created by Antigravity on 1/3/25.
//

import SwiftUI

struct DailyPerformerCardView: View {
    let performer: DailyPerformer
    let candidates: [DailyPerformer]
    
    // Date Selection Integration
    let games: [GamesModel]
    @Binding var selectedIndex: Int
    
    // For sharing
    @State private var showShareSheet = false
    @State private var snapshotImage: UIImage? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            SectionHeaderView(title: "PERFORMANCE OF THE NIGHT")
//            .overlay(
//                 // Share Button (Aligned to header)
//                 HStack {
//                     Spacer()
//                     Button(action: {
//                         shareCard()
//                     }) {
//                         Image(systemName: "square.and.arrow.up")
//                             .foregroundColor(.white) // Keep consistent
//                             .padding(.trailing, 14) // Match header padding
//                     }
//                 }
//            )
            .padding(.horizontal, -8) // Counteract parent padding slightly if needed, or adjust
            // Since DailyPerformerCardView has padding(8), internal padding of header (14) might be too much.
            // Let's adjust usage to fit.
            
            // The Card Content (Navigation is now internal)
            cardContent
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 5)
        }
        .padding(8)
        .sheet(isPresented: $showShareSheet) {
            if let image = snapshotImage {
                ShareSheet(items: [image])
            }
        }
    }
    
    var cardContent: some View {
        ZStack {
            // Background: Team Color (Edgy)
            Color(performer.teamCode.lowercased() + ".dark")
            
            // Watermark (Giant Initial)
            GeometryReader { geo in
                Text(String(performer.teamCode.nickNameToTriCode.prefix(1)))
                    .font(.system(size: geo.size.width * 0.8, weight: .black, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.1))
                    .rotationEffect(.degrees(-15))
                    .position(x: geo.size.width * 0.8, y: geo.size.height * 0.4)
            }
            
            VStack(spacing: 0) {
                // --- TOP SECTION: DATE SELECTOR ---
                // Integrating Date Selector into the Card
                DateSelectorView(games: games, selectedIndex: $selectedIndex)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                
                NavigationLink(destination: GameRecapView(viewModel: HomeAwayViewModel(homeAway: performer.game), gameRecap: games)) {
                    ZStack(alignment: .bottom) {
                        
                        // --- PLAYER IMAGE ---
                        if let playerId = performer.player.playerId {
                            AsyncImage(url: URL(string: playerId.imageUrl)) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFit()
                                } else {
                                    Color.clear.frame(height: 200)
                                }
                            }
                            .frame(height: 300)
                            .mask(LinearGradient(gradient: Gradient(colors: [.black, .black, .clear]), startPoint: .top, endPoint: .bottom))
                        }
                        
                        // --- HEADER INFO OVERLAY (Team vs Team) ---
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(performer.player.firstName?.uppercased() ?? "")
                                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Text(performer.player.lastName?.uppercased() ?? "")
                                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                        .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)
                                    
                                    HStack(spacing: 8) {
                                        Text("\(performer.teamCode.nickNameToTriCode) vs \(performer.opponentTriCode)")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.black.opacity(0.4))
                                            .foregroundColor(.white)
                                        
                                        Text(performer.gameResultText)
                                            .font(.caption)
                                            .fontWeight(.heavy)
                                            .foregroundColor(.white)
                                            .shadow(color: .black.opacity(0.8), radius: 1)
                                    }
                                    .padding(.top, 4)
                                }
                                Spacer()
                                
                                // Team Logo
                                SafeModeLogoView(originalCode: performer.teamCode, triCode: performer.teamCode.nickNameToTriCode)
                                    .frame(width: 44, height: 44)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
                                    .shadow(radius: 4)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 24)
                            
                            Spacer()
                        }
                        
                        // --- MAIN STATS OVERLAY ---
                        HStack(alignment: .bottom, spacing: 20) {
                            statBlock(value: performer.player.pts ?? "0", label: "PTS", isLarge: true)
                            statBlock(value: performer.player.reb ?? "0", label: "REB", isLarge: false)
                            statBlock(value: performer.player.ast ?? "0", label: "AST", isLarge: false)
                            Spacer()
                            
                            // Game Score Text (Moved here for Game Context)
                            VStack(alignment: .trailing) {
    //                                     Text("\(performer.teamCode.nickNameToTriCode) vs \(performer.opponentTriCode)")
    //                                         .font(.caption)
    //                                         .fontWeight(.bold)
    //                                         .foregroundColor(.white.opacity(0.8))
    //
    //                                     Text(performer.gameResultText)
    //                                         .font(.caption)
    //                                         .fontWeight(.heavy)
    //                                         .foregroundColor(.white)
                                // Only showing if needed, but redundant with top header. Removing to match clean look or keeping if user liked it?
                                // User layout had Header at top. I will keep Header at top and stats at bottom.
                                // The previous refactor added text here. I will remove it to avoid duplication if the Header is present.
                            }
                        }
                        .padding(24)
                    }
                }
                .frame(height: 350) // Top Section Height
                
                // --- BOTTOM SECTION: CANDIDATES ---
                if !candidates.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        // 3-Column Grid, Full Bleed
                        HStack(spacing: 0) {
                            ForEach(Array(candidates.prefix(3))) { candidate in
                                NavigationLink(destination: GameRecapView(viewModel: HomeAwayViewModel(homeAway: candidate.game), gameRecap: games)) {
                                    DailyCandidateCardView(performer: candidate)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 180)
                                        .overlay(
                                            // Right Divider for first 2 items
                                            HStack {
                                                Spacer()
                                                if candidate.id != candidates.prefix(3).last?.id {
                                                    Rectangle()
                                                        .fill(Color.white.opacity(0.1))
                                                        .frame(width: 1)
                                                        .padding(.vertical, 10)
                                                }
                                            }
                                        )
                                }
                            }
                            // Fill empty slots
                             if candidates.count < 3 {
                                 ForEach(0..<(3 - candidates.count), id: \.self) { _ in
                                     Spacer().frame(maxWidth: .infinity)
                                 }
                             }
                        }
                    }
                    .background(Color.black.opacity(0.3))
                }
            }
        }
        // Removed fixed frame(width: 350)
    }
    
    @ViewBuilder
    func statBlock(value: String, label: String, isLarge: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(value)
                .font(.system(size: isLarge ? 56 : 28, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
                .shadow(color: .black.opacity(0.3), radius: 1)
        }
    }
    
    // Sharing Logic
    @MainActor
    func shareCard() {
        // Render with fixed width for sharing consistent image
        let renderer = ImageRenderer(content: cardContent.frame(width: 390))
        renderer.scale = UIScreen.main.scale
        
        if let uiImage = renderer.uiImage {
            snapshotImage = uiImage
            showShareSheet = true
        }
    }
}

// Share Sheet Helper
struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
