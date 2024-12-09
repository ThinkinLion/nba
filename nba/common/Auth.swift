//
//  Auth.swift
//  green
//
//  Created by 1100690 on 2021/11/22.
//

import UIKit

class Auth {
    static func isDeveloper() -> Bool {
        print("uuid: \(UUID())")
        let uuid = UUID()
        if "504E4735-9B0E-4C2A-BF5E-A0C3C17477FE" == uuid ||
            "00E3BBC9-58CE-425B-8E0E-D2B48278936A" == uuid ||
            "F527E50F-C470-4C48-B72A-FF632C1995BA" == uuid || //iPhone 15 Pro
            "8F655830-FAA0-4189-8B77-A52434955169" == uuid || //iPhone 15 Pro
            "CC857344-35A5-4C63-B5E5-03868B9797CF" == uuid || //iPhone 14 Pro max
            "8C8AE870-C801-43F6-9333-C679D7E6B47E" == uuid || //iPhone 16 Pro max
            Platform.isSimulator {
            return true
        } else {
            return false
        }
    }

    static func UUID() -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
}

struct Platform {
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}
