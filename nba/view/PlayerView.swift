//
//  PlayerView.swift
//  nba
//
//  Created by 1100690 on 12/5/23.
//

import SwiftUI

struct PlayerView: View {
    @StateObject var viewModel = PlayerViewModel()
    @State private var hasAppeared = false
    let playerId: String
    let teamId: String
    @State var scrollOffset: CGFloat = CGFloat.zero
    @State var hideNavigationBar: Bool = true
//    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        let player = PlayerSummaryViewModel(player: viewModel.player)
        
        ObservableScrollView(scrollOffset: $scrollOffset) {
            ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center)) {
                AsyncImage(url: URL(string: playerId.imageUrl)) { image in
                    image.resizable()
                } placeholder: {}
                .aspectRatio(contentMode: .fill)
                .frame(width: 180, height: 180, alignment: .bottom)
                .padding(.leading, 200)
                .padding(.bottom, -55)
                .zIndex(0)
                
                VStack(alignment: .leading) {
                    Image(self.teamId.teamIdToTriCode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .scaleEffect(1.2)
                        .clipped()
                    
                    Text(player.upperCasedName)
                        .foregroundColor(.white)
                        .font(.title)
                        .fontWeight(.bold)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                    
                    Text(player.jerseyAndPosition)
                        .foregroundColor(.white.opacity(0.8))
                        .font(.system(size: 14))
                }
                .frame(width: 160)
                .padding(.trailing, 200)
                .zIndex(1)
            }
            .frame(height: 250)
            .frame(maxWidth: .infinity)
            .padding(.top, 15)
            .padding(.horizontal, 15)
            .background(Color(self.teamId.light))
        
            Text("")
                .frame(maxWidth: .infinity)
                .frame(height: 20)
                .background {
                    CustomCorner(corners: [.topLeft, ], radius: 20)
                        .fill(Color(self.teamId.dark))
                        .ignoresSafeArea()
                }
                .padding(.top, -19)
            
            self.summaryView(player: player)
          
            BannerView(adUnitId: .playerView, paddingTop: 10)
          
            //yearly Stats
            self.yearlyStatsView(title: "traditional stats", leftWidth: 60, rightWidth: 60, stats: player.traditional)
                .padding(.top, 20)
                .visible(player.hasTraditional)
          
            self.yearlyStatsView(title: "advanced stats", leftWidth: 60, rightWidth: 60, stats: player.advanced)
                .padding(.top, 20)
                .visible(player.hasAdvanced)
          
            self.rosterView(roster: self.viewModel.roster)
          
            self.yearlyStatsView(title: "misc stats", leftWidth: 108, rightWidth: 72, stats: player.misc)
                .visible(player.hasMisc)
          
            self.yearlyStatsView(title: "scoring stats", leftWidth: 108, rightWidth: 72, stats: player.scoring)
                .padding(.top, 20)
                .visible(player.hasScoring)
          
            self.yearlyStatsView(title: "usage stats", leftWidth: 60, rightWidth: 60, stats: player.usage)
                .padding(.top, 20)
                .padding(.bottom, 20)
                .visible(player.hasUsage)
            
        }
        .background(Color(self.teamId.dark))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear() {
            guard !hasAppeared else { return }
            viewModel.fetchPlayer(documentId: self.playerId)
            viewModel.fetchRoster(teamId: self.teamId)
            hasAppeared = true
        }
        .navigationBarTitle("", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 2) {
                    Image(self.teamId.teamIdToTriCode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                }
                .opacity(hideNavigationBar ? 0.0 : 1.0)
            }
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button {
//                    self.presentationMode.wrappedValue.dismiss()
//                } label: {
//                    Image("home")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 25, height: 25)
//                        .scaleEffect(1.2)
//                        .cornerRadius(12.5)
//                }
//                .buttonStyle(PlainButtonStyle())
//                .opacity(hideNavigationBar ? 0.0 : 1.0)
//            }
        }
        .onChange(of: scrollOffset, perform: { scrollOfset in
            let offset = scrollOfset + (self.hideNavigationBar ? 50 : 0) // note 1
            if offset > 60 { // note 2
                withAnimation(.easeIn(duration: 1), {
                    self.hideNavigationBar = false
                })
            }
            if offset < 50 {
                withAnimation(.easeIn(duration: 1), {
                    self.hideNavigationBar = true
                })
            }
        })
        .ignoresSafeArea()
        .analyticsScreen(name: "NBA-PlayerView")
    }
}

