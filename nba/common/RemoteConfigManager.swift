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
    
    @Published var shouldUseOfficialTeamData: Bool = true
    
    // MARK: - Debug Settings
    // 개발 모드에서 서버 Fetch 없이 강제로 적용할 값 (true: use_official_team_data 사용 /false: use_official_team_data 사용안함)
    private let debugForceValue: Bool = true
    
    // MARK: - Config Key Logic
    // 앱 버전에 따라 키를 동적으로 생성 (예: use_official_team_data_102)
    private var configKey: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "100"
        let cleanVersion = version.replacingOccurrences(of: ".", with: "")
        return "use_official_team_data_\(cleanVersion)"
    }
    
    private init() {
        setupRemoteConfig()
    }
    
    private func setupRemoteConfig() {
        // [테스트 팁] 개발자 폰에서 RemoteConfig 서버 값을 테스트하려면
        // 아래 #if DEBUG 블록 전체를 주석 처리하세요.
        // #if DEBUG ~ #endif 까지 주석 처리하면 프로덕션 로직을 타게 됩니다.
        
        #if DEBUG
        // 개발 환경: Remote Config Fetch 생략하고 로컬 강제 값 사용
        print("[RemoteConfig] Debug Mode: Forcing \(configKey) = \(debugForceValue)")
        self.shouldUseOfficialTeamData = debugForceValue
        return // 👈 여기서 이미 설정 끝내고 함수 종료
        #endif
        
        // --- 아래는 프로덕션 (또는 서버 테스트) 로직 ---
        
        // 기본값 설정
        let defaultValues: [String: NSObject] = [
            configKey: false as NSObject
        ]
        remoteConfig.setDefaults(defaultValues)
        
        // Fetch 간격 설정
        let settings = RemoteConfigSettings()
        #if DEBUG
        settings.minimumFetchInterval = 0 // 개발 중 테스트 시엔 0초
        #else
        settings.minimumFetchInterval = 3600 // 배포 시엔 1시간
        #endif
        remoteConfig.configSettings = settings
        
        // 캐시된 초기값 로드
        self.shouldUseOfficialTeamData = remoteConfig.configValue(forKey: configKey).boolValue
    }
    
    /// Remote Config 값 가져오기
    func fetchConfig(completion: @escaping (Bool) -> Void) {
        // [테스트 팁] 서버 연결 테스트 시 아래 #if DEBUG 블록 주석 처리
        #if DEBUG
        // 개발 환경: 즉시 완료 처리
        completion(true)
        return
        #endif
        
        // --- 아래는 실제 서버 Fetch 로직 ---
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
                        let value = self.remoteConfig.configValue(forKey: self.configKey).boolValue
                        self.shouldUseOfficialTeamData = value
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
