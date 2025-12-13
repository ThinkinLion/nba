//
//  BoxScoreTableView.swift
//  nba
//
//

import SwiftUI

struct BoxScoreTableView: View {
    let boxScores: [BoxScore]
    let teamName: String
    
    // Config
    let rowHeight: CGFloat = 36
    let headerHeight: CGFloat = 24
    
    var body: some View {
        VStack(spacing: 0) {
            // Team Header
            HStack(spacing: 10) {
                // Team Logo
                Image(teamName.nickNameToTriCode)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .shadow(color: .white.opacity(0.3), radius: 2)
                
                // Team Name
                Text(teamName.uppercased())
                    .font(.system(size: 16, weight: .heavy, design: .monospaced)) // Larger font
                    .foregroundColor(.white)
                    .tracking(2) // Wider tracking
                
                Spacer()
                
                // Neon Accent Line (Vertical) at end
                Rectangle()
                     .fill(Color(teamName.lowercased() + ".light"))
                     .frame(width: 4, height: 24)
                     .shadow(color: Color(teamName.lowercased() + ".light"), radius: 4)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 15)
            .background(
                LinearGradient(
                    colors: [
                        Color(teamName.lowercased() + ".dark").opacity(0.6),
                        Color.black.opacity(0.0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(teamName.lowercased() + ".light").opacity(0.3)),
                alignment: .top
            )
            .padding(.bottom, 0) // Remove bottom padding to attach to table
            
            // Terminal Container
            HStack(alignment: .top, spacing: 0) {
                // Sticky Column (Player Names)
                VStack(spacing: 0) {
                    // Header
                    Text("PLAYER")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.green.opacity(0.8))
                        .frame(height: headerHeight)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)
                        .background(Color.black.opacity(0.8))
                        .overlay(Rectangle().frame(height: 1).foregroundColor(Color.green.opacity(0.3)), alignment: .bottom)
                    
                    ForEach(boxScores, id: \.self) { score in
                        let vm = BoxScoreViewModel(boxScore: score)
                        NavigationLink(destination: PlayerView(playerId: vm.playerId, teamId: vm.teamId)) {
                            PlayerCell(viewModel: vm, height: rowHeight)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider().background(Color.white.opacity(0.1))
                    }
                }
                .frame(width: 130)
                .background(Color.black.opacity(0.6))
                .zIndex(1)
                .overlay(Rectangle().frame(width: 1).foregroundColor(Color.white.opacity(0.1)), alignment: .trailing)
                
                // Scrollable Stats Columns
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header Row
                        HStack(spacing: 0) {
                            ForEach(StatColumn.allCases, id: \.self) { col in
                                Text(col.rawValue)
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundColor(Color.green.opacity(0.8))
                                    .frame(width: col.width, height: headerHeight)
                            }
                        }
                        .background(Color.black.opacity(0.8))
                        .overlay(Rectangle().frame(height: 1).foregroundColor(Color.green.opacity(0.3)), alignment: .bottom)
                        
                        // Data Rows
                        ForEach(boxScores, id: \.self) { score in
                            let vm = BoxScoreViewModel(boxScore: score)
                            StatsRow(viewModel: vm, height: rowHeight)
                            
                            Divider().background(Color.white.opacity(0.1))
                        }
                    }
                }
            }
            .background(Color.black.opacity(0.4))
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

// Subcomponents
struct PlayerCell: View {
    let viewModel: BoxScoreViewModel
    let height: CGFloat
    
    var body: some View {
        HStack(spacing: 8) {
//            AsyncImage(url: URL(string: viewModel.smallImageUrl)) { image in
//                image.resizable()
//            } placeholder: {
//                Circle().fill(Color.gray.opacity(0.3))
//            }
//            .aspectRatio(contentMode: .fill)
//            .frame(width: 18, height: 18)
//            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 0) {
                Text(viewModel.lastName.uppercased())
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
//                Text(viewModel.position)
//                    .font(.system(size: 8, design: .monospaced))
//                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(.leading, 10)
        .frame(height: height)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.01))
    }
}

struct StatsRow: View {
    let viewModel: BoxScoreViewModel
    let height: CGFloat
    
    var body: some View {
        HStack(spacing: 0) {
            StatCell(value: viewModel.min, width: StatColumn.min.width)
            StatCell(value: viewModel.pts, width: StatColumn.pts.width, isHighlight: true)
            StatCell(value: viewModel.reb, width: StatColumn.reb.width)
            StatCell(value: viewModel.ast, width: StatColumn.ast.width)
            StatCell(value: viewModel.stl, width: StatColumn.stl.width)
            StatCell(value: viewModel.blk, width: StatColumn.blk.width)
            StatCell(value: viewModel.fg, width: StatColumn.fg.width)
            StatCell(value: viewModel.fgp, width: StatColumn.fgp.width)
            StatCell(value: viewModel.tp, width: StatColumn.tp.width)
            StatCell(value: viewModel.tpp, width: StatColumn.tpp.width)
            StatCell(value: viewModel.ft, width: StatColumn.ft.width)
            StatCell(value: viewModel.ftp, width: StatColumn.ftp.width)
            StatCell(value: viewModel.to, width: StatColumn.to.width)
            StatCell(value: viewModel.pf, width: StatColumn.pf.width)
            StatCell(value: viewModel.pm, width: StatColumn.pm.width)
        }
        .frame(height: height)
    }
}

struct StatCell: View {
    let value: String
    let width: CGFloat
    var isHighlight: Bool = false
    
    var body: some View {
        Text(value)
            .font(.system(size: 11, weight: isHighlight ? .bold : .regular, design: .monospaced))
            .foregroundColor(isHighlight ? .green : .white.opacity(0.7))
            .frame(width: width)
    }
}

enum StatColumn: String, CaseIterable {
    case min = "MIN"
    case pts = "PTS"
    case reb = "REB"
    case ast = "AST"
    case stl = "STL"
    case blk = "BLK"
    case fg = "FG"
    case fgp = "FG%"
    case tp = "3P"
    case tpp = "3P%"
    case ft = "FT"
    case ftp = "FT%"
    case to = "TO"
    case pf = "PF"
    case pm = "+/-"
    
    var width: CGFloat {
        switch self {
        case .min: return 50
        case .pts, .reb, .ast, .stl, .blk: return 40
        case .fg, .ft, .tp: return 55
        case .fgp, .ftp, .tpp: return 50
        case .to, .pf: return 35
        case .pm: return 40
        }
    }
}
