//
//  StandingsView.swift
//  nba
//
//  Created by 1100690 on 2023/11/11.
//

import SwiftUI

enum TypeOfConference: String, CaseIterable {
    case east = "East"
    case west = "West"
}

struct StandingsView: View {
    @StateObject var viewModel = StandingsViewModel()
    @State private var selectedConference: TypeOfConference = .east
    
    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = .systemRed
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                Picker("Conference", selection: $selectedConference) {
                    ForEach(TypeOfConference.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 100)
                .padding(.top, 15)
                .padding(.bottom, 15)
                
                ChosenStandingListView(viewModel: viewModel, selectedConference: selectedConference)
                
                Button(action: viewModel.addSampleItem ) {
                    Label("Then add it", systemImage: "plus")
                }
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear() {
//            viewModel.subscribe()
            viewModel.fetchStandings()
        }
        .onDisappear() {
//            viewModel.unsubscribe()
        }
    }
}

struct ChosenStandingListView: View {
    @ObservedObject var viewModel: StandingsViewModel
    var selectedConference: TypeOfConference
    var body: some View {
        switch selectedConference {
        case .west:
            StandingListView(items: viewModel.standings.west)
        default:
            StandingListView(items: viewModel.standings.east)
        }
    }
}

struct StandingListView: View {
    var items: [Team]
    var body: some View {
        StandingTitle()
        Divider()
            .padding(.horizontal, 15)
        
        ForEach(Array(items.enumerated()), id: \.element) { index, element in
            StandingRow(viewModel: TeamViewModel(team: element))

            if element != items.last {
                if 5 == index {
                    Line()
                        .stroke(Color.red, style: StrokeStyle(lineWidth: 1, dash: [5]))
                        .frame(height: 1)
                        .padding(.horizontal, 15)
                } else if 9 == index {
                    Line()
                        .stroke(Color.red)
                        .frame(height: 1)
                        .padding(.horizontal, 15)
                } else {
                    Divider().padding(.horizontal, 15)
                }
            }
        }
    }
}

struct StandingTitle: View {
    var body: some View {
        HStack() {
            Text("TEAM")
                .font(.system(size: 12))
                .frame(width: 182, alignment: .center)
            
            Text("W")
                .font(.system(size: 12))
                .frame(width: 30, alignment: .leading)
            
            Text("L")
                .font(.system(size: 12))
                .frame(width: 30, alignment: .leading)
            
            Text("WIN%")
                .font(.system(size: 12))
                .frame(width: 40, alignment: .trailing)
            
            Text("GB")
                .font(.system(size: 12))
                .frame(width: 30, alignment: .center)
        }
        .padding(.horizontal, 15)
    }
}

struct StandingRow: View {
    var viewModel: TeamViewModel
    var body: some View {
//        NavigationLink(destination: TeamView(viewModel: viewModel)) {
            HStack() {
                Text(viewModel.conferenceRank)
                    .font(.system(size: 18))
                    .frame(width: 25, alignment: .leading)
                
                Image(viewModel.teamCode)
                    .resizable()
                    .background(Color("background1"))
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 35, height: 35)
                    .clipShape(Circle())
                
                Text(viewModel.teamName)
                    .font(.system(size: 15, weight: .bold))
//                    .minimumScaleFactor(0.8)
                    .frame(width: 110, height: 35, alignment: .leading)
                
                Text(viewModel.win)
                    .font(.system(size: 21))
                    .frame(width: 30, alignment: .leading)
                
                Text(viewModel.loss)
                    .font(.system(size: 21))
                    .frame(width: 30, alignment: .leading)
                
                Text(viewModel.winPct)
                    .font(.system(size: 14))
                    .frame(width: 40, alignment: .trailing)
                
                Text(viewModel.gamesBehind)
                    .font(.system(size: 14))
                    .frame(width: 30, alignment: .center)
                
//                    Spacer()
            }
            .padding(.horizontal, 15)
        }
//        .buttonStyle(PlainButtonStyle())
//    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

struct TitleView: View {
    var title: LocalizedStringKey
    var font: Font = .title
    var paddingTop: CGFloat = 20
    var paddingBottom: CGFloat = 0
    var paddingHorizontal: CGFloat = 15
    var body: some View {
        HStack {
            Text(title).font(font)
            Spacer()
        }
        .padding(.top, paddingTop)
        .padding(.horizontal, paddingHorizontal)
    }
}

struct StandingsView_Previews: PreviewProvider {
    static var previews: some View {
        StandingsView()
    }
}
