//
//  RemoteConfigManager.swift
//  nba
//
//  Created on 12/10/24.
//

import Foundation
import FirebaseRemoteConfig

final class RemoteConfigManager: ObservableObject {
    static let shared = RemoteConfigManager()
    
    private let remoteConfig = RemoteConfig.remoteConfig()
    
    @Published var shouldUseOfficialTeamData: Bool = false
    
    // Remote Config 키
    enum ConfigKey: String {
        case useOfficialTeamData = "use_official_team_data"
    }
    
    // 기본값 설정
    private var defaultValues: [String: NSObject] {
        [
            ConfigKey.useOfficialTeamData.rawValue: false as NSObject
        ]
    }
    
    private init() {
        setupRemoteConfig()
    }
    
    private func setupRemoteConfig() {
        // 기본값 설정
        remoteConfig.setDefaults(defaultValues)
        
        // Fetch 간격 설정 (초 단위)
        let settings = RemoteConfigSettings()
        #if DEBUG
        // 개발 환경: 더 짧은 간격
        settings.minimumFetchInterval = 0
        #else
        // 프로덕션: 1시간
        settings.minimumFetchInterval = 3600
        #endif
        remoteConfig.configSettings = settings
        
        // 초기값 로드
        self.shouldUseOfficialTeamData = remoteConfig.configValue(forKey: ConfigKey.useOfficialTeamData.rawValue).boolValue
    }
    
    /// Remote Config 값 가져오기
    func fetchConfig(completion: @escaping (Bool) -> Void) {
        remoteConfig.fetch { [weak self] status, error in
            guard let self = self else {
                completion(false)
                return
            }
            
            if status == .success {
                self.remoteConfig.activate { changed, error in
                    if let error = error {
                        print("Remote Config activate error: \(error.localizedDescription)")
                    }
                    
                    DispatchQueue.main.async {
                        self.shouldUseOfficialTeamData = self.remoteConfig.configValue(forKey: ConfigKey.useOfficialTeamData.rawValue).boolValue
                        completion(true)
                    }
                }
            } else {
                if let error = error {
                    print("Remote Config fetch error: \(error.localizedDescription)")
                }
                completion(false)
            }
        }
    }
    

}

