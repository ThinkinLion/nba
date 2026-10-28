//
//  NBATeamCatalog.swift
//  nba
//
//  30개 구단 정적 목록 (팀 선택 UI 용). 식별자 변환은 String+ 확장을 그대로 사용.
//

import Foundation

struct NBATeamCatalogItem: Identifiable, Hashable {
    let triCode: String   // "HOU"
    let teamId: String    // "1610612745"
    let name: String      // "Houston"
    let conference: String // "East" / "West"
    
    var id: String { triCode }
    var nickname: String { teamId.teamIdToNickName }   // 색상 에셋 조회용 ("rockets")
    var darkColorName: String { teamId.dark }           // "rockets.dark"
}

enum NBATeamCatalog {
    /// 동부 → 서부 순, 각 컨퍼런스 내 도시명 알파벳 순
    static let all: [NBATeamCatalogItem] = {
        func items(_ codes: Set<String>, _ conf: String) -> [NBATeamCatalogItem] {
            codes.compactMap { tri -> NBATeamCatalogItem? in
                let normalized = NBAStaticConference.normalizeTriAlias(tri)
                let teamId = normalized.triCodeToTeamId
                guard !teamId.isEmpty else { return nil }
                return NBATeamCatalogItem(triCode: normalized, teamId: teamId, name: teamId.teamIdToName, conference: conf)
            }
            .reduce(into: [String: NBATeamCatalogItem]()) { $0[$1.triCode] = $1 } // 별칭 중복 제거 (CHO/CHA)
            .values
            .sorted { $0.name < $1.name }
        }
        return items(NBAStaticConference.easternTriCodes, "East") + items(NBAStaticConference.westernTriCodes, "West")
    }()
    
    static let east: [NBATeamCatalogItem] = all.filter { $0.conference == "East" }
    static let west: [NBATeamCatalogItem] = all.filter { $0.conference == "West" }
    
    static func item(triCode: String) -> NBATeamCatalogItem? {
        all.first { $0.triCode == NBAStaticConference.normalizeTriAlias(triCode.uppercased()) }
    }
}
