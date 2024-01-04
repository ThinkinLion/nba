//
//  BoxScoreViewModel.swift
//  nba
//
//  Created by 1100690 on 1/3/24.
//

import Foundation

struct BoxScoreViewModel {
    private let boxScore: BoxScore
    
    init(boxScore: BoxScore) {
        self.boxScore = boxScore
    }
    
    var playerId: String {
        boxScore.playerId ?? ""
    }
    
    var smallImageUrl: String {
        playerId.smallImageUrl
    }
    
    var teamId: String {
        boxScore.teamId ?? ""
    }
    
    var teamNickName: String {
        teamId.teamIdToNickName
    }
    
    var fullName: String {
        firstName + " " + lastName
    }
    
    var firstName: String {
        boxScore.firstName ?? ""
    }
    
    var lastName: String {
        boxScore.lastName ?? ""
    }
    
    var min: String {
        boxScore.min ?? ""
    }
    
    var minTitle: String {
        "MIN"
    }
    
    var pts: String {
        boxScore.pts ?? ""
    }
    
    var ptsTitle: String {
        "PTS"
    }
    
    //fg
    var fg: String {
        guard let fgm = boxScore.fgm else { return "" }
        guard let fga = boxScore.fga else { return "" }
        guard !fgm.isEmpty && !fga.isEmpty else { return "" }
        return fgm + "/" + fga
    }
    
    var fgp: String {
        boxScore.fgp ?? ""
    }
    
    var fgTitle: String {
        "FG"
    }
    
    var fgpTitle: String {
        "FG%"
    }
    
    //tp
    var tp: String {
        guard let tpm = boxScore.tpm else { return "" }
        guard let tpa = boxScore.tpa else { return "" }
        guard !tpm.isEmpty && !tpa.isEmpty else { return "" }
        return tpm + "/" + tpa
    }
    
    var tpp: String {
        boxScore.tpp ?? ""
    }
    
    var tpTitle: String {
        "3P"
    }
    
    var tppTitle: String {
        "3P%"
    }
    
    //ft
    var ft: String {
        guard let ftm = boxScore.ftm else { return "" }
        guard let fta = boxScore.fta else { return "" }
        guard !ftm.isEmpty && !fta.isEmpty else { return "" }
        return ftm + "/" + fta
    }
    
    var ftp: String {
        boxScore.ftp ?? ""
    }
    
    var ftTitle: String {
        "FT"
    }
    
    var ftpTitle: String {
        "FT%"
    }
    
    //reb
    var oreb: String {
        boxScore.oreb ?? ""
    }
    
    var dreb: String {
        boxScore.dreb ?? ""
    }
    
    var reb: String {
        boxScore.reb ?? ""
    }
    
    var orebTitle: String {
        "OREB"
    }
    
    var drebTitle: String {
        "DREB"
    }
    
    var rebTitle: String {
        "REB"
    }
    
    //ast
    var ast: String {
        boxScore.ast ?? ""
    }
    
    var stl: String {
        boxScore.stl ?? ""
    }
    
    var blk: String {
        boxScore.blk ?? ""
    }
    
    var astTitle: String {
        "AST"
    }
    
    var stlTitle: String {
        "STL"
    }
    
    var blkTitle: String {
        "BLK"
    }
    
    //to
    var to: String {
        boxScore.to ?? ""
    }
    
    var pf: String {
        boxScore.pf ?? ""
    }
    
    var pm: String {
        boxScore.pm ?? ""
    }
    
    var toTitle: String {
        "TO"
    }
    
    var pfTitle: String {
        "PF"
    }
    
    var pmTitle: String {
        "+/-"
    }
}