extension PlayerView {
  @ViewBuilder
  private func yearlyStatsView<T: StatsGeneratable & Hashable>(title: String, leftWidth: CGFloat, rightWidth: CGFloat, stats: [T]) -> some View {
    ZStack(alignment: .topLeading) {
//      LinearGradient(colors: title.containerColor, startPoint: .topLeading, endPoint: .bottom)
      LinearGradient(colors: [Color(self.teamId.light), Color.gray.opacity(0.5), Color(self.teamId.dark)], startPoint: .top, endPoint: .bottom)
        .clipShape(RoundedRectangle(cornerRadius: 0, style: .continuous))

      HStack {
        Text("\(title.uppercased())")
          .textStyle(color: .white.opacity(0.9), font: .system(size: 18), weight: .bold)
          .padding(10)
          .padding(.leading, 15)
        Spacer()
      }
      
      let layout = [
        GridItem(.flexible(maximum: 80)),
      ]

      ScrollView(.horizontal, showsIndicators: false) {
        LazyHGrid(rows: layout, spacing: 0) {
          ForEach(Array(stats.enumerated()), id: \.element) { index, stat in
            let statsItems = stat.createStatsItemViewModels(teamId: self.teamId)
            LazyHStack(spacing: 0) {
              self.cardView(stats: statsItems, leftWidth: leftWidth, rightWidth: rightWidth)
              
//              Divider()
//                .background(Color.black.opacity(0.5))
//                .padding(.vertical, 20)
//                .visible(index < stats.count - 1)
            }
            .frame(maxHeight: .infinity) // Ensure the HStack expands fully
          }
        }
      }
      .padding(.top, 20)
      .padding(.horizontal, 10)
    }
//    .frame(height: 450) //StatsView마다 높이가 다르다. 자식의 크기에 따라 커지도록..
  }
  
  @ViewBuilder
  private func cardView(stats: [PlayerStatsItemViewModel], leftWidth: CGFloat, rightWidth: CGFloat) -> some View {
    VStack {
      ForEach(Array(stats.enumerated()), id: \.element) { index, item in
        if index == 0 {
          HStack(spacing: 0) {
            Spacer()
            Image(item.title)
              .resizable()
              .frame(width: 30, height: 30, alignment: .trailing)
              .visible(item.title != "TOT")
            Text(item.title)
              .textStyle(color: .white.opacity(0.8), font: .system(size: 16), weight: .bold)
              .frame(height: 30, alignment: .trailing)
              .padding(.trailing, 4)
              .visible(item.title == "TOT")
            Text(item.value)
              .textStyle(color: .white.opacity(0.8), font: .system(size: 16), weight: .bold)
              .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
          }
        } else {
          HStack {
            Spacer()
            Text(item.title)
              .textStyle(color: .white.opacity(0.9), font: .system(size: 14))
//              .frame(maxWidth: .infinity, alignment: .trailing)
              .frame(width: leftWidth, alignment: .trailing)
              .minimumScaleFactor(0.8)
            
            Text(item.value)
              .textStyle(color: .white.opacity(0.9), font: .system(size: 14))
//              .frame(maxWidth: .infinity, alignment: .leading)
              .frame(width: rightWidth, alignment: .leading)
            Spacer()
          }
        }
      }
    }
//    .frame(width: width)
//    .frame(maxWidth: .infinity)
    .padding()
  }
}

extension PlayerView {
    @ViewBuilder
    private func statsView(stats: [PlayerStatsItemViewModel], title: String) -> some View {
        VStack {
            HStack {
                Text(title)
                    .textStyle(color: .white.opacity(0.9), font: .system(size: 18), weight: .bold)
                Spacer()
            }
            .padding(.horizontal, 15)
            
            let layout = [
                  GridItem(.flexible(maximum: 80)),
                  GridItem(.flexible(maximum: 80)),
                  GridItem(.flexible(maximum: 80)),
    //              GridItem(.flexible(maximum: 80))
              ]
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: layout, spacing: 10) {
                    ForEach(stats, id: \.self) { viewModel in
                        ZStack(alignment: .topLeading) {
                            LinearGradient(colors: viewModel.colors, startPoint: .topLeading, endPoint: .bottom)
                                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                            Text(viewModel.value)
                                .textStyle(color: .white.opacity(0.9), font: .system(size: 22, design: .rounded), weight: .semibold)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .padding(.top, 5)
                                .padding(.leading, 90)
                            Text(viewModel.title)
                                .textStyle(color: .white.opacity(0.8), font: .system(size: 13))
                                .padding(.leading, 5)
                                .padding(.top, 40)
                        }
                        .frame(width: 150, height: 60)
                    }
                }
            }
            .padding(.horizontal, 10)
        }
    }
}

