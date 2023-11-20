//
//  StandingsView.swift
//  nba
//
//  Created by 1100690 on 2023/11/13.
//

import SwiftUI

struct StandingsView: View {
    @StateObject var viewModel = StandingsViewModel()
    var body: some View {
        ScrollView(.vertical) {
            HStack {
                Image("person")
                    .resizable()
                    .background(.white)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 35, height: 35)
                    .clipShape(Circle())
                Text("The NBA's East & West standings following Friday's games!")
                    .font(.callout)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 15)
            .padding(.horizontal, 10)
            
            conferenceView(playoffs: viewModel.east.0,
                           playInTournament: viewModel.east.1,
                           nonPlayoff: viewModel.east.2,
                           title: "EASTERN CONFERENCE",
                           backgroundColor: Color("#101D46"))
            
            conferenceView(playoffs: viewModel.west.0,
                           playInTournament: viewModel.west.1,
                           nonPlayoff: viewModel.west.2,
                           title: "WESTERN CONFERENCE",
                           backgroundColor: Color("#821E26"))
            .padding(.top, 15)
            
            Button(action: viewModel.addSampleItem ) {
                Label("Then add it", systemImage: "plus")
            }
        }
        .preferredColorScheme(.dark)
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear() {
            viewModel.fetchStandings()
        }
        .onDisappear() {
        }
    }
}

extension StandingsView {
    @ViewBuilder
    func conferenceView(playoffs: [Team],
                        playInTournament: [Team],
                        nonPlayoff: [Team],
                        title: String,
                        backgroundColor: Color) -> some View {
        VStack {
            Text(title)
                .padding(.top, 10)
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
            
            HStack(alignment: .top) {
                standingRowView(items: playoffs)
                
                VerticalLineView()
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 1, dash: [5]))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
                
                standingRowView(items: playInTournament)
                
                VerticalLineView()
                    .stroke(Color.white)
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
                
                standingRowView(items: nonPlayoff)
            }
        }
        .frame(height: 360)
        .frame(maxWidth: .infinity)
        .padding(7)
        .background(backgroundColor)
        .cornerRadius(10)
        .padding(.horizontal, 10)
    }
    
    @ViewBuilder
    func standingRowView(items: [Team]) -> some View {

        //.font(.system(size: 25, weight: .bold, design: .serif))
        //.font(.system(size: 25, weight: .bold, design: .rounded))
        //.font(.system(size: 25, weight: .bold, design: .monospaced))
        VStack {
            ForEach(Array(items.enumerated()), id: \.element) { index, model in
                let viewModel = TeamViewModel(team: model)
                HStack(spacing: 0) {
                    Text(viewModel.conferenceRank)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .frame(width: 25, height: 40)
                        .foregroundColor(.white)
                        .background(.black)
                    
                    Image(viewModel.teamCode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40)
                    
                    Text(" ")
                    
                    Text(viewModel.winLoss) //Text("79-19")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .frame(width: 55)
                        .frame(alignment: .leading)
                        .foregroundColor(.white)
                }
                .background(Color(viewModel.teamCode))
            }
        }
    }
}

struct StandingsView_Previews: PreviewProvider {
    static var previews: some View {
        StandingsView()
    }
}
