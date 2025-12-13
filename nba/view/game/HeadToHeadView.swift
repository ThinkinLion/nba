//
//  HeadToHeadView.swift
//  nba
//
//

import SwiftUI

struct HeadToHeadView: View {
    let viewModel: HomeAwayViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Comparison Bars
            VStack(spacing: 25) {
                PowerStatBar(
                    label: "PTS",
                    awayValue: viewModel.awayLeaderPts,
                    homeValue: viewModel.homeLeaderPts,
                    awayColor: Color(viewModel.awayTeamId.light),
                    homeColor: Color(viewModel.homeTeamId.light)
                )
                
                PowerStatBar(
                    label: "REB",
                    awayValue: viewModel.awayLeaderReb,
                    homeValue: viewModel.homeLeaderReb,
                    awayColor: Color(viewModel.awayTeamId.light),
                    homeColor: Color(viewModel.homeTeamId.light)
                )
                
                PowerStatBar(
                    label: "AST",
                    awayValue: viewModel.awayLeaderAst,
                    homeValue: viewModel.homeLeaderAst,
                    awayColor: Color(viewModel.awayTeamId.light),
                    homeColor: Color(viewModel.homeTeamId.light)
                )
            }
            .padding(.horizontal, 25) // Increased internal padding since outer padding is removed
        }
        .padding(.top, 30) // Top padding to give space from the header image edge
        .padding(.bottom, 20)
        .background(Color.black.opacity(0.5)) // Darker background to separate from header content slightly but blend
    }

}

struct PowerStatBar: View {
    let label: String
    let awayValue: String
    let homeValue: String
    let awayColor: Color
    let homeColor: Color
    
    var awayInt: Double { Double(awayValue) ?? 0 }
    var homeInt: Double { Double(homeValue) ?? 0 }
    
    var isAwayWinner: Bool { awayInt >= homeInt }
    var isHomeWinner: Bool { homeInt >= awayInt }
    
    var body: some View {

        HStack(spacing: 0) {
            // Bars Area
            GeometryReader { geo in
                ZStack {
                    // Center Line
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 1)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    
                    // Away Bar (Grow Left from Center)
                    HStack(spacing: 8) {
                        Spacer()
                        
                        // Value at Tip
                        Text(awayValue)
                            .font(.system(size: 18, weight: .bold, design: .monospaced)) // Increased size
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2)
                        
                        Rectangle()
                            .fill(LinearGradient(colors: [awayColor.opacity(0.6), awayColor], startPoint: .leading, endPoint: .trailing))
                            .frame(width: barWidth(total: geo.size.width, val: awayInt))
                            .overlay(
                                Rectangle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    .opacity(isAwayWinner ? 1 : 0.5)
                            )
                            .shadow(color: awayColor, radius: 8) // Strengthened Glow
                    }
                    .frame(width: geo.size.width / 2)
                    .position(x: geo.size.width / 4, y: geo.size.height / 2)
                    .padding(.trailing, 0) // REMOVED PADDING
                    
                    // Home Bar (Grow Right from Center)
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(LinearGradient(colors: [homeColor, homeColor.opacity(0.6)], startPoint: .leading, endPoint: .trailing))
                            .frame(width: barWidth(total: geo.size.width, val: homeInt))
                            .overlay(
                                Rectangle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    .opacity(isHomeWinner ? 1 : 0.5)
                            )
                            .shadow(color: homeColor, radius: 8) // Strengthened Glow
                        
                        // Value at Tip
                        Text(homeValue)
                            .font(.system(size: 18, weight: .bold, design: .monospaced)) // Increased size
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2)
                        
                        Spacer()
                    }
                    .frame(width: geo.size.width / 2)
                    .position(x: (geo.size.width / 4) * 3, y: geo.size.height / 2)
                    .padding(.leading, 0) // REMOVED PADDING

                    // Center Label (Overlay)
                    ZStack {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 24, height: 24) // Reduced slightly
                            .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                        
                        Text(label)
                            .font(.system(size: 8, weight: .heavy))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
            }
            .frame(height: 16) // Reduced height from 30 to 16
        }
    }
    
    func barWidth(total: CGFloat, val: Double) -> CGFloat {
        let maxVal = max(awayInt, homeInt) + 5
        if maxVal == 0 { return 0 }
        // Available width is half width minus text space (approx 30) and center buffer (16)
        let availableHalfWidth = (total / 2) - 50 
        return (CGFloat(val) / CGFloat(maxVal)) * availableHalfWidth
    }
}