extension PlayerView {
    @ViewBuilder
    private func rosterItemView(viewModel: PlayerSummaryViewModel) -> some View {
        VStack {
            ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center)) {
                AsyncImage(url: URL(string: viewModel.smallImageUrl)) { image in
                    image.resizable()
                } placeholder: {
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80, alignment: .bottom)
                .padding(.trailing, 20)
                .zIndex(1)
                
                Text(viewModel.jersey)
                    .frame(width: 30)
                    .padding(.trailing, 90)
                    .padding(.bottom, 30)
                    .foregroundColor(.white.opacity(0.8))
                    .font(.system(size: 14))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .zIndex(0)
            }
            
            Text(viewModel.lastName)
                .foregroundColor(.white.opacity(0.8))
                .font(.system(size: 14))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(width: 120)
    }
    
    @ViewBuilder
    private func rosterView(roster: [PlayerModel]) -> some View {
        VStack(alignment: .leading) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(roster, id: \.self) { player in
                        let viewModel = PlayerSummaryViewModel(player: player)
                        NavigationLink(destination: PlayerView(playerId: viewModel.playerId, teamId: viewModel.teamId)) {
                            rosterItemView(viewModel: viewModel)
                        }
                    }
                }
                .frame(height: 120)
                .padding(.leading, 10)
            }
            
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
        .padding(7)
        .padding(.bottom, 30)
    }
    
    @ViewBuilder
    private func summaryView(player: PlayerSummaryViewModel) -> some View {
        statsSummaryView(player: player)
        
        dividerWithBackground()
        
        bioSummaryView(title: player.heightTitle, value: player.height)
        
        dividerWithBackground()
        
        bioSummaryView(title: player.weightTitle, value: player.weight)
        
        dividerWithBackground()
        
        bioSummaryView(title: player.ageTitle, value: player.age)
        
        dividerWithBackground()
        
        bioSummaryView(title: player.birthdateTitle, value: player.birthdate)
        
        dividerWithBackground()
        
        bioSummaryView(title: player.experienceTitle, value: player.experience)
        
        dividerWithBackground()
        
        bioSummaryView(title: player.draftTitle, value: player.draft)
        
        dividerWithBackground()
        
        bioSummaryView(title: player.countryTitle, value: player.country)
        
        dividerWithBackground()
        
        bioSummaryView(title: player.lastAttendedTitle, value: player.lastAttended)
    }
    
    private func dividerWithBackground() -> some View {
        Divider()
            .background(Color("#272628"))
            .opacity(0.9)
            .frame(height: 1.5)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 15)
    }
    
    @ViewBuilder
    private func bioSummaryView(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.9))
                .padding(.leading, 20)
            Spacer()
            Text(value)
                .foregroundColor(.white.opacity(0.9))
                .font(.system(size: 14, weight: .semibold))
                .padding(.trailing, 20)
        }
        .frame(height: 30)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func statsSummaryView(player: PlayerSummaryViewModel) -> some View {
        HStack {
            VStack(alignment: .center) {
                Text(player.pieTitle)
                    .padding(.horizontal, 5)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .background(Color("#5C5B60"))
                
                Text(player.pie)
                    .padding(2)
                    .foregroundColor(Color("#db4c30"))
                    .font(.title)
                    .fontWeight(.bold)
            }
            .padding(.leading, 20)
            Spacer()
            
            VStack(alignment: .center) {
                Text(player.ppgTitle)
                    .padding(.horizontal, 5)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .background(Color("#5C5B60"))
                
                Text(player.ppg)
                    .padding(2)
                    .foregroundColor(.white)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            Spacer()
            
            VStack(alignment: .center) {
                Text(player.rpgTitle)
                    .padding(.horizontal, 5)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .background(Color("#5C5B60"))
                
                Text(player.rpg)
                    .padding(2)
                    .foregroundColor(.white)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            Spacer()
            
            VStack(alignment: .center) {
                Text(player.apgTitle)
                    .padding(.horizontal, 5)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .background(Color("#5C5B60"))
                
                Text(player.apg)
                    .padding(2)
                    .foregroundColor(.white)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .padding(.trailing, 20)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    StandingsView()
}
