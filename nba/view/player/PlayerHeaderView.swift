//
//  PlayerHeaderView.swift
//  nba
//
//

import SwiftUI

struct PlayerHeaderView: View {
    let player: PlayerSummaryViewModel
    
    /// 헤더 전체 높이 (상단 safe area 포함, PlayerView가 top safe area를 무시하므로 화면 최상단부터 시작)
    private let headerHeight: CGFloat = 320
    /// 선수 컷아웃 높이 (1040x760 상반신 샷 → 화면 폭 안에서 fit)
    private let cutoutHeight: CGFloat = 262
    /// 컷아웃을 우측으로 밀어 어깨가 화면 밖으로 자연스럽게 빠지게 하고, 좌측 텍스트 공간을 확보
    private let cutoutTrailingBleed: CGFloat = 56
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background Mesh Gradient
            // 주의: 텍스처용 Circle(400pt)을 ZStack의 직접 자식으로 두면 ZStack 자체가 400pt로 커져
            //       frame(height: 320) 밖으로 상하 40pt씩 삐져나가고, bottom 정렬된 컷아웃/텍스트가 아래로 밀려 잘린다.
            //       → overlay 로 넣어 레이아웃 크기에 영향을 주지 않도록 한다.
            LinearGradient(
                colors: [
                    Color(player.teamId.dark),
                    Color(player.teamId.light),
                    Color(player.teamId.dark)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                // Texture overlay (Dots/Mesh)
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 400, height: 400)
                    .offset(y: -100)
                    .blur(radius: 50)
            )
            
            // Player Cutout Image
            // - 상반신 샷이므로 이미지 바닥을 헤더 바닥에 완전히 밀착 (하단 페이드 마스크 없음)
            // - 우측으로 bleed 시켜 어깨/팔이 화면 가장자리에서 잘리도록 배치
            if RemoteConfigManager.shared.shouldUseOfficialTeamData {
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    AsyncImage(url: URL(string: player.playerId.imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Image(systemName: "person.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white.opacity(0.3))
                            .padding(.bottom, 40)
                    }
                    .frame(height: cutoutHeight, alignment: .bottom)
                    .offset(x: cutoutTrailingBleed)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            // 좌측 텍스트 가독성용 가로 스크림 (바닥 라인은 건드리지 않고 좌→우로만 옅어짐)
            LinearGradient(
                stops: [
                    .init(color: Color(player.teamId.dark).opacity(0.85), location: 0.0),
                    .init(color: Color(player.teamId.dark).opacity(0.45), location: 0.42),
                    .init(color: .clear, location: 0.72)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .allowsHitTesting(false)
            
            // Left Side: Name and Team Info
            VStack(alignment: .leading, spacing: 4) {
                // Team Logo and TriCode
                HStack(spacing: 8) {
                    if RemoteConfigManager.shared.shouldUseOfficialTeamData {
                        Image(player.teamTriCode)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                    }
                    
                    Text(player.teamNickName.uppercased())
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                        .tracking(1)
                }
                .padding(.bottom, 8)

                Text(player.firstName.uppercased())
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                
                Text(player.lastName.uppercased())
                    .font(.system(size: 38, weight: .black))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                HStack(spacing: 8) {
                    Text(player.jersey)
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundColor(Color(player.teamId.light)) // Team Accent
                    
                    Text("•")
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text(player.position)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(1)
                }
                .padding(.top, 4)
            }
            .shadow(color: .black.opacity(0.55), radius: 6, x: 0, y: 2)
            .frame(maxWidth: 250, alignment: .leading)
            .padding(.leading, 20)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: headerHeight)
        .clipped()
    }
}
