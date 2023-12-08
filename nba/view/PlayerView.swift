//
//  PlayerView.swift
//  nba
//
//  Created by 1100690 on 12/5/23.
//

import SwiftUI

struct PlayerView: View {
    var viewModel: SeasonLeaderViewModel
    
    var body: some View {
        
        ScrollView(.vertical) {
//            HStack (spacing: 0) {
            ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center)) {
                AsyncImage(url: URL(string: viewModel.imageUrl)) { image in
                    image.resizable()
                } placeholder: {}
                .aspectRatio(contentMode: .fill)
                .frame(width: 180, height: 180, alignment: .bottom)
                .padding(.leading, 180)
                .padding(.bottom, -55)
                .zIndex(0)
                
                VStack(alignment: .leading) {
                    Image(viewModel.teamTriCode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .clipped()
                    
                    Text(viewModel.name)
                    .foregroundColor(.white)
                    .font(.title)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .zIndex(1)
                }
                .frame(width: 160)
                .padding(.trailing, 200)
            }
            .frame(height: 250)
            .frame(maxWidth: .infinity)
            .padding(.top, 15)
            .padding(.horizontal, 15)
            .background(Color(viewModel.teamTriCode.triCodeToNickName.toLightColor))
        
            Divider()
                .frame(height: 15)
                .background {
                    CustomCorner(corners: [.topLeft, .topRight], radius: 15)
                        .fill(Color(viewModel.teamTriCode.triCodeToNickName.toDarkColor))
                        .ignoresSafeArea()
                }
                .padding(.top, -20)
            
            VStack {
//                Text(viewModel.name)
//                    .font(.title)
//                    .fontWeight(.bold)
//                    .padding(.top, 15)
//                Spacer()
                Text("Luka Doncic's 41 points help Dallas edge Brooklyn despite Kyrie Irving's 39 points.")
                    .font(.callout)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                
            }
            .padding(.bottom, 15)
            .padding(15)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .background(Color(viewModel.teamTriCode.triCodeToNickName.toDarkColor))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color(viewModel.teamTriCode.triCodeToNickName))
        .ignoresSafeArea()
    }
}

#Preview {
    StandingsView()
}
